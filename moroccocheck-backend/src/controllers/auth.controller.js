/**
 * Authentication controller functions
 * 
 * This module contains the business logic for user authentication:
 * - User registration with password hashing
 * - User login with JWT token generation
 * - Profile retrieval
 * - Profile updates
 */

import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import Joi from 'joi';
import pool from '../config/database.js';

/**
 * Register a new user
 * 
 * @param {Object} req - Express request object
 * @param {Object} res - Express response object
 */
const register = async (req, res) => {
  try {
    // Validation schema
    const schema = Joi.object({
      name: Joi.string()
        .min(2)
        .max(100)
        .required()
        .messages({
          'string.min': 'Le nom doit contenir au moins 2 caractères',
          'string.max': 'Le nom ne doit pas dépasser 100 caractères',
          'any.required': 'Le nom est requis'
        }),
      email: Joi.string()
        .email()
        .required()
        .messages({
          'string.email': 'Veuillez fournir un email valide',
          'any.required': 'L\'email est requis'
        }),
      password: Joi.string()
        .min(6)
        .required()
        .messages({
          'string.min': 'Le mot de passe doit contenir au moins 6 caractères',
          'any.required': 'Le mot de passe est requis'
        })
    });

    // Validate request data
    const { error, value } = schema.validate(req.body);
    if (error) {
      return res.status(400).json({
        success: false,
        message: 'Validation échouée',
        errors: error.details.map(detail => detail.message)
      });
    }

    const { name, email, password } = value;

    // Check if email already exists
    const emailCheckQuery = 'SELECT COUNT(*) as count FROM users WHERE email = ?';
    const emailCheckResult = await pool.query(emailCheckQuery, [email]);
    
    if (emailCheckResult[0].count > 0) {
      return res.status(400).json({
        success: false,
        message: 'Email déjà utilisé'
      });
    }

    // Hash password
    const saltRounds = 10;
    const hashedPassword = await bcrypt.hash(password, saltRounds);

    // Insert user into database
    const insertQuery = `
      INSERT INTO users (name, email, password, role, points, level) 
      VALUES (?, ?, ?, 'tourist', 0, 'Bronze')
    `;
    const insertResult = await pool.query(insertQuery, [name, email, hashedPassword]);

    // Generate JWT token
    const payload = {
      userId: insertResult.insertId,
      email: email,
      role: 'tourist'
    };

    const token = jwt.sign(
      payload,
      process.env.JWT_SECRET,
      { expiresIn: '7d' }
    );

    // Return success response
    res.status(201).json({
      success: true,
      data: {
        token: token,
        user: {
          id: insertResult.insertId,
          name: name,
          email: email,
          role: 'tourist',
          points: 0,
          level: 'Bronze'
        }
      },
      message: 'Inscription réussie'
    });

  } catch (error) {
    console.error('Erreur lors de l\'inscription:', error);
    res.status(500).json({
      success: false,
      message: 'Erreur serveur',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
};

/**
 * Login user and return JWT token
 * 
 * @param {Object} req - Express request object
 * @param {Object} res - Express response object
 */
const login = async (req, res) => {
  try {
    // Validation schema
    const schema = Joi.object({
      email: Joi.string()
        .email()
        .required()
        .messages({
          'string.email': 'Veuillez fournir un email valide',
          'any.required': 'L\'email est requis'
        }),
      password: Joi.string()
        .required()
        .messages({
          'any.required': 'Le mot de passe est requis'
        })
    });

    // Validate request data
    const { error, value } = schema.validate(req.body);
    if (error) {
      return res.status(400).json({
        success: false,
        message: 'Validation échouée',
        errors: error.details.map(detail => detail.message)
      });
    }

    const { email, password } = value;

    // Find user by email
    const userQuery = 'SELECT * FROM users WHERE email = ?';
    const userResult = await pool.query(userQuery, [email]);
    
    if (userResult.length === 0) {
      return res.status(401).json({
        success: false,
        message: 'Email ou mot de passe incorrect'
      });
    }

    const user = userResult[0];

    // Verify password
    const isPasswordValid = await bcrypt.compare(password, user.password);
    if (!isPasswordValid) {
      return res.status(401).json({
        success: false,
        message: 'Email ou mot de passe incorrect'
      });
    }

    // Generate JWT token
    const payload = {
      userId: user.id,
      email: user.email,
      role: user.role
    };

    const token = jwt.sign(
      payload,
      process.env.JWT_SECRET,
      { expiresIn: '7d' }
    );

    // Remove password from user object before returning
    const userResponse = { ...user };
    delete userResponse.password;

    // Return success response
    res.status(200).json({
      success: true,
      data: {
        token: token,
        user: userResponse
      },
      message: 'Connexion réussie'
    });

  } catch (error) {
    console.error('Erreur lors de la connexion:', error);
    res.status(500).json({
      success: false,
      message: 'Erreur serveur',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
};

/**
 * Get user profile (protected route)
 * 
 * @param {Object} req - Express request object (with user from auth middleware)
 * @param {Object} res - Express response object
 */
const getProfile = async (req, res) => {
  try {
    const userId = req.userId;

    // Query to get complete user profile
    const profileQuery = `
      SELECT 
        id, name, email, role, points, level, avatar_url,
        created_at, updated_at
      FROM users 
      WHERE id = ?
    `;
    const profileResult = await pool.query(profileQuery, [userId]);
    
    if (profileResult.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Utilisateur non trouvé'
      });
    }

    const user = profileResult[0];

    // Return success response
    res.status(200).json({
      success: true,
      data: {
        user: user
      }
    });

  } catch (error) {
    console.error('Erreur lors de la récupération du profil:', error);
    res.status(500).json({
      success: false,
      message: 'Erreur serveur',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
};

/**
 * Update user profile (protected route)
 * 
 * @param {Object} req - Express request object (with user from auth middleware)
 * @param {Object} res - Express response object
 */
const updateProfile = async (req, res) => {
  try {
    const userId = req.userId;
    const { name, email, avatar_url } = req.body;

    // Validation schema (all fields optional)
    const schema = Joi.object({
      name: Joi.string()
        .min(2)
        .max(100)
        .optional()
        .messages({
          'string.min': 'Le nom doit contenir au moins 2 caractères',
          'string.max': 'Le nom ne doit pas dépasser 100 caractères'
        }),
      email: Joi.string()
        .email()
        .optional()
        .messages({
          'string.email': 'Veuillez fournir un email valide'
        }),
      avatar_url: Joi.string()
        .uri()
        .optional()
        .messages({
          'string.uri': 'Veuillez fournir une URL valide pour l\'avatar'
        })
    });

    // Validate request data
    const { error, value } = schema.validate(req.body);
    if (error) {
      return res.status(400).json({
        success: false,
        message: 'Validation échouée',
        errors: error.details.map(detail => detail.message)
      });
    }

    // Check if email already exists (if provided and different)
    if (email) {
      const emailCheckQuery = 'SELECT id FROM users WHERE email = ? AND id != ?';
      const emailCheckResult = await pool.query(emailCheckQuery, [email, userId]);
      
      if (emailCheckResult.length > 0) {
        return res.status(400).json({
          success: false,
          message: 'Email déjà utilisé'
        });
      }
    }

    // Build dynamic UPDATE query
    const updateFields = [];
    const updateValues = [];
    
    if (name !== undefined) {
      updateFields.push('name = ?');
      updateValues.push(name);
    }
    
    if (email !== undefined) {
      updateFields.push('email = ?');
      updateValues.push(email);
    }
    
    if (avatar_url !== undefined) {
      updateFields.push('avatar_url = ?');
      updateValues.push(avatar_url);
    }

    // Always update the updated_at timestamp
    updateFields.push('updated_at = NOW()');
    
    if (updateFields.length === 1) {
      return res.status(400).json({
        success: false,
        message: 'Aucun champ à mettre à jour fourni'
      });
    }

    // Execute UPDATE query
    const updateQuery = `
      UPDATE users 
      SET ${updateFields.join(', ')} 
      WHERE id = ?
    `;
    updateValues.push(userId);
    
    await pool.query(updateQuery, updateValues);

    // Get updated user profile
    const profileQuery = `
      SELECT 
        id, name, email, role, points, level, avatar_url
      FROM users 
      WHERE id = ?
    `;
    const profileResult = await pool.query(profileQuery, [userId]);
    
    if (profileResult.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Utilisateur non trouvé'
      });
    }

    const user = profileResult[0];

    // Return success response
    res.status(200).json({
      success: true,
      data: {
        user: user
      },
      message: 'Profil mis à jour avec succès'
    });

  } catch (error) {
    console.error('Erreur lors de la mise à jour du profil:', error);
    res.status(500).json({
      success: false,
      message: 'Erreur serveur',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
};

export {
  register,
  login,
  getProfile,
  updateProfile
};
