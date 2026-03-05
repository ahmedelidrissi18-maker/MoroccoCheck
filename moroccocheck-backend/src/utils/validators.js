/**
 * Validation utilities using Joi for request validation
 * 
 * This module provides Joi schemas for validating various API requests
 * and a utility function to perform the validation.
 */

const Joi = require('joi');

// Schema for user registration
const registerSchema = Joi.object({
  email: Joi.string()
    .email()
    .required()
    .messages({
      'string.email': 'Veuillez fournir une adresse email valide',
      'any.required': 'L\'email est requis'
    }),
  password: Joi.string()
    .min(6)
    .required()
    .messages({
      'string.min': 'Le mot de passe doit contenir au moins 6 caractères',
      'any.required': 'Le mot de passe est requis'
    }),
  first_name: Joi.string()
    .min(2)
    .max(50)
    .required()
    .messages({
      'string.min': 'Le prénom doit contenir au moins 2 caractères',
      'string.max': 'Le prénom ne peut pas dépasser 50 caractères',
      'any.required': 'Le prénom est requis'
    }),
  last_name: Joi.string()
    .min(2)
    .max(50)
    .required()
    .messages({
      'string.min': 'Le nom doit contenir au moins 2 caractères',
      'string.max': 'Le nom ne peut pas dépasser 50 caractères',
      'any.required': 'Le nom est requis'
    })
});

// Schema for user login
const loginSchema = Joi.object({
  email: Joi.string()
    .email()
    .required()
    .messages({
      'string.email': 'Veuillez fournir une adresse email valide',
      'any.required': 'L\'email est requis'
    }),
  password: Joi.string()
    .required()
    .messages({
      'any.required': 'Le mot de passe est requis'
    })
});

// Schema for profile update
const updateProfileSchema = Joi.object({
  first_name: Joi.string()
    .min(2)
    .max(50)
    .optional()
    .messages({
      'string.min': 'Le prénom doit contenir au moins 2 caractères',
      'string.max': 'Le prénom ne peut pas dépasser 50 caractères'
    }),
  last_name: Joi.string()
    .min(2)
    .max(50)
    .optional()
    .messages({
      'string.min': 'Le nom doit contenir au moins 2 caractères',
      'string.max': 'Le nom ne peut pas dépasser 50 caractères'
    }),
  phone_number: Joi.string()
    .pattern(/^[0-9]{10}$/)
    .optional()
    .messages({
      'string.pattern.base': 'Le numéro de téléphone doit contenir exactement 10 chiffres'
    })
});

// Schema for site check-in
const checkinSchema = Joi.object({
  site_id: Joi.number()
    .integer()
    .positive()
    .required()
    .messages({
      'number.base': 'L\'ID du site doit être un nombre',
      'number.integer': 'L\'ID du site doit être un entier',
      'number.positive': 'L\'ID du site doit être positif',
      'any.required': 'L\'ID du site est requis'
    }),
  status: Joi.string()
    .valid('OPEN', 'CLOSED', 'UNDER_CONSTRUCTION')
    .required()
    .messages({
      'any.only': 'Le statut doit être OPEN, CLOSED ou UNDER_CONSTRUCTION',
      'any.required': 'Le statut est requis'
    }),
  comment: Joi.string()
    .max(500)
    .optional()
    .messages({
      'string.max': 'Le commentaire ne peut pas dépasser 500 caractères'
    }),
  latitude: Joi.number()
    .min(-90)
    .max(90)
    .required()
    .messages({
      'number.base': 'La latitude doit être un nombre',
      'number.min': 'La latitude doit être comprise entre -90 et 90',
      'number.max': 'La latitude doit être comprise entre -90 et 90',
      'any.required': 'La latitude est requise'
    }),
  longitude: Joi.number()
    .min(-180)
    .max(180)
    .required()
    .messages({
      'number.base': 'La longitude doit être un nombre',
      'number.min': 'La longitude doit être comprise entre -180 et 180',
      'number.max': 'La longitude doit être comprise entre -180 et 180',
      'any.required': 'La longitude est requise'
    })
});

// Schema for site review
const reviewSchema = Joi.object({
  site_id: Joi.number()
    .integer()
    .positive()
    .required()
    .messages({
      'number.base': 'L\'ID du site doit être un nombre',
      'number.integer': 'L\'ID du site doit être un entier',
      'number.positive': 'L\'ID du site doit être positif',
      'any.required': 'L\'ID du site est requis'
    }),
  rating: Joi.number()
    .integer()
    .min(1)
    .max(5)
    .required()
    .messages({
      'number.base': 'La note doit être un nombre',
      'number.integer': 'La note doit être un entier',
      'number.min': 'La note doit être comprise entre 1 et 5',
      'number.max': 'La note doit être comprise entre 1 et 5',
      'any.required': 'La note est requise'
    }),
  comment: Joi.string()
    .max(1000)
    .optional()
    .messages({
      'string.max': 'Le commentaire ne peut pas dépasser 1000 caractères'
    })
});

/**
 * Validate request data against a Joi schema
 * 
 * @param {Joi.Schema} schema - The Joi schema to validate against
 * @param {Object} data - The data to validate
 * @returns {Object} Object containing error and value properties
 * 
 * @example
 * const { error, value } = validateRequest(registerSchema, req.body);
 * if (error) {
 *   return res.status(400).json({ error: error.details[0].message });
 * }
 */
function validateRequest(schema, data) {
  const result = schema.validate(data, { abortEarly: false });
  
  return {
    error: result.error,
    value: result.value
  };
}

// Export all schemas and the validation function
module.exports = {
  registerSchema,
  loginSchema,
  updateProfileSchema,
  checkinSchema,
  reviewSchema,
  validateRequest
};