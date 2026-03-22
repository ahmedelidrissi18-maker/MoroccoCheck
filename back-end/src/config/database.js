import mysql from 'mysql2/promise';
import dotenv from 'dotenv';

dotenv.config();

const pool = mysql.createPool({
  host: process.env.DB_HOST || 'localhost',
  user: process.env.DB_USER || 'root',
  password: process.env.DB_PASSWORD || '',
  database: process.env.DB_NAME || 'moroccocheck',
  port: Number(process.env.DB_PORT || 3306),
  connectionLimit: 10,
  waitForConnections: true,
  queueLimit: 0,
  enableKeepAlive: true,
  keepAliveInitialDelay: 0
});

try {
  const connection = await pool.getConnection();
  console.log(`Database connected: ${process.env.DB_NAME || 'moroccocheck'}`);
  connection.release();
} catch (error) {
  console.error(`Database connection failed: ${error.message}`);
  const shouldExit =
    process.env.NODE_ENV !== 'test' &&
    process.env.DB_EXIT_ON_FAILURE !== 'false';

  if (shouldExit) {
    process.exit(1);
  }
}

export default pool;
