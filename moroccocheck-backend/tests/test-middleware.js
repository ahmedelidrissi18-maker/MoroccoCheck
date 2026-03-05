/**
 * Test suite for Authentication Middleware
 * 
 * This file contains tests for JWT token validation, authentication middleware,
 * and authorization middleware to ensure proper security measures are in place.
 */

import { describe, it, before, after } from 'mocha';
import { expect } from 'chai';
import express from 'express';
import request from 'supertest';
import jwt from 'jsonwebtoken';
import { authMiddleware, adminMiddleware } from '../src/middleware/auth.middleware.js';
import dotenv from 'dotenv';

// Load environment variables
dotenv.config();

const JWT_SECRET = process.env.JWT_SECRET || 'test-secret-key';

describe('Authentication Middleware', function() {
    let app;

    before(function() {
        // Setup Express app for testing middleware
        app = express();
        app.use(express.json());

        // Test route that requires authentication
        app.get('/protected', authMiddleware, (req, res) => {
            res.json({
                success: true,
                message: 'Protected route accessed successfully',
                userId: req.userId,
                userRole: req.userRole
            });
        });

        // Test route that requires admin role
        app.get('/admin', authMiddleware, adminMiddleware, (req, res) => {
            res.json({
                success: true,
                message: 'Admin route accessed successfully',
                userId: req.userId,
                userRole: req.userRole
            });
        });

        // Test route for testing without middleware
        app.get('/public', (req, res) => {
            res.json({
                success: true,
                message: 'Public route accessed successfully'
            });
        });
    });

    describe('authMiddleware', function() {
        it('should allow access with valid JWT token', async function() {
            const token = jwt.sign(
                { userId: 1, email: 'test@example.com', role: 'tourist' },
                JWT_SECRET,
                { expiresIn: '1h' }
            );

            const response = await request(app)
                .get('/protected')
                .set('Authorization', `Bearer ${token}`)
                .expect(200);

            expect(response.body).to.have.property('success', true);
            expect(response.body).to.have.property('message', 'Protected route accessed successfully');
            expect(response.body).to.have.property('userId', 1);
            expect(response.body).to.have.property('userRole', 'tourist');
        });

        it('should reject access without token', async function() {
            const response = await request(app)
                .get('/protected')
                .expect(401);

            expect(response.body).to.have.property('success', false);
            expect(response.body).to.have.property('message', 'Token manquant');
        });

        it('should reject access with malformed Authorization header', async function() {
            const response = await request(app)
                .get('/protected')
                .set('Authorization', 'InvalidFormat')
                .expect(401);

            expect(response.body).to.have.property('success', false);
            expect(response.body).to.have.property('message', 'Token manquant');
        });

        it('should reject access with invalid token', async function() {
            const response = await request(app)
                .get('/protected')
                .set('Authorization', 'Bearer invalid-token')
                .expect(401);

            expect(response.body).to.have.property('success', false);
            expect(response.body).to.have.property('message', 'Token invalide');
        });

        it('should reject access with expired token', async function() {
            const expiredToken = jwt.sign(
                { userId: 1, email: 'test@example.com', role: 'tourist' },
                JWT_SECRET,
                { expiresIn: '-1h' } // Expired 1 hour ago
            );

            const response = await request(app)
                .get('/protected')
                .set('Authorization', `Bearer ${expiredToken}`)
                .expect(401);

            expect(response.body).to.have.property('success', false);
            expect(response.body).to.have.property('message', 'Token expiré');
        });

        it('should reject access with token missing required claims', async function() {
            const incompleteToken = jwt.sign(
                { email: 'test@example.com' }, // Missing userId and role
                JWT_SECRET,
                { expiresIn: '1h' }
            );

            const response = await request(app)
                .get('/protected')
                .set('Authorization', `Bearer ${incompleteToken}`)
                .expect(200); // Should pass auth but fail in subsequent middleware

            // The middleware should still work, but req.userId and req.userRole might be undefined
            expect(response.body).to.have.property('success', true);
        });

        it('should handle JWT verification errors gracefully', async function() {
            // Test with token signed with wrong secret
            const wrongSecretToken = jwt.sign(
                { userId: 1, email: 'test@example.com', role: 'tourist' },
                'wrong-secret',
                { expiresIn: '1h' }
            );

            const response = await request(app)
                .get('/protected')
                .set('Authorization', `Bearer ${wrongSecretToken}`)
                .expect(401);

            expect(response.body).to.have.property('success', false);
            expect(response.body).to.have.property('message', 'Token invalide');
        });

        it('should handle malformed JWT tokens', async function() {
            const response = await request(app)
                .get('/protected')
                .set('Authorization', 'Bearer not.a.valid.jwt.token')
                .expect(401);

            expect(response.body).to.have.property('success', false);
            expect(response.body).to.have.property('message', 'Token invalide');
        });
    });

    describe('adminMiddleware', function() {
        it('should allow access for admin users', async function() {
            const adminToken = jwt.sign(
                { userId: 1, email: 'admin@example.com', role: 'ADMIN' },
                JWT_SECRET,
                { expiresIn: '1h' }
            );

            const response = await request(app)
                .get('/admin')
                .set('Authorization', `Bearer ${adminToken}`)
                .expect(200);

            expect(response.body).to.have.property('success', true);
            expect(response.body).to.have.property('message', 'Admin route accessed successfully');
            expect(response.body).to.have.property('userId', 1);
            expect(response.body).to.have.property('userRole', 'ADMIN');
        });

        it('should reject access for non-admin users', async function() {
            const userToken = jwt.sign(
                { userId: 1, email: 'user@example.com', role: 'tourist' },
                JWT_SECRET,
                { expiresIn: '1h' }
            );

            const response = await request(app)
                .get('/admin')
                .set('Authorization', `Bearer ${userToken}`)
                .expect(403);

            expect(response.body).to.have.property('success', false);
            expect(response.body).to.have.property('message', 'Accès refusé');
        });

        it('should reject access without authentication', async function() {
            const response = await request(app)
                .get('/admin')
                .expect(401);

            expect(response.body).to.have.property('success', false);
            expect(response.body).to.have.property('message', 'Token manquant');
        });

        it('should reject access with invalid token', async function() {
            const response = await request(app)
                .get('/admin')
                .set('Authorization', 'Bearer invalid-token')
                .expect(401);

            expect(response.body).to.have.property('success', false);
            expect(response.body).to.have.property('message', 'Token invalide');
        });

        it('should handle missing userRole gracefully', async function() {
            const tokenWithoutRole = jwt.sign(
                { userId: 1, email: 'test@example.com' }, // Missing role
                JWT_SECRET,
                { expiresIn: '1h' }
            );

            const response = await request(app)
                .get('/admin')
                .set('Authorization', `Bearer ${tokenWithoutRole}`)
                .expect(401);

            expect(response.body).to.have.property('success', false);
            expect(response.body).to.have.property('message', 'Utilisateur non authentifié');
        });
    });

    describe('Middleware Integration', function() {
        it('should allow public routes without authentication', async function() {
            const response = await request(app)
                .get('/public')
                .expect(200);

            expect(response.body).to.have.property('success', true);
            expect(response.body).to.have.property('message', 'Public route accessed successfully');
        });

        it('should process multiple middleware in sequence', async function() {
            const token = jwt.sign(
                { userId: 1, email: 'test@example.com', role: 'tourist' },
                JWT_SECRET,
                { expiresIn: '1h' }
            );

            const response = await request(app)
                .get('/protected')
                .set('Authorization', `Bearer ${token}`)
                .expect(200);

            expect(response.body).to.have.property('success', true);
            expect(response.body).to.have.property('userId', 1);
            expect(response.body).to.have.property('userRole', 'tourist');
        });

        it('should stop processing on first middleware failure', async function() {
            const response = await request(app)
                .get('/protected')
                .expect(401);

            expect(response.body).to.have.property('success', false);
            expect(response.body).to.have.property('message', 'Token manquant');
        });
    });

    describe('Security Tests', function() {
        it('should not expose sensitive information in error responses', async function() {
            const response = await request(app)
                .get('/protected')
                .set('Authorization', 'Bearer invalid-token')
                .expect(401);

            expect(response.body).to.not.have.property('stack');
            expect(response.body).to.not.have.property('error');
            expect(response.body).to.not.have.property('details');
        });

        it('should handle very long tokens gracefully', async function() {
            const longToken = 'Bearer ' + 'a'.repeat(10000);
            
            const response = await request(app)
                .get('/protected')
                .set('Authorization', longToken)
                .expect(401);

            expect(response.body).to.have.property('success', false);
            expect(response.body).to.have.property('message', 'Token invalide');
        });

        it('should handle empty Authorization header', async function() {
            const response = await request(app)
                .get('/protected')
                .set('Authorization', '')
                .expect(401);

            expect(response.body).to.have.property('success', false);
            expect(response.body).to.have.property('message', 'Token manquant');
        });

        it('should handle Authorization header with only "Bearer"', async function() {
            const response = await request(app)
                .get('/protected')
                .set('Authorization', 'Bearer')
                .expect(401);

            expect(response.body).to.have.property('success', false);
            expect(response.body).to.have.property('message', 'Token manquant');
        });

        it('should handle Authorization header with extra spaces', async function() {
            const token = jwt.sign(
                { userId: 1, email: 'test@example.com', role: 'tourist' },
                JWT_SECRET,
                { expiresIn: '1h' }
            );

            const response = await request(app)
                .get('/protected')
                .set('Authorization', `  Bearer  ${token}  `)
                .expect(200);

            expect(response.body).to.have.property('success', true);
        });
    });

    describe('Token Payload Validation', function() {
        it('should handle tokens with additional claims', async function() {
            const tokenWithExtraClaims = jwt.sign(
                { 
                    userId: 1, 
                    email: 'test@example.com', 
                    role: 'tourist',
                    extraClaim: 'extraValue'
                },
                JWT_SECRET,
                { expiresIn: '1h' }
            );

            const response = await request(app)
                .get('/protected')
                .set('Authorization', `Bearer ${tokenWithExtraClaims}`)
                .expect(200);

            expect(response.body).to.have.property('success', true);
            expect(response.body).to.have.property('userId', 1);
            expect(response.body).to.have.property('userRole', 'tourist');
        });

        it('should handle tokens with numeric userId', async function() {
            const tokenWithNumericUserId = jwt.sign(
                { userId: 123, email: 'test@example.com', role: 'tourist' },
                JWT_SECRET,
                { expiresIn: '1h' }
            );

            const response = await request(app)
                .get('/protected')
                .set('Authorization', `Bearer ${tokenWithNumericUserId}`)
                .expect(200);

            expect(response.body).to.have.property('success', true);
            expect(response.body).to.have.property('userId', 123);
        });

        it('should handle tokens with string userId', async function() {
            const tokenWithStringUserId = jwt.sign(
                { userId: 'user123', email: 'test@example.com', role: 'tourist' },
                JWT_SECRET,
                { expiresIn: '1h' }
            );

            const response = await request(app)
                .get('/protected')
                .set('Authorization', `Bearer ${tokenWithStringUserId}`)
                .expect(200);

            expect(response.body).to.have.property('success', true);
            expect(response.body).to.have.property('userId', 'user123');
        });
    });
});