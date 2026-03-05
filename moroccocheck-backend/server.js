import express from 'express';
import cors from 'cors';
import morgan from 'morgan';
import helmet from 'helmet';
import dotenv from 'dotenv';
import pool from './src/config/database.js';
import healthRoutes from './src/routes/health.routes.js';
import authRoutes from './src/routes/auth.routes.js';
import errorMiddleware from './src/middleware/error.middleware.js';

// Configuration
dotenv.config();
const app = express();
const PORT = process.env.PORT || 5000;

// Middleware
app.use(helmet());
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(morgan('dev'));

// Routes de test

// Health check routes
app.use('/api/health', healthRoutes);

// Authentication routes
app.use('/api/auth', authRoutes);

// Error handling middleware (must be after all routes)
app.use(errorMiddleware.notFoundHandler);
app.use(errorMiddleware.errorHandler);

// Start server
app.listen(PORT, () => {
    const box = `
╔══════════════════════════════════════════════════════════════╗
║                    🚀 MOROCCOCHECK API                      ║
╠══════════════════════════════════════════════════════════════╣
║                                                              ║
║  📦 Port: ${PORT.toString().padEnd(48)} ║
║  🌍 Environment: ${process.env.NODE_ENV || 'development'}${' '.repeat(35 - (process.env.NODE_ENV || 'development').length)} ║
║  🔗 URL: http://localhost:${PORT}${' '.repeat(39 - PORT.toString().length)} ║
║                                                              ║
║  ✨ Ready to serve MoroccoCheck API requests!                ║
║                                                              ║
╚══════════════════════════════════════════════════════════════╝
`;
    
    console.log(box);
    console.log('Available endpoints:');
    console.log('  GET /api/health     - Health check');
    console.log('  GET /api/health/db  - Database connectivity and stats');
    console.log('  GET /api/health/system - System information');
    console.log('  GET /api/test-db    - Test database connection (legacy)');
    console.log('  GET /api/test-tables - List all tables (legacy)');
    console.log('  GET /api/db-stats   - Database statistics (legacy)');
    console.log('');
});