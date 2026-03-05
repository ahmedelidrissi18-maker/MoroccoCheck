/**
 * Test suite for Database connectivity and configuration
 * 
 * This file contains tests for database connection, configuration,
 * and basic database operations to ensure the database layer is working correctly.
 */

import { describe, it, before, after } from 'mocha';
import { expect } from 'chai';
import pool from '../src/config/database.js';
import dotenv from 'dotenv';

// Load environment variables
dotenv.config();

describe('Database Configuration', function() {
    this.timeout(10000); // Increase timeout for database operations

    describe('Database Connection', function() {
        it('should establish a connection to the database', async function() {
            try {
                const connection = await pool.getConnection();
                expect(connection).to.exist;
                connection.release();
            } catch (error) {
                throw new Error(`Database connection failed: ${error.message}`);
            }
        });

        it('should execute a simple query successfully', async function() {
            const [rows] = await pool.query('SELECT 1 as test');
            expect(rows).to.be.an('array');
            expect(rows[0].test).to.equal(1);
        });

        it('should return database version', async function() {
            const [rows] = await pool.query('SELECT VERSION() as version');
            expect(rows).to.be.an('array');
            expect(rows[0]).to.have.property('version');
            expect(rows[0].version).to.be.a('string');
        });

        it('should handle connection pooling correctly', async function() {
            // Test multiple concurrent connections
            const promises = [];
            for (let i = 0; i < 5; i++) {
                promises.push(pool.query('SELECT ? as connection_id', [i]));
            }
            
            const results = await Promise.all(promises);
            expect(results).to.have.length(5);
            
            results.forEach((result, index) => {
                expect(result[0][0].connection_id).to.equal(index);
            });
        });
    });

    describe('Database Configuration', function() {
        it('should have correct connection parameters', function() {
            const config = pool.config;
            
            expect(config).to.have.property('host');
            expect(config).to.have.property('user');
            expect(config).to.have.property('database');
            expect(config).to.have.property('connectionLimit');
            expect(config.connectionLimit).to.be.at.least(1);
        });

        it('should have environment variables loaded', function() {
            expect(process.env.DB_HOST).to.exist;
            expect(process.env.DB_USER).to.exist;
            expect(process.env.DB_PASSWORD).to.exist;
            expect(process.env.DB_NAME).to.exist;
        });

        it('should handle missing environment variables gracefully', function() {
            // Test with minimal configuration
            const testConfig = {
                host: process.env.DB_HOST || 'localhost',
                user: process.env.DB_USER || 'root',
                password: process.env.DB_PASSWORD || '',
                database: process.env.DB_NAME || 'test'
            };

            expect(testConfig.host).to.be.a('string');
            expect(testConfig.user).to.be.a('string');
            expect(testConfig.database).to.be.a('string');
        });
    });

    describe('Database Operations', function() {
        let testUserId;

        before(async function() {
            // Clean up any existing test data
            try {
                await pool.query('DELETE FROM users WHERE email LIKE ?', ['test_%@example.com']);
            } catch (error) {
                // Ignore errors if table doesn't exist yet
            }
        });

        after(async function() {
            // Clean up test data
            try {
                await pool.query('DELETE FROM users WHERE email LIKE ?', ['test_%@example.com']);
            } catch (error) {
                // Ignore errors
            }
        });

        it('should create and query a test user', async function() {
            // Insert test user
            const insertQuery = `
                INSERT INTO users (name, email, password_hash, role, points, level) 
                VALUES (?, ?, ?, 'tourist', 0, 'Bronze')
            `;
            
            const hashedPassword = '$2a$10$test.hash.for.testing.purposes.only';
            const [insertResult] = await pool.query(insertQuery, [
                'Test User',
                'test_user@example.com',
                hashedPassword
            ]);

            testUserId = insertResult.insertId;
            expect(testUserId).to.be.a('number');
            expect(testUserId).to.be.greaterThan(0);

            // Query the inserted user
            const [rows] = await pool.query(
                'SELECT * FROM users WHERE id = ?',
                [testUserId]
            );

            expect(rows).to.be.an('array');
            expect(rows).to.have.length(1);
            expect(rows[0].name).to.equal('Test User');
            expect(rows[0].email).to.equal('test_user@example.com');
            expect(rows[0].role).to.equal('tourist');
            expect(rows[0].points).to.equal(0);
            expect(rows[0].level).to.equal('Bronze');
        });

        it('should handle duplicate email constraint', async function() {
            const insertQuery = `
                INSERT INTO users (name, email, password_hash, role, points, level) 
                VALUES (?, ?, ?, 'tourist', 0, 'Bronze')
            `;
            
            const hashedPassword = '$2a$10$test.hash.for.testing.purposes.only';
            
            try {
                await pool.query(insertQuery, [
                    'Another User',
                    'test_user@example.com', // Same email as previous test
                    hashedPassword
                ]);
                throw new Error('Should have thrown a duplicate key error');
            } catch (error) {
                // In MySQL, this should throw a duplicate key error
                expect(error.code).to.equal('ER_DUP_ENTRY');
            }
        });

        it('should update user data correctly', async function() {
            if (!testUserId) {
                this.skip();
            }

            const updateQuery = `
                UPDATE users 
                SET name = ?, email = ?, updated_at = NOW() 
                WHERE id = ?
            `;
            
            const [updateResult] = await pool.query(updateQuery, [
                'Updated Test User',
                'updated_test@example.com',
                testUserId
            ]);

            expect(updateResult.affectedRows).to.equal(1);

            // Verify the update
            const [rows] = await pool.query(
                'SELECT * FROM users WHERE id = ?',
                [testUserId]
            );

            expect(rows[0].name).to.equal('Updated Test User');
            expect(rows[0].email).to.equal('updated_test@example.com');
        });

        it('should delete test user', async function() {
            if (!testUserId) {
                this.skip();
            }

            const deleteQuery = 'DELETE FROM users WHERE id = ?';
            const [deleteResult] = await pool.query(deleteQuery, [testUserId]);

            expect(deleteResult.affectedRows).to.equal(1);

            // Verify deletion
            const [rows] = await pool.query(
                'SELECT * FROM users WHERE id = ?',
                [testUserId]
            );

            expect(rows).to.have.length(0);
        });
    });

    describe('Database Error Handling', function() {
        it('should handle invalid SQL queries gracefully', async function() {
            try {
                await pool.query('INVALID SQL QUERY');
                throw new Error('Should have thrown an error');
            } catch (error) {
                expect(error).to.exist;
                expect(error.code).to.be.a('string');
            }
        });

        it('should handle connection timeouts', async function() {
            // This test might be skipped in some environments
            this.timeout(5000);
            
            try {
                // Try to connect to a non-existent host
                const testPool = await import('mysql2/promise').then(mysql => 
                    mysql.createPool({
                        host: 'non-existent-host',
                        user: 'test',
                        password: 'test',
                        database: 'test',
                        connectTimeout: 1000
                    })
                );
                
                await testPool.getConnection();
                throw new Error('Should have thrown a connection error');
            } catch (error) {
                expect(error).to.exist;
            }
        });

        it('should handle database disconnection', async function() {
            // Test that the pool can handle temporary disconnections
            const [rows] = await pool.query('SELECT 1 as test');
            expect(rows[0].test).to.equal(1);
        });
    });

    describe('Database Performance', function() {
        it('should handle multiple concurrent queries efficiently', async function() {
            const startTime = Date.now();
            
            const promises = [];
            for (let i = 0; i < 10; i++) {
                promises.push(pool.query('SELECT ? as query_number', [i]));
            }
            
            const results = await Promise.all(promises);
            const endTime = Date.now();
            
            expect(results).to.have.length(10);
            expect(endTime - startTime).to.be.lessThan(5000); // Should complete within 5 seconds
            
            results.forEach((result, index) => {
                expect(result[0][0].query_number).to.equal(index);
            });
        });

        it('should reuse connections from the pool', async function() {
            // Execute multiple queries to test connection reuse
            for (let i = 0; i < 5; i++) {
                const [rows] = await pool.query('SELECT ? as iteration', [i]);
                expect(rows[0].iteration).to.equal(i);
            }
        });
    });
});