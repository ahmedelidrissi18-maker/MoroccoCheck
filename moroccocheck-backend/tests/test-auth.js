/**
 * Test suite for Authentication API endpoints
 * 
 * This file contains comprehensive tests for the MoroccoCheck authentication system
 * including user registration, login, profile management, and JWT token validation.
 */

import { describe, it, before, after } from 'mocha';
import { expect } from 'chai';
import request from 'supertest';
import express from 'express';
import pool from '../src/config/database.js';
import authRoutes from '../src/routes/auth.routes.js';
import dotenv from 'dotenv';

// Load environment variables
dotenv.config();

// Test configuration
const TEST_DB_NAME = 'moroccocheck_test';
const JWT_SECRET = process.env.JWT_SECRET || 'test-secret-key';

describe('Authentication API', function() {
    let app;
    let testUser = {
        name: 'Test User',
        email: 'test@example.com',
        password: 'password123'
    };
    let authToken;

    before(async function() {
        // Create test database if it doesn't exist
        try {
            await pool.query(`CREATE DATABASE IF NOT EXISTS ${TEST_DB_NAME}`);
            await pool.query(`USE ${TEST_DB_NAME}`);
        } catch (error) {
            console.log('Database setup skipped:', error.message);
        }

        // Setup Express app for testing
        app = express();
        app.use(express.json());
        app.use('/api/auth', authRoutes);

        // Clean up any existing test data
        try {
            await pool.query('DELETE FROM users WHERE email = ?', [testUser.email]);
        } catch (error) {
            console.log('Cleanup skipped:', error.message);
        }
    });

    after(async function() {
        // Clean up test data
        try {
            await pool.query('DELETE FROM users WHERE email = ?', [testUser.email]);
        } catch (error) {
            console.log('Cleanup after tests skipped:', error.message);
        }
    });

    describe('POST /api/auth/register', function() {
        it('should register a new user successfully', async function() {
            const response = await request(app)
                .post('/api/auth/register')
                .send(testUser)
                .expect(201);

            expect(response.body).to.have.property('success', true);
            expect(response.body).to.have.property('message', 'Inscription réussie');
            expect(response.body.data).to.have.property('token');
            expect(response.body.data.user).to.have.property('id');
            expect(response.body.data.user.name).to.equal(testUser.name);
            expect(response.body.data.user.email).to.equal(testUser.email);
            expect(response.body.data.user.role).to.equal('tourist');
            expect(response.body.data.user.points).to.equal(0);
            expect(response.body.data.user.level).to.equal('Bronze');

            // Store token for subsequent tests
            authToken = response.body.data.token;
        });

        it('should return 400 for duplicate email', async function() {
            const response = await request(app)
                .post('/api/auth/register')
                .send(testUser)
                .expect(400);

            expect(response.body).to.have.property('success', false);
            expect(response.body).to.have.property('message', 'Email déjà utilisé');
        });

        it('should return 400 for invalid email format', async function() {
            const response = await request(app)
                .post('/api/auth/register')
                .send({
                    name: 'Test User',
                    email: 'invalid-email',
                    password: 'password123'
                })
                .expect(400);

            expect(response.body).to.have.property('success', false);
            expect(response.body).to.have.property('message', 'Validation échouée');
            expect(response.body.errors).to.be.an('array');
            expect(response.body.errors[0]).to.include('email valide');
        });

        it('should return 400 for password too short', async function() {
            const response = await request(app)
                .post('/api/auth/register')
                .send({
                    name: 'Test User',
                    email: 'test2@example.com',
                    password: '123'
                })
                .expect(400);

            expect(response.body).to.have.property('success', false);
            expect(response.body).to.have.property('message', 'Validation échouée');
            expect(response.body.errors).to.be.an('array');
            expect(response.body.errors[0]).to.include('6 caractères');
        });

        it('should return 400 for missing required fields', async function() {
            const response = await request(app)
                .post('/api/auth/register')
                .send({
                    name: 'Test User'
                    // Missing email and password
                })
                .expect(400);

            expect(response.body).to.have.property('success', false);
            expect(response.body).to.have.property('message', 'Validation échouée');
            expect(response.body.errors).to.be.an('array');
        });
    });

    describe('POST /api/auth/login', function() {
        it('should login successfully with correct credentials', async function() {
            const response = await request(app)
                .post('/api/auth/login')
                .send({
                    email: testUser.email,
                    password: testUser.password
                })
                .expect(200);

            expect(response.body).to.have.property('success', true);
            expect(response.body).to.have.property('message', 'Connexion réussie');
            expect(response.body.data).to.have.property('token');
            expect(response.body.data.user).to.have.property('id');
            expect(response.body.data.user.name).to.equal(testUser.name);
            expect(response.body.data.user.email).to.equal(testUser.email);
            expect(response.body.data.user).to.not.have.property('password');
        });

        it('should return 401 for incorrect password', async function() {
            const response = await request(app)
                .post('/api/auth/login')
                .send({
                    email: testUser.email,
                    password: 'wrongpassword'
                })
                .expect(401);

            expect(response.body).to.have.property('success', false);
            expect(response.body).to.have.property('message', 'Email ou mot de passe incorrect');
        });

        it('should return 401 for non-existent email', async function() {
            const response = await request(app)
                .post('/api/auth/login')
                .send({
                    email: 'nonexistent@example.com',
                    password: 'password123'
                })
                .expect(401);

            expect(response.body).to.have.property('success', false);
            expect(response.body).to.have.property('message', 'Email ou mot de passe incorrect');
        });

        it('should return 400 for missing credentials', async function() {
            const response = await request(app)
                .post('/api/auth/login')
                .send({})
                .expect(400);

            expect(response.body).to.have.property('success', false);
            expect(response.body).to.have.property('message', 'Validation échouée');
        });
    });

    describe('GET /api/auth/profile', function() {
        it('should return user profile with valid token', async function() {
            const response = await request(app)
                .get('/api/auth/profile')
                .set('Authorization', `Bearer ${authToken}`)
                .expect(200);

            expect(response.body).to.have.property('success', true);
            expect(response.body.data.user).to.have.property('id');
            expect(response.body.data.user.name).to.equal(testUser.name);
            expect(response.body.data.user.email).to.equal(testUser.email);
            expect(response.body.data.user).to.not.have.property('password');
        });

        it('should return 401 for missing token', async function() {
            const response = await request(app)
                .get('/api/auth/profile')
                .expect(401);

            expect(response.body).to.have.property('success', false);
            expect(response.body).to.have.property('message', 'Token manquant');
        });

        it('should return 401 for invalid token', async function() {
            const response = await request(app)
                .get('/api/auth/profile')
                .set('Authorization', 'Bearer invalid-token')
                .expect(401);

            expect(response.body).to.have.property('success', false);
            expect(response.body).to.have.property('message', 'Token invalide');
        });

        it('should return 401 for expired token', async function() {
            // Create an expired token for testing
            const jwt = await import('jsonwebtoken');
            const expiredToken = jwt.sign(
                { userId: 1, email: 'test@example.com', role: 'tourist' },
                JWT_SECRET,
                { expiresIn: '-1h' } // Expired 1 hour ago
            );

            const response = await request(app)
                .get('/api/auth/profile')
                .set('Authorization', `Bearer ${expiredToken}`)
                .expect(401);

            expect(response.body).to.have.property('success', false);
            expect(response.body).to.have.property('message', 'Token expiré');
        });
    });

    describe('PUT /api/auth/profile', function() {
        it('should update user profile successfully', async function() {
            const updateData = {
                name: 'Updated Test User',
                avatar_url: 'https://example.com/avatar.jpg'
            };

            const response = await request(app)
                .put('/api/auth/profile')
                .set('Authorization', `Bearer ${authToken}`)
                .send(updateData)
                .expect(200);

            expect(response.body).to.have.property('success', true);
            expect(response.body).to.have.property('message', 'Profil mis à jour avec succès');
            expect(response.body.data.user.name).to.equal(updateData.name);
            expect(response.body.data.user.avatar_url).to.equal(updateData.avatar_url);
            expect(response.body.data.user.email).to.equal(testUser.email); // Should remain unchanged
        });

        it('should return 400 for invalid email format in update', async function() {
            const response = await request(app)
                .put('/api/auth/profile')
                .set('Authorization', `Bearer ${authToken}`)
                .send({
                    email: 'invalid-email-format'
                })
                .expect(400);

            expect(response.body).to.have.property('success', false);
            expect(response.body).to.have.property('message', 'Validation échouée');
            expect(response.body.errors).to.be.an('array');
        });

        it('should return 400 for duplicate email in update', async function() {
            // First register another user
            await request(app)
                .post('/api/auth/register')
                .send({
                    name: 'Another User',
                    email: 'another@example.com',
                    password: 'password123'
                });

            const response = await request(app)
                .put('/api/auth/profile')
                .set('Authorization', `Bearer ${authToken}`)
                .send({
                    email: 'another@example.com'
                })
                .expect(400);

            expect(response.body).to.have.property('success', false);
            expect(response.body).to.have.property('message', 'Email déjà utilisé');
        });

        it('should return 401 for missing token', async function() {
            const response = await request(app)
                .put('/api/auth/profile')
                .send({
                    name: 'Updated Name'
                })
                .expect(401);

            expect(response.body).to.have.property('success', false);
            expect(response.body).to.have.property('message', 'Token manquant');
        });

        it('should return 400 for empty update data', async function() {
            const response = await request(app)
                .put('/api/auth/profile')
                .set('Authorization', `Bearer ${authToken}`)
                .send({})
                .expect(400);

            expect(response.body).to.have.property('success', false);
            expect(response.body).to.have.property('message', 'Aucun champ à mettre à jour fourni');
        });
    });

    describe('JWT Token Validation', function() {
        it('should generate tokens with correct payload', async function() {
            const jwt = await import('jsonwebtoken');
            const decoded = jwt.verify(authToken, JWT_SECRET);

            expect(decoded).to.have.property('userId');
            expect(decoded).to.have.property('email', testUser.email);
            expect(decoded).to.have.property('role', 'tourist');
            expect(decoded).to.have.property('exp');
        });

        it('should generate tokens with 7-day expiration', async function() {
            const jwt = await import('jsonwebtoken');
            const decoded = jwt.verify(authToken, JWT_SECRET);
            const now = Math.floor(Date.now() / 1000);
            const expiresAt = decoded.exp;
            const expiresInDays = (expiresAt - now) / (24 * 3600);

            expect(expiresInDays).to.be.closeTo(7, 0.1);
        });
    });

    describe('Security Tests', function() {
        it('should not expose password in any response', async function() {
            // Test registration response
            const registerResponse = await request(app)
                .post('/api/auth/register')
                .send({
                    name: 'Security Test User',
                    email: 'security@example.com',
                    password: 'password123'
                });

            expect(registerResponse.body.data.user).to.not.have.property('password');

            // Test login response
            const loginResponse = await request(app)
                .post('/api/auth/login')
                .send({
                    email: 'security@example.com',
                    password: 'password123'
                });

            expect(loginResponse.body.data.user).to.not.have.property('password');

            // Test profile response
            const profileResponse = await request(app)
                .get('/api/auth/profile')
                .set('Authorization', `Bearer ${loginResponse.body.data.token}`);

            expect(profileResponse.body.data.user).to.not.have.property('password');
        });

        it('should handle SQL injection attempts', async function() {
            const response = await request(app)
                .post('/api/auth/login')
                .send({
                    email: "'; DROP TABLE users; --",
                    password: "'; DROP TABLE users; --"
                })
                .expect(401);

            expect(response.body).to.have.property('success', false);
            expect(response.body).to.have.property('message', 'Email ou mot de passe incorrect');
        });

        it('should handle XSS attempts in user input', async function() {
            const response = await request(app)
                .post('/api/auth/register')
                .send({
                    name: '<script>alert("xss")</script>',
                    email: 'xss@example.com',
                    password: 'password123'
                })
                .expect(201);

            expect(response.body.data.user.name).to.equal('<script>alert("xss")</script>');
        });
    });
});