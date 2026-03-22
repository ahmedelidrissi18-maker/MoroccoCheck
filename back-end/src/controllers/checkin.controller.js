import { paginatedResponse, successResponse } from '../utils/response.utils.js';
import { validateRequest, checkinSchema } from '../utils/validators.js';
import {
  createCheckin,
  listCheckins,
  getCheckinById
} from '../services/checkin.service.js';

const formatValidationError = (error) => ({
  success: false,
  message: 'Validation echouee',
  errors: error.details.map((detail) => detail.message)
});

export const createCheckinHandler = async (req, res) => {
  const { error, value } = validateRequest(checkinSchema, req.body);
  if (error) {
    return res.status(400).json(formatValidationError(error));
  }

  const result = await createCheckin(value, req.user, {
    ipAddress: req.ip
  });
  return successResponse(res, result, 'Check-in enregistre avec succes', 201);
};

export const getCheckins = async (req, res) => {
  const result = await listCheckins(req.query, req.user);
  return paginatedResponse(res, result.data, result.pagination);
};

export const getCheckin = async (req, res) => {
  const result = await getCheckinById(Number(req.params.id), req.user);
  return successResponse(res, result);
};
