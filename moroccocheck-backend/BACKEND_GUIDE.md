# Guide de développement backend – MoroccoCheck

Ce guide décrit la méthode complète pour développer et faire évoluer le backend MoroccoCheck en cohérence avec le **Dossier_conceptuelle_MC** (MCD, MPD, UML, spécifications API).

---

## Table des matières

1. [Objectif et public](#1-objectif-et-public)
2. [Prérequis et installation](#2-prérequis-et-installation)
3. [Architecture du backend](#3-architecture-du-backend)
4. [Conventions de développement](#4-conventions-de-développement)
5. [Mapping MCD ↔ backend](#5-mapping-mcd--backend)
6. [Flux à implémenter (priorités)](#6-flux-à-implémenter-priorités)
7. [Sécurité](#7-sécurité)
8. [Logging, monitoring et erreurs](#8-logging-monitoring-et-erreurs)
9. [Tests](#9-tests)
10. [Workflow de développement](#10-workflow-de-développement)
11. [Références (dossier conceptuel)](#11-références-dossier-conceptuel)

---

## 1. Objectif et public

- **Objectif** : garantir un backend cohérent avec le MCD/MPD, sécurisé, testable et maintenable.
- **Public** : développeur(s) backend travaillant sur MoroccoCheck (Node.js, Express, MySQL).

---

## 2. Prérequis et installation

### 2.1 Outils requis

| Outil    | Version recommandée |
|----------|---------------------|
| Node.js  | 20.x LTS            |
| npm      | 10.x                |
| MySQL    | 8.x                 |
| Postman / Thunder Client | Pour tester les APIs |

### 2.2 Installation du backend

```bash
# Depuis la racine du projet
cd moroccocheck-backend

# Dépendances
npm install

# Configuration
cp .env.example .env
# Éditer .env : DB_*, JWT_SECRET, PORT, etc.

# Base de données (scripts du MPD)
mysql -u root -p < sql/install_database.sql
# ou exécuter les scripts create_* + seed_data.sql selon Phase2_3_MPD_Scripts_SQL.md

# Lancement
npm run dev   # développement (nodemon)
npm start     # production
```

### 2.3 Variables d'environnement (.env)

- **DB** : `DB_HOST`, `DB_USER`, `DB_PASSWORD`, `DB_NAME`, `DB_PORT`
- **JWT** : `JWT_SECRET`, `JWT_EXPIRES_IN`
- **Serveur** : `PORT`, `NODE_ENV`
- **Upload** : `UPLOAD_DIR`, `MAX_FILE_SIZE`
- **Rate limiting** (optionnel) : `RATE_LIMIT_WINDOW_MS`, `RATE_LIMIT_MAX_REQUESTS`, `RATE_LIMIT_LOGIN_MAX`

---

## 3. Architecture du backend

### 3.1 Structure des dossiers

```
moroccocheck-backend/
├── server.js                 # Point d'entrée Express
├── package.json
├── .env / .env.example
├── BACKEND_GUIDE.md           # Ce guide
├── sql/                       # Scripts MPD (création, seed, triggers, vues)
├── src/
│   ├── config/
│   │   ├── database.js        # Pool MySQL (mysql2/promise)
│   │   └── constants.js      # Rôles, statuts, points, GPS
│   ├── middleware/
│   │   ├── auth.middleware.js
│   │   └── error.middleware.js
│   ├── routes/
│   │   ├── health.routes.js
│   │   ├── auth.routes.js
│   │   ├── sites.routes.js    # à créer
│   │   ├── checkins.routes.js # à créer
│   │   ├── reviews.routes.js  # à créer
│   │   └── ...
│   ├── controllers/
│   │   ├── auth.controller.js
│   │   ├── sites.controller.js   # à créer
│   │   ├── checkins.controller.js # à créer
│   │   └── ...
│   ├── services/              # Logique métier réutilisable
│   │   ├── gamification.service.js
│   │   ├── freshness.service.js
│   │   └── ...
│   └── utils/
│       ├── gps.utils.js
│       └── validators.js
└── tests/
    ├── test-auth.js
    ├── test-database.js
    └── ...
```

### 3.2 Rôles des couches

| Couche      | Rôle |
|------------|------|
| **Route**  | Expose l’API (verb + path), délègue au controller |
| **Controller** | Reçoit req/res, valide (Joi), appelle service(s), renvoie la réponse |
| **Service** | Logique métier (règles MCD, calculs, gamification) |
| **Config/Utils** | DB, constantes, validation, GPS |

---

## 4. Conventions de développement

### 4.1 Modules

- **ES Modules** partout : `import` / `export` (pas de `require` sauf utilitaires legacy à migrer).

### 4.2 Nommage des fichiers

- Contrôleur : `xxx.controller.js`
- Route : `xxx.routes.js`
- Middleware : `xxx.middleware.js`
- Service : `xxx.service.js`

### 4.3 Alignement avec le MPD

- **Colonnes et attributs** : utiliser exactement les noms du MPD (ex. `password_hash`, `first_name`, `last_name`, `rank`, `profile_picture`).
- Ne pas inventer de colonnes (`name`, `password`, `avatar_url`, `level` string) si le MPD utilise d’autres noms.

### 4.4 Utilisation de mysql2 (promise)

- `pool.query()` retourne **`[rows, fields]`**.
- Toujours déstructurer ou accéder correctement :

```javascript
// SELECT
const [rows] = await pool.query('SELECT * FROM users WHERE email = ?', [email]);
const user = rows[0];  // première ligne

// INSERT
const [result] = await pool.query('INSERT INTO users (...) VALUES (...)', [...]);
const newId = result.insertId;

// COUNT / agrégats
const [rows] = await pool.query('SELECT COUNT(*) as count FROM users WHERE email = ?', [email]);
const count = rows[0].count;
```

### 4.5 Gestion des erreurs

- Utiliser `next(err)` ou lancer des erreurs avec `err.statusCode` pour que le `errorHandler` renvoie le bon code HTTP.
- Ne pas exposer les stacks ni détails internes en production.

---

## 5. Mapping MCD ↔ backend

Les entités du MCD (`Phase2_1_MCD_Modele_Conceptuel.md`) doivent être respectées dans le code et la base.

### 5.1 USER

- **Table** : `users`
- **Colonnes clés** : `id`, `email`, `password_hash`, `first_name`, `last_name`, `phone_number`, `role`, `status`, `points`, `level`, `rank`, `profile_picture`, `created_at`, `updated_at`, etc.
- **Auth** : inscription avec `first_name`, `last_name`, hash du mot de passe dans `password_hash` ; login via `bcrypt.compare` ; JWT avec `userId`, `email`, `role`.

### 5.2 TOURIST_SITE

- **Table** : `tourist_sites`
- **Colonnes clés** : `id`, `name`, `name_ar`, `description`, `category_id`, `latitude`, `longitude`, `address`, `city`, `region`, `average_rating`, `freshness_score`, `status`, `owner_id`, etc.
- **Health / stats** : utiliser le nom de table `tourist_sites` (pas `sites`) dans les requêtes.

### 5.3 CHECKIN

- **Table** : `checkins`
- **Règles** : RG1 (rôle ≥ CONTRIBUTOR), RG2 (1 check-in/jour/site/user), RG4 (distance ≤ 100 m), RG5 (points avec/sans photo).

### 5.4 REVIEW

- **Table** : `reviews`
- **Règles** : RG3 (1 avis par site par utilisateur), RG6 (points), recalcul de `average_rating` et `total_reviews` du site.

### 5.5 BADGE / USER_BADGE

- **Tables** : `badges`, `user_badges`
- **Service** : après chaque action (check-in, review), vérifier les conditions de badges et attribuer via `user_badges`.

### 5.6 Autres entités

- **CATEGORY**, **FAVORITE**, **PHOTO**, **NOTIFICATION**, **SUBSCRIPTION**, **PAYMENT** : prévus dans le MCD/MPD ; créer les routes/controllers au fur et à mesure des besoins.

---

## 6. Flux à implémenter (priorités)

Alignés sur `Phase1_Conception_Detaillee_Suivi.md` et le MCD.

### 6.1 Auth (priorité haute)

| Route | Méthode | Description |
|-------|---------|-------------|
| `/api/auth/register` | POST | Validation (email unique, first_name, last_name, password) → hash → INSERT → JWT (+ email bienvenue optionnel) |
| `/api/auth/login` | POST | Recherche user par email → bcrypt.compare → mise à jour last_login_at → JWT + user (sans password_hash) |
| `/api/auth/profile` | GET | Protégé ; retourne profil de l’utilisateur connecté |
| `/api/auth/profile` | PUT | Protégé ; mise à jour first_name, last_name, email, profile_picture (avec validation et unicité email) |

### 6.2 Check-ins GPS (priorité haute)

- **POST `/api/checkins`**
  - Body : `site_id`, `status` (OPEN/CLOSED/UNDER_CONSTRUCTION), `comment`, `latitude`, `longitude`, optionnellement photo.
  - Vérifications : rôle, distance ≤ 100 m (utils GPS), unicité 1 check-in/jour/site/user.
  - Insertion check-in, calcul `points_earned`, mise à jour user (points, checkins_count, level/rank) et site (freshness, last_verified_at).

### 6.3 Avis (reviews) (priorité haute)

- **POST `/api/reviews`**
  - Vérifier qu’il n’existe pas déjà un avis pour ce user + site.
  - Valider notes (1–5), titre, contenu, photos.
  - INSERT review, recalcul `average_rating` et `total_reviews` du site, attribution points et vérification badges.

### 6.4 Sites touristiques (priorité moyenne)

- GET liste (filtres, pagination), GET détail, POST (création par admin/pro), PUT, DELETE selon droits.
- Utiliser la table `tourist_sites` et les relations `categories`.

### 6.5 Gamification et notifications (priorité moyenne)

- Service gamification : mise à jour points/level/rank après check-in et review ; attribution badges (`user_badges`).
- Notifications : enregistrement en base (table `notifications`) et envoi (email/push) selon spécifications.

---

## 7. Sécurité

- **JWT** : secret dans `.env` uniquement ; expiration cohérente (ex. 7d) ; vérification systématique via `authMiddleware`.
- **Rôles** : stockés en base et dans le JWT ; middlewares dédiés (ex. `adminMiddleware`) pour les routes sensibles.
- **Validation** : Joi sur toutes les entrées critiques (auth, checkins, reviews, création de sites).
- **CORS** : en production, restreindre aux origines autorisées (app mobile, dashboard).
- **Helmet** : activé ; adapter CSP si nécessaire.
- **Upload** : multer + limite de taille (ex. 5 Mo) et types MIME autorisés.

---

## 8. Logging, monitoring et erreurs

- **HTTP** : `morgan('dev')` en dev ; format adapté en prod.
- **Health** : `/api/health`, `/api/health/db`, `/api/health/system` pour monitoring et déploiement.
- **Erreurs** : middleware global d’erreur ; en prod, pas de stack ni détails internes dans la réponse.

---

## 9. Tests

### 9.1 Dépendances

```json
"devDependencies": {
  "mocha": "^10.x",
  "chai": "^4.x",
  "supertest": "^6.x"
},
"scripts": {
  "test": "mocha tests/**/*.js"
}
```

### 9.2 Périmètre recommandé

- **Auth** : register, login, profile (GET/PUT), cas d’erreur (email existant, mauvais mot de passe).
- **Health** : statut API, connexion DB, cohérence des tables.
- **Middleware** : auth (token manquant/invalide/expiré), erreurs, rôles.
- **Check-ins / reviews** : à couvrir dès que les routes sont stables (avec base de test ou mocks).

---

## 10. Workflow de développement

1. **Corriger les incohérences actuelles**  
   Aligner le code auth et health avec le MPD (noms de colonnes, structure des résultats MySQL, table `tourist_sites`).

2. **Finaliser l’auth**  
   Register/Login/Profile conformes au MCD/MPD ; tests verts.

3. **Implémenter les check-ins**  
   Route, validations, règles RG1/RG2/RG4/RG5, mise à jour user et site.

4. **Implémenter les reviews**  
   Route, unicité, recalcul des notes, points et badges.

5. **Gamification et notifications**  
   Services dédiés, badges, niveau/rang.

6. **Documentation API**  
   Swagger/OpenAPI à partir de `Phase3_4_Specifications_API.md`.

7. **Déploiement**  
   Variables d’environnement, backups DB, monitoring (health, logs).

---

## 11. Références (dossier conceptuel)

| Document | Contenu |
|----------|--------|
| `Dossier_conceptuelle_MC/modélisation_BD/Phase2_1_MCD_Modele_Conceptuel.md` | Entités, relations, règles de gestion |
| `Dossier_conceptuelle_MC/modélisation_BD/Phase2_2_MLD_Modele_Logique.md` | Modèle logique (tables, clés) |
| `Dossier_conceptuelle_MC/modélisation_BD/Phase2_3_MPD_Scripts_SQL.md` | Scripts SQL complets (tables, vues, triggers, seeds) |
| `Dossier_conceptuelle_MC/Conception_UML/Diagramme de sequences/Phase1_Conception_Detaillee_Suivi.md` | Séquences (inscription, check-in, avis, paiement, etc.) |
| `Dossier_conceptuelle_MC/Architecture_Technique/Phase3_1_Architecture_Systeme_Securite.md` | Architecture et sécurité |
| `Dossier_conceptuelle_MC/spécifications-des-apis/Phase3_4_Specifications_API.md` | Spécifications des endpoints API |

---

*Guide créé pour le projet MoroccoCheck – Backend. À mettre à jour au fil de l’évolution du MCD/MPD et des spécifications.*
