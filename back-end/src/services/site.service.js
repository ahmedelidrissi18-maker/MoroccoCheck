import pool from '../config/database.js';
import { SITE_STATUS } from '../config/constants.js';
import {
  canManageSites,
  canModerate,
  paginationMeta,
  parsePagination,
  toAppError
} from './common.service.js';

function distanceSelect(latitude, longitude) {
  if (latitude === undefined || longitude === undefined) {
    return '';
  }

  return `,
    (
      6371000 * ACOS(
        COS(RADIANS(?)) * COS(RADIANS(ts.latitude)) * COS(RADIANS(ts.longitude) - RADIANS(?)) +
        SIN(RADIANS(?)) * SIN(RADIANS(ts.latitude))
      )
    ) AS distance_meters`;
}

function distanceParams(latitude, longitude) {
  if (latitude === undefined || longitude === undefined) {
    return [];
  }
  return [Number(latitude), Number(longitude), Number(latitude)];
}

function includeChildCategoriesFilter(value) {
  if (value === undefined || value === null) {
    return true;
  }

  const normalized = String(value).trim().toLowerCase();
  return normalized !== 'false' && normalized !== '0' && normalized !== 'no';
}

export async function listSites(filters, currentUser = null) {
  const { page, limit, offset } = parsePagination(filters);
  const where = ['ts.deleted_at IS NULL', 'ts.is_active = TRUE'];
  const params = [];
  const latitude = filters.lat !== undefined ? Number(filters.lat) : undefined;
  const longitude = filters.lng !== undefined ? Number(filters.lng) : undefined;
  const includeChildren = includeChildCategoriesFilter(filters.include_children);

  if (!canModerate(currentUser?.role)) {
    where.push('ts.status = ?');
    params.push(SITE_STATUS.PUBLISHED);
  } else if (filters.status) {
    where.push('ts.status = ?');
    params.push(filters.status);
  }

  if (filters.category_id) {
    const categoryId = Number(filters.category_id);
    if (includeChildren) {
      where.push('(ts.category_id = ? OR c.parent_id = ?)');
      params.push(categoryId, categoryId);
    } else {
      where.push('ts.category_id = ?');
      params.push(categoryId);
    }
  }
  if (filters.subcategory_id) {
    where.push('ts.category_id = ?');
    params.push(Number(filters.subcategory_id));
  }
  if (filters.subcategory) {
    where.push(
      `LOWER(COALESCE(ts.subcategory, CASE WHEN c.parent_id IS NOT NULL THEN c.name ELSE NULL END, '')) LIKE ?`
    );
    params.push(`%${String(filters.subcategory).trim().toLowerCase()}%`);
  }
  if (filters.city) {
    where.push('ts.city = ?');
    params.push(filters.city);
  }
  if (filters.region) {
    where.push('ts.region = ?');
    params.push(filters.region);
  }
  if (filters.min_rating) {
    where.push('ts.average_rating >= ?');
    params.push(Number(filters.min_rating));
  }
  if (filters.q) {
    where.push('(ts.name LIKE ? OR ts.description LIKE ? OR ts.address LIKE ?)');
    const search = `%${filters.q}%`;
    params.push(search, search, search);
  }

  const selectDistance = distanceSelect(latitude, longitude);
  const selectDistanceParams = distanceParams(latitude, longitude);

  const baseQuery = `
    FROM tourist_sites ts
    INNER JOIN categories c ON c.id = ts.category_id
    LEFT JOIN categories parent_c ON parent_c.id = c.parent_id
    LEFT JOIN users owner ON owner.id = ts.owner_id
    WHERE ${where.join(' AND ')}
  `;

  const [countRows] = await pool.query(
    `SELECT COUNT(*) AS total ${baseQuery}`,
    params
  );

  const [rows] = await pool.query(
    `SELECT
        ts.id,
        ts.name,
        ts.name_ar,
        ts.description,
        ts.category_id,
        ts.subcategory,
        COALESCE(parent_c.id, c.id) AS top_level_category_id,
        c.parent_id AS category_parent_id,
        ts.latitude,
        ts.longitude,
        ts.address,
        ts.city,
        ts.region,
        ts.country,
        ts.average_rating,
        ts.total_reviews,
        ts.freshness_score,
        ts.freshness_status,
        ts.last_verified_at,
        ts.cover_photo,
        ts.status,
        ts.verification_status,
        ts.is_featured,
        ts.views_count,
        ts.favorites_count,
        COALESCE(parent_c.name, c.name) AS category_name,
        COALESCE(parent_c.name_ar, c.name_ar) AS category_name_ar,
        parent_c.name AS category_parent_name,
        CASE
          WHEN c.parent_id IS NOT NULL THEN c.name
          ELSE ts.subcategory
        END AS subcategory_name,
        owner.id AS owner_id,
        owner.first_name AS owner_first_name,
        owner.last_name AS owner_last_name
        ${selectDistance}
      ${baseQuery}
      ORDER BY ${selectDistance ? 'distance_meters ASC,' : ''} ts.is_featured DESC, ts.freshness_score DESC, ts.average_rating DESC
      LIMIT ? OFFSET ?`,
    [...selectDistanceParams, ...params, limit, offset]
  );

  return {
    data: rows,
    pagination: paginationMeta(Number(countRows[0]?.total || 0), page, limit)
  };
}

