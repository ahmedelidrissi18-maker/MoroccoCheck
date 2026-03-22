import { paginatedResponse, successResponse } from '../utils/response.utils.js';
import { validateRequest, updatePasswordSchema } from '../utils/validators.js';
import {
  listBadges,
  getUserBadges,
  getLeaderboard,
  getMe,
  updateMyPassword,
  getMyStats,
  getPublicUserProfile
} from '../services/user.service.js';

export const getBadges = async (_req, res) => {
  const result = await listBadges();
  return successResponse(res, result);
};

export const getMyBadges = async (req, res) => {
  const result = await getUserBadges(req.userId);
  return successResponse(res, result);
};

export const getLeaderboardHandler = async (req, res) => {
  const result = await getLeaderboard(req.query);
  return paginatedResponse(res, result.data, result.pagination);
};

export const getMeHandler = async (req, res) => {
  const result = await getMe(req.userId);
  return successResponse(res, result);
};

export const updateMyPasswordHandler = async (req, res) => {
  const { error, value } = validateRequest(updatePasswordSchema, req.body);
  if (error) {
    return res.status(400).json({
      success: false,
      message: 'Validation echouee',
      errors: error.details.map((detail) => detail.message)
    });
  }

  const result = await updateMyPassword(req.userId, value);
  return successResponse(res, result, 'Mot de passe mis a jour avec succes');
};

export const getMyStatsHandler = async (req, res) => {
  const result = await getMyStats(req.userId);
  return successResponse(res, result);
};

export const getPublicUserProfileHandler = async (req, res) => {
  const result = await getPublicUserProfile(Number(req.params.id));
  return successResponse(res, result);
};
