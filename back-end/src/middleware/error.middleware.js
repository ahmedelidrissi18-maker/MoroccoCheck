const notFoundHandler = (req, res) => {
  res.status(404).json({
    success: false,
    message: 'Route non trouvee',
    path: req.originalUrl,
    method: req.method,
    timestamp: new Date().toISOString()
  });
};

const errorHandler = (err, req, res, next) => {
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
    console.error(`Error: ${err.message} - ${req.method} ${req.originalUrl}`);
  }

  let statusCode = err.statusCode || err.status || 500;
  const payload = {
    success: false,
    message: err.message || 'Une erreur est survenue',
    timestamp: new Date().toISOString()
  };

  if (err.name === 'ValidationError') {
    statusCode = 400;
    payload.message = 'Donnees de validation invalides';
  } else if (err.name === 'JsonWebTokenError') {
    statusCode = 401;
    payload.message = 'Token d\'authentification invalide';
  } else if (err.name === 'TokenExpiredError') {
    statusCode = 401;
    payload.message = 'Token d\'authentification expire';
  }

  if (err.code) {
    payload.code = err.code;
  }
  if (err.details) {
    payload.details = err.details;
  }
  if (process.env.NODE_ENV === 'development') {
    payload.stack = err.stack;
  }

  if (res.headersSent) {
    return next(err);
  }

  return res.status(statusCode).json(payload);
};

const asyncHandler = (fn) => (req, res, next) => {
  Promise.resolve(fn(req, res, next)).catch(next);
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