export async function listMySites(currentUser, filters = {}) {
  const { page, limit, offset } = parsePagination(filters);

  const where = ['ts.deleted_at IS NULL', 'ts.owner_id = ?'];
  const params = [currentUser.id];

  if (filters.status) {
    where.push('ts.status = ?');
    params.push(filters.status);
  }

  if (filters.city) {
    where.push('ts.city = ?');
    params.push(filters.city);
  }

  if (filters.q) {
    where.push('(ts.name LIKE ? OR ts.description LIKE ? OR ts.address LIKE ?)');
    const search = `%${filters.q}%`;
    params.push(search, search, search);
  }

  const baseQuery = `
    FROM tourist_sites ts
    INNER JOIN categories c ON c.id = ts.category_id
    LEFT JOIN users moderator ON moderator.id = ts.moderated_by
    WHERE ${where.join(' AND ')}
  `;

  const [countRows] = await pool.query(
    `SELECT COUNT(*) AS total ${baseQuery}`,
    params
  );

  const [rows] = await pool.query(
    `SELECT
        ts.id,
        ts.name,
        ts.description,
        ts.category_id,
        ts.latitude,
        ts.longitude,
        ts.address,
        ts.city,
        ts.region,
        ts.phone_number,
        ts.email,
        ts.website,
        ts.price_range,
        ts.accepts_card_payment,
        ts.has_wifi,
        ts.has_parking,
        ts.is_accessible,
        ts.average_rating,
        ts.freshness_score,
        ts.status,
        ts.verification_status,
        ts.moderation_notes,
        ts.moderated_by,
        ts.moderated_at,
        ts.owner_id,
        ts.cover_photo,
        c.name AS category_name,
        moderator.first_name AS moderator_first_name,
        moderator.last_name AS moderator_last_name
      ${baseQuery}
      ORDER BY ts.updated_at DESC, ts.created_at DESC
      LIMIT ? OFFSET ?`,
    [...params, limit, offset]
  );

  return {
    data: rows,
    pagination: paginationMeta(Number(countRows[0]?.total || 0), page, limit)
  };
}

async function loadSiteDetails(siteId, currentUser = null, options = {}) {
  const { incrementViews = true } = options;
  const [rows] = await pool.query(
    `SELECT
        ts.*,
        COALESCE(parent_c.name, c.name) AS category_name,
        COALESCE(parent_c.name_ar, c.name_ar) AS category_name_ar,
        COALESCE(parent_c.id, c.id) AS top_level_category_id,
        c.parent_id AS category_parent_id,
        parent_c.name AS category_parent_name,
        CASE
          WHEN c.parent_id IS NOT NULL THEN c.name
          ELSE ts.subcategory
        END AS subcategory_name,
        owner.first_name AS owner_first_name,
        owner.last_name AS owner_last_name,
        moderator.first_name AS moderator_first_name,
        moderator.last_name AS moderator_last_name
     FROM tourist_sites ts
     INNER JOIN categories c ON c.id = ts.category_id
     LEFT JOIN categories parent_c ON parent_c.id = c.parent_id
     LEFT JOIN users owner ON owner.id = ts.owner_id
     LEFT JOIN users moderator ON moderator.id = ts.moderated_by
     WHERE ts.id = ? AND ts.deleted_at IS NULL`,
    [siteId]
  );

  if (!rows.length) {
    throw toAppError('Site non trouve', 404);
  }

  const site = rows[0];
  if (
    !canModerate(currentUser?.role) &&
    site.status !== SITE_STATUS.PUBLISHED &&
    site.owner_id !== currentUser?.id
  ) {
    throw toAppError('Site non trouve', 404);
  }

  if (incrementViews) {
    await pool.query('UPDATE tourist_sites SET views_count = views_count + 1 WHERE id = ?', [siteId]);
  }

  const [openingHours] = await pool.query(
    `SELECT day_of_week, opens_at, closes_at, is_closed, is_24_hours, notes
     FROM opening_hours
     WHERE site_id = ?
     ORDER BY FIELD(day_of_week, 'MONDAY', 'TUESDAY', 'WEDNESDAY', 'THURSDAY', 'FRIDAY', 'SATURDAY', 'SUNDAY')`,
    [siteId]
  );

  const [recentReviews] = await pool.query(
    `SELECT
        r.id,
        r.overall_rating,
        r.title,
        r.content,
        r.created_at,
        u.first_name,
        u.last_name
     FROM reviews r
     INNER JOIN users u ON u.id = r.user_id
     WHERE r.site_id = ?
       AND r.deleted_at IS NULL
       AND r.status = 'PUBLISHED'
     ORDER BY r.created_at DESC
     LIMIT 5`,
    [siteId]
  );

  return {
    site,
    opening_hours: openingHours,
    recent_reviews: recentReviews
  };
}

