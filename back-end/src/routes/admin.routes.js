import express from 'express';
import { asyncHandler } from '../middleware/error.middleware.js';
import { authMiddleware, authorizeRoles } from '../middleware/auth.middleware.js';
import {
  getPendingSites,
  getAdminSiteDetailHandler,
  reviewSiteHandler,
  getPendingReviews,
  getAdminReviewDetailHandler,
  moderateReviewHandler,
  getUsers,
  updateUserStatusHandler,
  getAdminStatsHandler
} from '../controllers/admin.controller.js';

const router = express.Router();

router.use(authMiddleware, authorizeRoles('MODERATOR', 'ADMIN'));

router.get('/sites/pending', asyncHandler(getPendingSites));
router.get('/sites/:id', asyncHandler(getAdminSiteDetailHandler));
router.put('/sites/:id/review', asyncHandler(reviewSiteHandler));
router.get('/reviews/pending', asyncHandler(getPendingReviews));
router.get('/reviews/:id', asyncHandler(getAdminReviewDetailHandler));
router.put('/reviews/:id/moderate', asyncHandler(moderateReviewHandler));
router.get('/stats', asyncHandler(getAdminStatsHandler));
router.get('/users', asyncHandler(getUsers));
router.patch('/users/:id/status', authorizeRoles('ADMIN'), asyncHandler(updateUserStatusHandler));

export default router;
