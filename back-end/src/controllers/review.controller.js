import { paginatedResponse, successResponse } from '../utils/response.utils.js';
import { validateRequest, reviewSchema, reviewUpdateSchema } from '../utils/validators.js';
import {
  createReview,
  listReviews,
  getReviewById,
  updateReview,
  deleteReview
} from '../services/review.service.js';

const formatValidationError = (error) => ({
  success: false,
  message: 'Validation echouee',
  errors: error.details.map((detail) => detail.message)
});

export const createReviewHandler = async (req, res) => {
  const { error, value } = validateRequest(reviewSchema, req.body);
  if (error) {
    return res.status(400).json(formatValidationError(error));
  }

  const result = await createReview(value, req.user);
  return successResponse(res, result, 'Avis cree avec succes', 201);
};

export const getReviews = async (req, res) => {
  const result = await listReviews(req.query, req.user);
  return paginatedResponse(res, result.data, result.pagination);
};

export const getReview = async (req, res) => {
  const result = await getReviewById(Number(req.params.id), req.user);
  return successResponse(res, result);
};

export const updateReviewHandler = async (req, res) => {
  const { error, value } = validateRequest(reviewUpdateSchema, req.body);
  if (error) {
    return res.status(400).json(formatValidationError(error));
  }

  const result = await updateReview(Number(req.params.id), value, req.user);
  return successResponse(res, result, 'Avis mis a jour avec succes');
};

export const deleteReviewHandler = async (req, res) => {
  const result = await deleteReview(Number(req.params.id), req.user);
  return successResponse(res, result, 'Avis supprime avec succes');
};
