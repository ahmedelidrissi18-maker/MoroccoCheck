import { before, describe, it } from 'mocha';
import { expect } from 'chai';
import dotenv from 'dotenv';
import express from 'express';
import jwt from 'jsonwebtoken';
import request from 'supertest';
import { adminMiddleware, authMiddleware } from '../src/middleware/auth.middleware.js';

dotenv.config();

const JWT_SECRET = process.env.JWT_SECRET || 'test-secret-key';

describe('Authentication Middleware', function () {
  let app;

  before(function () {
    app = express();
    app.use(express.json());

    app.get('/protected', authMiddleware, (req, res) => {
      res.json({
        success: true,
        userId: req.userId,
        userRole: req.userRole
      });
    });

    app.get('/admin', authMiddleware, adminMiddleware, (req, res) => {
      res.json({
        success: true,
        userId: req.userId,
        userRole: req.userRole
      });
    });
  });

  it('should allow access with a valid token', async function () {
    const token = jwt.sign(
      { userId: 1, email: 'test@example.com', role: 'TOURIST' },
      JWT_SECRET,
      { expiresIn: '1h' }
    );

    const response = await request(app)
      .get('/protected')
      .set('Authorization', `Bearer ${token}`)
      .expect(200);

    expect(response.body).to.include({
      success: true,
      userId: 1,
      userRole: 'TOURIST'
    });
  });

  it('should reject missing token', async function () {
    const response = await request(app)
      .get('/protected')
      .expect(401);

    expect(response.body.message).to.equal('Token manquant');
  });

  it('should reject invalid token', async function () {
    const response = await request(app)
      .get('/protected')
      .set('Authorization', 'Bearer invalid-token')
      .expect(401);

    expect(response.body.message).to.equal('Token invalide');
  });

  it('should reject expired token', async function () {
    const token = jwt.sign(
      { userId: 1, email: 'test@example.com', role: 'TOURIST' },
      JWT_SECRET,
      { expiresIn: '-1h' }
    );

    const response = await request(app)
      .get('/protected')
      .set('Authorization', `Bearer ${token}`)
      .expect(401);

    expect(response.body.message).to.equal('Token expire');
  });

  it('should allow admin access for ADMIN role', async function () {
    const token = jwt.sign(
      { userId: 1, email: 'admin@example.com', role: 'ADMIN' },
      JWT_SECRET,
      { expiresIn: '1h' }
    );

    const response = await request(app)
      .get('/admin')
      .set('Authorization', `Bearer ${token}`)
      .expect(200);

    expect(response.body.success).to.equal(true);
    expect(response.body.userRole).to.equal('ADMIN');
  });

  it('should reject non-admin access', async function () {
    const token = jwt.sign(
      { userId: 1, email: 'user@example.com', role: 'TOURIST' },
      JWT_SECRET,
      { expiresIn: '1h' }
    );

    const response = await request(app)
      .get('/admin')
      .set('Authorization', `Bearer ${token}`)
      .expect(403);

    expect(response.body.message).to.equal('Acces refuse');
  });

  it('should accept authorization header with extra spaces', async function () {
    const token = jwt.sign(
      { userId: 1, email: 'test@example.com', role: 'TOURIST' },
      JWT_SECRET,
      { expiresIn: '1h' }
    );

    const response = await request(app)
      .get('/protected')
      .set('Authorization', `  Bearer   ${token}  `)
      .expect(200);

    expect(response.body.success).to.equal(true);
  });
});
