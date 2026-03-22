import { paginatedResponse, successResponse } from '../utils/response.utils.js';
import {
  validateRequest,
  adminSiteReviewSchema,
  adminReviewModerationSchema,
  userStatusUpdateSchema
} from '../utils/validators.js';
import {
  listPendingSites,
  getAdminSiteDetail,
  reviewSite,
  listPendingReviews,
  getAdminReviewDetail,
  moderateReview,
  listUsers,
  updateUserStatus,
  getAdminStats
} from '../services/admin.service.js';

const formatValidationError = (error) => ({
  success: false,
  message: 'Validation echouee',
  errors: error.details.map((detail) => detail.message)
});

export const getPendingSites = async (req, res) => {
  const result = await listPendingSites(req.query);
  return paginatedResponse(res, result.data, result.pagination);
};

export const reviewSiteHandler = async (req, res) => {
  const { error, value } = validateRequest(adminSiteReviewSchema, req.body);
  if (error) {
    return res.status(400).json(formatValidationError(error));
  }

  const result = await reviewSite(Number(req.params.id), req.userId, value);
  return successResponse(res, result, 'Decision de moderation appliquee');
};

export const getAdminSiteDetailHandler = async (req, res) => {
  const result = await getAdminSiteDetail(Number(req.params.id));
  return successResponse(res, result);
};

export const getPendingReviews = async (req, res) => {
  const result = await listPendingReviews(req.query);
  return paginatedResponse(res, result.data, result.pagination);
};

export const moderateReviewHandler = async (req, res) => {
  const { error, value } = validateRequest(adminReviewModerationSchema, req.body);
  if (error) {
    return res.status(400).json(formatValidationError(error));
  }

  const result = await moderateReview(Number(req.params.id), req.userId, value);
  return successResponse(res, result, 'Moderation appliquee');
};

export const getAdminReviewDetailHandler = async (req, res) => {
  const result = await getAdminReviewDetail(Number(req.params.id));
  return successResponse(res, result);
};

export const getUsers = async (req, res) => {
  const result = await listUsers(req.query);
  return paginatedResponse(res, result.data, result.pagination);
};

export const updateUserStatusHandler = async (req, res) => {
  const { error, value } = validateRequest(userStatusUpdateSchema, req.body);
  if (error) {
    return res.status(400).json(formatValidationError(error));
  }

  const result = await updateUserStatus(Number(req.params.id), value.status);
  return successResponse(res, result, 'Statut utilisateur mis a jour');
};

export const getAdminStatsHandler = async (_req, res) => {
  const result = await getAdminStats();
  return successResponse(res, result);
};
