import express from 'express';
import errorMiddleware from '../../src/middleware/error.middleware.js';

export function createTestApp(mountPath, router) {
  const app = express();
  app.use(express.json());
  app.use(mountPath, router);
  app.use(errorMiddleware.notFoundHandler);
  app.use(errorMiddleware.errorHandler);
  return app;
}

