# Guide Complet : Étapes Avant la Programmation de MoroccoCheck

## 📋 Table des Matières

1. [Vue d'ensemble](#vue-densemble)
2. [Phase 1 : Conception Détaillée](#phase-1--conception-détaillée)
3. [Phase 2 : Modélisation de la Base de Données](#phase-2--modélisation-de-la-base-de-données)
4. [Phase 3 : Architecture Technique](#phase-3--architecture-technique)
5. [Phase 4 : Spécifications des APIs](#phase-4--spécifications-des-apis)
6. [Phase 5 : Conception UI/UX](#phase-5--conception-uiux)
7. [Phase 6 : Configuration Environnement](#phase-6--configuration-environnement)
8. [Phase 7 : Documentation Technique](#phase-7--documentation-technique)
9. [Phase 8 : Planification du Développement](#phase-8--planification-du-développement)
10. [Checklist Finale](#checklist-finale)

---

## 🎯 Vue d'ensemble

Avant de commencer à coder MoroccoCheck, vous devez compléter **8 phases essentielles** qui garantiront un développement structuré, efficace et maintenable.

### Pourquoi c'est important ?

✅ **Éviter la réécriture de code**  
✅ **Réduire les bugs et problèmes d'architecture**  
✅ **Faciliter le travail en équipe**  
✅ **Accélérer le développement**  
✅ **Produire une application professionnelle**

### Temps estimé : 2-3 semaines

| Phase | Durée estimée | Priorité |
|-------|---------------|----------|
| Phase 1 : Conception Détaillée | 3-4 jours | 🔴 Critique |
| Phase 2 : Base de Données | 2-3 jours | 🔴 Critique |
| Phase 3 : Architecture | 2 jours | 🔴 Critique |
| Phase 4 : APIs | 3-4 jours | 🔴 Critique |
| Phase 5 : UI/UX | 4-5 jours | 🟡 Haute |
| Phase 6 : Environnement | 1-2 jours | 🟡 Haute |
| Phase 7 : Documentation | 2 jours | 🟢 Moyenne |
| Phase 8 : Planification | 1 jour | 🟢 Moyenne |

---

## Phase 1 : Conception Détaillée

### 1.1 Diagrammes de Séquence

**Objectif** : Montrer les interactions temporelles entre les objets du système.

#### Diagrammes à créer :

**Priorité HAUTE** :
1. **Séquence d'inscription et connexion**
   - Inscription utilisateur
   - Connexion avec email/password
   - Connexion OAuth (Google/Facebook)
   - Récupération mot de passe

2. **Séquence de check-in GPS**
   - Demande de localisation
   - Validation position GPS
   - Enregistrement check-in
   - Attribution points
   - Mise à jour fraîcheur

3. **Séquence de dépôt d'avis**
   - Sélection site
   - Saisie avis et note
   - Upload photos
   - Validation et enregistrement
   - Attribution points

4. **Séquence de paiement (Stripe)**
   - Sélection plan
   - Redirection Stripe
   - Traitement paiement
   - Webhook confirmation
   - Activation abonnement

**Priorité MOYENNE** :
5. Recherche et consultation de sites
6. Gestion d'établissement professionnel
7. Modération de contenu (Admin)

#### Exemple de structure :

```
Actor: Contributeur
System: MoroccoCheck Backend
External: Google Maps API

1. Contributeur clique "Check-in"
2. System demande localisation
3. System → Google Maps: getLocation()
4. Google Maps → System: coordinates
5. System calcule distance
6. SI distance < 100m
   7. System affiche formulaire
   8. Contributeur remplit formulaire
   9. System valide données
   10. System enregistre check-in DB
   11. System calcule points
   12. System met à jour profil
   13. System → Contributeur: succès + points
```

### 1.2 Diagrammes de Classes

**Objectif** : Définir la structure objet de l'application.

#### Classes principales à modéliser :

**Couche Domain (Modèles)** :
- `User` (attributs, méthodes)
- `TouristSite` 
- `CheckIn`
- `Review`
- `Badge`
- `Subscription`
- `Payment`

**Couche Services** :
- `AuthService`
- `LocationService`
- `GamificationService`
- `PaymentService`

**Relations** :
- Héritage : `Contributor` extends `Tourist`
- Association : `User` → `Review` (1..*)
- Composition : `TouristSite` ◆ `CheckIn`
- Agrégation : `User` ◇ `Badge`

#### Exemple de classe :

```
┌─────────────────────────┐
│      TouristSite        │
├─────────────────────────┤
│ - id: int               │
│ - name: String          │
│ - latitude: double      │
│ - longitude: double     │
│ - category: Category    │
│ - freshnessScore: int   │
│ - averageRating: double │
│ - lastVerifiedAt: Date  │
├─────────────────────────┤
│ + calculateFreshness()  │
│ + updateRating()        │
│ + getDistance(location) │
└─────────────────────────┘
```

### 1.3 Diagrammes d'Activité

**Objectif** : Représenter les flux de travail et la logique métier.

#### Diagrammes critiques :

1. **Processus de vérification d'un site**
   ```
   [Début]
   ↓
   [Utilisateur sur un site]
   ↓
   [Récupérer position GPS]
   ↓
   <Distance < 100m?> ── NON → [Message erreur] → [Fin]
   ↓ OUI
   [Afficher formulaire]
   ↓
   [Sélectionner statut]
   ↓
   <Ajouter photo?> ── OUI → [Upload photo]
   ↓ NON               ↓
   [Valider formulaire] ←┘
   ↓
   [Enregistrer check-in]
   ↓
   [Calculer points : 10 + (photo ? 5 : 0)]
   ↓
   [Mettre à jour profil]
   ↓
   <Nouveau badge?> ── OUI → [Afficher animation badge]
   ↓ NON                     ↓
   [Afficher succès] ←────────┘
   ↓
   [Fin]
   ```

2. **Processus de calcul du score de fraîcheur**
3. **Processus de validation d'établissement professionnel**
4. **Processus de modération d'avis**

### 1.4 Diagrammes de Composants

**Objectif** : Montrer l'organisation des composants logiciels.

#### Architecture Flutter (Frontend) :

```
┌─────────────────────────────────┐
│     Presentation Layer          │
│  ┌──────────┐  ┌──────────┐    │
│  │  Screens │  │  Widgets │    │
│  └────┬─────┘  └────┬─────┘    │
│       └─────┬───────┘            │
└─────────────┼───────────────────┘
              │
┌─────────────┼───────────────────┐
│     Business Logic Layer        │
│       ┌─────▼─────┐             │
│       │  Providers │             │
│       │  (State)   │             │
│       └─────┬─────┘             │
└─────────────┼───────────────────┘
              │
┌─────────────┼───────────────────┐
│      Data Layer                 │
│  ┌────▼─────┐  ┌──────────┐    │
│  │ Services │  │  Models  │    │
│  └──────────┘  └──────────┘    │
└─────────────────────────────────┘
```

#### Architecture Backend (Node.js) :

```
┌─────────────────────────────────┐
│      Routes Layer               │
│  (Express Router)               │
└────────────┬────────────────────┘
             │
┌────────────▼────────────────────┐
│    Controllers Layer            │
│  (Business Logic)               │
└────────────┬────────────────────┘
             │
┌────────────▼────────────────────┐
│     Services Layer              │
│  (Business Services)            │
└────────────┬────────────────────┘
             │
┌────────────▼────────────────────┐
│      Models Layer               │
│  (Data Access)                  │
└─────────────────────────────────┘
```

### 1.5 Diagrammes d'États

**Objectif** : Modéliser les différents états d'un objet.

#### États critiques à modéliser :

1. **États d'un Check-in**
   ```
   [Créé] → [En validation] → [Validé] → [Actif]
                    ↓
                [Rejeté]
   ```

2. **États d'un Abonnement**
   ```
   [Créé] → [En attente paiement] → [Actif]
                    ↓                  ↓
                [Échoué]          [Expiré]
                                      ↓
                                  [Renouvelé]
   ```

3. **États d'un Site Touristique**
   ```
   [Brouillon] → [En attente validation] → [Publié]
                          ↓                   ↓
                    [Rejeté]            [Archivé]
   ```

---

## Phase 2 : Modélisation de la Base de Données

### 2.1 Modèle Conceptuel de Données (MCD)

**Objectif** : Définir les entités et leurs relations sans considération technique.

#### Entités principales :

1. **USER**
   - Attributs : id, email, password, name, role, points, level, created_at
   - Relations : 
     - 1,N → CHECKIN
     - 1,N → REVIEW
     - N,M → BADGE (via USER_BADGE)

2. **TOURIST_SITE**
   - Attributs : id, name, description, latitude, longitude, category, freshness_score, average_rating
   - Relations :
     - 1,N → CHECKIN
     - 1,N → REVIEW
     - 1,N → PHOTO

3. **CHECKIN**
   - Attributs : id, user_id, site_id, status, comment, photo_url, points_earned, created_at
   - Relations :
     - N,1 → USER
     - N,1 → TOURIST_SITE

4. **REVIEW**
   - Attributs : id, user_id, site_id, rating, title, comment, helpful_count, created_at
   - Relations :
     - N,1 → USER
     - N,1 → TOURIST_SITE
     - 1,N → REVIEW_PHOTO

**À créer** : Diagramme entité-association complet avec cardinalités.

### 2.2 Modèle Logique de Données (MLD)

**Objectif** : Transformer le MCD en structure relationnelle.

#### Tables principales :

```sql
users (
  id INT PRIMARY KEY AUTO_INCREMENT,
  email VARCHAR(255) UNIQUE NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  name VARCHAR(255) NOT NULL,
  role ENUM('tourist', 'contributor', 'professional', 'admin'),
  points INT DEFAULT 0,
  level ENUM('bronze', 'silver', 'gold', 'platinum') DEFAULT 'bronze',
  avatar_url VARCHAR(500),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  last_login_at TIMESTAMP,
  is_active BOOLEAN DEFAULT TRUE,
  INDEX idx_email (email),
  INDEX idx_role (role)
)

tourist_sites (
  id INT PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(255) NOT NULL,
  description TEXT,
  address VARCHAR(500),
  latitude DECIMAL(10, 8) NOT NULL,
  longitude DECIMAL(11, 8) NOT NULL,
  category_id INT,
  freshness_score INT DEFAULT 0,
  average_rating DECIMAL(3, 2) DEFAULT 0,
  total_reviews INT DEFAULT 0,
  last_verified_at TIMESTAMP,
  owner_id INT,
  status ENUM('draft', 'pending', 'published', 'archived') DEFAULT 'published',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (category_id) REFERENCES categories(id),
  FOREIGN KEY (owner_id) REFERENCES users(id),
  INDEX idx_location (latitude, longitude),
  INDEX idx_category (category_id),
  INDEX idx_freshness (freshness_score)
)

checkins (
  id INT PRIMARY KEY AUTO_INCREMENT,
  user_id INT NOT NULL,
  site_id INT NOT NULL,
  status ENUM('open', 'closed', 'temporarily_closed') NOT NULL,
  comment TEXT,
  photo_url VARCHAR(500),
  latitude DECIMAL(10, 8) NOT NULL,
  longitude DECIMAL(11, 8) NOT NULL,
  distance_meters INT,
  points_earned INT DEFAULT 10,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (site_id) REFERENCES tourist_sites(id) ON DELETE CASCADE,
  INDEX idx_user (user_id),
  INDEX idx_site (site_id),
  INDEX idx_date (created_at),
  UNIQUE KEY unique_user_site_date (user_id, site_id, DATE(created_at))
)

reviews (
  id INT PRIMARY KEY AUTO_INCREMENT,
  user_id INT NOT NULL,
  site_id INT NOT NULL,
  rating INT NOT NULL CHECK (rating >= 1 AND rating <= 5),
  title VARCHAR(255),
  comment TEXT,
  helpful_count INT DEFAULT 0,
  is_moderated BOOLEAN DEFAULT FALSE,
  moderation_status ENUM('pending', 'approved', 'rejected') DEFAULT 'approved',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (site_id) REFERENCES tourist_sites(id) ON DELETE CASCADE,
  INDEX idx_site (site_id),
  INDEX idx_user (user_id),
  INDEX idx_rating (rating),
  UNIQUE KEY unique_user_site_review (user_id, site_id)
)
```

**À faire** : 
- Créer le script SQL complet pour toutes les tables
- Définir toutes les contraintes d'intégrité
- Créer les index pour optimisation des requêtes

### 2.3 Modèle Physique de Données (MPD)

**Objectif** : Optimiser pour MySQL.

#### Considérations d'optimisation :

1. **Index composites** pour requêtes fréquentes
   ```sql
   CREATE INDEX idx_site_freshness ON tourist_sites(freshness_score DESC, average_rating DESC);
   CREATE INDEX idx_checkin_user_date ON checkins(user_id, created_at DESC);
   ```

2. **Partitionnement** des grandes tables (si nécessaire)
   ```sql
   -- Partitionner checkins par mois
   PARTITION BY RANGE (YEAR(created_at) * 100 + MONTH(created_at)) (
     PARTITION p202601 VALUES LESS THAN (202602),
     PARTITION p202602 VALUES LESS THAN (202603),
     ...
   );
   ```

3. **Vues matérialisées** pour analytics
   ```sql
   CREATE VIEW v_user_stats AS
   SELECT 
     u.id,
     u.name,
     u.points,
     COUNT(DISTINCT c.id) as total_checkins,
     COUNT(DISTINCT r.id) as total_reviews,
     AVG(r.rating) as avg_rating_given
   FROM users u
   LEFT JOIN checkins c ON u.id = c.user_id
   LEFT JOIN reviews r ON u.id = r.user_id
   GROUP BY u.id;
   ```

### 2.4 Dictionnaire de Données

**À créer** : Un fichier Excel/CSV avec toutes les colonnes :

| Table | Colonne | Type | Taille | Nullable | Default | Description | Contraintes |
|-------|---------|------|--------|----------|---------|-------------|-------------|
| users | id | INT | - | NO | AUTO_INCREMENT | Identifiant unique | PK |
| users | email | VARCHAR | 255 | NO | - | Email utilisateur | UNIQUE |
| users | password_hash | VARCHAR | 255 | NO | - | Mot de passe hashé | - |
| ... | ... | ... | ... | ... | ... | ... | ... |

---

## Phase 3 : Architecture Technique

### 3.1 Architecture Système Complète

**À créer** : Diagramme d'architecture détaillé montrant :

```
┌─────────────────────────────────────────────────────┐
│                  CLIENTS                            │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐         │
│  │ iOS App  │  │Android App│  │  Admin  │         │
│  │ Flutter  │  │  Flutter  │  │   Web   │         │
│  └────┬─────┘  └────┬──────┘  └────┬────┘         │
└───────┼─────────────┼──────────────┼───────────────┘
        │             │              │
        └─────────────┴──────────────┘
                      │
        ┌─────────────▼──────────────┐
        │     Load Balancer          │
        │        (Nginx)             │
        └─────────────┬──────────────┘
                      │
        ┌─────────────▼──────────────┐
        │    API Gateway             │
        │   (Express.js)             │
        └─────────────┬──────────────┘
                      │
        ┌─────────────┴──────────────┐
        │                            │
┌───────▼────────┐          ┌────────▼────────┐
│  Auth Service  │          │  Core Service   │
│   (Node.js)    │          │   (Node.js)     │
└───────┬────────┘          └────────┬────────┘
        │                            │
        └────────────┬───────────────┘
                     │
        ┌────────────┴────────────┐
        │                         │
┌───────▼────────┐       ┌────────▼────────┐
│  MySQL DB      │       │   Redis Cache   │
│   (Primary)    │       │   (Session)     │
└────────────────┘       └─────────────────┘
        │
┌───────▼────────┐
│  MySQL DB      │
│  (Replica)     │
└────────────────┘
```

### 3.2 Architecture de Sécurité

**Éléments à définir** :

1. **Authentification et Autorisation**
   ```
   JWT Token Structure:
   {
     "header": {
       "alg": "HS256",
       "typ": "JWT"
     },
     "payload": {
       "userId": 123,
       "email": "user@example.com",
       "role": "contributor",
       "iat": 1234567890,
       "exp": 1234654290
     }
   }
   
   Secret Key: Stockée dans variable d'environnement
   Expiration: 24 heures
   Refresh Token: 7 jours
   ```

2. **Chiffrement des données sensibles**
   - Mots de passe : bcrypt avec 10 rounds
   - Données personnelles : AES-256-GCM
   - Communications : TLS 1.3

3. **Protection contre les attaques**
   - Rate Limiting : 100 requêtes/minute par IP
   - CORS : Whitelist des origines autorisées
   - SQL Injection : Requêtes préparées uniquement
   - XSS : Validation et échappement côté serveur

4. **Gestion des permissions**
   ```javascript
   const permissions = {
     tourist: ['read:sites', 'read:reviews'],
     contributor: ['read:sites', 'read:reviews', 'create:checkin', 'create:review'],
     professional: ['read:sites', 'manage:own-site', 'read:analytics'],
     admin: ['*']
   };
   ```

### 3.3 Architecture de Déploiement

**Infrastructure recommandée** :

```
Production Environment:
├── Frontend (Flutter)
│   ├── iOS App → App Store
│   └── Android App → Google Play Store
│
├── Backend (Node.js)
│   ├── Server: AWS EC2 / DigitalOcean Droplet
│   ├── RAM: 4GB minimum
│   ├── CPU: 2 vCPU minimum
│   └── Storage: 50GB SSD
│
├── Base de données
│   ├── MySQL Primary: 8GB RAM, 4 vCPU
│   └── MySQL Replica: 4GB RAM, 2 vCPU (lecture)
│
├── Cache
│   └── Redis: 2GB RAM
│
├── Stockage fichiers
│   └── AWS S3 / Cloudinary (images)
│
└── CDN
    └── CloudFlare (assets statiques)
```

---

## Phase 4 : Spécifications des APIs

### 4.1 Documentation API Complète (OpenAPI/Swagger)

**À créer** : Fichier `swagger.yaml` ou `openapi.json` avec toutes les spécifications.

#### Exemple de structure :

```yaml
openapi: 3.0.0
info:
  title: MoroccoCheck API
  version: 1.0.0
  description: API REST pour l'application MoroccoCheck

servers:
  - url: https://api.moroccocheck.com/v1
    description: Production
  - url: http://localhost:3000/api
    description: Development

paths:
  /auth/register:
    post:
      summary: Inscription d'un nouvel utilisateur
      tags:
        - Authentication
      requestBody:
        required: true
        content:
          application/json:
            schema:
              type: object
              required:
                - email
                - password
                - name
              properties:
                email:
                  type: string
                  format: email
                  example: user@example.com
                password:
                  type: string
                  format: password
                  minLength: 8
                  example: SecurePass123
                name:
                  type: string
                  minLength: 2
                  maxLength: 100
                  example: John Doe
                role:
                  type: string
                  enum: [tourist, professional]
                  default: tourist
      responses:
        '201':
          description: Utilisateur créé avec succès
          content:
            application/json:
              schema:
                type: object
                properties:
                  success:
                    type: boolean
                    example: true
                  message:
                    type: string
                    example: "Utilisateur créé avec succès"
                  data:
                    type: object
                    properties:
                      user:
                        $ref: '#/components/schemas/User'
                      token:
                        type: string
                        example: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
        '400':
          description: Données invalides
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Error'
        '409':
          description: Email déjà utilisé
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Error'

  /checkins:
    post:
      summary: Effectuer un check-in GPS
      tags:
        - Check-ins
      security:
        - bearerAuth: []
      requestBody:
        required: true
        content:
          application/json:
            schema:
              type: object
              required:
                - site_id
                - status
                - latitude
                - longitude
              properties:
                site_id:
                  type: integer
                  example: 123
                status:
                  type: string
                  enum: [open, closed, temporarily_closed]
                  example: open
                comment:
                  type: string
                  maxLength: 500
                  example: "Site magnifique et bien entretenu"
                latitude:
                  type: number
                  format: double
                  example: 33.5731
                longitude:
                  type: number
                  format: double
                  example: -7.5898
                photo:
                  type: string
                  format: binary
                  description: Photo du site (optionnel)
      responses:
        '201':
          description: Check-in enregistré avec succès
          content:
            application/json:
              schema:
                type: object
                properties:
                  success:
                    type: boolean
                    example: true
                  message:
                    type: string
                    example: "Check-in enregistré avec succès"
                  data:
                    type: object
                    properties:
                      checkin:
                        $ref: '#/components/schemas/CheckIn'
                      points_earned:
                        type: integer
                        example: 15
                      new_badge:
                        $ref: '#/components/schemas/Badge'
                        nullable: true
        '400':
          description: Distance trop grande (> 100m)
        '401':
          description: Non authentifié
        '409':
          description: Check-in déjà effectué aujourd'hui

components:
  securitySchemes:
    bearerAuth:
      type: http
      scheme: bearer
      bearerFormat: JWT
  
  schemas:
    User:
      type: object
      properties:
        id:
          type: integer
        email:
          type: string
        name:
          type: string
        role:
          type: string
          enum: [tourist, contributor, professional, admin]
        points:
          type: integer
        level:
          type: string
          enum: [bronze, silver, gold, platinum]
        avatar_url:
          type: string
          nullable: true
        created_at:
          type: string
          format: date-time
    
    CheckIn:
      type: object
      properties:
        id:
          type: integer
        user_id:
          type: integer
        site_id:
          type: integer
        status:
          type: string
        comment:
          type: string
          nullable: true
        photo_url:
          type: string
          nullable: true
        points_earned:
          type: integer
        created_at:
          type: string
          format: date-time
    
    Error:
      type: object
      properties:
        success:
          type: boolean
          example: false
        message:
          type: string
        errors:
          type: array
          items:
            type: object
            properties:
              field:
                type: string
              message:
                type: string
```

### 4.2 Liste Complète des Endpoints

**À documenter pour chaque endpoint** :

| Endpoint | Méthode | Auth | Description | Request | Response | Status Codes |
|----------|---------|------|-------------|---------|----------|--------------|
| /auth/register | POST | Non | Inscription | email, password, name | user, token | 201, 400, 409 |
| /auth/login | POST | Non | Connexion | email, password | user, token | 200, 401 |
| /auth/refresh | POST | Oui | Renouveler token | refresh_token | token | 200, 401 |
| /sites | GET | Non | Liste sites | query params | sites[] | 200 |
| /sites/:id | GET | Non | Détails site | - | site | 200, 404 |
| /checkins | POST | Oui | Check-in | site_id, status, location | checkin, points | 201, 400, 409 |
| /reviews | POST | Oui | Avis | site_id, rating, comment | review, points | 201, 400, 409 |
| ... | ... | ... | ... | ... | ... | ... |

### 4.3 Codes de Réponse Standards

```javascript
// Structure de réponse réussie
{
  "success": true,
  "message": "Opération réussie",
  "data": {
    // Données de la réponse
  },
  "meta": {
    "timestamp": "2026-01-15T10:30:00Z",
    "version": "1.0.0"
  }
}

// Structure de réponse d'erreur
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Données invalides",
    "details": [
      {
        "field": "email",
        "message": "Format d'email invalide"
      }
    ]
  },
  "meta": {
    "timestamp": "2026-01-15T10:30:00Z"
  }
}
```

---

## Phase 5 : Conception UI/UX

### 5.1 Design System

**À créer** : Document de design system complet.

#### Éléments du design system :

1. **Palette de couleurs**
   ```
   Primary Colors:
   - Primary: #3498DB (Bleu)
   - Secondary: #E74C3C (Rouge)
   - Accent: #F39C12 (Orange)
   
   Neutral Colors:
   - Dark: #2C3E50
   - Gray: #95A5A6
   - Light Gray: #ECF0F1
   - White: #FFFFFF
   
   Status Colors:
   - Success: #27AE60 (Vert)
   - Warning: #F39C12 (Orange)
   - Error: #E74C3C (Rouge)
   - Info: #3498DB (Bleu)
   
   Freshness Colors:
   - Fresh: #27AE60 (< 24h)
   - Recent: #F39C12 (< 7 jours)
   - Old: #E74C3C (< 30 jours)
   - Stale: #95A5A6 (> 30 jours)
   ```

2. **Typographie**
   ```
   Font Family: Roboto (principal), Open Sans (secondaire)
   
   Headings:
   - H1: 32px, Bold, Letter-spacing: -0.5px
   - H2: 28px, Bold
   - H3: 24px, Semi-Bold
   - H4: 20px, Semi-Bold
   - H5: 18px, Medium
   - H6: 16px, Medium
   
   Body:
   - Large: 18px, Regular, Line-height: 1.6
   - Normal: 16px, Regular, Line-height: 1.5
   - Small: 14px, Regular, Line-height: 1.4
   - Tiny: 12px, Regular, Line-height: 1.3
   ```

3. **Espacement et grille**
   ```
   Base: 8px
   
   Spacing Scale:
   - xs: 4px (0.5 × base)
   - sm: 8px (1 × base)
   - md: 16px (2 × base)
   - lg: 24px (3 × base)
   - xl: 32px (4 × base)
   - 2xl: 48px (6 × base)
   - 3xl: 64px (8 × base)
   
   Grid:
   - Colonnes: 12
   - Gutter: 16px
   - Margin: 16px (mobile), 24px (tablet), 32px (desktop)
   ```

4. **Composants UI**
   - Boutons (primary, secondary, tertiary, disabled)
   - Champs de formulaire (input, textarea, select)
   - Cards (site card, review card, profile card)
   - Badges et labels
   - Navigation (bottom nav, app bar)
   - Modals et dialogs
   - Loaders et skeletons

### 5.2 Wireframes Basse Fidélité

**À créer** : Wireframes pour tous les écrans principaux (papier ou outil).

#### Écrans prioritaires :

**Authentification** :
1. Splash Screen
2. Onboarding (3-4 slides)
3. Login
4. Register
5. Forgot Password

**Navigation principale (Touriste)** :
6. Home / Carte interactive
7. Search / Filtres
8. Site Details
9. Reviews List
10. Profile (visiteur)

**Contribution** :
11. Check-in Form
12. Review Form
13. Photo Upload
14. Success Animations

**Gamification** :
15. Profile Stats
16. Badges List
17. Leaderboard
18. Rewards

**Professionnel** :
19. Dashboard
20. Site Management
21. Analytics
22. Reviews Management
23. Subscription Plans
24. Payment

**Admin** :
25. Admin Dashboard
26. Content Moderation
27. User Management
28. Site Validation

### 5.3 Maquettes Haute Fidélité

**À créer avec Figma/Adobe XD** :

#### Caractéristiques des maquettes :

- **Résolutions** : 
  - Mobile : 375×812 (iPhone X)
  - Tablet : 768×1024 (iPad)
  
- **États des composants** :
  - Default
  - Hover (pour web)
  - Active/Pressed
  - Disabled
  - Loading
  - Error
  
- **Flux utilisateur** :
  - Liens entre écrans
  - Animations de transition
  - Micro-interactions

#### Livrables attendus :

1. Fichier Figma/XD avec tous les écrans
2. Assets exportés (icônes, images, illustrations)
3. Guide de style PDF
4. Prototype interactif cliquable

### 5.4 Prototype Interactif

**Outils** : Figma, Adobe XD, InVision, Marvel

**Fonctionnalités du prototype** :
- Navigation entre écrans
- Animations de transition
- États interactifs des boutons
- Simulations de formulaires
- Feedback utilisateur

**Objectif** : Tester l'UX avant de coder.

---

## Phase 6 : Configuration Environnement

### 6.1 Environnement de Développement

#### Configuration Flutter :

```bash
# Installation Flutter
flutter doctor

# Créer projet
flutter create moroccocheck

# Structure recommandée
lib/
├── main.dart
├── app.dart
├── core/
│   ├── constants/
│   ├── theme/
│   ├── utils/
│   └── config/
├── data/
│   ├── models/
│   ├── repositories/
│   └── services/
├── domain/
│   ├── entities/
│   └── usecases/
├── presentation/
│   ├── screens/
│   ├── widgets/
│   └── providers/
└── routes/
    └── app_routes.dart
```

#### Configuration Node.js :

```bash
# Initialiser projet
npm init -y

# Installer dépendances de base
npm install express mysql2 bcrypt jsonwebtoken dotenv cors helmet

# Structure recommandée
server/
├── src/
│   ├── config/
│   │   ├── database.js
│   │   └── config.js
│   ├── controllers/
│   │   ├── authController.js
│   │   ├── siteController.js
│   │   └── checkinController.js
│   ├── middlewares/
│   │   ├── auth.js
│   │   ├── validation.js
│   │   └── errorHandler.js
│   ├── models/
│   │   ├── User.js
│   │   ├── TouristSite.js
│   │   └── CheckIn.js
│   ├── routes/
│   │   ├── auth.js
│   │   ├── sites.js
│   │   └── checkins.js
│   ├── services/
│   │   ├── authService.js
│   │   ├── gamificationService.js
│   │   └── emailService.js
│   ├── utils/
│   │   ├── logger.js
│   │   └── validators.js
│   └── app.js
├── tests/
├── .env.example
├── .gitignore
└── package.json
```

### 6.2 Variables d'Environnement

**Créer fichier `.env.example`** :

```env
# Application
NODE_ENV=development
PORT=3000
APP_URL=http://localhost:3000

# Database
DB_HOST=localhost
DB_PORT=3306
DB_NAME=moroccocheck_dev
DB_USER=root
DB_PASSWORD=your_password

# Redis
REDIS_HOST=localhost
REDIS_PORT=6379
REDIS_PASSWORD=

# JWT
JWT_SECRET=your_super_secret_key_change_in_production
JWT_EXPIRES_IN=24h
JWT_REFRESH_SECRET=your_refresh_secret
JWT_REFRESH_EXPIRES_IN=7d

# Google Maps
GOOGLE_MAPS_API_KEY=your_google_maps_key

# Stripe
STRIPE_SECRET_KEY=sk_test_your_key
STRIPE_WEBHOOK_SECRET=whsec_your_webhook_secret

# Firebase
FIREBASE_PROJECT_ID=your_project_id
FIREBASE_PRIVATE_KEY=your_private_key
FIREBASE_CLIENT_EMAIL=your_client_email

# AWS S3 (pour images)
AWS_ACCESS_KEY_ID=your_access_key
AWS_SECRET_ACCESS_KEY=your_secret_key
AWS_BUCKET_NAME=moroccocheck-images
AWS_REGION=eu-west-1

# Email (SendGrid)
SENDGRID_API_KEY=your_sendgrid_key
FROM_EMAIL=noreply@moroccocheck.com

# Logs
LOG_LEVEL=debug
```

### 6.3 Services Externes à Configurer

**Comptes à créer et configurer** :

1. **Google Cloud Platform**
   - Activer Maps SDK for Android
   - Activer Maps SDK for iOS
   - Activer Geocoding API
   - Activer Directions API
   - Créer clés API (avec restrictions)

2. **Stripe**
   - Créer compte test
   - Obtenir clés API test
   - Configurer webhooks
   - Créer produits et prix

3. **Firebase**
   - Créer projet Firebase
   - Activer Authentication
   - Activer Cloud Messaging
   - Télécharger google-services.json (Android)
   - Télécharger GoogleService-Info.plist (iOS)

4. **AWS S3 / Cloudinary**
   - Créer bucket S3
   - Configurer CORS
   - Créer IAM user avec permissions

5. **SendGrid / Mailgun**
   - Créer compte email
   - Vérifier domaine
   - Créer templates d'emails

### 6.4 Outils de Développement

**Outils recommandés** :

```
IDE:
- VS Code avec extensions:
  - Flutter
  - Dart
  - ESLint
  - Prettier
  - GitLens

API Testing:
- Postman (collection partagée)
- Insomnia

Base de données:
- MySQL Workbench
- TablePlus
- DBeaver

Version Control:
- Git
- GitHub/GitLab

CI/CD:
- GitHub Actions
- GitLab CI

Monitoring:
- Sentry (erreurs)
- LogRocket (sessions)
- Google Analytics

Design:
- Figma
- Adobe XD
```

---

## Phase 7 : Documentation Technique

### 7.1 README Principal

**Créer `README.md`** avec :

```markdown
# MoroccoCheck

Application mobile touristique intelligente pour le Maroc.

## 📱 Fonctionnalités

- Carte interactive des sites touristiques
- Check-ins GPS avec validation de proximité
- Système d'avis et notations
- Gamification (points, badges, leaderboard)
- Espace professionnel pour établissements
- Administration et modération

## 🚀 Technologies

- Frontend: Flutter (iOS & Android)
- Backend: Node.js + Express.js
- Base de données: MySQL + Redis
- Services: Stripe, Google Maps, Firebase

## 📋 Prérequis

- Flutter SDK 3.x
- Node.js 18.x+
- MySQL 8.0+
- Redis 7.x+

## ⚙️ Installation

### Backend

\`\`\`bash
cd server
npm install
cp .env.example .env
# Configurer .env
npm run migrate
npm run seed
npm start
\`\`\`

### Mobile

\`\`\`bash
cd mobile
flutter pub get
flutter run
\`\`\`

## 📚 Documentation

- [Architecture](docs/architecture.md)
- [API Documentation](docs/api.md)
- [Database Schema](docs/database.md)
- [Deployment](docs/deployment.md)

## 🧪 Tests

\`\`\`bash
# Backend
npm test
npm run test:coverage

# Mobile
flutter test
\`\`\`

## 📄 Licence

Projet de Fin d'Études - 2026
```

### 7.2 Documentation API

**Créer `docs/api.md`** avec :
- Introduction
- Authentication
- Tous les endpoints groupés par ressource
- Exemples de requêtes/réponses
- Codes d'erreur
- Rate limiting
- Versioning

### 7.3 Guide de Contribution

**Créer `CONTRIBUTING.md`** :

```markdown
# Guide de Contribution

## Convention de Commits

Format: `type(scope): message`

Types:
- feat: Nouvelle fonctionnalité
- fix: Correction de bug
- docs: Documentation
- style: Formatage
- refactor: Refactoring
- test: Tests
- chore: Tâches diverses

Exemples:
- `feat(auth): add OAuth login`
- `fix(checkin): validate GPS distance`
- `docs(api): update endpoints list`

## Branches

- `main`: Production
- `develop`: Développement
- `feature/nom-feature`: Nouvelles fonctionnalités
- `fix/nom-bug`: Corrections
- `hotfix/nom-urgence`: Corrections urgentes

## Pull Requests

1. Créer une branche depuis develop
2. Implémenter la fonctionnalité
3. Écrire les tests
4. Mettre à jour la documentation
5. Créer une PR vers develop
6. Attendre review et approval
```

### 7.4 Documentation Base de Données

**Créer `docs/database.md`** avec :
- Diagramme ERD
- Description de chaque table
- Relations et contraintes
- Index et optimisations
- Procédures stockées
- Triggers
- Scripts de migration

---

## Phase 8 : Planification du Développement

### 8.1 Découpage en Sprints

**Organisation recommandée** : Sprints de 2 semaines

#### Sprint 0 (Semaine 1-2) : Setup
- Configuration environnement complet
- Structure projet backend et mobile
- Pipeline CI/CD
- Base de données initiale

#### Sprint 1 (Semaine 3-4) : Authentication
- Backend:
  - Inscription/Connexion email
  - OAuth Google/Facebook
  - JWT tokens
  - Middleware d'authentification
- Mobile:
  - Écrans login/register
  - Gestion des tokens
  - Navigation conditionnelle

#### Sprint 2 (Semaine 5-6) : Sites Touristiques - Lecture
- Backend:
  - API liste des sites
  - API détails site
  - Recherche et filtres
  - Sites à proximité
- Mobile:
  - Carte interactive
  - Liste des sites
  - Détails site
  - Recherche

#### Sprint 3 (Semaine 7-8) : Check-ins
- Backend:
  - Validation GPS
  - Enregistrement check-in
  - Calcul de fraîcheur
  - Attribution points
- Mobile:
  - Formulaire check-in
  - Validation GPS
  - Upload photo
  - Feedback succès

#### Sprint 4 (Semaine 9-10) : Avis et Notations
- Backend:
  - Créer/modifier avis
  - Upload photos avis
  - Marquer comme utile
  - Calcul note moyenne
- Mobile:
  - Formulaire avis
  - Liste des avis
  - Tri et filtres
  - Interactions

#### Sprint 5 (Semaine 11-12) : Gamification
- Backend:
  - Système de points
  - Gestion badges
  - Leaderboards
  - Niveaux utilisateur
- Mobile:
  - Profil utilisateur
  - Badges obtenus
  - Leaderboard
  - Progression

#### Sprint 6 (Semaine 13-14) : Espace Professionnel
- Backend:
  - Dashboard professionnel
  - Gestion établissement
  - Analytics basiques
  - Réponse aux avis
- Mobile:
  - Dashboard pro
  - Modification infos
  - Consultation analytics
  - Gestion avis

#### Sprint 7 (Semaine 15-16) : Paiements & Abonnements
- Backend:
  - Intégration Stripe
  - Webhooks Stripe
  - Gestion abonnements
  - Plans tarifaires
- Mobile:
  - Affichage plans
  - Processus paiement
  - Gestion abonnement
  - Factures

#### Sprint 8 (Semaine 17-18) : Administration
- Backend:
  - Modération contenus
  - Gestion utilisateurs
  - Validation établissements
  - Statistiques globales
- Web Admin:
  - Dashboard admin
  - Interface modération
  - Gestion des données

#### Sprint 9 (Semaine 19-20) : Finalisation & Tests
- Tests d'intégration complets
- Tests de performance
- Correction des bugs
- Optimisations

#### Sprint 10 (Semaine 21-22) : Déploiement & Documentation
- Préparation production
- Déploiement serveurs
- Publication stores
- Documentation finale

### 8.2 Estimation des Tâches

**Méthode** : Planning Poker ou Story Points

Exemple de tâches estimées :

| Tâche | Story Points | Temps estimé |
|-------|--------------|--------------|
| Setup projet Flutter | 3 | 1 jour |
| API inscription/connexion | 5 | 2 jours |
| Écran login mobile | 3 | 1 jour |
| Intégration Google Maps | 8 | 3 jours |
| Check-in GPS validation | 13 | 5 jours |
| Système de gamification | 21 | 8 jours |
| ... | ... | ... |

### 8.3 Diagramme de Gantt

**À créer** : Planification visuelle avec dépendances.

```
Semaines    1  2  3  4  5  6  7  8  9  10 11 12 13 14 15 16
─────────────────────────────────────────────────────────────
Setup       ██
Auth           ██ ██
Sites              ██ ██
Check-ins                 ██ ██
Avis                         ██ ██
Gamif.                          ██ ██
Pro                                   ██ ██
Paiement                                 ██ ██
Admin                                       ██ ██
Tests                                          ██
Deploy                                            ██
```

### 8.4 Gestion des Risques

**Identifier et planifier** :

| Risque | Probabilité | Impact | Mitigation |
|--------|-------------|--------|------------|
| Dépassement délai Sprint | Haute | Moyen | Buffer de 20% sur estimations |
| API Google Maps quota | Moyenne | Élevé | Prévoir cache local + fallback |
| Problème Stripe test | Faible | Élevé | Environnement test isolé |
| Bug GPS validation | Moyenne | Élevé | Tests unitaires exhaustifs |
| Retard design UI | Moyenne | Moyen | Wireframes avant Sprint 1 |

---

## ✅ Checklist Finale

### Avant de Commencer le Développement

#### Phase 1 : Conception ✓
- [ ] Diagrammes de séquence créés (minimum 5)
- [ ] Diagrammes de classes complets
- [ ] Diagrammes d'activité pour flux critiques
- [ ] Diagrammes de composants (Frontend + Backend)
- [ ] Diagrammes d'états définis

#### Phase 2 : Base de Données ✓
- [ ] MCD (Modèle Conceptuel) validé
- [ ] MLD (Modèle Logique) créé
- [ ] MPD (Modèle Physique) optimisé
- [ ] Scripts SQL de création
- [ ] Scripts de migration
- [ ] Scripts de seed (données test)
- [ ] Dictionnaire de données complet

#### Phase 3 : Architecture ✓
- [ ] Architecture système documentée
- [ ] Architecture de sécurité définie
- [ ] Architecture de déploiement planifiée
- [ ] Choix technologiques validés
- [ ] Patterns d'architecture sélectionnés

#### Phase 4 : APIs ✓
- [ ] Documentation OpenAPI/Swagger complète
- [ ] Liste de tous les endpoints
- [ ] Formats de requêtes/réponses définis
- [ ] Codes d'erreur standardisés
- [ ] Règles d'authentification documentées
- [ ] Rate limiting défini

#### Phase 5 : UI/UX ✓
- [ ] Design system créé
- [ ] Palette de couleurs définie
- [ ] Typographie choisie
- [ ] Wireframes basse fidélité (tous les écrans)
- [ ] Maquettes haute fidélité (écrans principaux)
- [ ] Prototype interactif testé
- [ ] Assets exportés (icônes, images)

#### Phase 6 : Environnement ✓
- [ ] Flutter installé et configuré
- [ ] Node.js installé et configuré
- [ ] MySQL installé et configuré
- [ ] Redis installé
- [ ] Structure des projets créée
- [ ] Variables d'environnement définies
- [ ] Comptes services externes créés:
  - [ ] Google Cloud (Maps API)
  - [ ] Stripe (test)
  - [ ] Firebase
  - [ ] AWS S3 / Cloudinary
  - [ ] SendGrid / Mailgun

#### Phase 7 : Documentation ✓
- [ ] README principal
- [ ] Documentation API
- [ ] Guide de contribution
- [ ] Documentation base de données
- [ ] Guide de déploiement
- [ ] Documentation architecture

#### Phase 8 : Planification ✓
- [ ] Sprints définis (10 sprints)
- [ ] Backlog créé et priorisé
- [ ] Estimation des tâches faite
- [ ] Diagramme de Gantt créé
- [ ] Risques identifiés et mitigés
- [ ] Équipe assignée (si équipe)

### Validation Finale

- [ ] **Revue par un mentor/professeur**
- [ ] **Validation des choix techniques**
- [ ] **Confirmation du planning**
- [ ] **Budget estimé (services payants)**
- [ ] **Plan de test défini**

---

## 📊 Résumé des Livrables

### Documents à Produire

1. **Diagrammes UML** (7 types)
   - ✅ Cas d'utilisation (déjà fait)
   - ⏳ Séquence
   - ⏳ Classes
   - ⏳ Activité
   - ⏳ Composants
   - ⏳ États
   - ⏳ Déploiement

2. **Base de Données**
   - ⏳ MCD / ERD
   - ⏳ Scripts SQL
   - ⏳ Dictionnaire de données

3. **APIs**
   - ⏳ Documentation Swagger/OpenAPI
   - ⏳ Collection Postman

4. **UI/UX**
   - ⏳ Design System
   - ⏳ Wireframes (25+ écrans)
   - ⏳ Maquettes haute fidélité
   - ⏳ Prototype interactif

5. **Documentation**
   - ⏳ README
   - ⏳ Architecture
   - ⏳ Guide développement
   - ⏳ Guide déploiement

6. **Planification**
   - ⏳ Backlog produit
   - ⏳ Planning sprints
   - ⏳ Diagramme Gantt

---

## 🎯 Prochaines Étapes Recommandées

### Semaine 1-2 : Conception Détaillée

**Jour 1-2** : Diagrammes de séquence
- Inscription/Connexion
- Check-in GPS
- Dépôt d'avis
- Paiement Stripe

**Jour 3-4** : Diagrammes de classes
- Modèles domaine
- Services
- Contrôleurs

**Jour 5-6** : Diagrammes d'activité
- Flux check-in
- Calcul fraîcheur
- Processus modération

**Jour 7** : Review et validation

### Semaine 2-3 : Base de Données

**Jour 8-9** : MCD/ERD
- Entités et relations
- Cardinalités

**Jour 10-11** : Scripts SQL
- CREATE TABLE
- INDEX
- CONSTRAINTS

**Jour 12-13** : Migration et Seed
- Scripts de migration
- Données de test

**Jour 14** : Review et tests

### Semaine 3 : Architecture & APIs

**Jour 15-16** : Architecture
- Diagrammes architecture
- Choix techniques
- Sécurité

**Jour 17-19** : Documentation API
- Swagger complet
- Collection Postman

**Jour 20-21** : UI/UX - Wireframes
- Tous les écrans
- Flux utilisateur

---

## 📚 Ressources Utiles

### Documentation

- [Flutter Documentation](https://flutter.dev/docs)
- [Node.js Best Practices](https://github.com/goldbergyoni/nodebestpractices)
- [MySQL Documentation](https://dev.mysql.com/doc/)
- [Stripe API Docs](https://stripe.com/docs/api)
- [Google Maps Platform](https://developers.google.com/maps)
- [Firebase Documentation](https://firebase.google.com/docs)

### Outils

- [Draw.io](https://draw.io) - Diagrammes UML
- [Lucidchart](https://lucidchart.com) - Diagrammes
- [Figma](https://figma.com) - Design UI/UX
- [Swagger Editor](https://editor.swagger.io) - API Docs
- [Postman](https://postman.com) - API Testing
- [DB Designer](https://www.dbdesigner.net) - MCD/ERD

### Tutoriels

- Flutter Clean Architecture
- Node.js REST API Best Practices
- MySQL Performance Optimization
- JWT Authentication Implementation
- Stripe Payment Integration
- Google Maps Flutter Integration

---

## 💡 Conseils Finaux

### DO ✅

1. **Prenez le temps de bien concevoir**
   - 2-3 semaines de conception = 2-3 mois économisés en développement

2. **Documentez au fur et à mesure**
   - Plus facile que de documenter après

3. **Commencez par les fonctionnalités critiques**
   - MVP d'abord, features avancées ensuite

4. **Testez régulièrement**
   - Tests unitaires dès le début

5. **Utilisez Git correctement**
   - Commits fréquents, branches par feature

6. **Demandez des reviews**
   - Code review, design review, architecture review

### DON'T ❌

1. **Ne codez pas sans design**
   - Vous perdrez du temps à refaire

2. **N'optimisez pas prématurément**
   - Faites fonctionner d'abord, optimisez ensuite

3. **Ne négligez pas la sécurité**
   - Intégrez-la dès le début

4. **N'oubliez pas les tests**
   - Vous les paierez en bugs plus tard

5. **Ne travaillez pas sans sauvegarde**
   - Git + backups réguliers

6. **N'ignorez pas les warnings**
   - Ils deviennent des bugs

---

## 📞 Support

Pour toute question sur ces phases :
- Consultez la documentation projet
- Demandez à votre encadrant
- Utilisez les ressources en ligne

---

**Bon courage pour votre projet ! 🚀**

*Document créé le 15 janvier 2026*  
*MoroccoCheck - Guide Pré-Développement*
