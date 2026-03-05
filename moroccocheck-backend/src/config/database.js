import mysql from 'mysql2/promise';
import dotenv from 'dotenv';

// Charger les variables d'environnement
dotenv.config();

// Configuration du pool de connexions MySQL
const pool = mysql.createPool({
  host: process.env.DB_HOST || 'localhost',
  user: process.env.DB_USER || 'root',
  password: process.env.DB_PASSWORD || '',
  database: process.env.DB_NAME || 'moroccocheck',
  port: process.env.DB_PORT || 3306,
  connectionLimit: 10,
  waitForConnections: true,
  queueLimit: 0,
  enableKeepAlive: true,
  keepAliveInitialDelay: 0
});

// Tester la connexion au démarrage
try {
  const connection = await pool.getConnection();
  console.log(`✅ Connexion réussie à la base de données: ${process.env.DB_NAME || 'moroccocheck'}`);
  connection.release();
} catch (error) {
  console.error(`❌ Erreur de connexion à la base de données: ${error.message}`);
  process.exit(1);
}

// Exporter le pool
export default pool;