export async function getSiteById(siteId, currentUser = null) {
  return loadSiteDetails(siteId, currentUser, { incrementViews: true });
}

export async function getMySiteById(siteId, currentUser) {
  const result = await loadSiteDetails(siteId, currentUser, { incrementViews: false });

  if (result.site.owner_id !== currentUser.id && !canModerate(currentUser.role)) {
    throw toAppError('Site non trouve', 404);
  }

  return result;
}

export async function createSite(payload, currentUser) {
  if (!canManageSites(currentUser.role)) {
    throw toAppError('Acces refuse', 403, 'FORBIDDEN');
  }

  const insertPayload = {
    ...payload,
    owner_id: currentUser.role === 'PROFESSIONAL' ? currentUser.id : payload.owner_id ?? null,
    status: currentUser.role === 'ADMIN' ? SITE_STATUS.PUBLISHED : SITE_STATUS.PENDING_REVIEW,
    verification_status: currentUser.role === 'ADMIN' ? 'VERIFIED' : 'PENDING'
  };

  const [result] = await pool.query(
    `INSERT INTO tourist_sites (
        name, name_ar, description, description_ar, category_id, subcategory,
        latitude, longitude, address, city, region, postal_code, country,
        phone_number, email, website, price_range, accepts_card_payment, has_wifi,
        has_parking, is_accessible, amenities, cover_photo, owner_id, status,
        verification_status, is_active, is_featured
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, TRUE, FALSE)`,
    [
      insertPayload.name,
      insertPayload.name_ar || null,
      insertPayload.description || null,
      insertPayload.description_ar || null,
      insertPayload.category_id,
      insertPayload.subcategory || null,
      insertPayload.latitude,
      insertPayload.longitude,
      insertPayload.address || null,
      insertPayload.city || null,
      insertPayload.region || null,
      insertPayload.postal_code || null,
      insertPayload.country || 'MA',
      insertPayload.phone_number || null,
      insertPayload.email || null,
      insertPayload.website || null,
      insertPayload.price_range || null,
      Boolean(insertPayload.accepts_card_payment),
      Boolean(insertPayload.has_wifi),
      Boolean(insertPayload.has_parking),
      Boolean(insertPayload.is_accessible),
      insertPayload.amenities ? JSON.stringify(insertPayload.amenities) : null,
      insertPayload.cover_photo || null,
      insertPayload.owner_id,
      insertPayload.status,
      insertPayload.verification_status
    ]
  );

  return getSiteById(result.insertId, currentUser);
}

export async function updateSite(siteId, payload, currentUser) {
  const [rows] = await pool.query(
    `SELECT id, owner_id, status FROM tourist_sites WHERE id = ? AND deleted_at IS NULL`,
    [siteId]
  );
  if (!rows.length) {
    throw toAppError('Site non trouve', 404);
  }

  const existingSite = rows[0];
  const isOwner = existingSite.owner_id === currentUser.id;
  if (!isOwner && !canModerate(currentUser.role)) {
    throw toAppError('Acces refuse', 403, 'FORBIDDEN');
  }

  const fields = [];
  const params = [];
  for (const [key, value] of Object.entries(payload)) {
    if (value === undefined) continue;
    fields.push(`${key} = ?`);
    if (key === 'amenities' && value !== null) {
      params.push(JSON.stringify(value));
    } else {
      params.push(value === '' ? null : value);
    }
  }

  if (!fields.length) {
    throw toAppError('Aucune mise a jour fournie', 400);
  }

  params.push(siteId);
  await pool.query(
    `UPDATE tourist_sites SET ${fields.join(', ')}, updated_at = NOW() WHERE id = ?`,
    params
  );

  return getSiteById(siteId, currentUser);
}

