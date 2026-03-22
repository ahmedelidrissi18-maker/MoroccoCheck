import express from 'express';
import { asyncHandler } from '../middleware/error.middleware.js';
import { authMiddleware } from '../middleware/auth.middleware.js';
import {
  getBadges,
  getMyBadges,
  getLeaderboardHandler,
  getMeHandler,
  updateMyPasswordHandler,
  getMyStatsHandler,
  getPublicUserProfileHandler
} from '../controllers/user.controller.js';

const router = express.Router();

router.get('/badges', asyncHandler(getBadges));
router.get('/leaderboard', asyncHandler(getLeaderboardHandler));
router.get('/users/me', authMiddleware, asyncHandler(getMeHandler));
router.get('/users/me/badges', authMiddleware, asyncHandler(getMyBadges));
router.get('/users/me/stats', authMiddleware, asyncHandler(getMyStatsHandler));
router.put('/users/me/password', authMiddleware, asyncHandler(updateMyPasswordHandler));
router.get('/users/:id', asyncHandler(getPublicUserProfileHandler));

export default router;
