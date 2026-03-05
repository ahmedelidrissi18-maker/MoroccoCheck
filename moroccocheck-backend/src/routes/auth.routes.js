/**
 * Authentication routes for user registration, login, and profile management
 * 
 * This module provides endpoints for user authentication including:
 * - User registration
 * - User login
 * - Profile retrieval (protected)
 * - Profile updates (protected)
 */

import express from 'express';
import { register, login, getProfile, updateProfile } from '../controllers/auth.controller.js';
import { authMiddleware } from '../middleware/auth.middleware.js';

const router = express.Router();

/**
 * @route   POST /api/auth/register
 * @desc    Register a new user
 * @access  Public
 */
router.post('/register', register);

/**
 * @route   POST /api/auth/login
 * @desc    Login user and return JWT token
 * @access  Public
 */
router.post('/login', login);

/**
 * @route   GET /api/auth/profile
 * @desc    Get user profile (protected route)
 * @access  Private
 */
router.get('/profile', authMiddleware, getProfile);

/**
 * @route   PUT /api/auth/profile
 * @desc    Update user profile (protected route)
 * @access  Private
 */
router.put('/profile', authMiddleware, updateProfile);

export default router;
