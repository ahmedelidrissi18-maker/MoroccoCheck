import { after, before, describe, it } from 'mocha';
import { expect } from 'chai';
import dotenv from 'dotenv';
import express from 'express';
import request from 'supertest';
import pool from '../src/config/database.js';
import adminRoutes from '../src/routes/admin.routes.js';
import sitesRoutes from '../src/routes/sites.routes.js';
import errorMiddleware from '../src/middleware/error.middleware.js';
import { generateToken } from '../src/utils/jwt.utils.js';
import {
  cleanupTestData,
  createTestCategory,
  createTestSite,
  createTestUser,
  hasTable,
  isDatabaseAvailable
} from './helpers/db.helper.js';

dotenv.config();

describe('Admin API', function () {
  let app;
  let admin;
  let professional;
  let adminToken;
  let professionalToken;
  let category;
  let pendingSite;
  let reviewAuthor;
  let review;
  let dbReady = false;
  let schemaReady = false;

  before(async function () {
    dbReady = await isDatabaseAvailable();
    const requiredTables = await Promise.all([
      hasTable('users'),
      hasTable('tourist_sites'),
      hasTable('categories')
    ]);
    schemaReady = requiredTables.every(Boolean);

    if (!dbReady || !schemaReady) {
      this.skip();
    }

    app = express();
    app.use(express.json());
    app.use('/api/admin', adminRoutes);
    app.use('/api/sites', sitesRoutes);
    app.use(errorMiddleware.notFoundHandler);
    app.use(errorMiddleware.errorHandler);

    category = await createTestCategory();
    admin = await createTestUser({
      role: 'ADMIN',
      email: `admin.review.${Date.now()}@example.com`
    });
    professional = await createTestUser({
      role: 'PROFESSIONAL',
      email: `pro.review.${Date.now()}@example.com`
    });
    reviewAuthor = await createTestUser({
      role: 'TOURIST',
      email: `review.author.${Date.now()}@example.com`
    });
    pendingSite = await createTestSite(category.id, {
      owner_id: professional.id,
      status: 'PENDING_REVIEW',
      verification_status: 'PENDING'
    });
    const [reviewResult] = await pool.query(
      `INSERT INTO reviews (
          user_id, site_id, overall_rating, title, content, status, moderation_status
       ) VALUES (?, ?, ?, ?, ?, ?, ?)`,
      [
        reviewAuthor.id,
        pendingSite.id,
        4.5,
        'Lieu tres prometteur',
        'Le lieu merite verification avant publication finale.',
        'PENDING',
        'PENDING'
      ]
    );
    review = { id: reviewResult.insertId };

    adminToken = generateToken(admin);
    professionalToken = generateToken(professional);
  });

  after(async function () {
    if (!dbReady || !schemaReady) {
      return;
    }

    await cleanupTestData({
      reviewIds: [review?.id].filter(Boolean),
      siteIds: [pendingSite?.id].filter(Boolean),
      userIds: [admin?.id, professional?.id, reviewAuthor?.id].filter(Boolean),
      categoryIds: category ? [category.id] : []
    });
  });

  it('should persist moderation notes for a reviewed site and expose them to the owner', async function () {
    const notes =
      'Merci de preciser les horaires exacts et de corriger l adresse avant republication.';

    const moderationResponse = await request(app)
      .put(`/api/admin/sites/${pendingSite.id}/review`)
      .set('Authorization', `Bearer ${adminToken}`)
      .send({
        action: 'REJECT',
        notes
      })
      .expect(200);

    expect(moderationResponse.body.success).to.equal(true);
    expect(moderationResponse.body.data.notes).to.equal(notes);
    expect(moderationResponse.body.data.verification_status).to.equal('REJECTED');

    const ownerResponse = await request(app)
      .get(`/api/sites/mine/${pendingSite.id}`)
      .set('Authorization', `Bearer ${professionalToken}`)
      .expect(200);

    expect(ownerResponse.body.success).to.equal(true);
    expect(ownerResponse.body.data.site.verification_status).to.equal('REJECTED');
    expect(ownerResponse.body.data.site.moderation_notes).to.equal(notes);
    expect(ownerResponse.body.data.site.moderated_by).to.equal(admin.id);
    expect(ownerResponse.body.data.site.moderator_first_name).to.equal(admin.first_name);
  });

  it('should expose admin site detail for moderation pages', async function () {
    const response = await request(app)
      .get(`/api/admin/sites/${pendingSite.id}`)
      .set('Authorization', `Bearer ${adminToken}`)
      .expect(200);

    expect(response.body.success).to.equal(true);
    expect(response.body.data.id).to.equal(pendingSite.id);
    expect(response.body.data.name).to.equal(pendingSite.name);
    expect(response.body.data.owner_id).to.equal(professional.id);
    expect(response.body.data.owner_email).to.equal(professional.email);
  });

  it('should expose admin review detail for moderation pages', async function () {
    const response = await request(app)
      .get(`/api/admin/reviews/${review.id}`)
      .set('Authorization', `Bearer ${adminToken}`)
      .expect(200);

    expect(response.body.success).to.equal(true);
    expect(response.body.data.id).to.equal(review.id);
    expect(response.body.data.site_id).to.equal(pendingSite.id);
    expect(response.body.data.author_email).to.equal(reviewAuthor.email);
    expect(response.body.data.content).to.include('verification');
  });
});
