# Phase 3.2 : Architecture de Sécurité
## MoroccoCheck - Spécifications de Sécurité Complètes

*Document créé le 16 janvier 2026*

---

## Table des Matières

1. [Principes de Sécurité](#1-principes-de-sécurité)
2. [Authentification et Autorisation](#2-authentification-et-autorisation)
3. [Chiffrement des Données](#3-chiffrement-des-données)
4. [Protection contre les Attaques](#4-protection-contre-les-attaques)
5. [Gestion des Sessions](#5-gestion-des-sessions)
6. [Sécurité des API](#6-sécurité-des-api)
7. [Conformité et Audit](#7-conformité-et-audit)
8. [Plan de Réponse aux Incidents](#8-plan-de-réponse-aux-incidents)

---

## 1. Principes de Sécurité

### 1.1 Principes Fondamentaux

#### Defense in Depth (Défense en Profondeur)

**Concept** : Plusieurs couches de sécurité indépendantes pour protéger les données et systèmes.

**Implémentation MoroccoCheck** :

```
Couche 1: Périmètre
├── CloudFlare DDoS Protection
├── WAF (Web Application Firewall)
└── Rate Limiting (CDN level)

Couche 2: Réseau
├── Load Balancer avec TLS Termination
├── VPC (Virtual Private Cloud)
└── Security Groups / Firewall Rules

Couche 3: Application
├── API Gateway Authentication
├── Input Validation (Joi)
├── Output Encoding
└── CORS Whitelist

Couche 4: Données
├── Database Encryption at Rest
├── Encrypted Backups
├── Access Control Lists
└── Audit Logging

Couche 5: Surveillance
├── Intrusion Detection (Sentry)
├── Log Monitoring (CloudWatch)
├── Anomaly Detection
└── Security Alerts
```

#### Least Privilege (Privilège Minimum)

**Principe** : Chaque utilisateur/service n'a que les permissions strictement nécessaires.

**Implémentation** :

```javascript
// Rôles et permissions granulaires
const PERMISSIONS = {
  TOURIST: [
    'sites:read',
    'reviews:read',
    'profile:read:own',
    'profile:update:own'
  ],
  
  CONTRIBUTOR: [
    'sites:read',
    'reviews:read',
    'reviews:create',
    'checkins:create',
    'photos:upload',
    'profile:read:own',
    'profile:update:own'
  ],
  
  PROFESSIONAL: [
    'sites:read',
    'sites:claim',
    'sites:update:own',
    'reviews:read',
    'reviews:respond:own',
    'analytics:read:own',
    'subscription:manage:own',
    'profile:read:own',
    'profile:update:own'
  ],
  
  MODERATOR: [
    'reviews:moderate',
    'checkins:validate',
    'photos:moderate',
    'sites:validate',
    'users:suspend'
  ],
  
  ADMIN: ['*'] // Tous les accès
};
```

#### Fail Secure (Échec Sécurisé)

**Principe** : En cas d'erreur, le système refuse l'accès par défaut.

**Exemples** :

```javascript
// ✅ CORRECT - Fail secure
function checkPermission(user, permission) {
  try {
    if (!user) return false;
    if (!user.permissions) return false;
    return user.permissions.includes(permission);
  } catch (error) {
    logError('Permission check failed', error);
    return false; // Refuse par défaut
  }
}

// ❌ INCORRECT - Fail insecure
function checkPermissionBad(user, permission) {
  try {
    return user.permissions.includes(permission);
  } catch (error) {
    return true; // DANGEREUX !
  }
}
```

#### Zero Trust (Confiance Zéro)

**Principe** : Ne faire confiance à aucune requête, même interne. Toujours vérifier.

**Implémentation** :

- ✅ Authentification requise pour TOUTES les requêtes sensibles
- ✅ Validation des tokens à chaque requête
- ✅ Vérification des permissions à chaque action
- ✅ Logs de toutes les actions sensibles
- ✅ Pas de "trusted zones" dans le réseau

---

## 2. Authentification et Autorisation

### 2.1 JWT (JSON Web Tokens)

#### Structure des Tokens

**Access Token** (courte durée - 15 minutes) :

```json
{
  "header": {
    "alg": "HS256",
    "typ": "JWT"
  },
  "payload": {
    "userId": 12345,
    "email": "user@example.com",
    "role": "CONTRIBUTOR",
    "permissions": [
      "sites:read",
      "reviews:create",
      "checkins:create"
    ],
    "iat": 1705417200,
    "exp": 1705418100,
    "jti": "a1b2c3d4-e5f6-4789-a0b1-c2d3e4f5a6b7"
  },
  "signature": "..."
}
```

**Refresh Token** (longue durée - 7 jours) :

```json
{
  "header": {
    "alg": "HS256",
    "typ": "JWT"
  },
  "payload": {
    "userId": 12345,
    "tokenId": "refresh_token_123abc",
    "iat": 1705417200,
    "exp": 1706022000,
    "type": "refresh"
  },
  "signature": "..."
}
```

#### Configuration JWT

```javascript
// Configuration sécurisée
const JWT_CONFIG = {
  accessToken: {
    secret: process.env.JWT_ACCESS_SECRET, // 256+ bits, aléatoire
    expiresIn: '15m',
    algorithm: 'HS256',
    issuer: 'moroccocheck.com',
    audience: 'moroccocheck-api'
  },
  
  refreshToken: {
    secret: process.env.JWT_REFRESH_SECRET, // Secret différent !
    expiresIn: '7d',
    algorithm: 'HS256',
    issuer: 'moroccocheck.com',
    audience: 'moroccocheck-api'
  }
};

// Génération token
function generateAccessToken(user) {
  return jwt.sign(
    {
      userId: user.id,
      email: user.email,
      role: user.role,
      permissions: PERMISSIONS[user.role],
      jti: uuidv4() // Token unique ID
    },
    JWT_CONFIG.accessToken.secret,
    {
      expiresIn: JWT_CONFIG.accessToken.expiresIn,
      algorithm: JWT_CONFIG.accessToken.algorithm,
      issuer: JWT_CONFIG.accessToken.issuer,
      audience: JWT_CONFIG.accessToken.audience
    }
  );
}
```

#### Validation JWT

```javascript
// Middleware de validation
async function validateJWT(req, res, next) {
  try {
    // 1. Extraire le token
    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({ error: 'No token provided' });
    }
    
    const token = authHeader.substring(7);
    
    // 2. Vérifier le token
    const decoded = jwt.verify(token, JWT_CONFIG.accessToken.secret, {
      algorithms: [JWT_CONFIG.accessToken.algorithm],
      issuer: JWT_CONFIG.accessToken.issuer,
      audience: JWT_CONFIG.accessToken.audience
    });
    
    // 3. Vérifier si le token est révoqué (Redis blacklist)
    const isRevoked = await redis.get(`revoked:${decoded.jti}`);
    if (isRevoked) {
      return res.status(401).json({ error: 'Token revoked' });
    }
    
    // 4. Charger l'utilisateur
    const user = await User.findById(decoded.userId);
    if (!user || user.status !== 'ACTIVE') {
      return res.status(401).json({ error: 'User not found or inactive' });
    }
    
    // 5. Attacher à la requête
    req.user = user;
    req.token = decoded;
    
    next();
  } catch (error) {
    if (error.name === 'TokenExpiredError') {
      return res.status(401).json({ error: 'Token expired' });
    }
    if (error.name === 'JsonWebTokenError') {
      return res.status(401).json({ error: 'Invalid token' });
    }
    return res.status(500).json({ error: 'Authentication failed' });
  }
}
```

#### Refresh Token Flow

```javascript
// Endpoint de refresh
router.post('/auth/refresh', async (req, res) => {
  try {
    const { refreshToken } = req.body;
    
    // 1. Valider le refresh token
    const decoded = jwt.verify(
      refreshToken,
      JWT_CONFIG.refreshToken.secret
    );
    
    // 2. Vérifier si le token existe en DB et n'est pas révoqué
    const session = await Session.findOne({
      where: {
        user_id: decoded.userId,
        refresh_token: refreshToken,
        is_active: true,
        expires_at: { [Op.gt]: new Date() }
      }
    });
    
    if (!session) {
      return res.status(401).json({ error: 'Invalid refresh token' });
    }
    
    // 3. Charger l'utilisateur
    const user = await User.findById(decoded.userId);
    if (!user || user.status !== 'ACTIVE') {
      return res.status(401).json({ error: 'User not found or inactive' });
    }
    
    // 4. Générer nouveau access token
    const newAccessToken = generateAccessToken(user);
    
    // 5. OPTIONNEL: Rotation du refresh token (plus sécurisé)
    const newRefreshToken = generateRefreshToken(user);
    await session.update({
      refresh_token: newRefreshToken,
      updated_at: new Date()
    });
    
    res.json({
      accessToken: newAccessToken,
      refreshToken: newRefreshToken
    });
    
  } catch (error) {
    res.status(401).json({ error: 'Refresh failed' });
  }
});
```

### 2.2 OAuth 2.0 Social Login

#### Google OAuth

**Flow** :

```
1. Client → Google Auth URL avec redirect_uri
2. User authentifie sur Google
3. Google → Redirect vers notre app avec code
4. Backend → Exchange code pour Google tokens
5. Backend → Récupère user info de Google
6. Backend → Crée/met à jour user dans DB
7. Backend → Génère JWT tokens
8. Backend → Retourne tokens au client
```

**Implémentation** :

```javascript
// Configuration Google OAuth
const GOOGLE_CONFIG = {
  clientId: process.env.GOOGLE_CLIENT_ID,
  clientSecret: process.env.GOOGLE_CLIENT_SECRET,
  redirectUri: process.env.GOOGLE_REDIRECT_URI,
  scope: [
    'https://www.googleapis.com/auth/userinfo.email',
    'https://www.googleapis.com/auth/userinfo.profile'
  ]
};

// Endpoint callback Google
router.get('/auth/google/callback', async (req, res) => {
  try {
    const { code } = req.query;
    
    // 1. Exchange code for tokens
    const tokenResponse = await axios.post(
      'https://oauth2.googleapis.com/token',
      {
        code,
        client_id: GOOGLE_CONFIG.clientId,
        client_secret: GOOGLE_CONFIG.clientSecret,
        redirect_uri: GOOGLE_CONFIG.redirectUri,
        grant_type: 'authorization_code'
      }
    );
    
    const { access_token } = tokenResponse.data;
    
    // 2. Get user info
    const userInfo = await axios.get(
      'https://www.googleapis.com/oauth2/v2/userinfo',
      { headers: { Authorization: `Bearer ${access_token}` } }
    );
    
    const { id, email, given_name, family_name, picture } = userInfo.data;
    
    // 3. Find or create user
    let user = await User.findOne({ where: { google_id: id } });
    
    if (!user) {
      // Vérifier si email existe déjà
      const existingUser = await User.findOne({ where: { email } });
      if (existingUser) {
        // Lier le compte Google à l'utilisateur existant
        user = await existingUser.update({ google_id: id });
      } else {
        // Créer nouveau utilisateur
        user = await User.create({
          google_id: id,
          email,
          first_name: given_name,
          last_name: family_name,
          profile_picture: picture,
          is_email_verified: true, // Google vérifie les emails
          role: 'TOURIST',
          status: 'ACTIVE'
        });
      }
    }
    
    // 4. Générer nos JWT tokens
    const accessToken = generateAccessToken(user);
    const refreshToken = generateRefreshToken(user);
    
    // 5. Créer session
    await Session.create({
      user_id: user.id,
      refresh_token: refreshToken,
      device_type: 'WEB',
      ip_address: req.ip,
      expires_at: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000)
    });
    
    // 6. Rediriger vers le frontend avec tokens
    res.redirect(
      `${process.env.FRONTEND_URL}/auth/callback?` +
      `access_token=${accessToken}&refresh_token=${refreshToken}`
    );
    
  } catch (error) {
    logError('Google OAuth failed', error);
    res.redirect(`${process.env.FRONTEND_URL}/auth/error`);
  }
});
```

#### Facebook OAuth

```javascript
// Configuration similaire à Google
const FACEBOOK_CONFIG = {
  appId: process.env.FACEBOOK_APP_ID,
  appSecret: process.env.FACEBOOK_APP_SECRET,
  redirectUri: process.env.FACEBOOK_REDIRECT_URI,
  scope: ['email', 'public_profile']
};

// Flow identique avec URLs Facebook
```

#### Apple Sign In

```javascript
// Configuration Apple
const APPLE_CONFIG = {
  clientId: process.env.APPLE_CLIENT_ID,
  teamId: process.env.APPLE_TEAM_ID,
  keyId: process.env.APPLE_KEY_ID,
  privateKey: process.env.APPLE_PRIVATE_KEY,
  redirectUri: process.env.APPLE_REDIRECT_URI
};

// Apple utilise JWT pour l'authentification (plus complexe)
```

### 2.3 Autorisation RBAC

#### Middleware de Vérification des Permissions

```javascript
// Middleware généralisé
function requirePermission(permission) {
  return async (req, res, next) => {
    try {
      // L'utilisateur doit être authentifié d'abord
      if (!req.user) {
        return res.status(401).json({ error: 'Authentication required' });
      }
      
      // Vérifier la permission
      const hasPermission = req.token.permissions.includes(permission) ||
                           req.token.permissions.includes('*');
      
      if (!hasPermission) {
        return res.status(403).json({
          error: 'Insufficient permissions',
          required: permission
        });
      }
      
      next();
    } catch (error) {
      res.status(500).json({ error: 'Authorization failed' });
    }
  };
}

// Utilisation
router.post(
  '/sites',
  validateJWT,
  requirePermission('sites:create'),
  SiteController.create
);

router.put(
  '/sites/:id',
  validateJWT,
  requirePermission('sites:update'),
  checkSiteOwnership, // Middleware additionnel
  SiteController.update
);
```

#### Vérification de Propriété

```javascript
// Middleware pour vérifier que l'utilisateur est propriétaire
async function checkSiteOwnership(req, res, next) {
  try {
    const { id } = req.params;
    const site = await TouristSite.findById(id);
    
    if (!site) {
      return res.status(404).json({ error: 'Site not found' });
    }
    
    // Admins peuvent tout modifier
    if (req.user.role === 'ADMIN') {
      req.site = site;
      return next();
    }
    
    // Professionnels peuvent modifier leurs sites
    if (site.owner_id !== req.user.id) {
      return res.status(403).json({
        error: 'You can only modify your own sites'
      });
    }
    
    req.site = site;
    next();
  } catch (error) {
    res.status(500).json({ error: 'Ownership check failed' });
  }
}
```

---

## 3. Chiffrement des Données

### 3.1 Données en Transit (TLS/SSL)

#### Configuration TLS 1.3

**Nginx Configuration** :

```nginx
server {
    listen 443 ssl http2;
    server_name api.moroccocheck.com;
    
    # Certificats SSL (Let's Encrypt)
    ssl_certificate /etc/letsencrypt/live/api.moroccocheck.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/api.moroccocheck.com/privkey.pem;
    
    # TLS 1.3 uniquement (TLS 1.2 en fallback)
    ssl_protocols TLSv1.3 TLSv1.2;
    
    # Ciphers sécurisés
    ssl_ciphers 'TLS_AES_128_GCM_SHA256:TLS_AES_256_GCM_SHA384:TLS_CHACHA20_POLY1305_SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384';
    ssl_prefer_server_ciphers on;
    
    # HSTS (HTTP Strict Transport Security)
    add_header Strict-Transport-Security "max-age=63072000; includeSubDomains; preload" always;
    
    # Autres headers de sécurité
    add_header X-Frame-Options "DENY" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header Referrer-Policy "strict-origin-when-cross-origin" always;
    
    # OCSP Stapling
    ssl_stapling on;
    ssl_stapling_verify on;
    
    location / {
        proxy_pass http://localhost:3000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}

# Redirect HTTP to HTTPS
server {
    listen 80;
    server_name api.moroccocheck.com;
    return 301 https://$server_name$request_uri;
}
```

### 3.2 Données au Repos

#### Hachage des Mots de Passe (Bcrypt)

```javascript
const bcrypt = require('bcrypt');

// Configuration
const BCRYPT_ROUNDS = 10; // 2^10 itérations (~100ms sur serveur moderne)

// Hash password lors de l'inscription
async function hashPassword(plainPassword) {
  // Validation
  if (!plainPassword || plainPassword.length < 8) {
    throw new Error('Password must be at least 8 characters');
  }
  
  // Générer salt et hash
  const salt = await bcrypt.genSalt(BCRYPT_ROUNDS);
  const hash = await bcrypt.hash(plainPassword, salt);
  
  return hash;
}

// Vérification lors de la connexion
async function verifyPassword(plainPassword, hash) {
  return await bcrypt.compare(plainPassword, hash);
}

// Utilisation
async function registerUser(email, password, firstName, lastName) {
  const passwordHash = await hashPassword(password);
  
  const user = await User.create({
    email,
    password_hash: passwordHash,
    first_name: firstName,
    last_name: lastName
  });
  
  return user;
}

async function loginUser(email, password) {
  const user = await User.findOne({ where: { email } });
  
  if (!user) {
    throw new Error('Invalid credentials');
  }
  
  const isValid = await verifyPassword(password, user.password_hash);
  
  if (!isValid) {
    throw new Error('Invalid credentials');
  }
  
  return user;
}
```

#### Chiffrement des Données Sensibles (AES-256-GCM)

```javascript
const crypto = require('crypto');

// Configuration
const ALGORITHM = 'aes-256-gcm';
const KEY = Buffer.from(process.env.ENCRYPTION_KEY, 'hex'); // 32 bytes
const IV_LENGTH = 12; // 96 bits pour GCM
const AUTH_TAG_LENGTH = 16; // 128 bits

// Chiffrement
function encrypt(plaintext) {
  // Générer IV aléatoire
  const iv = crypto.randomBytes(IV_LENGTH);
  
  // Créer cipher
  const cipher = crypto.createCipheriv(ALGORITHM, KEY, iv);
  
  // Chiffrer
  let ciphertext = cipher.update(plaintext, 'utf8', 'hex');
  ciphertext += cipher.final('hex');
  
  // Récupérer auth tag
  const authTag = cipher.getAuthTag();
  
  // Retourner IV + AuthTag + Ciphertext (tout en hex)
  return iv.toString('hex') + authTag.toString('hex') + ciphertext;
}

// Déchiffrement
function decrypt(encryptedData) {
  // Extraire IV, AuthTag, Ciphertext
  const iv = Buffer.from(encryptedData.slice(0, IV_LENGTH * 2), 'hex');
  const authTag = Buffer.from(
    encryptedData.slice(IV_LENGTH * 2, (IV_LENGTH + AUTH_TAG_LENGTH) * 2),
    'hex'
  );
  const ciphertext = encryptedData.slice((IV_LENGTH + AUTH_TAG_LENGTH) * 2);
  
  // Créer decipher
  const decipher = crypto.createDecipheriv(ALGORITHM, KEY, iv);
  decipher.setAuthTag(authTag);
  
  // Déchiffrer
  let plaintext = decipher.update(ciphertext, 'hex', 'utf8');
  plaintext += decipher.final('utf8');
  
  return plaintext;
}

// Utilisation pour données sensibles
async function storePaymentMethod(userId, cardData) {
  const encryptedCardNumber = encrypt(cardData.cardNumber);
  const encryptedCVV = encrypt(cardData.cvv);
  
  await PaymentMethod.create({
    user_id: userId,
    card_number_encrypted: encryptedCardNumber,
    cvv_encrypted: encryptedCVV,
    expiry_month: cardData.expiryMonth,
    expiry_year: cardData.expiryYear
  });
}
```

#### Chiffrement Base de Données (MySQL)

```sql
-- Activer le chiffrement au repos (MySQL 8.0+)
ALTER INSTANCE ROTATE INNODB MASTER KEY;

-- Chiffrer une table spécifique
CREATE TABLE sensitive_data (
    id INT PRIMARY KEY,
    data TEXT
) ENCRYPTION='Y';

-- Ou pour une table existante
ALTER TABLE users ENCRYPTION='Y';
```

---

## 4. Protection contre les Attaques

### 4.1 Injection SQL

**Protection** : **Uniquement des requêtes préparées (Prepared Statements)**

```javascript
// ❌ DANGEREUX - Injection SQL possible
async function getUserByEmailBad(email) {
  const query = `SELECT * FROM users WHERE email = '${email}'`;
  const [rows] = await db.query(query);
  return rows[0];
}
// Attaque: email = "' OR '1'='1"

// ✅ CORRECT - Requête préparée
async function getUserByEmail(email) {
  const query = 'SELECT * FROM users WHERE email = ?';
  const [rows] = await db.query(query, [email]);
  return rows[0];
}

// ✅ CORRECT - Avec ORM (Sequelize)
async function getUserByEmailORM(email) {
  return await User.findOne({ where: { email } });
}
```

### 4.2 Cross-Site Scripting (XSS)

**Protection** :

1. **Output Encoding** (échappement automatique)
2. **Content Security Policy (CSP)**
3. **Sanitization des inputs**

```javascript
// 1. Sanitization des inputs
const validator = require('validator');

function sanitizeInput(input) {
  if (typeof input !== 'string') return input;
  
  // Échapper HTML
  return validator.escape(input);
}

// Validation Joi avec sanitization
const reviewSchema = Joi.object({
  title: Joi.string()
    .max(255)
    .required()
    .custom((value, helpers) => {
      return sanitizeInput(value);
    }),
  content: Joi.string()
    .min(20)
    .max(2000)
    .required()
    .custom((value, helpers) => {
      return sanitizeInput(value);
    })
});

// 2. CSP Headers
app.use((req, res, next) => {
  res.setHeader(
    'Content-Security-Policy',
    "default-src 'self'; " +
    "script-src 'self' 'unsafe-inline' https://cdnjs.cloudflare.com; " +
    "style-src 'self' 'unsafe-inline'; " +
    "img-src 'self' data: https:; " +
    "font-src 'self' data:; " +
    "connect-src 'self' https://api.moroccocheck.com; " +
    "frame-ancestors 'none';"
  );
  next();
});
```

### 4.3 Cross-Site Request Forgery (CSRF)

**Protection** : CSRF Tokens (Double Submit Cookie)

```javascript
const csrf = require('csurf');

// Configuration CSRF
const csrfProtection = csrf({
  cookie: {
    httpOnly: true,
    secure: true, // HTTPS uniquement
    sameSite: 'strict'
  }
});

// Appliquer aux routes modifiant l'état
app.use('/api', csrfProtection);

// Endpoint pour obtenir le token
app.get('/api/csrf-token', (req, res) => {
  res.json({ csrfToken: req.csrfToken() });
});

// Les requêtes POST/PUT/DELETE doivent inclure le token
// Header: X-CSRF-Token: <token>
// Ou dans le body: _csrf: <token>
```

### 4.4 Rate Limiting

**Protection** : Limitation du nombre de requêtes par IP/utilisateur

```javascript
const rateLimit = require('express-rate-limit');
const RedisStore = require('rate-limit-redis');

// Rate limiter global (100 requêtes / 15 minutes)
const globalLimiter = rateLimit({
  store: new RedisStore({
    client: redisClient,
    prefix: 'rl:global:'
  }),
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100, // 100 requêtes
  message: 'Too many requests, please try again later',
  standardHeaders: true,
  legacyHeaders: false
});

// Rate limiter strict pour login (5 tentatives / 15 minutes)
const loginLimiter = rateLimit({
  store: new RedisStore({
    client: redisClient,
    prefix: 'rl:login:'
  }),
  windowMs: 15 * 60 * 1000,
  max: 5,
  skipSuccessfulRequests: true, // Ne compte que les échecs
  message: 'Too many login attempts, please try again in 15 minutes'
});

// Rate limiter pour l'API (par utilisateur authentifié)
const apiLimiter = rateLimit({
  store: new RedisStore({
    client: redisClient,
    prefix: 'rl:api:'
  }),
  windowMs: 60 * 1000, // 1 minute
  max: 60, // 60 requêtes/minute
  keyGenerator: (req) => {
    return req.user ? req.user.id.toString() : req.ip;
  }
});

// Application
app.use('/api', globalLimiter);
app.post('/auth/login', loginLimiter, AuthController.login);
app.use('/api/*', validateJWT, apiLimiter);
```

### 4.5 DDoS Protection

**Protection multi-niveaux** :

```
Niveau 1: CloudFlare
├── DDoS mitigation automatique
├── Challenge pages pour trafic suspect
└── Geo-blocking si nécessaire

Niveau 2: Load Balancer (Nginx)
├── Connection limiting
├── Request rate limiting
└── Timeout configuration

Niveau 3: Application
├── Rate limiting (Express)
├── Request size limits
└── Slow loris protection
```

**Configuration Nginx** :

```nginx
http {
    # Limiter les connexions par IP
    limit_conn_zone $binary_remote_addr zone=addr:10m;
    limit_conn addr 10; # Max 10 connexions simultanées par IP
    
    # Limiter les requêtes par IP
    limit_req_zone $binary_remote_addr zone=api:10m rate=10r/s;
    limit_req zone=api burst=20 nodelay;
    
    # Taille max des requêtes
    client_max_body_size 10M;
    client_body_buffer_size 128k;
    
    # Timeouts
    client_body_timeout 12s;
    client_header_timeout 12s;
    send_timeout 10s;
}
```

---

## 5. Gestion des Sessions

### 5.1 Stockage des Sessions (Redis)

```javascript
// Structure de session dans Redis
const SESSION_KEY_PREFIX = 'session:';

async function createSession(user, deviceInfo) {
  const sessionId = uuidv4();
  const refreshToken = generateRefreshToken(user);
  
  const session = {
    id: sessionId,
    user_id: user.id,
    refresh_token: refreshToken,
    device_type: deviceInfo.type,
    device_name: deviceInfo.name,
    ip_address: deviceInfo.ip,
    user_agent: deviceInfo.userAgent,
    created_at: new Date().toISOString(),
    last_activity_at: new Date().toISOString(),
    expires_at: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000).toISOString()
  };
  
  // Stocker en Redis avec TTL de 7 jours
  await redis.setex(
    `${SESSION_KEY_PREFIX}${sessionId}`,
    7 * 24 * 60 * 60,
    JSON.stringify(session)
  );
  
  // Stocker aussi en MySQL pour persistence
  await Session.create(session);
  
  return { sessionId, refreshToken };
}

// Invalider session (logout)
async function revokeSession(sessionId) {
  // Supprimer de Redis
  await redis.del(`${SESSION_KEY_PREFIX}${sessionId}`);
  
  // Marquer comme inactive en MySQL
  await Session.update(
    { is_active: false },
    { where: { id: sessionId } }
  );
}

// Invalider toutes les sessions d'un utilisateur
async function revokeAllUserSessions(userId) {
  const sessions = await Session.findAll({
    where: { user_id: userId, is_active: true }
  });
  
  for (const session of sessions) {
    await redis.del(`${SESSION_KEY_PREFIX}${session.id}`);
  }
  
  await Session.update(
    { is_active: false },
    { where: { user_id: userId } }
  );
}
```

### 5.2 Token Revocation (Blacklist)

```javascript
// Révoquer un access token spécifique
async function revokeAccessToken(jti, expiresIn) {
  // Ajouter le JTI à la blacklist Redis
  // TTL = temps restant jusqu'à expiration naturelle
  await redis.setex(`revoked:${jti}`, expiresIn, '1');
}

// Vérifier si un token est révoqué (dans le middleware)
async function isTokenRevoked(jti) {
  const revoked = await redis.get(`revoked:${jti}`);
  return revoked === '1';
}
```

---

## 6. Sécurité des API

### 6.1 CORS (Cross-Origin Resource Sharing)

```javascript
const cors = require('cors');

// Configuration CORS stricte
const corsOptions = {
  origin: function (origin, callback) {
    // Whitelist des origines autorisées
    const whitelist = [
      'https://moroccocheck.com',
      'https://www.moroccocheck.com',
      'https://admin.moroccocheck.com',
      process.env.NODE_ENV === 'development' ? 'http://localhost:3001' : null
    ].filter(Boolean);
    
    if (!origin || whitelist.indexOf(origin) !== -1) {
      callback(null, true);
    } else {
      callback(new Error('Not allowed by CORS'));
    }
  },
  credentials: true, // Permettre les cookies
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: [
    'Content-Type',
    'Authorization',
    'X-CSRF-Token',
    'X-Requested-With'
  ],
  exposedHeaders: ['X-Total-Count', 'X-Page'],
  maxAge: 600 // Cache preflight 10 minutes
};

app.use(cors(corsOptions));
```

### 6.2 Input Validation

```javascript
const Joi = require('joi');

// Schémas de validation
const schemas = {
  // Inscription
  register: Joi.object({
    email: Joi.string().email().required(),
    password: Joi.string()
      .min(8)
      .max(128)
      .pattern(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]/)
      .required()
      .messages({
        'string.pattern.base': 'Password must contain uppercase, lowercase, number and special character'
      }),
    firstName: Joi.string().min(2).max(100).required(),
    lastName: Joi.string().min(2).max(100).required(),
    phoneNumber: Joi.string()
      .pattern(/^\+?[1-9]\d{1,14}$/)
      .optional()
  }),
  
  // Check-in
  createCheckin: Joi.object({
    siteId: Joi.number().integer().positive().required(),
    status: Joi.string()
      .valid('OPEN', 'CLOSED_TEMPORARILY', 'CLOSED_PERMANENTLY', 'RENOVATING', 'RELOCATED', 'NO_CHANGE')
      .required(),
    comment: Joi.string().max(500).optional(),
    latitude: Joi.number().min(27).max(36).required(), // Maroc
    longitude: Joi.number().min(-13).max(-1).required(),
    accuracy: Joi.number().min(0).required()
  }),
  
  // Avis
  createReview: Joi.object({
    siteId: Joi.number().integer().positive().required(),
    overallRating: Joi.number().min(1).max(5).precision(1).required(),
    serviceRating: Joi.number().min(1).max(5).precision(1).optional(),
    cleanlinessRating: Joi.number().min(1).max(5).precision(1).optional(),
    valueRating: Joi.number().min(1).max(5).precision(1).optional(),
    locationRating: Joi.number().min(1).max(5).precision(1).optional(),
    title: Joi.string().max(255).optional(),
    content: Joi.string().min(20).max(2000).required(),
    visitDate: Joi.date().max('now').optional(),
    visitType: Joi.string()
      .valid('BUSINESS', 'COUPLE', 'FAMILY', 'FRIENDS', 'SOLO')
      .optional()
  })
};

// Middleware de validation
function validate(schema) {
  return (req, res, next) => {
    const { error, value } = schema.validate(req.body, {
      abortEarly: false, // Retourner toutes les erreurs
      stripUnknown: true // Supprimer les champs inconnus
    });
    
    if (error) {
      const errors = error.details.map(detail => ({
        field: detail.path.join('.'),
        message: detail.message
      }));
      
      return res.status(400).json({
        success: false,
        error: {
          code: 'VALIDATION_ERROR',
          message: 'Invalid input data',
          details: errors
        }
      });
    }
    
    req.validatedData = value;
    next();
  };
}

// Utilisation
router.post('/auth/register', validate(schemas.register), AuthController.register);
router.post('/checkins', validateJWT, validate(schemas.createCheckin), CheckinController.create);
```

---

## 7. Conformité et Audit

### 7.1 Logging de Sécurité

```javascript
const winston = require('winston');

// Configuration logger
const securityLogger = winston.createLogger({
  level: 'info',
  format: winston.format.combine(
    winston.format.timestamp(),
    winston.format.json()
  ),
  defaultMeta: { service: 'security' },
  transports: [
    new winston.transports.File({ filename: 'logs/security.log' }),
    new winston.transports.File({ filename: 'logs/security-error.log', level: 'error' })
  ]
});

// Events à logger
function logSecurityEvent(event) {
  securityLogger.info({
    event: event.type,
    userId: event.userId,
    ip: event.ip,
    userAgent: event.userAgent,
    timestamp: new Date().toISOString(),
    details: event.details
  });
}

// Exemples d'événements
const SECURITY_EVENTS = {
  LOGIN_SUCCESS: 'login_success',
  LOGIN_FAILED: 'login_failed',
  PASSWORD_CHANGED: 'password_changed',
  EMAIL_VERIFIED: 'email_verified',
  ACCOUNT_LOCKED: 'account_locked',
  PERMISSION_DENIED: 'permission_denied',
  TOKEN_REVOKED: 'token_revoked',
  SUSPICIOUS_ACTIVITY: 'suspicious_activity'
};

// Utilisation
async function login(req, res) {
  try {
    const { email, password } = req.body;
    const user = await loginUser(email, password);
    
    logSecurityEvent({
      type: SECURITY_EVENTS.LOGIN_SUCCESS,
      userId: user.id,
      ip: req.ip,
      userAgent: req.get('user-agent')
    });
    
    // ...
  } catch (error) {
    logSecurityEvent({
      type: SECURITY_EVENTS.LOGIN_FAILED,
      ip: req.ip,
      userAgent: req.get('user-agent'),
      details: { email: req.body.email }
    });
    
    // ...
  }
}
```

### 7.2 RGPD / Conformité

**Droits des utilisateurs** :

1. **Droit d'accès** - Export de toutes les données
2. **Droit de rectification** - Modification des données
3. **Droit à l'effacement** - Suppression du compte
4. **Droit à la portabilité** - Export JSON
5. **Droit d'opposition** - Opt-out marketing

```javascript
// Export des données utilisateur (RGPD)
async function exportUserData(userId) {
  const user = await User.findById(userId);
  const checkins = await Checkin.findAll({ where: { user_id: userId } });
  const reviews = await Review.findAll({ where: { user_id: userId } });
  const photos = await Photo.findAll({ where: { user_id: userId } });
  const badges = await UserBadge.findAll({ where: { user_id: userId } });
  
  return {
    user: {
      id: user.id,
      email: user.email,
      firstName: user.first_name,
      lastName: user.last_name,
      createdAt: user.created_at
    },
    checkins: checkins.map(c => ({
      siteId: c.site_id,
      date: c.created_at,
      comment: c.comment
    })),
    reviews: reviews.map(r => ({
      siteId: r.site_id,
      rating: r.overall_rating,
      content: r.content,
      date: r.created_at
    })),
    photos: photos.map(p => ({
      url: p.url,
      date: p.created_at
    })),
    badges: badges.map(b => ({
      badgeId: b.badge_id,
      earnedAt: b.earned_at
    }))
  };
}

// Suppression du compte (soft delete + anonymisation)
async function deleteUserAccount(userId) {
  const user = await User.findById(userId);
  
  // Anonymiser les données
  await user.update({
    email: `deleted_${userId}@deleted.com`,
    first_name: 'Deleted',
    last_name: 'User',
    phone_number: null,
    profile_picture: null,
    bio: null,
    google_id: null,
    facebook_id: null,
    apple_id: null,
    status: 'DELETED',
    deleted_at: new Date()
  });
  
  // Garder les avis/check-ins pour statistiques mais anonymisés
  // Supprimer les sessions
  await Session.destroy({ where: { user_id: userId } });
  
  // Supprimer les tokens
  await revokeAllUserSessions(userId);
}
```

---

## 8. Plan de Réponse aux Incidents

### 8.1 Détection

**Monitoring continu** :

- Logs de sécurité en temps réel (CloudWatch)
- Alertes anomalies (Sentry, Datadog)
- Scan de vulnérabilités (Snyk, npm audit)

### 8.2 Procédure d'Incident

```
1. DÉTECTION
   - Alerting automatique
   - Notification équipe sécurité
   
2. ÉVALUATION
   - Analyser la gravité (P0-P4)
   - Identifier l'ampleur
   
3. CONTAINMENT
   - Isoler le système affecté
   - Bloquer l'attaquant (IP, compte)
   - Révoquer tokens compromis
   
4. ÉRADICATION
   - Corriger la vulnérabilité
   - Deployer le patch
   
5. RÉCUPÉRATION
   - Restaurer les services
   - Vérifier l'intégrité des données
   
6. POST-MORTEM
   - Documenter l'incident
   - Améliorer les défenses
   - Communication si nécessaire
```

### 8.3 Contacts d'Urgence

```
Security Team:
- Email: security@moroccocheck.com
- Slack: #security-alerts
- On-call: +212 XXX XXX XXX

Escalation:
- CTO: +212 XXX XXX XXX
- CEO: +212 XXX XXX XXX
```

---

## Conclusion

Cette architecture de sécurité assure :

✅ **Authentification robuste** - JWT + OAuth 2.0 + MFA
✅ **Autorisation granulaire** - RBAC avec permissions fines
✅ **Chiffrement end-to-end** - TLS 1.3 + AES-256-GCM
✅ **Protection OWASP Top 10** - SQL Injection, XSS, CSRF, etc.
✅ **Rate Limiting** - Multi-niveaux
✅ **Audit complet** - Logging de tous les événements de sécurité
✅ **Conformité RGPD** - Export et suppression des données
✅ **Réponse rapide** - Plan d'incident structuré

---

**Document créé le 16 janvier 2026**  
**MoroccoCheck - Phase 3.2 : Architecture de Sécurité**  
**Version 1.0 - Complet**
