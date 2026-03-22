import pool from '../config/database.js';
import { paginationMeta, parsePagination, syncSiteReviewAggregates, toAppError } from './common.service.js';

export async function listPendingSites(query) {
  const { page, limit, offset } = parsePagination(query);
  const [countRows] = await pool.query(
    `SELECT COUNT(*) AS total
     FROM tourist_sites
     WHERE deleted_at IS NULL AND verification_status = 'PENDING'`
  );
  const [rows] = await pool.query(
    `SELECT
        ts.id,
        ts.name,
        ts.city,
        ts.region,
        ts.status,
        ts.verification_status,
        ts.created_at,
        u.first_name AS owner_first_name,
        u.last_name AS owner_last_name
     FROM tourist_sites ts
     LEFT JOIN users u ON u.id = ts.owner_id
     WHERE ts.deleted_at IS NULL AND ts.verification_status = 'PENDING'
     ORDER BY ts.created_at ASC
     LIMIT ? OFFSET ?`,
    [limit, offset]
  );

  return {
    data: rows,
    pagination: paginationMeta(Number(countRows[0]?.total || 0), page, limit)
  };
}

export async function reviewSite(siteId, adminUserId, payload) {
  const [rows] = await pool.query(
    `SELECT id FROM tourist_sites WHERE id = ? AND deleted_at IS NULL`,
    [siteId]
  );
  if (!rows.length) {
    throw toAppError('Site non trouve', 404);
  }

  const states = {
    APPROVE: { verification_status: 'VERIFIED', status: 'PUBLISHED' },
    REJECT: { verification_status: 'REJECTED', status: 'ARCHIVED' },
    ARCHIVE: { verification_status: 'VERIFIED', status: 'ARCHIVED' }
  };
  const nextState = states[payload.action];
  const notes = payload.notes?.trim() || null;

  await pool.query(
    `UPDATE tourist_sites
     SET verification_status = ?, status = ?, moderation_notes = ?, moderated_by = ?, moderated_at = NOW(), updated_at = NOW()
     WHERE id = ?`,
    [nextState.verification_status, nextState.status, notes, adminUserId, siteId]
  );

  return {
    id: Number(siteId),
    reviewed_by: adminUserId,
    ...nextState,
    notes
  };
}

export async function getAdminSiteDetail(siteId) {
  const [rows] = await pool.query(
    `SELECT
        ts.id,
        ts.name,
        ts.description,
        ts.address,
        ts.city,
        ts.region,
        ts.country,
        ts.latitude,
        ts.longitude,
        ts.phone_number,
        ts.email,
        ts.website,
        ts.status,
        ts.verification_status,
        ts.created_at,
        ts.updated_at,
        ts.last_verified_at,
        ts.average_rating,
        ts.total_reviews,
        ts.freshness_score,
        ts.freshness_status,
        ts.moderation_notes,
        ts.moderated_at,
        c.name AS category_name,
        owner.id AS owner_id,
        owner.email AS owner_email,
        owner.first_name AS owner_first_name,
        owner.last_name AS owner_last_name,
        moderator.id AS moderator_id,
        moderator.first_name AS moderator_first_name,
        moderator.last_name AS moderator_last_name
     FROM tourist_sites ts
     LEFT JOIN categories c ON c.id = ts.category_id
     LEFT JOIN users owner ON owner.id = ts.owner_id
     LEFT JOIN users moderator ON moderator.id = ts.moderated_by
     WHERE ts.id = ? AND ts.deleted_at IS NULL
     LIMIT 1`,
    [siteId]
  );

  if (!rows.length) {
    throw toAppError('Site non trouve', 404);
  }

  return rows[0];
}

export async function listPendingReviews(query) {
  const { page, limit, offset } = parsePagination(query);
  const [countRows] = await pool.query(
    `SELECT COUNT(*) AS total
     FROM reviews
     WHERE deleted_at IS NULL AND moderation_status = 'PENDING'`
  );
  const [rows] = await pool.query(
    `SELECT
        r.id,
        r.site_id,
        r.user_id,
        r.overall_rating,
        r.title,
        r.created_at,
        ts.name AS site_name,
        u.first_name,
        u.last_name
     FROM reviews r
     INNER JOIN tourist_sites ts ON ts.id = r.site_id
     INNER JOIN users u ON u.id = r.user_id
     WHERE r.deleted_at IS NULL AND r.moderation_status = 'PENDING'
     ORDER BY r.created_at ASC
     LIMIT ? OFFSET ?`,
    [limit, offset]
  );

  return {
    data: rows,
    pagination: paginationMeta(Number(countRows[0]?.total || 0), page, limit)
  };
}

