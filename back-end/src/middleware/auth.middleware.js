import { verifyToken } from '../utils/jwt.utils.js';
import { errorResponse } from '../utils/response.utils.js';

const authMiddleware = (req, res, next) => {
  try {
    const authHeader = req.headers.authorization?.trim();
    if (!authHeader || !/^Bearer\s+/i.test(authHeader)) {
      return errorResponse(res, 'Token manquant', 401, 'TOKEN_MISSING');
    }

    const token = authHeader.replace(/^Bearer\s+/i, '').trim();
    if (!token) {
      return errorResponse(res, 'Token manquant', 401, 'TOKEN_MISSING');
    }

    const decoded = verifyToken(token);

    req.user = {
      id: decoded.userId,
      email: decoded.email,
      role: decoded.role
    };
    req.authToken = token;
    req.userId = decoded.userId;
    req.userRole = decoded.role;
    return next();
  } catch (error) {
    if (error.name === 'JsonWebTokenError') {
      return errorResponse(res, 'Token invalide', 401, 'TOKEN_INVALID');
    }
    if (error.name === 'TokenExpiredError') {
      return errorResponse(res, 'Token expire', 401, 'TOKEN_EXPIRED');
    }
    return errorResponse(res, 'Erreur lors de la verification du token', 500);
  }
};

const authorizeRoles = (...roles) => (req, res, next) => {
  if (!req.userRole) {
    return errorResponse(res, 'Utilisateur non authentifie', 401);
  }
  if (!roles.includes(req.userRole)) {
    return errorResponse(res, 'Acces refuse', 403, 'FORBIDDEN');
  }
  return next();
};

const adminMiddleware = authorizeRoles('ADMIN');

export {
  authMiddleware,
  authorizeRoles,
  adminMiddleware
};

export default {
  authMiddleware,
  authorizeRoles,
  adminMiddleware
};
