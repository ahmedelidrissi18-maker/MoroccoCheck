import pool from '../config/database.js';
import { GPS_VALIDATION, POINTS } from '../config/constants.js';
import {
  awardEligibleBadges,
  awardPoints,
  canContribute,
  computeDistanceFromSite,
  getFreshnessStatus,
  normalizeCheckinStatus,
  paginationMeta,
  parsePagination,
  syncUserStats,
  toAppError
} from './common.service.js';

export async function createCheckin(payload, currentUser, requestMeta = {}) {
  if (!canContribute(currentUser.role)) {
    throw toAppError('Le role utilisateur ne permet pas les check-ins', 403, 'ROLE_NOT_ALLOWED');
  }

  const connection = await pool.getConnection();
  try {
    await connection.beginTransaction();

    const [siteRows] = await connection.query(
      `SELECT id, name, latitude, longitude, status, is_active
       FROM tourist_sites
       WHERE id = ? AND deleted_at IS NULL`,
      [payload.site_id]
    );
    if (!siteRows.length) {
      throw toAppError('Site non trouve', 404);
    }

    const site = siteRows[0];
    if (!site.is_active || !['PUBLISHED', 'PENDING_REVIEW'].includes(site.status)) {
      throw toAppError('Le site ne peut pas recevoir de check-in', 400);
    }

    const [existingRows] = await connection.query(
      `SELECT id
       FROM checkins
       WHERE user_id = ?
         AND site_id = ?
         AND DATE(created_at) = CURDATE()
       LIMIT 1`,
      [currentUser.id, payload.site_id]
    );
    if (existingRows.length) {
      throw toAppError('Un check-in existe deja aujourd\'hui pour ce site', 409, 'CHECKIN_ALREADY_EXISTS');
    }

    const distance = computeDistanceFromSite(site, payload.latitude, payload.longitude);
    if (distance > GPS_VALIDATION.MAX_DISTANCE) {
      throw toAppError('Vous etes trop loin du site pour valider ce check-in', 400, 'CHECKIN_TOO_FAR', {
        distance,
        maxDistance: GPS_VALIDATION.MAX_DISTANCE
      });
    }

    const pointsEarned = payload.has_photo ? POINTS.CHECKIN_WITH_PHOTO : POINTS.CHECKIN;
    const normalizedStatus = normalizeCheckinStatus(payload.status);

    const [result] = await connection.query(
      `INSERT INTO checkins (
          user_id, site_id, status, comment, latitude, longitude, accuracy, distance,
          is_location_verified, has_photo, points_earned, validation_status, device_info, ip_address
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, TRUE, ?, ?, 'APPROVED', ?, ?)`,
      [
        currentUser.id,
        payload.site_id,
        normalizedStatus,
        payload.comment || null,
        payload.latitude,
        payload.longitude,
        payload.accuracy ?? 20,
        distance,
        Boolean(payload.has_photo),
        pointsEarned,
        payload.device_info ? JSON.stringify(payload.device_info) : null,
        requestMeta.ipAddress || null
      ]
    );

    const freshnessScore = payload.has_photo ? 100 : 95;
    await connection.query(
      `UPDATE tourist_sites
       SET freshness_score = ?, freshness_status = ?, last_verified_at = NOW(), last_updated_at = NOW(), updated_at = NOW()
       WHERE id = ?`,
      [freshnessScore, getFreshnessStatus(freshnessScore), payload.site_id]
    );

    await awardPoints(connection, currentUser.id, pointsEarned);
    await syncUserStats(connection, currentUser.id);
    const awardedBadges = await awardEligibleBadges(connection, currentUser.id);

    await connection.commit();

    const [rows] = await pool.query(
      `SELECT c.*, ts.name AS site_name
       FROM checkins c
       INNER JOIN tourist_sites ts ON ts.id = c.site_id
       WHERE c.id = ?`,
      [result.insertId]
    );

    return {
      checkin: rows[0],
      points_earned: pointsEarned,
      awarded_badges: awardedBadges
    };
  } catch (error) {
    await connection.rollback();
    throw error;
  } finally {
    connection.release();
  }
}

export async function listCheckins(query, currentUser) {
  const { page, limit, offset } = parsePagination(query);
  const filters = [];
  const params = [];

  if (query.user_id && ['MODERATOR', 'ADMIN'].includes(currentUser.role)) {
    filters.push('c.user_id = ?');
    params.push(Number(query.user_id));
  } else {
    filters.push('c.user_id = ?');
    params.push(currentUser.id);
  }

  if (query.site_id) {
    filters.push('c.site_id = ?');
    params.push(Number(query.site_id));
  }

  const whereClause = filters.length ? `WHERE ${filters.join(' AND ')}` : '';
  const [countRows] = await pool.query(
    `SELECT COUNT(*) AS total FROM checkins c ${whereClause}`,
    params
  );
  const [rows] = await pool.query(
    `SELECT
        c.*,
        ts.name AS site_name,
        ts.city,
        ts.region
     FROM checkins c
     INNER JOIN tourist_sites ts ON ts.id = c.site_id
     ${whereClause}
     ORDER BY c.created_at DESC
     LIMIT ? OFFSET ?`,
    [...params, limit, offset]
  );

  return {
    data: rows,
    pagination: paginationMeta(Number(countRows[0]?.total || 0), page, limit)
  };
}

export async function getCheckinById(checkinId, currentUser) {
  const [rows] = await pool.query(
    `SELECT
        c.*,
        ts.name AS site_name,
        ts.address,
        u.first_name,
        u.last_name
     FROM checkins c
     INNER JOIN tourist_sites ts ON ts.id = c.site_id
     INNER JOIN users u ON u.id = c.user_id
     WHERE c.id = ?`,
    [checkinId]
  );

  if (!rows.length) {
    throw toAppError('Check-in non trouve', 404);
  }

  const checkin = rows[0];
  if (checkin.user_id !== currentUser.id && !['MODERATOR', 'ADMIN'].includes(currentUser.role)) {
    throw toAppError('Acces refuse', 403, 'FORBIDDEN');
  }

  return checkin;
}