export async function moderateReview(reviewId, adminUserId, payload) {
  const [rows] = await pool.query(
    `SELECT id, site_id FROM reviews WHERE id = ? AND deleted_at IS NULL`,
    [reviewId]
  );
  if (!rows.length) {
    throw toAppError('Avis non trouve', 404);
  }

  const states = {
    APPROVE: { moderation_status: 'APPROVED', status: 'PUBLISHED' },
    REJECT: { moderation_status: 'REJECTED', status: 'HIDDEN' },
    FLAG: { moderation_status: 'FLAGGED', status: 'HIDDEN' },
    SPAM: { moderation_status: 'SPAM', status: 'HIDDEN' }
  };
  const nextState = states[payload.action];

  await pool.query(
    `UPDATE reviews
     SET moderation_status = ?, status = ?, moderated_by = ?, moderated_at = NOW(), moderation_notes = ?, updated_at = NOW()
     WHERE id = ?`,
    [nextState.moderation_status, nextState.status, adminUserId, payload.notes || null, reviewId]
  );
  await syncSiteReviewAggregates(pool, rows[0].site_id);

  return {
    id: Number(reviewId),
    moderated_by: adminUserId,
    ...nextState,
    notes: payload.notes || null
  };
}

export async function getAdminReviewDetail(reviewId) {
  const [rows] = await pool.query(
    `SELECT
        r.id,
        r.site_id,
        r.user_id,
        r.overall_rating,
        r.service_rating,
        r.cleanliness_rating,
        r.value_rating,
        r.location_rating,
        r.title,
        r.content,
        r.visit_date,
        r.visit_type,
        r.status,
        r.moderation_status,
        r.moderation_notes,
        r.moderated_at,
        r.created_at,
        r.updated_at,
        r.helpful_count,
        r.not_helpful_count,
        r.reports_count,
        ts.name AS site_name,
        ts.city AS site_city,
        ts.region AS site_region,
        author.email AS author_email,
        author.first_name AS author_first_name,
        author.last_name AS author_last_name,
        moderator.id AS moderator_id,
        moderator.first_name AS moderator_first_name,
        moderator.last_name AS moderator_last_name
     FROM reviews r
     INNER JOIN tourist_sites ts ON ts.id = r.site_id
     INNER JOIN users author ON author.id = r.user_id
     LEFT JOIN users moderator ON moderator.id = r.moderated_by
     WHERE r.id = ? AND r.deleted_at IS NULL
     LIMIT 1`,
    [reviewId]
  );

  if (!rows.length) {
    throw toAppError('Avis non trouve', 404);
  }

  return rows[0];
}

export async function listUsers(query) {
  const { page, limit, offset } = parsePagination(query);
  const filters = ['deleted_at IS NULL'];
  const params = [];

  if (query.role) {
    filters.push('role = ?');
    params.push(query.role);
  }
  if (query.status) {
    filters.push('status = ?');
    params.push(query.status);
  }
  if (query.q) {
    filters.push('(email LIKE ? OR first_name LIKE ? OR last_name LIKE ?)');
    const search = `%${query.q}%`;
    params.push(search, search, search);
  }

  const whereClause = `WHERE ${filters.join(' AND ')}`;
  const [countRows] = await pool.query(
    `SELECT COUNT(*) AS total FROM users ${whereClause}`,
    params
  );
  const [rows] = await pool.query(
    `SELECT
        id,
        email,
        first_name,
        last_name,
        role,
        status,
        points,
        level,
        rank,
        created_at,
        last_login_at
     FROM users
     ${whereClause}
     ORDER BY created_at DESC
     LIMIT ? OFFSET ?`,
    [...params, limit, offset]
  );

  return {
    data: rows,
    pagination: paginationMeta(Number(countRows[0]?.total || 0), page, limit)
  };
}

export async function updateUserStatus(userId, status) {
  const [rows] = await pool.query(
    `SELECT id FROM users WHERE id = ? AND deleted_at IS NULL`,
    [userId]
  );
  if (!rows.length) {
    throw toAppError('Utilisateur non trouve', 404);
  }

  await pool.query(
    `UPDATE users SET status = ?, updated_at = NOW() WHERE id = ?`,
    [status, userId]
  );

  const [updatedRows] = await pool.query(
    `SELECT id, email, first_name, last_name, role, status, points, level, rank
     FROM users
     WHERE id = ?`,
    [userId]
  );

  return updatedRows[0];
}

export async function getAdminStats() {
  const [rows] = await pool.query(
    `SELECT
        (SELECT COUNT(*) FROM users WHERE deleted_at IS NULL) AS users,
        (SELECT COUNT(*) FROM tourist_sites WHERE deleted_at IS NULL) AS sites,
        (SELECT COUNT(*) FROM checkins) AS checkins,
        (SELECT COUNT(*) FROM reviews WHERE deleted_at IS NULL) AS reviews,
        (SELECT COUNT(*) FROM tourist_sites WHERE deleted_at IS NULL AND verification_status = 'PENDING') AS pending_sites,
        (SELECT COUNT(*) FROM reviews WHERE deleted_at IS NULL AND moderation_status = 'PENDING') AS pending_reviews,
        (SELECT COUNT(*) FROM users WHERE deleted_at IS NULL AND status = 'SUSPENDED') AS suspended_users`
  );

  return rows[0];
}
