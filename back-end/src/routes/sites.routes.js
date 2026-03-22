import express from 'express';
import { asyncHandler } from '../middleware/error.middleware.js';
import { authMiddleware, authorizeRoles } from '../middleware/auth.middleware.js';
import {
  getSites,
  getMySitesHandler,
  getMySiteHandler,
  getSite,
  createSiteHandler,
  updateSiteHandler,
  deleteSiteHandler,
  getSiteReviewsHandler,
  getSitePhotosHandler
} from '../controllers/site.controller.js';

const router = express.Router();

router.get('/', asyncHandler(getSites));
router.get(
  '/mine',
  authMiddleware,
  authorizeRoles('PROFESSIONAL', 'MODERATOR', 'ADMIN'),
  asyncHandler(getMySitesHandler)
);
router.get(
  '/mine/:id',
  authMiddleware,
  authorizeRoles('PROFESSIONAL', 'MODERATOR', 'ADMIN'),
  asyncHandler(getMySiteHandler)
);
router.get('/:id/reviews', asyncHandler(getSiteReviewsHandler));
router.get('/:id/photos', asyncHandler(getSitePhotosHandler));
router.get('/:id', asyncHandler(getSite));
router.post(
  '/',
  authMiddleware,
  authorizeRoles('PROFESSIONAL', 'MODERATOR', 'ADMIN'),
  asyncHandler(createSiteHandler)
);
router.put('/:id', authMiddleware, asyncHandler(updateSiteHandler));
router.delete('/:id', authMiddleware, asyncHandler(deleteSiteHandler));

export default router;
