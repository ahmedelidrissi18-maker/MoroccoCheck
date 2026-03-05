/**
 * Health check routes for system monitoring and diagnostics
 * 
 * This module provides endpoints for checking the health status of the
 * MoroccoCheck API, database connectivity, and system information.
 */

import express from 'express';
import pool from '../config/database.js';

const router = express.Router();

/**
 * Simple health check endpoint
 * 
 * Returns basic status and timestamp for quick health verification
 * 
 * @route GET /api/health
 * @returns {Object} Health status response
 */
router.get('/', (req, res) => {
  res.json({
    status: 'OK',
    timestamp: new Date().toISOString(),
    service: 'moroccocheck-backend'
  });
});

/**
 * Database connectivity and statistics endpoint
 * 
 * Tests database connection and returns database information,
 * table list, and record counts for key tables.
 * 
 * @route GET /api/health/db
 * @returns {Object} Database status and statistics
 */
router.get('/db', async (req, res) => {
  try {
    // Test database connection with a simple query
    const connectionTest = await pool.query('SELECT 1 as test');
    
    if (!connectionTest) {
      throw new Error('Database connection test failed');
    }

    // Get list of tables in the database
    const tablesQuery = `
      SELECT table_name 
      FROM information_schema.tables 
      WHERE table_schema = 'moroccocheck' 
      AND table_type = 'BASE TABLE'
      ORDER BY table_name
    `;
    const tablesResult = await pool.query(tablesQuery);
    const tables = tablesResult.map(row => row.table_name);

    // Get record counts for key tables
    const statsQuery = `
      SELECT 
        (SELECT COUNT(*) FROM users) as users,
        (SELECT COUNT(*) FROM sites) as sites,
        (SELECT COUNT(*) FROM checkins) as checkins,
        (SELECT COUNT(*) FROM reviews) as reviews
    `;
    const statsResult = await pool.query(statsQuery);
    const stats = statsResult[0] || {};

    res.json({
      database: 'moroccocheck',
      connected: true,
      timestamp: new Date().toISOString(),
      tables: tables,
      stats: {
        users: parseInt(stats.users || 0),
        sites: parseInt(stats.sites || 0),
        checkins: parseInt(stats.checkins || 0),
        reviews: parseInt(stats.reviews || 0)
      }
    });

  } catch (error) {
    console.error('Database health check failed:', error);
    res.status(500).json({
      database: 'moroccocheck',
      connected: false,
      error: error.message,
      timestamp: new Date().toISOString()
    });
  }
});

/**
 * System information endpoint
 * 
 * Returns Node.js version, platform information, uptime,
 * and memory usage statistics.
 * 
 * @route GET /api/health/system
 * @returns {Object} System information and metrics
 */
router.get('/system', (req, res) => {
  const memoryUsage = process.memoryUsage();
  
  res.json({
    nodeVersion: process.version,
    platform: process.platform,
    arch: process.arch,
    uptime: process.uptime(),
    timestamp: new Date().toISOString(),
    memory: {
      rss: Math.round(memoryUsage.rss / 1024 / 1024) + ' MB', // Resident Set Size
      heapTotal: Math.round(memoryUsage.heapTotal / 1024 / 1024) + ' MB', // Total Heap Allocated
      heapUsed: Math.round(memoryUsage.heapUsed / 1024 / 1024) + ' MB', // Heap Actually Used
      external: Math.round(memoryUsage.external / 1024 / 1024) + ' MB' // External Memory Usage
    },
    environment: {
      nodeEnv: process.env.NODE_ENV || 'development',
      port: process.env.PORT || 'not set'
    }
  });
});

export default router;
