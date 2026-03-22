qimport { successResponse } from '../utils/response.utils.js';
import {
  validateRequest,
  registerSchema,
  loginSchema,
  updateProfileSchema,
  refreshTokenSchema
} from '../utils/validators.js';
import {
  registerUser,
  loginUser,
  getProfileById,
  updateProfileById,
  refreshSession,
  logoutSession
} from '../services/auth.service.js';

const formatValidationError = (error) => ({
  success: false,
  message: 'Validation echouee',
  errors: error.details.map((detail) => detail.message)
});

const register = async (req, res) => {
  const { error, value } = validateRequest(registerSchema, req.body);
  if (error) {
    return res.status(400).json(formatValidationError(error));
  }

  const result = await registerUser(value, {
    ipAddress: req.ip,
    userAgent: req.get('user-agent'),
    deviceInfo: req.body?.device_info
  });
  return successResponse(res, result, 'Inscription reussie', 201);
};

const login = async (req, res) => {
  const { error, value } = validateRequest(loginSchema, req.body);
  if (error) {
    return res.status(400).json(formatValidationError(error));
  }

  const result = await loginUser(value, {
    ipAddress: req.ip,
    userAgent: req.get('user-agent'),
    deviceInfo: value.device_info
  });
  return successResponse(res, result, 'Connexion reussie');
};

const getProfile = async (req, res) => {
  const result = await getProfileById(req.userId);
  return successResponse(res, result);
};

const updateProfile = async (req, res) => {
  const { error, value } = validateRequest(updateProfileSchema, req.body);
  if (error) {
    return res.status(400).json(formatValidationError(error));
  }

  const result = await updateProfileById(req.userId, value);
  return successResponse(res, result, 'Profil mis a jour avec succes');
};

const refresh = async (req, res) => {
  const { error, value } = validateRequest(refreshTokenSchema, req.body);
  if (error) {
    return res.status(400).json(formatValidationError(error));
  }

  const result = await refreshSession(value.refresh_token, {
    ipAddress: req.ip,
    userAgent: req.get('user-agent')
  });
  return successResponse(res, result);
};

const logout = async (req, res) => {
  await logoutSession(req.userId, req.authToken);
  return successResponse(res, { logged_out: true }, 'Deconnexion reussie');
};

export {
  register,
  login,
  getProfile,
  updateProfile,
  refresh,
  logout
};
