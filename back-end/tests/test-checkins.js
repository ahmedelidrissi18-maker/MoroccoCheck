import { after, before, describe, it } from 'mocha';
import { expect } from 'chai';
import dotenv from 'dotenv';
import request from 'supertest';
import { generateToken } from '../src/utils/jwt.utils.js';
import checkinsRoutes from '../src/routes/checkins.routes.js';
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

describe('Check-ins API', function () {
  let app;
  let contributor;
  let contributorToken;
  let category;
  let site;
  let dbReady = false;
  let schemaReady = false;

  const createdCheckinIds = [];

  before(async function () {
    dbReady = await isDatabaseAvailable();
    const requiredTables = await Promise.all([
      hasTable('users'),
      hasTable('tourist_sites'),
      hasTable('checkins'),
      hasTable('categories')
    ]);
    schemaReady = requiredTables.every(Boolean);

    if (!dbReady || !schemaReady) {
      this.skip();
    }

    app = createTestApp('/api/checkins', checkinsRoutes);
    category = await createTestCategory();
    contributor = await createTestUser({
      role: 'CONTRIBUTOR',
      email: `checkin.user.${Date.now()}@example.com`
    });
    site = await createTestSite(category.id, {
      latitude: 33.5731,
      longitude: -7.5898,
      status: 'PUBLISHED',
      verification_status: 'VERIFIED'
    });
    contributorToken = generateToken(contributor);
  });

  after(async function () {
    if (!dbReady || !schemaReady) {
      return;
    }

    await cleanupTestData({
      checkinIds: createdCheckinIds,
      siteIds: site ? [site.id] : [],
      userIds: contributor ? [contributor.id] : [],
      categoryIds: category ? [category.id] : []
    });
  });

  it('should create a valid check-in within 100 meters', async function () {
    const response = await request(app)
      .post('/api/checkins')
      .set('Authorization', `Bearer ${contributorToken}`)
      .send({
        site_id: site.id,
        status: 'OPEN',
        comment: 'Presence verifiee sur place',
        latitude: 33.57315,
        longitude: -7.58975,
        accuracy: 10,
        has_photo: true
      })
      .expect(201);

    expect(response.body.success).to.equal(true);
    expect(response.body.message).to.equal('Check-in enregistre avec succes');
    expect(response.body.data.checkin.site_id).to.equal(site.id);
    expect(response.body.data.points_earned).to.equal(15);

    createdCheckinIds.push(response.body.data.checkin.id);
  });

  it('should reject a second check-in for the same site on the same day', async function () {
    const response = await request(app)
      .post('/api/checkins')
      .set('Authorization', `Bearer ${contributorToken}`)
      .send({
        site_id: site.id,
        status: 'OPEN',
        comment: 'Deuxieme tentative',
        latitude: 33.57315,
        longitude: -7.58975,
        accuracy: 10
      })
      .expect(409);

    expect(response.body.success).to.equal(false);
    expect(response.body.code).to.equal('CHECKIN_ALREADY_EXISTS');
  });

  it('should reject a check-in when the user is too far from the site', async function () {
    const farUser = await createTestUser({
      role: 'CONTRIBUTOR',
      email: `checkin.far.${Date.now()}@example.com`
    });
    const farToken = generateToken(farUser);

    try {
      const response = await request(app)
        .post('/api/checkins')
        .set('Authorization', `Bearer ${farToken}`)
        .send({
          site_id: site.id,
          status: 'OPEN',
          comment: 'Trop loin',
          latitude: 34.0209,
          longitude: -6.8416,
          accuracy: 10
        })
        .expect(400);

      expect(response.body.success).to.equal(false);
      expect(response.body.code).to.equal('CHECKIN_TOO_FAR');
    } finally {
      await cleanupTestData({ userIds: [farUser.id] });
    }
  });
});

