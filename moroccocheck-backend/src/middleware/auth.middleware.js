/**
 * Authentication middleware using JWT tokens
 * 
 * This module provides middleware functions for JWT-based authentication
 * and role-based authorization for the MoroccoCheck API.
 */

import jwt from 'jsonwebtoken';
import dotenv from 'dotenv';

dotenv.config();

/**
 * Authentication middleware to verify JWT tokens
 * 
 * Extracts JWT token from Authorization header, verifies it, and adds
 * user information to the request object for subsequent middleware/handlers.
 * 
 * @param {Object} req - Express request object
 * @param {Object} res - Express response object
 * @param {Function} next - Express next function
 * 
 * @example
 * // Usage in route: app.get('/protected', authMiddleware, (req, res) => { ... })
 */
const authMiddleware = (req, res, next) => {
  try {
    // Extract token from Authorization header
    const authHeader = req.headers.authorization;
    
    // Check if Authorization header exists and has Bearer format
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({
        success: false,
        message: 'Token manquant'
      });
    }
    
    // Extract token from "Bearer TOKEN" format
    const token = authHeader.substring(7);
    
    // Verify JWT token using secret from environment variables
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    
    // Add user information to request object
    req.userId = decoded.userId;
    req.userRole = decoded.role;
    
    // Continue to next middleware/handler
    next();
    
  } catch (error) {
    // Handle JWT verification errors
    if (error.name === 'JsonWebTokenError') {
      return res.status(401).json({
        success: false,
        message: 'Token invalide'
      });
    }
    
    if (error.name === 'TokenExpiredError') {
      return res.status(401).json({
        success: false,
        message: 'Token expiré'
      });
    }
    
    // Handle any other errors
    return res.status(500).json({
      success: false,
      message: 'Erreur lors de la vérification du token'
    });
  }
};

/**
 * Admin authorization middleware
 * 
 * Checks if the authenticated user has ADMIN role.
 * Must be used after authMiddleware to ensure req.userRole is available.
 * 
 * @param {Object} req - Express request object
 * @param {Object} res - Express response object
 * @param {Function} next - Express next function
 * 
 * @example
 * // Usage in route: app.get('/admin', authMiddleware, adminMiddleware, (req, res) => { ... })
 */
const adminMiddleware = (req, res, next) => {
  try {
    // Check if user is authenticated (should be done by authMiddleware first)
    if (!req.userRole) {
      return res.status(401).json({
        success: false,
        message: 'Utilisateur non authentifié'
      });
    }
    
    // Check if user has admin role
    if (req.userRole !== 'ADMIN') {
      return res.status(403).json({
        success: false,
        message: 'Accès refusé'
      });
    }
    
    // User is admin, continue to next middleware/handler
    next();
    
  } catch (error) {
    // Handle any unexpected errors
    return res.status(500).json({
      success: false,
      message: 'Erreur lors de la vérification des permissions'
    });
  }
};

export {
  authMiddleware,
  adminMiddleware
};

export default {
  authMiddleware,
  adminMiddleware
};
