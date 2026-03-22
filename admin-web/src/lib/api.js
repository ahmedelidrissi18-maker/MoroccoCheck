const API_BASE_URL =
  import.meta.env.VITE_API_BASE_URL || 'http://127.0.0.1:5001/api';

const TOKEN_KEY = 'moroccocheck_admin_token';
const USER_KEY = 'moroccocheck_admin_user';

function readJson(response) {
  return response.json().catch(() => ({}));
}

async function request(path, options = {}) {
  const token = getStoredToken();
  const headers = {
    'Content-Type': 'application/json',
    Accept: 'application/json',
    ...(options.headers || {})
  };

  if (token) {
    headers.Authorization = `Bearer ${token}`;
  }

  const response = await fetch(`${API_BASE_URL}${path}`, {
    ...options,
    headers
  });

  const payload = await readJson(response);
  if (!response.ok) {
    const error = new Error(
      payload.message || `Erreur API (${response.status})`
    );
    error.status = response.status;
    error.payload = payload;
    throw error;
  }

  return payload;
}

export async function login(email, password) {
  const payload = await request('/auth/login', {
    method: 'POST',
    body: JSON.stringify({ email, password })
  });

  const data = payload.data || payload;
  const user = data.user || {};
  const token = data.access_token || data.token;

  if (!token) {
    throw new Error('Token manquant dans la reponse serveur');
  }

  persistSession({ token, user });
  return { token, user };
}

export async function logout() {
  try {
    await request('/auth/logout', { method: 'POST' });
  } catch (_error) {
  } finally {
    clearSession();
  }
}

export async function fetchAdminStats() {
  const payload = await request('/admin/stats');
  return payload.data || payload;
}

function normalizePagination(meta = {}) {
  return meta.pagination || meta || {};
}

export async function fetchPendingSites(query = {}) {
  const params = new URLSearchParams();
  Object.entries(query).forEach(([key, value]) => {
    if (value !== undefined && value !== null && `${value}`.trim() !== '') {
      params.set(key, value);
    }
  });

  const suffix = params.toString() ? `?${params.toString()}` : '';
  const payload = await request(`/admin/sites/pending${suffix}`);
  return {
    items: payload.data || [],
    meta: normalizePagination(payload.meta || {})
  };
}

export async function moderateSite(siteId, action, notes) {
  const payload = await request(`/admin/sites/${siteId}/review`, {
    method: 'PUT',
    body: JSON.stringify({ action, notes })
  });
  return payload.data || payload;
}

export async function fetchAdminSiteDetail(siteId) {
  const payload = await request(`/admin/sites/${siteId}`);
  return payload.data || payload;
}

export async function fetchPendingReviews(query = {}) {
  const params = new URLSearchParams();
  Object.entries(query).forEach(([key, value]) => {
    if (value !== undefined && value !== null && `${value}`.trim() !== '') {
      params.set(key, value);
    }
  });

  const suffix = params.toString() ? `?${params.toString()}` : '';
  const payload = await request(`/admin/reviews/pending${suffix}`);
  return {
    items: payload.data || [],
    meta: normalizePagination(payload.meta || {})
  };
}

export async function moderateReview(reviewId, action, notes) {
  const payload = await request(`/admin/reviews/${reviewId}/moderate`, {
    method: 'PUT',
    body: JSON.stringify({ action, notes })
  });
  return payload.data || payload;
}

export async function fetchAdminReviewDetail(reviewId) {
  const payload = await request(`/admin/reviews/${reviewId}`);
  return payload.data || payload;
}

export async function fetchUsers(query = {}) {
  const params = new URLSearchParams();
  Object.entries(query).forEach(([key, value]) => {
    if (value !== undefined && value !== null && `${value}`.trim() !== '') {
      params.set(key, value);
    }
  });

  const suffix = params.toString() ? `?${params.toString()}` : '';
  const payload = await request(`/admin/users${suffix}`);
  return {
    items: payload.data || [],
    meta: normalizePagination(payload.meta || {})
  };
}

export async function updateUserStatus(userId, status) {
  const payload = await request(`/admin/users/${userId}/status`, {
    method: 'PATCH',
    body: JSON.stringify({ status })
  });
  return payload.data || payload;
}

export function persistSession({ token, user }) {
  localStorage.setItem(TOKEN_KEY, token);
  localStorage.setItem(USER_KEY, JSON.stringify(user));
}

export function clearSession() {
  localStorage.removeItem(TOKEN_KEY);
  localStorage.removeItem(USER_KEY);
}

export function getStoredToken() {
  return localStorage.getItem(TOKEN_KEY);
}

export function getStoredUser() {
  const raw = localStorage.getItem(USER_KEY);
  if (!raw) return null;

  try {
    return JSON.parse(raw);
  } catch (_error) {
    return null;
  }
}

export function isAdminRole(role) {
  return role === 'ADMIN' || role === 'MODERATOR';
}

export { API_BASE_URL };
