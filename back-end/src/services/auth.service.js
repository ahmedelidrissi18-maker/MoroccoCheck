import pool from '../config/database.js';
import { randomBytes, randomUUID } from 'crypto';
import { USER_RANKS, USER_ROLES, USER_STATUS } from '../config/constants.js';
import { decodeToken, generateToken } from '../utils/jwt.utils.js';
import { hashPassword, verifyPassword } from '../utils/password.utils.js';
import { awardEligibleBadges, syncUserStats, toAppError } from './common.service.js';

const REFRESH_TOKEN_TTL_DAYS = Number(process.env.REFRESH_TOKEN_TTL_DAYS || 30);

function normalizeDeviceType(deviceInfo = {}) {
  const rawType = String(
    deviceInfo.device_type ||
      deviceInfo.platform ||
      deviceInfo.type ||
      'WEB'
  ).toUpperCase();

  if (['IOS', 'ANDROID', 'WEB', 'OTHER'].includes(rawType)) {
    return rawType;
  }

  return 'OTHER';
}

function buildSessionPayload(accessToken, refreshToken) {
  const decoded = decodeToken(accessToken);
  return {
    access_token: accessToken,
    refresh_token: refreshToken,
    expires_in: decoded?.exp && decoded?.iat ? decoded.exp - decoded.iat : null,
    token: accessToken
  };
}

async function createSession(db, user, requestContext = {}) {
  const accessToken = generateToken(user);
  const refreshToken = randomBytes(32).toString('hex');
  const deviceInfo = requestContext.deviceInfo || {};

  await db.query(
    `INSERT INTO sessions (
        id, user_id, access_token, refresh_token, device_type, device_name, device_id,
        os_version, app_version, ip_address, user_agent, country, city, expires_at
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, DATE_ADD(NOW(), INTERVAL ? DAY))`,
    [
      randomUUID(),
      user.id,
      accessToken,
      refreshToken,
      normalizeDeviceType(deviceInfo),
      deviceInfo.device_name || null,
      deviceInfo.device_id || null,
      deviceInfo.os_version || null,
      deviceInfo.app_version || null,
      requestContext.ipAddress || '0.0.0.0',
      requestContext.userAgent || null,
      deviceInfo.country || null,
      deviceInfo.city || null,
      REFRESH_TOKEN_TTL_DAYS
    ]
  );

  return buildSessionPayload(accessToken, refreshToken);
}

export async function registerUser(payload, requestContext = {}) {
  const { first_name, last_name, email, password } = payload;

  const [emailRows] = await pool.query(
    'SELECT COUNT(*) AS count FROM users WHERE email = ?',
    [email]
  );
  if (Number(emailRows[0]?.count || 0) > 0) {
    throw toAppError('Email deja utilise', 400, 'EMAIL_ALREADY_USED');
  }

  const password_hash = await hashPassword(password);
  const [result] = await pool.query(
    `INSERT INTO users (
        first_name,
        last_name,
        email,
        password_hash,
        role,
        status,
        points,
        level,
        rank,
        is_email_verified
      ) VALUES (?, ?, ?, ?, ?, ?, 0, 1, ?, FALSE)`,
    [
      first_name,
      last_name,
      email,
      password_hash,
      USER_ROLES.TOURIST,
      USER_STATUS.ACTIVE,
      USER_RANKS.BRONZE
    ]
  );

  const userId = result.insertId;
  const [rows] = await pool.query(
    `SELECT id, first_name, last_name, email, role, status, points, level, rank, profile_picture,
            checkins_count, reviews_count, created_at, updated_at
     FROM users
     WHERE id = ?`,
    [userId]
  );

  const user = rows[0];
  const session = await createSession(pool, user, requestContext);

  return {
    ...session,
    user
  };
}

export async function loginUser(payload, requestContext = {}) {
  const { email, password } = payload;
  const [rows] = await pool.query('SELECT * FROM users WHERE email = ? AND deleted_at IS NULL', [email]);

  if (!rows.length) {
    throw toAppError('Email ou mot de passe incorrect', 401, 'INVALID_CREDENTIALS');
  }

  const user = rows[0];
  const isPasswordValid = await verifyPassword(password, user.password_hash);
  if (!isPasswordValid) {
    throw toAppError('Email ou mot de passe incorrect', 401, 'INVALID_CREDENTIALS');
  }

  if ([USER_STATUS.SUSPENDED, USER_STATUS.BANNED, USER_STATUS.INACTIVE].includes(user.status)) {
    throw toAppError('Compte indisponible', 403, 'ACCOUNT_DISABLED');
  }

  await pool.query(
    'UPDATE users SET last_login_at = NOW(), last_seen_at = NOW(), updated_at = NOW() WHERE id = ?',
    [user.id]
  );

  const [freshRows] = await pool.query(
    `SELECT id, first_name, last_name, email, role, status, points, level, rank, profile_picture,
            checkins_count, reviews_count, created_at, updated_at
     FROM users
     WHERE id = ?`,
    [user.id]
  );
  const freshUser = freshRows[0];
  const session = await createSession(pool, freshUser, requestContext);

  return {
    ...session,
    user: freshUser
  };
}

