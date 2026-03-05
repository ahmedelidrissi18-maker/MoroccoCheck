/**
 * Error handling middleware for the MoroccoCheck API
 * 
 * This module provides centralized error handling including
 * 404 handlers, global error handlers, and async function wrappers
 * to simplify error management throughout the application.
 */

/**
 * 404 Not Found handler middleware
 * 
 * Handles requests to routes that don't exist
 * 
 * @param {Object} req - Express request object
 * @param {Object} res - Express response object
 * @param {Function} next - Express next function
 */
const notFoundHandler = (req, res, next) => {
  res.status(404).json({
    success: false,
    message: 'Route non trouvée',
    path: req.originalUrl,
    method: req.method
  });
};

/**
 * Global error handler middleware
 * 
 * Centralized error handling for all uncaught errors in the application
 * Provides detailed error information in development mode
 * 
 * @param {Error} err - Error object
 * @param {Object} req - Express request object
 * @param {Object} res - Express response object
 * @param {Function} next - Express next function
 */
const errorHandler = (err, req, res, next) => {
  // Log error details in development mode
  if (process.env.NODE_ENV === 'development') {
    console.error('Error details:', {
      message: err.message,
      stack: err.stack,
      path: req.originalUrl,
      method: req.method,
      ip: req.ip,
      timestamp: new Date().toISOString()
    });
  } else {
    // Log basic error info in production
    console.error(`Error: ${err.message} - ${req.method} ${req.originalUrl}`);
  }

  // Determine status code (use err.statusCode if available, default to 500)
  const statusCode = err.statusCode || err.status || 500;
  
  // Prepare error response
  const errorResponse = {
    success: false,
    message: err.message || 'Une erreur est survenue',
    timestamp: new Date().toISOString()
  };

  // Include stack trace in development mode for debugging
  if (process.env.NODE_ENV === 'development') {
    errorResponse.stack = err.stack;
  }

  // Handle specific error types with custom messages
  if (err.name === 'ValidationError') {
    statusCode = 400;
    errorResponse.message = 'Données de validation invalides';
    errorResponse.details = err.details;
  } else if (err.name === 'CastError') {
    statusCode = 400;
    errorResponse.message = 'Format d\'ID invalide';
  } else if (err.code === 11000) {
    statusCode = 409;
    errorResponse.message = 'Conflit de données - enregistrement déjà existant';
  } else if (err.name === 'JsonWebTokenError') {
    statusCode = 401;
    errorResponse.message = 'Token d\'authentification invalide';
  } else if (err.name === 'TokenExpiredError') {
    statusCode = 401;
    errorResponse.message = 'Token d\'authentification expiré';
  }

  res.status(statusCode).json(errorResponse);
};

/**
 * Async error handler wrapper
 * 
 * Wraps async route handlers to automatically catch and forward errors
 * to the global error handler, eliminating the need for try/catch blocks
 * 
 * @param {Function} fn - Async function to wrap
 * @returns {Function} Wrapped function that handles async errors
 * 
 * @example
 * // Instead of:
 * app.get('/api/users', async (req, res) => {
 *   try {
 *     const users = await User.find();
 *     res.json(users);
 *   } catch (error) {
 *     next(error);
 *   }
 * });
 * 
 * // Use:
 * app.get('/api/users', asyncHandler(async (req, res) => {
 *   const users = await User.find();
 *   res.json(users);
 * }));
 */
const asyncHandler = (fn) => {
  return (req, res, next) => {
    // Execute the async function and catch any errors
    Promise.resolve(fn(req, res, next)).catch(next);
  };
};

export {
  notFoundHandler,
  errorHandler,
  asyncHandler
};

export default {
  notFoundHandler,
  errorHandler,
  asyncHandler
};
