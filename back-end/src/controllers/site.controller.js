import { paginatedResponse, successResponse } from '../utils/response.utils.js';
import { validateRequest, siteCreateSchema, siteUpdateSchema } from '../utils/validators.js';
import {
  listSites,
  listMySites,
  getSiteById,
  getMySiteById,
  createSite,
  updateSite,
  deleteSite,
  getSiteReviews,
  getSitePhotos
} from '../services/site.service.js';

const formatValidationError = (error) => ({
  success: false,
  message: 'Validation echouee',
  errors: error.details.map((detail) => detail.message)
});

export const getSites = async (req, res) => {
  const result = await listSites(req.query, req.user);
  return paginatedResponse(res, result.data, result.pagination);
};

export const getMySitesHandler = async (req, res) => {
  const result = await listMySites(req.user, req.query);
  return paginatedResponse(res, result.data, result.pagination);
};

export const getMySiteHandler = async (req, res) => {
  const result = await getMySiteById(Number(req.params.id), req.user);
  return successResponse(res, result);
};

export const getSite = async (req, res) => {
  const result = await getSiteById(Number(req.params.id), req.user);
  return successResponse(res, result);
};

export const createSiteHandler = async (req, res) => {
  const { error, value } = validateRequest(siteCreateSchema, req.body);
  if (error) {
    return res.status(400).json(formatValidationError(error));
  }

  const result = await createSite(value, req.user);
  return successResponse(res, result, 'Site cree avec succes', 201);
};

export const updateSiteHandler = async (req, res) => {
  const { error, value } = validateRequest(siteUpdateSchema, req.body);
  if (error) {
    return res.status(400).json(formatValidationError(error));
  }

  const result = await updateSite(Number(req.params.id), value, req.user);
  return successResponse(res, result, 'Site mis a jour avec succes');
};

export const deleteSiteHandler = async (req, res) => {
  const result = await deleteSite(Number(req.params.id), req.user);
  return successResponse(res, result, 'Site archive avec succes');
};

export const getSiteReviewsHandler = async (req, res) => {
  const result = await getSiteReviews(Number(req.params.id), req.query, req.user);
  return paginatedResponse(res, result.data, result.pagination);
};

export const getSitePhotosHandler = async (req, res) => {
  const result = await getSitePhotos(Number(req.params.id), req.query);
  return paginatedResponse(res, result.data, result.pagination);
};