export async function getProfileById(userId) {
  const [rows] = await pool.query(
    `SELECT id, first_name, last_name, email, phone_number, nationality, bio, role, status, points,
            level, rank, profile_picture, checkins_count, reviews_count, created_at, updated_at
     FROM users
     WHERE id = ? AND deleted_at IS NULL`,
    [userId]
  );

  if (!rows.length) {
    throw toAppError('Utilisateur non trouve', 404);
  }

  const [badgeRows] = await pool.query(
    `SELECT b.id, b.name, b.icon, b.color, b.rarity, ub.earned_at
     FROM user_badges ub
     INNER JOIN badges b ON b.id = ub.badge_id
     WHERE ub.user_id = ?
     ORDER BY ub.earned_at DESC`,
    [userId]
  );

  return {
    user: rows[0],
    badges: badgeRows
  };
}

export async function updateProfileById(userId, payload) {
  const updateEntries = Object.entries(payload).filter(([, value]) => value !== undefined);
  if (!updateEntries.length) {
    throw toAppError('Aucun champ a mettre a jour fourni', 400);
  }

  if (payload.email) {
    const [emailRows] = await pool.query(
      'SELECT id FROM users WHERE email = ? AND id != ? AND deleted_at IS NULL',
      [payload.email, userId]
    );
    if (emailRows.length) {
      throw toAppError('Email deja utilise', 400, 'EMAIL_ALREADY_USED');
    }
  }

  const updates = [];
  const params = [];
  for (const [key, value] of updateEntries) {
    updates.push(`${key} = ?`);
    params.push(value === '' ? null : value);
  }

  params.push(userId);
  await pool.query(
    `UPDATE users SET ${updates.join(', ')}, updated_at = NOW() WHERE id = ? AND deleted_at IS NULL`,
    params
  );

  await syncUserStats(pool, userId);
  await awardEligibleBadges(pool, userId);

  return getProfileById(userId);
}

export async function refreshSession(refreshToken, requestContext = {}) {
  const [rows] = await pool.query(
    `SELECT
        s.id,
        s.user_id,
        s.is_active,
        s.expires_at,
        u.id AS user_id_ref,
        u.email,
        u.role,
        u.status
     FROM sessions s
     INNER JOIN users u ON u.id = s.user_id
     WHERE s.refresh_token = ?
       AND s.is_active = TRUE
       AND s.expires_at > NOW()
       AND u.deleted_at IS NULL
     LIMIT 1`,
    [refreshToken]
  );

  if (!rows.length) {
    throw toAppError('Refresh token invalide ou expire', 401, 'INVALID_REFRESH_TOKEN');
  }

  const session = rows[0];
  if ([USER_STATUS.SUSPENDED, USER_STATUS.BANNED, USER_STATUS.INACTIVE].includes(session.status)) {
    throw toAppError('Compte indisponible', 403, 'ACCOUNT_DISABLED');
  }

  const accessToken = generateToken({
    id: session.user_id_ref,
    email: session.email,
    role: session.role
  });
  const nextRefreshToken = randomBytes(32).toString('hex');

  await pool.query(
    `UPDATE sessions
     SET access_token = ?, refresh_token = ?, ip_address = ?, user_agent = ?,
         last_activity_at = NOW(), expires_at = DATE_ADD(NOW(), INTERVAL ? DAY), updated_at = NOW()
     WHERE id = ?`,
    [
      accessToken,
      nextRefreshToken,
      requestContext.ipAddress || '0.0.0.0',
      requestContext.userAgent || null,
      REFRESH_TOKEN_TTL_DAYS,
      session.id
    ]
  );

  return buildSessionPayload(accessToken, nextRefreshToken);
}

export async function logoutSession(userId, accessToken) {
  const [result] = await pool.query(
    `UPDATE sessions
     SET is_active = FALSE, updated_at = NOW()
     WHERE user_id = ? AND access_token = ? AND is_active = TRUE`,
    [userId, accessToken]
  );

  if (!result.affectedRows) {
    await pool.query(
      `UPDATE sessions
       SET is_active = FALSE, updated_at = NOW()
       WHERE user_id = ? AND is_active = TRUE`,
      [userId]
    );
  }

  return { logged_out: true };
}
