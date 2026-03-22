import { after, before, describe, it } from 'mocha';
import { expect } from 'chai';
import dotenv from 'dotenv';
import request from 'supertest';
import { generateToken } from '../src/utils/jwt.utils.js';
import reviewsRoutes from '../src/routes/reviews.routes.js';
import {
  cleanupTestData,
  createTestCategory,
  createTestSite,
  createTestUser,
  hasTable,
  isDatabaseAvailable
} from './helpers/db.helper.js';
import { createTestApp } from './helpers/app.helper.js';

dotenv.config();

describe('Reviews API', function () {
  let app;
  let reviewer;
  let reviewerToken;
  let category;
  let site;
  let dbReady = false;
  let schemaReady = false;

  const createdReviewIds = [];

  before(async function () {
    dbReady = await isDatabaseAvailable();
    const requiredTables = await Promise.all([
      hasTable('users'),
      hasTable('tourist_sites'),
      hasTable('reviews'),
      hasTable('categories')
    ]);
    schemaReady = requiredTables.every(Boolean);

    if (!dbReady || !schemaReady) {
      this.skip();
    }

    app = createTestApp('/api/reviews', reviewsRoutes);
    category = await createTestCategory();
    reviewer = await createTestUser({
      role: 'CONTRIBUTOR',
      email: `review.user.${Date.now()}@example.com`
    });
    site = await createTestSite(category.id, {
      status: 'PUBLISHED',
      verification_status: 'VERIFIED'
    });
    reviewerToken = generateToken(reviewer);
  });

  after(async function () {
    if (!dbReady || !schemaReady) {
      return;
    }

    await cleanupTestData({
      reviewIds: createdReviewIds,
      siteIds: site ? [site.id] : [],
      userIds: reviewer ? [reviewer.id] : [],
      categoryIds: category ? [category.id] : []
    });
  });

  it('should create a review for a published site', async function () {
    const response = await request(app)
      .post('/api/reviews')
      .set('Authorization', `Bearer ${reviewerToken}`)
      .send({
        site_id: site.id,
        rating: 4,
        title: 'Belle experience',
        content: 'Une visite tres agreable avec un excellent accueil et un site bien entretenu.',
        visit_type: 'FRIENDS'
      })
      .expect(201);

    expect(response.body.success).to.equal(true);
    expect(response.body.message).to.equal('Avis cree avec succes');
    expect(response.body.data.review.site_id).to.equal(site.id);
    expect(response.body.data.moderation_status).to.equal('PENDING');

    createdReviewIds.push(response.body.data.review.id);
  });

  it('should reject duplicate review for the same user and site', async function () {
    const response = await request(app)
      .post('/api/reviews')
      .set('Authorization', `Bearer ${reviewerToken}`)
      .send({
        site_id: site.id,
        rating: 5,
        title: 'Deuxieme avis',
        content: 'Ce second avis devrait etre refuse car un avis existe deja pour ce site.',
        visit_type: 'SOLO'
      })
      .expect(409);

    expect(response.body.success).to.equal(false);
    expect(response.body.code).to.equal('REVIEW_ALREADY_EXISTS');
  });
});
