# Phase 3.1 : Architecture Système et Sécurité
## MoroccoCheck - Spécifications Techniques

*Document créé le 16 janvier 2026*

---

## Table des Matières

1. [Architecture Système Globale](#1-architecture-système-globale)
2. [Architecture Backend](#2-architecture-backend)
3. [Architecture Frontend](#3-architecture-frontend)
4. [Architecture de Sécurité](#4-architecture-de-sécurité)
5. [Architecture de Déploiement](#5-architecture-de-déploiement)
6. [Gestion des Sessions](#6-gestion-des-sessions)

---

## 1. Architecture Système Globale

### 1.1 Vue d'Ensemble

```
┌─────────────────────────────────────────────────────────────────┐
│                         COUCHE CLIENT                            │
│  ┌──────────────┐  ┌──────────────┐  ┌─────────────────────┐   │
│  │   iOS App    │  │ Android App  │  │  Admin Web Panel    │   │
│  │   Flutter    │  │   Flutter    │  │   React.js/Next.js  │   │
│  └──────┬───────┘  └──────┬───────┘  └──────────┬──────────┘   │
└─────────┼──────────────────┼──────────────────────┼──────────────┘
          │                  │                      │
          └──────────────────┴──────────────────────┘
                             │
                    HTTPS / TLS 1.3
                             │
┌────────────────────────────┼──────────────────────────────────────┐
│                            ▼                                      │
│                   ┌─────────────────┐                            │
│                   │  Load Balancer  │                            │
│                   │   Nginx/HAProxy │                            │
│                   │  - SSL Termination                           │
│                   │  - Rate Limiting                             │
│                   │  - DDoS Protection                           │
│                   └────────┬────────┘                            │
│                            │                                      │
│                   ┌────────▼────────┐                            │
│                   │   API Gateway   │                            │
│                   │   Express.js    │                            │
│                   │  - Auth Check                                │
│                   │  - Request Validation                        │
│                   │  - Response Formatting                       │
│                   └────────┬────────┘                            │
│                            │                                      │
│         ┌──────────────────┼──────────────────┐                 │
│         │                  │                  │                 │
│  ┌──────▼──────┐   ┌──────▼──────┐   ┌──────▼──────┐          │
│  │Auth Service │   │Core Service │   │Admin Service│          │
│  │  Node.js    │   │  Node.js    │   │  Node.js    │          │
│  │             │   │             │   │             │          │
│  │- Register   │   │- Sites      │   │- Moderation │          │
│  │- Login      │   │- Check-ins  │   │- Analytics  │          │
│  │- OAuth      │   │- Reviews    │   │- Reports    │          │
│  │- Sessions   │   │- Gamification│   │- Config     │          │
│  └──────┬──────┘   └──────┬──────┘   └──────┬──────┘          │
│         │                  │                  │                 │
│         └──────────────────┴──────────────────┘                 │
│                            │                                      │
│  ┌─────────────────────────┼────────────────────────────────┐   │
│  │                         │                                │   │
│  │  ┌──────────────────────▼───────────────────────┐       │   │
│  │  │         Data Access Layer (Repositories)      │       │   │
│  │  └──────────────────────┬───────────────────────┘       │   │
│  │                         │                                │   │
└──┼─────────────────────────┼────────────────────────────────┼───┘
   │                         │                                │
┌──▼─────────────────────────▼────────────────────────────────▼───┐
│                    COUCHE DONNÉES                                │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────────────┐  │
│  │MySQL Primary │  │ Redis Cache  │  │  Elasticsearch       │  │
│  │ (Write/Read) │  │ - Sessions   │  │  - Full-text Search  │  │
│  └──────┬───────┘  │ - Cache      │  └──────────────────────┘  │
│         │          │ - Rate Limit │                             │
│  ┌──────▼───────┐  │ - Queue      │  ┌──────────────────────┐  │
│  │MySQL Replica │  └──────────────┘  │  AWS S3 / Cloudinary │  │
│  │  (Read Only) │                    │  - Images            │  │
│  └──────────────┘                    │  - Documents         │  │
│                                      └──────────────────────┘  │
└──────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│                    SERVICES EXTERNES                             │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────────────┐  │
│  │ Google Maps  │  │    Stripe    │  │  Firebase FCM        │  │
│  │ - Geocoding  │  │ - Payments   │  │  - Push Notifications│  │
│  │ - Directions │  │ - Subscriptions│ └──────────────────────┘  │
│  └──────────────┘  └──────────────┘                             │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────────────┐  │
│  │  SendGrid    │  │   Twilio     │  │   Sentry/NewRelic    │  │
│  │ - Emails     │  │ - SMS/2FA    │  │  - Monitoring/Errors │  │
│  └──────────────┘  └──────────────┘  └──────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
```

### 1.2 Flux de Communication

**Requête typique d'un utilisateur** :

1. **Client** → Envoie requête HTTPS
2. **Load Balancer** → Vérifie rate limit, distribue la charge
3. **API Gateway** → Valide JWT, route vers service approprié
4. **Service** → Traite la logique métier
5. **Repository** → Accède aux données
6. **Cache** → Vérifie Redis avant DB
7. **Database** → Lecture (replica) ou écriture (primary)
8. **Service** → Formate la réponse
9. **API Gateway** → Ajoute métadonnées
10. **Client** → Reçoit réponse JSON

---

## 2. Architecture Backend

### 2.1 Structure en Couches

```
┌────────────────────────────────────────────────┐
│           PRESENTATION LAYER                   │
│  ┌──────────────────────────────────────────┐ │
│  │ Routes / Controllers                      │ │
│  │ - authRoutes.js                          │ │
│  │ - siteRoutes.js                          │ │
│  │ - checkinRoutes.js                       │ │
│  │ - reviewRoutes.js                        │ │
│  └──────────────────────────────────────────┘ │
└────────────────────────────────────────────────┘
                     │
┌────────────────────▼───────────────────────────┐
│         MIDDLEWARE LAYER                       │
│  ┌──────────────────────────────────────────┐ │
│  │ - Authentication (JWT Verify)            │ │
│  │ - Authorization (Role/Permission Check)  │ │
│  │ - Validation (Request Schema)            │ │
│  │ - Rate Limiting                          │ │
│  │ - Error Handling                         │ │
│  │ - Request Logging                        │ │
│  │ - File Upload (Multer)                   │ │
│  └──────────────────────────────────────────┘ │
└────────────────────────────────────────────────┘
                     │
┌────────────────────▼───────────────────────────┐
│           SERVICE LAYER                        │
│  ┌──────────────────────────────────────────┐ │
│  │ Business Logic Services                  │ │
│  │ - AuthService                            │ │
│  │ - SiteService                            │ │
│  │ - CheckInService                         │ │
│  │ - ReviewService                          │ │
│  │ - GamificationService                    │ │
│  │ - NotificationService                    │ │
│  │ - SubscriptionService                    │ │
│  │ - PaymentService (Stripe)                │ │
│  └──────────────────────────────────────────┘ │
└────────────────────────────────────────────────┘
                     │
┌────────────────────▼───────────────────────────┐
│         REPOSITORY LAYER                       │
│  ┌──────────────────────────────────────────┐ │
│  │ Data Access Repositories                 │ │
│  │ - UserRepository                         │ │
│  │ - SiteRepository                         │ │
│  │ - CheckInRepository                      │ │
│  │ - ReviewRepository                       │ │
│  │ - BadgeRepository                        │ │
│  └──────────────────────────────────────────┘ │
└────────────────────────────────────────────────┘
                     │
┌────────────────────▼───────────────────────────┐
│            DATA LAYER                          │
│  ┌──────────────────────────────────────────┐ │
│  │ - MySQL Connection Pool                  │ │
│  │ - Redis Client                           │ │
│  │ - Elasticsearch Client                   │ │
│  │ - AWS S3 SDK                             │ │
│  └──────────────────────────────────────────┘ │
└────────────────────────────────────────────────┘
```

### 2.2 Design Patterns Utilisés

#### 2.2.1 Repository Pattern

**Objectif** : Séparer la logique d'accès aux données de la logique métier

```javascript
// repositories/UserRepository.js
class UserRepository {
  constructor(dbPool) {
    this.db = dbPool;
  }

  async findById(userId) {
    const [rows] = await this.db.query(
      'SELECT * FROM users WHERE id = ?',
      [userId]
    );
    return rows[0] || null;
  }

  async findByEmail(email) {
    const [rows] = await this.db.query(
      'SELECT * FROM users WHERE email = ?',
      [email]
    );
    return rows[0] || null;
  }

  async create(userData) {
    const [result] = await this.db.query(
      'INSERT INTO users SET ?',
      [userData]
    );
    return result.insertId;
  }

  async update(userId, userData) {
    await this.db.query(
      'UPDATE users SET ? WHERE id = ?',
      [userData, userId]
    );
  }

  async delete(userId) {
    await this.db.query(
      'UPDATE users SET deleted_at = NOW() WHERE id = ?',
      [userId]
    );
  }
}

module.exports = UserRepository;
```

#### 2.2.2 Service Pattern

**Objectif** : Centraliser la logique métier

```javascript
// services/CheckInService.js
class CheckInService {
  constructor(checkInRepository, userRepository, siteRepository, gamificationService) {
    this.checkInRepo = checkInRepository;
    this.userRepo = userRepository;
    this.siteRepo = siteRepository;
    this.gamificationService = gamificationService;
  }

  async createCheckIn(userId, checkInData) {
    // 1. Valider le cooldown (1 check-in/site/jour)
    const lastCheckIn = await this.checkInRepo.findLastCheckIn(userId, checkInData.site_id);
    if (lastCheckIn && this.isToday(lastCheckIn.created_at)) {
      throw new Error('CHECK_IN_COOLDOWN');
    }

    // 2. Calculer la distance GPS
    const site = await this.siteRepo.findById(checkInData.site_id);
    const distance = this.calculateDistance(
      checkInData.latitude,
      checkInData.longitude,
      site.latitude,
      site.longitude
    );

    // 3. Valider la distance (max 100m)
    if (distance > 100) {
      throw new Error('DISTANCE_TOO_FAR');
    }

    // 4. Créer le check-in
    const points = checkInData.has_photo ? 15 : 10;
    const checkInId = await this.checkInRepo.create({
      ...checkInData,
      distance,
      points_earned: points,
      validation_status: 'APPROVED'
    });

    // 5. Mettre à jour les points de l'utilisateur
    await this.userRepo.incrementPoints(userId, points);

    // 6. Vérifier les badges
    const newBadges = await this.gamificationService.checkAndAwardBadges(userId);

    // 7. Mettre à jour le score de fraîcheur du site
    await this.siteRepo.updateFreshnessScore(checkInData.site_id);

    return {
      checkIn: await this.checkInRepo.findById(checkInId),
      pointsEarned: points,
      newBadges
    };
  }

  calculateDistance(lat1, lon1, lat2, lon2) {
    // Formule Haversine
    const R = 6371000; // Rayon de la Terre en mètres
    const φ1 = lat1 * Math.PI / 180;
    const φ2 = lat2 * Math.PI / 180;
    const Δφ = (lat2 - lat1) * Math.PI / 180;
    const Δλ = (lon2 - lon1) * Math.PI / 180;

    const a = Math.sin(Δφ / 2) * Math.sin(Δφ / 2) +
              Math.cos(φ1) * Math.cos(φ2) *
              Math.sin(Δλ / 2) * Math.sin(Δλ / 2);
    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));

    return R * c; // Distance en mètres
  }

  isToday(date) {
    const today = new Date();
    const checkDate = new Date(date);
    return checkDate.toDateString() === today.toDateString();
  }
}

module.exports = CheckInService;
```

#### 2.2.3 Dependency Injection

**Objectif** : Faciliter les tests et la maintenabilité

```javascript
// config/container.js
const mysql = require('mysql2/promise');
const redis = require('redis');

// Repositories
const UserRepository = require('../repositories/UserRepository');
const SiteRepository = require('../repositories/SiteRepository');
const CheckInRepository = require('../repositories/CheckInRepository');

// Services
const AuthService = require('../services/AuthService');
const CheckInService = require('../services/CheckInService');
const GamificationService = require('../services/GamificationService');

class Container {
  constructor() {
    this.services = {};
  }

  async initialize() {
    // Database connections
    this.dbPool = await mysql.createPool({
      host: process.env.DB_HOST,
      user: process.env.DB_USER,
      password: process.env.DB_PASSWORD,
      database: process.env.DB_NAME,
      waitForConnections: true,
      connectionLimit: 10,
      queueLimit: 0
    });

    this.redisClient = redis.createClient({
      host: process.env.REDIS_HOST,
      port: process.env.REDIS_PORT
    });

    // Repositories
    this.services.userRepository = new UserRepository(this.dbPool);
    this.services.siteRepository = new SiteRepository(this.dbPool);
    this.services.checkInRepository = new CheckInRepository(this.dbPool);

    // Services
    this.services.gamificationService = new GamificationService(
      this.services.userRepository,
      // ... autres dépendances
    );

    this.services.checkInService = new CheckInService(
      this.services.checkInRepository,
      this.services.userRepository,
      this.services.siteRepository,
      this.services.gamificationService
    );

    this.services.authService = new AuthService(
      this.services.userRepository,
      this.redisClient
    );
  }

  get(serviceName) {
    return this.services[serviceName];
  }
}

module.exports = new Container();
```

---

## 3. Architecture Frontend

### 3.1 Architecture Flutter (Clean Architecture)

```
lib/
├── main.dart                      # Point d'entrée de l'application
├── app.dart                       # Configuration de l'app
│
├── core/                          # Fonctionnalités transversales
│   ├── constants/
│   │   ├── app_constants.dart     # Constantes globales
│   │   ├── api_constants.dart     # URLs API
│   │   └── colors.dart            # Palette de couleurs
│   ├── theme/
│   │   ├── app_theme.dart         # Thème de l'application
│   │   └── text_styles.dart       # Styles de texte
│   ├── utils/
│   │   ├── validators.dart        # Validateurs de formulaire
│   │   ├── formatters.dart        # Formatage de données
│   │   └── helpers.dart           # Fonctions utilitaires
│   ├── config/
│   │   └── env_config.dart        # Configuration environnement
│   └── errors/
│       └── exceptions.dart        # Exceptions personnalisées
│
├── data/                          # Couche données
│   ├── models/                    # Modèles de données (DTOs)
│   │   ├── user_model.dart
│   │   ├── site_model.dart
│   │   ├── checkin_model.dart
│   │   └── review_model.dart
│   ├── repositories/              # Implémentation des repositories
│   │   ├── auth_repository_impl.dart
│   │   ├── site_repository_impl.dart
│   │   └── checkin_repository_impl.dart
│   ├── datasources/               # Sources de données
│   │   ├── remote/
│   │   │   ├── api_service.dart   # Client HTTP (Dio)
│   │   │   └── endpoints.dart     # Endpoints API
│   │   └── local/
│   │       ├── shared_prefs.dart  # SharedPreferences
│   │       ├── secure_storage.dart# Flutter Secure Storage
│   │       └── database.dart      # SQLite local
│   └── providers/                 # Providers pour injection
│       └── api_provider.dart
│
├── domain/                        # Couche métier (logique pure)
│   ├── entities/                  # Entités métier
│   │   ├── user.dart
│   │   ├── tourist_site.dart
│   │   ├── checkin.dart
│   │   └── review.dart
│   ├── repositories/              # Interfaces des repositories
│   │   ├── auth_repository.dart
│   │   ├── site_repository.dart
│   │   └── checkin_repository.dart
│   └── usecases/                  # Cas d'utilisation
│       ├── auth/
│       │   ├── login_usecase.dart
│       │   ├── register_usecase.dart
│       │   └── logout_usecase.dart
│       ├── checkin/
│       │   ├── create_checkin_usecase.dart
│       │   └── get_user_checkins_usecase.dart
│       └── site/
│           ├── get_nearby_sites_usecase.dart
│           └── search_sites_usecase.dart
│
├── presentation/                  # Couche présentation (UI)
│   ├── screens/                   # Écrans de l'application
│   │   ├── splash/
│   │   │   └── splash_screen.dart
│   │   ├── auth/
│   │   │   ├── login_screen.dart
│   │   │   ├── register_screen.dart
│   │   │   └── forgot_password_screen.dart
│   │   ├── home/
│   │   │   ├── home_screen.dart
│   │   │   └── widgets/
│   │   │       ├── site_card.dart
│   │   │       └── map_view.dart
│   │   ├── site_details/
│   │   │   ├── site_details_screen.dart
│   │   │   └── widgets/
│   │   ├── checkin/
│   │   │   └── checkin_screen.dart
│   │   ├── review/
│   │   │   └── review_screen.dart
│   │   └── profile/
│   │       └── profile_screen.dart
│   │
│   ├── widgets/                   # Widgets réutilisables
│   │   ├── common/
│   │   │   ├── app_button.dart
│   │   │   ├── app_text_field.dart
│   │   │   ├── loading_indicator.dart
│   │   │   └── error_widget.dart
│   │   ├── site/
│   │   │   ├── site_card.dart
│   │   │   └── site_rating.dart
│   │   └── navigation/
│   │       └── bottom_nav_bar.dart
│   │
│   └── providers/                 # State management (Provider/Riverpod)
│       ├── auth_provider.dart
│       ├── site_provider.dart
│       ├── checkin_provider.dart
│       └── theme_provider.dart
│
└── routes/                        # Gestion de la navigation
    ├── app_routes.dart            # Définition des routes
    └── route_generator.dart       # Générateur de routes
```

### 3.2 State Management Pattern

**Provider Pattern avec ChangeNotifier**

```dart
// presentation/providers/auth_provider.dart
import 'package:flutter/foundation.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/auth/login_usecase.dart';
import '../../domain/usecases/auth/logout_usecase.dart';

class AuthProvider extends ChangeNotifier {
  final LoginUseCase loginUseCase;
  final LogoutUseCase logoutUseCase;

  AuthProvider({
    required this.loginUseCase,
    required this.logoutUseCase,
  });

  User? _user;
  bool _isLoading = false;
  String? _errorMessage;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null;

  Future<void> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _user = await loginUseCase.execute(email, password);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await logoutUseCase.execute();
    _user = null;
    notifyListeners();
  }
}
```

---

## 4. Architecture de Sécurité

### 4.1 Authentification JWT

#### 4.1.1 Structure du Token

```javascript
// JWT Access Token
{
  "header": {
    "alg": "HS256",
    "typ": "JWT"
  },
  "payload": {
    "userId": 123,
    "email": "user@example.com",
    "role": "CONTRIBUTOR",
    "iat": 1673870400,        // Issued At
    "exp": 1673956800         // Expiration (24h)
  },
  "signature": "..."
}

// JWT Refresh Token
{
  "header": {
    "alg": "HS256",
    "typ": "JWT"
  },
  "payload": {
    "userId": 123,
    "sessionId": "550e8400-e29b-41d4-a716-446655440000",
    "iat": 1673870400,
    "exp": 1674475200         // Expiration (7 jours)
  },
  "signature": "..."
}
```

#### 4.1.2 Génération et Validation

```javascript
// utils/jwt.js
const jwt = require('jsonwebtoken');

class JWTService {
  generateAccessToken(user) {
    return jwt.sign(
      {
        userId: user.id,
        email: user.email,
        role: user.role
      },
      process.env.JWT_SECRET,
      { expiresIn: '24h' }
    );
  }

  generateRefreshToken(user, sessionId) {
    return jwt.sign(
      {
        userId: user.id,
        sessionId: sessionId
      },
      process.env.JWT_REFRESH_SECRET,
      { expiresIn: '7d' }
    );
  }

  verifyAccessToken(token) {
    try {
      return jwt.verify(token, process.env.JWT_SECRET);
    } catch (error) {
      throw new Error('INVALID_TOKEN');
    }
  }

  verifyRefreshToken(token) {
    try {
      return jwt.verify(token, process.env.JWT_REFRESH_SECRET);
    } catch (error) {
      throw new Error('INVALID_REFRESH_TOKEN');
    }
  }
}

module.exports = new JWTService();
```

#### 4.1.3 Middleware d'Authentification

```javascript
// middlewares/auth.js
const jwtService = require('../utils/jwt');
const UserRepository = require('../repositories/UserRepository');

const authenticate = async (req, res, next) => {
  try {
    // 1. Extraire le token du header Authorization
    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({
        success: false,
        error: {
          code: 'MISSING_TOKEN',
          message: 'Token d\'authentification manquant'
        }
      });
    }

    const token = authHeader.substring(7); // Enlever "Bearer "

    // 2. Vérifier et décoder le token
    const decoded = jwtService.verifyAccessToken(token);

    // 3. Charger l'utilisateur depuis la DB
    const userRepo = new UserRepository(req.app.locals.db);
    const user = await userRepo.findById(decoded.userId);

    if (!user) {
      return res.status(401).json({
        success: false,
        error: {
          code: 'USER_NOT_FOUND',
          message: 'Utilisateur non trouvé'
        }
      });
    }

    // 4. Vérifier que l'utilisateur est actif
    if (user.status !== 'ACTIVE') {
      return res.status(403).json({
        success: false,
        error: {
          code: 'ACCOUNT_INACTIVE',
          message: 'Compte inactif'
        }
      });
    }

    // 5. Attacher l'utilisateur à la requête
    req.user = user;
    next();

  } catch (error) {
    return res.status(401).json({
      success: false,
      error: {
        code: 'INVALID_TOKEN',
        message: 'Token invalide ou expiré'
      }
    });
  }
};

module.exports = authenticate;
```

### 4.2 Autorisation basée sur les Rôles (RBAC)

#### 4.2.1 Matrice de Permissions

```javascript
// config/permissions.js
const permissions = {
  TOURIST: [
    'read:sites',
    'read:reviews',
    'read:own-profile',
    'update:own-profile'
  ],
  
  CONTRIBUTOR: [
    'read:sites',
    'read:reviews',
    'read:own-profile',
    'update:own-profile',
    'create:checkin',
    'create:review',
    'upload:photo',
    'create:favorite'
  ],
  
  PROFESSIONAL: [
    'read:sites',
    'read:reviews',
    'read:own-profile',
    'update:own-profile',
    'manage:own-sites',
    'respond:reviews',
    'read:analytics',
    'manage:subscription'
  ],
  
  MODERATOR: [
    'read:sites',
    'read:reviews',
    'read:all-profiles',
    'moderate:checkins',
    'moderate:reviews',
    'moderate:photos',
    'moderate:users'
  ],
  
  ADMIN: ['*'] // Tous les droits
};

module.exports = permissions;
```

#### 4.2.2 Middleware d'Autorisation

```javascript
// middlewares/authorize.js
const permissions = require('../config/permissions');

const authorize = (...requiredPermissions) => {
  return (req, res, next) => {
    const userRole = req.user.role;
    const userPermissions = permissions[userRole] || [];

    // Admin a tous les droits
    if (userPermissions.includes('*')) {
      return next();
    }

    // Vérifier si l'utilisateur a toutes les permissions requises
    const hasPermission = requiredPermissions.every(permission =>
      userPermissions.includes(permission)
    );

    if (!hasPermission) {
      return res.status(403).json({
        success: false,
        error: {
          code: 'FORBIDDEN',
          message: 'Vous n\'avez pas les permissions nécessaires'
        }
      });
    }

    next();
  };
};

module.exports = authorize;
```

#### 4.2.3 Utilisation dans les Routes

```javascript
// routes/checkins.js
const express = require('express');
const authenticate = require('../middlewares/auth');
const authorize = require('../middlewares/authorize');
const checkinController = require('../controllers/checkinController');

const router = express.Router();

// Créer un check-in (nécessite CONTRIBUTOR ou +)
router.post(
  '/',
  authenticate,
  authorize('create:checkin'),
  checkinController.create
);

// Lire ses propres check-ins (authentifié uniquement)
router.get(
  '/me',
  authenticate,
  checkinController.getMyCheckIns
);

// Modérer un check-in (nécessite MODERATOR ou ADMIN)
router.put(
  '/:id/moderate',
  authenticate,
  authorize('moderate:checkins'),
  checkinController.moderate
);

module.exports = router;
```

### 4.3 Sécurité des Données

#### 4.3.1 Hachage des Mots de Passe

```javascript
// utils/password.js
const bcrypt = require('bcrypt');

class PasswordService {
  async hash(password) {
    const saltRounds = 10;
    return await bcrypt.hash(password, saltRounds);
  }

  async verify(password, hash) {
    return await bcrypt.compare(password, hash);
  }

  validate(password) {
    // Au moins 8 caractères, 1 majuscule, 1 minuscule, 1 chiffre
    const regex = /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).{8,}$/;
    return regex.test(password);
  }
}

module.exports = new PasswordService();
```

#### 4.3.2 Chiffrement des Données Sensibles

```javascript
// utils/encryption.js
const crypto = require('crypto');

class EncryptionService {
  constructor() {
    this.algorithm = 'aes-256-gcm';
    this.key = Buffer.from(process.env.ENCRYPTION_KEY, 'hex'); // 32 bytes
  }

  encrypt(text) {
    const iv = crypto.randomBytes(16);
    const cipher = crypto.createCipheriv(this.algorithm, this.key, iv);
    
    let encrypted = cipher.update(text, 'utf8', 'hex');
    encrypted += cipher.final('hex');
    
    const authTag = cipher.getAuthTag();
    
    return {
      encrypted,
      iv: iv.toString('hex'),
      authTag: authTag.toString('hex')
    };
  }

  decrypt(encrypted, ivHex, authTagHex) {
    const iv = Buffer.from(ivHex, 'hex');
    const authTag = Buffer.from(authTagHex, 'hex');
    const decipher = crypto.createDecipheriv(this.algorithm, this.key, iv);
    
    decipher.setAuthTag(authTag);
    
    let decrypted = decipher.update(encrypted, 'hex', 'utf8');
    decrypted += decipher.final('utf8');
    
    return decrypted;
  }
}

module.exports = new EncryptionService();
```

### 4.4 Protection contre les Attaques

#### 4.4.1 Rate Limiting

```javascript
// middlewares/rateLimiter.js
const redis = require('redis');
const redisClient = redis.createClient({
  host: process.env.REDIS_HOST,
  port: process.env.REDIS_PORT
});

const rateLimiter = (options = {}) => {
  const {
    windowMs = 60000,      // 1 minute
    max = 100,             // 100 requêtes max
    message = 'Trop de requêtes, veuillez réessayer plus tard'
  } = options;

  return async (req, res, next) => {
    const key = `rate_limit:${req.ip}`;
    
    try {
      const current = await redisClient.incr(key);
      
      if (current === 1) {
        await redisClient.expire(key, Math.ceil(windowMs / 1000));
      }
      
      if (current > max) {
        return res.status(429).json({
          success: false,
          error: {
            code: 'RATE_LIMIT_EXCEEDED',
            message: message
          }
        });
      }
      
      res.setHeader('X-RateLimit-Limit', max);
      res.setHeader('X-RateLimit-Remaining', Math.max(0, max - current));
      
      next();
    } catch (error) {
      // En cas d'erreur Redis, on laisse passer
      next();
    }
  };
};

module.exports = rateLimiter;
```

#### 4.4.2 Protection CSRF

```javascript
// middlewares/csrf.js
const crypto = require('crypto');

const generateCSRFToken = () => {
  return crypto.randomBytes(32).toString('hex');
};

const csrfProtection = (req, res, next) => {
  if (req.method === 'GET' || req.method === 'HEAD' || req.method === 'OPTIONS') {
    // Générer un token pour les requêtes safe
    const token = generateCSRFToken();
    req.session.csrfToken = token;
    res.cookie('XSRF-TOKEN', token, {
      httpOnly: false, // Accessible en JS
      secure: process.env.NODE_ENV === 'production',
      sameSite: 'strict'
    });
    return next();
  }

  // Vérifier le token pour les requêtes unsafe
  const tokenFromHeader = req.headers['x-csrf-token'];
  const tokenFromSession = req.session.csrfToken;

  if (!tokenFromHeader || tokenFromHeader !== tokenFromSession) {
    return res.status(403).json({
      success: false,
      error: {
        code: 'INVALID_CSRF_TOKEN',
        message: 'Token CSRF invalide'
      }
    });
  }

  next();
};

module.exports = { csrfProtection, generateCSRFToken };
```

#### 4.4.3 Validation et Sanitization

```javascript
// middlewares/validation.js
const { body, param, query, validationResult } = require('express-validator');

// Règles de validation pour l'inscription
const registerValidation = [
  body('email')
    .isEmail()
    .normalizeEmail()
    .withMessage('Email invalide'),
  
  body('password')
    .isLength({ min: 8 })
    .matches(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)/)
    .withMessage('Mot de passe faible'),
  
  body('first_name')
    .trim()
    .isLength({ min: 2, max: 100 })
    .escape()
    .withMessage('Prénom invalide'),
  
  body('last_name')
    .trim()
    .isLength({ min: 2, max: 100 })
    .escape()
    .withMessage('Nom invalide')
];

// Règles de validation pour un check-in
const checkInValidation = [
  body('site_id')
    .isInt({ min: 1 })
    .withMessage('ID site invalide'),
  
  body('latitude')
    .isFloat({ min: 27, max: 36 })
    .withMessage('Latitude invalide (Maroc: 27-36)'),
  
  body('longitude')
    .isFloat({ min: -13, max: -1 })
    .withMessage('Longitude invalide (Maroc: -13 à -1)'),
  
  body('status')
    .isIn(['OPEN', 'CLOSED_TEMPORARILY', 'CLOSED_PERMANENTLY', 'RENOVATING'])
    .withMessage('Statut invalide'),
  
  body('comment')
    .optional()
    .trim()
    .isLength({ max: 500 })
    .escape()
    .withMessage('Commentaire trop long (max 500 caractères)')
];

// Middleware pour vérifier les résultats de validation
const handleValidationErrors = (req, res, next) => {
  const errors = validationResult(req);
  
  if (!errors.isEmpty()) {
    return res.status(400).json({
      success: false,
      error: {
        code: 'VALIDATION_ERROR',
        message: 'Données invalides',
        details: errors.array().map(err => ({
          field: err.param,
          message: err.msg
        }))
      }
    });
  }
  
  next();
};

module.exports = {
  registerValidation,
  checkInValidation,
  handleValidationErrors
};
```

### 4.5 Sécurité des Headers HTTP

```javascript
// middlewares/security.js
const helmet = require('helmet');

const securityHeaders = helmet({
  contentSecurityPolicy: {
    directives: {
      defaultSrc: ["'self'"],
      styleSrc: ["'self'", "'unsafe-inline'"],
      scriptSrc: ["'self'"],
      imgSrc: ["'self'", 'data:', 'https://s3.amazonaws.com'],
      connectSrc: ["'self'", 'https://api.moroccocheck.com'],
      fontSrc: ["'self'"],
      objectSrc: ["'none'"],
      mediaSrc: ["'self'"],
      frameSrc: ["'none'"]
    }
  },
  hsts: {
    maxAge: 31536000, // 1 an
    includeSubDomains: true,
    preload: true
  },
  noSniff: true,
  referrerPolicy: { policy: 'strict-origin-when-cross-origin' }
});

module.exports = securityHeaders;
```

---

## 5. Architecture de Déploiement

### 5.1 Infrastructure de Production (AWS)

```
┌──────────────────────────────────────────────────────────────┐
│                       ROUTE 53 (DNS)                         │
│                  moroccocheck.com                             │
└────────────────────────┬─────────────────────────────────────┘
                         │
┌────────────────────────▼─────────────────────────────────────┐
│                    CLOUDFLARE CDN                             │
│              - DDoS Protection                                │
│              - SSL/TLS Termination                            │
│              - Static Assets Cache                            │
└────────────────────────┬─────────────────────────────────────┘
                         │
┌────────────────────────▼─────────────────────────────────────┐
│                  APPLICATION LOAD BALANCER                    │
│                  (ALB - Multi-AZ)                             │
│              - Health Checks                                  │
│              - SSL Termination                                │
│              - Target Groups                                  │
└──────────┬──────────────────────────────┬────────────────────┘
           │                              │
┌──────────▼──────────┐        ┌──────────▼──────────┐
│   Auto Scaling      │        │   Auto Scaling      │
│   Group 1           │        │   Group 2           │
│   (us-east-1a)      │        │   (us-east-1b)      │
│                     │        │                     │
│  ┌──────────────┐   │        │  ┌──────────────┐   │
│  │ EC2 Instance │   │        │  │ EC2 Instance │   │
│  │ t3.medium    │   │        │  │ t3.medium    │   │
│  │ Node.js App  │   │        │  │ Node.js App  │   │
│  │ PM2 Process  │   │        │  │ PM2 Process  │   │
│  └──────────────┘   │        │  └──────────────┘   │
│  ┌──────────────┐   │        │  ┌──────────────┐   │
│  │ EC2 Instance │   │        │  │ EC2 Instance │   │
│  │ t3.medium    │   │        │  │ t3.medium    │   │
│  │ Node.js App  │   │        │  │ Node.js App  │   │
│  │ PM2 Process  │   │        │  │ PM2 Process  │   │
│  └──────────────┘   │        │  └──────────────┘   │
└─────────────────────┘        └─────────────────────┘
           │                              │
           └──────────────┬───────────────┘
                          │
        ┌─────────────────┴─────────────────┐
        │                                   │
┌───────▼──────────┐              ┌─────────▼────────┐
│  RDS MySQL       │              │  ElastiCache     │
│  Multi-AZ        │              │  Redis Cluster   │
│  - Primary       │              │  - Primary       │
│  - Standby       │              │  - Replica       │
│  - Read Replica  │              └──────────────────┘
└──────────────────┘
        │
┌───────▼──────────┐              ┌──────────────────┐
│  S3 Buckets      │              │  CloudWatch      │
│  - User Photos   │              │  - Logs          │
│  - Documents     │              │  - Metrics       │
│  - Backups       │              │  - Alarms        │
└──────────────────┘              └──────────────────┘
```

### 5.2 Configuration Docker

#### 5.2.1 Dockerfile pour Node.js

```dockerfile
# Dockerfile
FROM node:18-alpine

# Installer les dépendances système
RUN apk add --no-cache \
    python3 \
    make \
    g++

# Créer le répertoire de l'application
WORKDIR /usr/src/app

# Copier les fichiers package
COPY package*.json ./

# Installer les dépendances
RUN npm ci --only=production

# Copier le code source
COPY . .

# Exposer le port
EXPOSE 3000

# Variables d'environnement (overridées par docker-compose)
ENV NODE_ENV=production

# Healthcheck
HEALTHCHECK --interval=30s --timeout=3s --start-period=40s \
  CMD node healthcheck.js

# Démarrer l'application
CMD ["node", "src/server.js"]
```

#### 5.2.2 Docker Compose

```yaml
# docker-compose.yml
version: '3.8'

services:
  app:
    build: .
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=production
      - DB_HOST=mysql
      - REDIS_HOST=redis
    depends_on:
      - mysql
      - redis
    restart: unless-stopped
    volumes:
      - ./logs:/usr/src/app/logs
    networks:
      - moroccocheck-network

  mysql:
    image: mysql:8.0
    environment:
      - MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD}
      - MYSQL_DATABASE=moroccocheck
      - MYSQL_USER=moroccocheck_user
      - MYSQL_PASSWORD=${MYSQL_PASSWORD}
    volumes:
      - mysql-data:/var/lib/mysql
      - ./init.sql:/docker-entrypoint-initdb.d/init.sql
    ports:
      - "3306:3306"
    restart: unless-stopped
    networks:
      - moroccocheck-network

  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"
    volumes:
      - redis-data:/data
    restart: unless-stopped
    networks:
      - moroccocheck-network

  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf
      - ./ssl:/etc/nginx/ssl
    depends_on:
      - app
    restart: unless-stopped
    networks:
      - moroccocheck-network

volumes:
  mysql-data:
  redis-data:

networks:
  moroccocheck-network:
    driver: bridge
```

### 5.3 Configuration Nginx

```nginx
# nginx.conf
upstream nodejs_backend {
    least_conn;
    server app:3000 max_fails=3 fail_timeout=30s;
}

# Redirect HTTP to HTTPS
server {
    listen 80;
    server_name api.moroccocheck.com;
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name api.moroccocheck.com;

    # SSL Configuration
    ssl_certificate /etc/nginx/ssl/fullchain.pem;
    ssl_certificate_key /etc/nginx/ssl/privkey.pem;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;
    ssl_prefer_server_ciphers on;

    # Security Headers
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains; preload" always;
    add_header X-Frame-Options "DENY" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;

    # Logging
    access_log /var/log/nginx/access.log;
    error_log /var/log/nginx/error.log;

    # Rate Limiting
    limit_req_zone $binary_remote_addr zone=api_limit:10m rate=100r/m;
    limit_req zone=api_limit burst=20 nodelay;

    # Client Body Size
    client_max_body_size 10M;

    # Compression
    gzip on;
    gzip_types text/plain application/json application/javascript text/css;
    gzip_min_length 1000;

    # Proxy to Node.js
    location / {
        proxy_pass http://nodejs_backend;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
        
        # Timeouts
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
    }

    # Health Check Endpoint
    location /health {
        access_log off;
        proxy_pass http://nodejs_backend/health;
    }
}
```

---

## 6. Gestion des Sessions

### 6.1 Stockage Redis

```javascript
// config/session.js
const session = require('express-session');
const RedisStore = require('connect-redis').default;
const redis = require('redis');

const redisClient = redis.createClient({
  host: process.env.REDIS_HOST,
  port: process.env.REDIS_PORT,
  password: process.env.REDIS_PASSWORD
});

redisClient.connect().catch(console.error);

const sessionConfig = session({
  store: new RedisStore({ client: redisClient }),
  secret: process.env.SESSION_SECRET,
  resave: false,
  saveUninitialized: false,
  name: 'moroccocheck.sid',
  cookie: {
    secure: process.env.NODE_ENV === 'production', // HTTPS only
    httpOnly: true,
    maxAge: 7 * 24 * 60 * 60 * 1000, // 7 jours
    sameSite: 'strict'
  }
});

module.exports = sessionConfig;
```

### 6.2 Gestion Multi-Device

```javascript
// services/SessionService.js
class SessionService {
  constructor(redisClient, userRepository) {
    this.redis = redisClient;
    this.userRepo = userRepository;
  }

  async createSession(userId, deviceInfo) {
    const sessionId = this.generateSessionId();
    const sessionData = {
      userId,
      deviceType: deviceInfo.deviceType,
      deviceName: deviceInfo.deviceName,
      deviceId: deviceInfo.deviceId,
      ipAddress: deviceInfo.ipAddress,
      userAgent: deviceInfo.userAgent,
      createdAt: new Date().toISOString(),
      lastActivity: new Date().toISOString()
    };

    // Stocker dans Redis avec TTL de 7 jours
    await this.redis.setEx(
      `session:${sessionId}`,
      7 * 24 * 60 * 60,
      JSON.stringify(sessionData)
    );

    // Ajouter à la liste des sessions de l'utilisateur
    await this.redis.sAdd(`user:${userId}:sessions`, sessionId);

    return sessionId;
  }

  async getSession(sessionId) {
    const sessionData = await this.redis.get(`session:${sessionId}`);
    return sessionData ? JSON.parse(sessionData) : null;
  }

  async updateActivity(sessionId) {
    const sessionData = await this.getSession(sessionId);
    if (sessionData) {
      sessionData.lastActivity = new Date().toISOString();
      await this.redis.setEx(
        `session:${sessionId}`,
        7 * 24 * 60 * 60,
        JSON.stringify(sessionData)
      );
    }
  }

  async getUserSessions(userId) {
    const sessionIds = await this.redis.sMembers(`user:${userId}:sessions`);
    const sessions = [];
    
    for (const sessionId of sessionIds) {
      const sessionData = await this.getSession(sessionId);
      if (sessionData) {
        sessions.push({
          sessionId,
          ...sessionData
        });
      } else {
        // Session expirée, la retirer de la liste
        await this.redis.sRem(`user:${userId}:sessions`, sessionId);
      }
    }
    
    return sessions;
  }

  async revokeSession(sessionId) {
    const sessionData = await this.getSession(sessionId);
    if (sessionData) {
      await this.redis.del(`session:${sessionId}`);
      await this.redis.sRem(`user:${sessionData.userId}:sessions`, sessionId);
    }
  }

  async revokeAllUserSessions(userId) {
    const sessionIds = await this.redis.sMembers(`user:${userId}:sessions`);
    for (const sessionId of sessionIds) {
      await this.redis.del(`session:${sessionId}`);
    }
    await this.redis.del(`user:${userId}:sessions`);
  }

  generateSessionId() {
    const crypto = require('crypto');
    return crypto.randomBytes(32).toString('hex');
  }
}

module.exports = SessionService;
```

---

## Conclusion Phase 3.1

Cette première partie de la Phase 3 couvre :

✅ **Architecture système complète** avec schémas détaillés
✅ **Architecture backend** en couches avec design patterns
✅ **Architecture frontend** Flutter (Clean Architecture)
✅ **Architecture de sécurité** (JWT, RBAC, encryption, protection attaques)
✅ **Architecture de déploiement** (AWS, Docker, Nginx)
✅ **Gestion des sessions** multi-device

**Prochaines sections** :
- Phase 3.2 : Spécifications des APIs (endpoints détaillés)
- Phase 3.3 : Intégrations externes (Google Maps, Stripe, etc.)
- Phase 3.4 : Monitoring et logging

---

**Document créé le 16 janvier 2026**  
**MoroccoCheck - Phase 3.1 : Architecture Système et Sécurité**  
**Version 1.0**
