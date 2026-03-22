import pool from '../config/database.js';
import { POINTS } from '../config/constants.js';
import {
  awardEligibleBadges,
  awardPoints,
  canModerate,
  paginationMeta,
  parsePagination,
  syncSiteReviewAggregates,
  syncUserStats,
  toAppError
} from './common.service.js';

export async function createReview(payload, currentUser) {
  const connection = await pool.getConnection();
  try {
    await connection.beginTransaction();

    const [siteRows] = await connection.query(
      `SELECT id, status, is_active
       FROM tourist_sites
       WHERE id = ? AND deleted_at IS NULL`,
      [payload.site_id]
    );
    if (!siteRows.length) {
      throw toAppError('Site non trouve', 404);
    }
    if (!siteRows[0].is_active || siteRows[0].status !== 'PUBLISHED') {
      throw toAppError('Le site ne peut pas recevoir d\'avis', 400);
    }

    const [existingRows] = await connection.query(
      `SELECT id
       FROM reviews
       WHERE user_id = ? AND site_id = ? AND deleted_at IS NULL
       LIMIT 1`,
      [currentUser.id, payload.site_id]
    );
    if (existingRows.length) {
      throw toAppError('Un avis existe deja pour ce site', 409, 'REVIEW_ALREADY_EXISTS');
    }

    const shouldAutoApprove = canModerate(currentUser?.role);
    const reviewStatus = shouldAutoApprove ? 'PUBLISHED' : 'PENDING';
    const moderationStatus = shouldAutoApprove ? 'APPROVED' : 'PENDING';

    const [result] = await connection.query(
      `INSERT INTO reviews (
          user_id, site_id, overall_rating, service_rating, cleanliness_rating, value_rating,
          location_rating, title, content, visit_date, visit_type, recommendations,
          status, moderation_status, points_earned
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
      [
        currentUser.id,
        payload.site_id,
        payload.rating,
        payload.service_rating ?? null,
        payload.cleanliness_rating ?? null,
        payload.value_rating ?? null,
        payload.location_rating ?? null,
        payload.title || null,
        payload.content,
        payload.visit_date || null,
        payload.visit_type || null,
        payload.recommendations ? JSON.stringify(payload.recommendations) : null,
        reviewStatus,
        moderationStatus,
        POINTS.REVIEW
      ]
    );

    await awardPoints(connection, currentUser.id, POINTS.REVIEW);
    await syncUserStats(connection, currentUser.id);
    if (reviewStatus === 'PUBLISHED') {
      await syncSiteReviewAggregates(connection, payload.site_id);
    }
    const awardedBadges = await awardEligibleBadges(connection, currentUser.id);

    await connection.commit();

    const review = await getReviewById(result.insertId, currentUser);
    return {
      review,
      points_earned: POINTS.REVIEW,
      moderation_status: moderationStatus,
      awarded_badges: awardedBadges
    };
  } catch (error) {
    await connection.rollback();
    throw error;
  } finally {
    connection.release();
  }
}

export async function listReviews(query, currentUser = null) {
  const { page, limit, offset } = parsePagination(query);
  const filters = ['r.deleted_at IS NULL'];
  const params = [];
  const isOwnReviewsQuery =
    currentUser?.id &&
    query.user_id &&
    Number(query.user_id) === Number(currentUser.id);

  if (!canModerate(currentUser?.role) && !isOwnReviewsQuery) {
    filters.push(`r.status = 'PUBLISHED'`);
  } else if (query.status) {
    filters.push('r.status = ?');
    params.push(query.status);
  }

  if (query.site_id) {
    filters.push('r.site_id = ?');
    params.push(Number(query.site_id));
  }
  if (query.user_id) {
    filters.push('r.user_id = ?');
    params.push(Number(query.user_id));
  }

  const whereClause = `WHERE ${filters.join(' AND ')}`;
  const [countRows] = await pool.query(
    `SELECT COUNT(*) AS total FROM reviews r ${whereClause}`,
    params
  );
  const [rows] = await pool.query(
    `SELECT
        r.id,
        r.site_id,
        r.user_id,
        r.overall_rating,
        r.title,
        r.content,
        r.status,
        r.moderation_status,
        r.helpful_count,
        r.created_at,
        ts.name AS site_name,
        u.first_name,
        u.last_name
     FROM reviews r
     INNER JOIN tourist_sites ts ON ts.id = r.site_id
     INNER JOIN users u ON u.id = r.user_id
     ${whereClause}
     ORDER BY r.created_at DESC
     LIMIT ? OFFSET ?`,
    [...params, limit, offset]
  );

  return {
    data: rows,
    pagination: paginationMeta(Number(countRows[0]?.total || 0), page, limit)
  };
}

export async function getReviewById(reviewId, currentUser = null) {
  const [rows] = await pool.query(
    `SELECT
        r.*,
        ts.name AS site_name,
        u.first_name,
        u.last_name
     FROM reviews r
     INNER JOIN tourist_sites ts ON ts.id = r.site_id
     INNER JOIN users u ON u.id = r.user_id
     WHERE r.id = ? AND r.deleted_at IS NULL`,
    [reviewId]
  );

  if (!rows.length) {
    throw toAppError('Avis non trouve', 404);
  }

  const review = rows[0];
  if (!canModerate(currentUser?.role) && review.status !== 'PUBLISHED' && review.user_id !== currentUser?.id) {
    throw toAppError('Avis non trouve', 404);
  }

  return review;
}

export async function updateReview(reviewId, payload, currentUser) {
  const review = await getReviewById(reviewId, currentUser);
  if (review.user_id !== currentUser.id && !canModerate(currentUser.role)) {
    throw toAppError('Acces refuse', 403, 'FORBIDDEN');
  }

  const fields = [];
  const params = [];
  const fieldMap = {
    rating: 'overall_rating',
    service_rating: 'service_rating',
    cleanliness_rating: 'cleanliness_rating',
    value_rating: 'value_rating',
    location_rating: 'location_rating',
    title: 'title',
    content: 'content',
    visit_date: 'visit_date',
    visit_type: 'visit_type',
    recommendations: 'recommendations'
  };

  for (const [key, value] of Object.entries(payload)) {
    if (value === undefined) continue;
    const column = fieldMap[key];
    if (!column) continue;
    fields.push(`${column} = ?`);
    if (key === 'recommendations' && value !== null) {
      params.push(JSON.stringify(value));
    } else {
      params.push(value === '' ? null : value);
    }
  }

  if (!fields.length) {
    throw toAppError('Aucune mise a jour fournie', 400);
  }

  params.push(reviewId);
  await pool.query(
    `UPDATE reviews SET ${fields.join(', ')}, updated_at = NOW() WHERE id = ?`,
    params
  );
  await syncSiteReviewAggregates(pool, review.site_id);

  return getReviewById(reviewId, currentUser);
}

export async function deleteReview(reviewId, currentUser) {
  const review = await getReviewById(reviewId, currentUser);
  if (review.user_id !== currentUser.id && !canModerate(currentUser.role)) {
    throw toAppError('Acces refuse', 403, 'FORBIDDEN');
  }

  await pool.query(
    `UPDATE reviews
     SET status = 'DELETED', deleted_at = NOW(), updated_at = NOW()
     WHERE id = ?`,
    [reviewId]
  );
  await syncUserStats(pool, review.user_id);
  await syncSiteReviewAggregates(pool, review.site_id);

  return { id: reviewId, deleted: true };
}