export async function deleteSite(siteId, currentUser) {
  const [rows] = await pool.query(
    `SELECT id, owner_id FROM tourist_sites WHERE id = ? AND deleted_at IS NULL`,
    [siteId]
  );
  if (!rows.length) {
    throw toAppError('Site non trouve', 404);
  }

  const site = rows[0];
  if (site.owner_id !== currentUser.id && !canModerate(currentUser.role)) {
    throw toAppError('Acces refuse', 403, 'FORBIDDEN');
  }

  await pool.query(
    `UPDATE tourist_sites
     SET status = ?, is_active = FALSE, deleted_at = NOW(), updated_at = NOW()
     WHERE id = ?`,
    [SITE_STATUS.ARCHIVED, siteId]
  );

  return { id: siteId, deleted: true };
}

export async function getSiteReviews(siteId, query, currentUser = null) {
  const { page, limit, offset } = parsePagination(query);
  const [siteRows] = await pool.query(
    `SELECT id, owner_id, status
     FROM tourist_sites
     WHERE id = ? AND deleted_at IS NULL`,
    [siteId]
  );

  if (!siteRows.length) {
    throw toAppError('Site non trouve', 404);
  }

  const site = siteRows[0];
  if (
    !canModerate(currentUser?.role) &&
    site.status !== SITE_STATUS.PUBLISHED &&
    site.owner_id !== currentUser?.id
  ) {
    throw toAppError('Site non trouve', 404);
  }

  const filters = ['r.site_id = ?', 'r.deleted_at IS NULL'];
  const params = [siteId];

  if (query.rating) {
    filters.push('r.overall_rating = ?');
    params.push(Number(query.rating));
  }

  if (!canModerate(currentUser?.role)) {
    filters.push(`r.status = 'PUBLISHED'`);
  } else if (query.status) {
    filters.push('r.status = ?');
    params.push(query.status);
  }

  const orderBy = {
    helpful: 'r.helpful_count DESC, r.created_at DESC',
    rating: 'r.overall_rating DESC, r.created_at DESC',
    recent: 'r.created_at DESC'
  };
  const sort = orderBy[query.sort] || orderBy.recent;
  const whereClause = `WHERE ${filters.join(' AND ')}`;

  const [countRows] = await pool.query(
    `SELECT COUNT(*) AS total
     FROM reviews r
     ${whereClause}`,
    params
  );
  const [rows] = await pool.query(
    `SELECT
        r.id,
        r.user_id,
        r.overall_rating,
        r.title,
        r.content,
        r.helpful_count,
        r.not_helpful_count,
        r.created_at,
        u.first_name,
        u.last_name,
        u.profile_picture
     FROM reviews r
     INNER JOIN users u ON u.id = r.user_id
     ${whereClause}
     ORDER BY ${sort}
     LIMIT ? OFFSET ?`,
    [...params, limit, offset]
  );

  return {
    data: rows,
    pagination: paginationMeta(Number(countRows[0]?.total || 0), page, limit)
  };
}

export async function getSitePhotos(siteId, query) {
  const { page, limit, offset } = parsePagination(query);
  const [siteRows] = await pool.query(
    `SELECT id
     FROM tourist_sites
     WHERE id = ? AND deleted_at IS NULL AND is_active = TRUE`,
    [siteId]
  );

  if (!siteRows.length) {
    throw toAppError('Site non trouve', 404);
  }

  const [countRows] = await pool.query(
    `SELECT COUNT(*) AS total
     FROM photos
     WHERE entity_type = 'SITE'
       AND entity_id = ?
       AND status = 'ACTIVE'
       AND moderation_status = 'APPROVED'`,
    [siteId]
  );
  const [rows] = await pool.query(
    `SELECT
        id,
        url,
        thumbnail_url,
        caption,
        alt_text,
        width,
        height,
        is_primary,
        likes_count,
        created_at
     FROM photos
     WHERE entity_type = 'SITE'
       AND entity_id = ?
       AND status = 'ACTIVE'
       AND moderation_status = 'APPROVED'
     ORDER BY is_primary DESC, display_order ASC, created_at DESC
     LIMIT ? OFFSET ?`,
    [siteId, limit, offset]
  );

  return {
    data: rows,
    pagination: paginationMeta(Number(countRows[0]?.total || 0), page, limit)
  };
}
