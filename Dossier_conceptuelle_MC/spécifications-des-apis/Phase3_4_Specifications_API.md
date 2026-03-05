# Phase 3.4 : Spécifications API (OpenAPI/Swagger)
## MoroccoCheck - Documentation API Complète

*Document créé le 16 janvier 2026*

---

## Table des Matières

1. [Introduction](#1-introduction)
2. [Informations Générales API](#2-informations-générales-api)
3. [Authentification](#3-authentification)
4. [Endpoints Authentication](#4-endpoints-authentication)
5. [Endpoints Sites](#5-endpoints-sites)
6. [Endpoints Check-ins](#6-endpoints-check-ins)
7. [Endpoints Reviews](#7-endpoints-reviews)
8. [Endpoints Users](#8-endpoints-users)
9. [Endpoints Gamification](#9-endpoints-gamification)
10. [Endpoints Subscriptions & Payments](#10-endpoints-subscriptions--payments)
11. [Endpoints Admin](#11-endpoints-admin)
12. [Schémas de Données](#12-schémas-de-données)
13. [Codes d'Erreur](#13-codes-derreur)
14. [Exemples cURL](#14-exemples-curl)

---

## 1. Introduction

Cette documentation décrit l'API REST de **MoroccoCheck**, une application mobile pour découvrir et vérifier les sites touristiques au Maroc.

### 1.1 Spécification OpenAPI

- **Version OpenAPI** : 3.0.3
- **Format** : JSON / YAML
- **Style API** : REST
- **Encodage** : UTF-8

### 1.2 Conventions

- **Naming** : snake_case pour JSON, camelCase pour Query Params
- **Dates** : ISO 8601 (YYYY-MM-DDTHH:mm:ss.sssZ)
- **IDs** : Integers (auto-increment)
- **Pagination** : Offset-based (page, limit)
- **Versioning** : URL-based (/v1/)

---

## 2. Informations Générales API

### 2.1 URLs de Base

```yaml
servers:
  - url: https://api.moroccocheck.com/v1
    description: Production
  - url: https://staging-api.moroccocheck.com/v1
    description: Staging
  - url: http://localhost:3000/api/v1
    description: Development
```

### 2.2 Headers Requis

```http
Content-Type: application/json
Accept: application/json
Accept-Language: fr-FR,fr;q=0.9,ar-MA,ar;q=0.8,en-US,en;q=0.7
```

### 2.3 Headers d'Authentification

```http
Authorization: Bearer <access_token>
```

### 2.4 Structure des Réponses

#### Réponse Succès

```json
{
  "success": true,
  "message": "Operation successful",
  "data": {
    // Données de la réponse
  },
  "meta": {
    "timestamp": "2026-01-16T14:30:00.000Z",
    "version": "1.0.0",
    "request_id": "req_abc123"
  }
}
```

#### Réponse Succès avec Pagination

```json
{
  "success": true,
  "data": [
    // Array d'objets
  ],
  "pagination": {
    "page": 1,
    "limit": 20,
    "total": 150,
    "total_pages": 8,
    "has_next": true,
    "has_prev": false
  },
  "meta": {
    "timestamp": "2026-01-16T14:30:00.000Z"
  }
}
```

#### Réponse Erreur

```json
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Invalid input data",
    "details": [
      {
        "field": "email",
        "message": "Email format is invalid"
      }
    ]
  },
  "meta": {
    "timestamp": "2026-01-16T14:30:00.000Z",
    "request_id": "req_abc123"
  }
}
```

### 2.5 Codes HTTP Standards

| Code | Signification | Usage |
|------|---------------|-------|
| 200 | OK | Requête réussie (GET, PUT, DELETE) |
| 201 | Created | Ressource créée (POST) |
| 204 | No Content | Succès sans données (DELETE) |
| 400 | Bad Request | Données invalides |
| 401 | Unauthorized | Non authentifié |
| 403 | Forbidden | Permissions insuffisantes |
| 404 | Not Found | Ressource introuvable |
| 409 | Conflict | Conflit (duplicate, constraint) |
| 422 | Unprocessable Entity | Validation métier échouée |
| 429 | Too Many Requests | Rate limit dépassé |
| 500 | Internal Server Error | Erreur serveur |
| 503 | Service Unavailable | Service temporairement indisponible |

---

## 3. Authentification

### 3.1 Schéma de Sécurité

```yaml
components:
  securitySchemes:
    bearerAuth:
      type: http
      scheme: bearer
      bearerFormat: JWT
      description: "JWT Access Token (15 minutes)"
    
    refreshToken:
      type: apiKey
      in: header
      name: X-Refresh-Token
      description: "Refresh Token (7 days)"
```

### 3.2 Flow d'Authentification

```
1. POST /auth/register ou /auth/login
   → Retourne { accessToken, refreshToken }

2. Utiliser accessToken dans Authorization header
   Authorization: Bearer <accessToken>

3. Quand accessToken expire (401)
   → POST /auth/refresh avec refreshToken
   → Retourne nouveau { accessToken, refreshToken }

4. Logout
   → POST /auth/logout (révoque la session)
```

---

## 4. Endpoints Authentication

### 4.1 POST /auth/register

**Description** : Inscription d'un nouvel utilisateur

**Authentification** : Non requise

**Request Body** :

```json
{
  "email": "user@example.com",
  "password": "SecurePass123!",
  "first_name": "Ahmed",
  "last_name": "Benali",
  "phone_number": "+212612345678",
  "date_of_birth": "1990-05-15",
  "gender": "MALE",
  "nationality": "MA"
}
```

**Validation** :
- `email` : Format email valide, unique
- `password` : Min 8 chars, 1 maj, 1 min, 1 chiffre, 1 caractère spécial
- `first_name`, `last_name` : 2-100 caractères
- `phone_number` : Format E.164 (optionnel)
- `date_of_birth` : Age >= 13 ans (optionnel)
- `gender` : MALE, FEMALE, OTHER, PREFER_NOT_TO_SAY (optionnel)
- `nationality` : Code ISO 2 lettres (optionnel)

**Response 201** :

```json
{
  "success": true,
  "message": "User registered successfully",
  "data": {
    "user": {
      "id": 12345,
      "email": "user@example.com",
      "first_name": "Ahmed",
      "last_name": "Benali",
      "role": "TOURIST",
      "status": "PENDING_VERIFICATION",
      "is_email_verified": false,
      "points": 0,
      "level": 1,
      "rank": "BRONZE",
      "created_at": "2026-01-16T14:30:00.000Z"
    },
    "tokens": {
      "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
      "refresh_token": "a1b2c3d4-e5f6-4789-a0b1-c2d3e4f5a6b7",
      "expires_in": 900
    }
  }
}
```

**Errors** :
- `400` : Validation failed
- `409` : Email already exists

---

### 4.2 POST /auth/login

**Description** : Connexion avec email et mot de passe

**Request Body** :

```json
{
  "email": "user@example.com",
  "password": "SecurePass123!",
  "device_info": {
    "type": "IOS",
    "name": "iPhone 14 Pro",
    "os_version": "17.2",
    "app_version": "1.2.0"
  }
}
```

**Response 200** :

```json
{
  "success": true,
  "message": "Login successful",
  "data": {
    "user": {
      "id": 12345,
      "email": "user@example.com",
      "first_name": "Ahmed",
      "last_name": "Benali",
      "role": "CONTRIBUTOR",
      "status": "ACTIVE",
      "profile_picture": "https://s3.../profile.jpg",
      "points": 1250,
      "level": 5,
      "rank": "GOLD",
      "badges_count": 8
    },
    "tokens": {
      "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
      "refresh_token": "a1b2c3d4-e5f6-4789-a0b1-c2d3e4f5a6b7",
      "expires_in": 900
    }
  }
}
```

**Errors** :
- `401` : Invalid credentials
- `403` : Account suspended/banned
- `429` : Too many login attempts (5 max/15min)

---

### 4.3 POST /auth/refresh

**Description** : Renouveler l'access token

**Request Body** :

```json
{
  "refresh_token": "a1b2c3d4-e5f6-4789-a0b1-c2d3e4f5a6b7"
}
```

**Response 200** :

```json
{
  "success": true,
  "data": {
    "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "refresh_token": "b2c3d4e5-f6a7-5890-b1c2-d3e4f5a6b7c8",
    "expires_in": 900
  }
}
```

**Errors** :
- `401` : Invalid or expired refresh token

---

### 4.4 POST /auth/logout

**Description** : Déconnexion (révoque la session)

**Authentification** : Requise

**Response 200** :

```json
{
  "success": true,
  "message": "Logged out successfully"
}
```

---

### 4.5 POST /auth/google

**Description** : Connexion avec Google OAuth

**Request Body** :

```json
{
  "id_token": "google_id_token_here",
  "device_info": { ... }
}
```

**Response 200** : Identique à `/auth/login`

---

### 4.6 POST /auth/verify-email

**Description** : Vérifier l'email avec le token

**Request Body** :

```json
{
  "token": "550e8400-e29b-41d4-a716-446655440000"
}
```

**Response 200** :

```json
{
  "success": true,
  "message": "Email verified successfully"
}
```

**Errors** :
- `400` : Invalid or expired token

---

### 4.7 POST /auth/forgot-password

**Description** : Demander un reset de mot de passe

**Request Body** :

```json
{
  "email": "user@example.com"
}
```

**Response 200** :

```json
{
  "success": true,
  "message": "Password reset email sent"
}
```

---

### 4.8 POST /auth/reset-password

**Description** : Réinitialiser le mot de passe

**Request Body** :

```json
{
  "token": "reset_token_here",
  "new_password": "NewSecurePass123!"
}
```

**Response 200** :

```json
{
  "success": true,
  "message": "Password reset successfully"
}
```

---

## 5. Endpoints Sites

### 5.1 GET /sites

**Description** : Liste des sites touristiques avec filtres

**Authentification** : Non requise

**Query Parameters** :

| Paramètre | Type | Requis | Description | Exemple |
|-----------|------|--------|-------------|---------|
| `page` | integer | Non | Numéro de page (défaut: 1) | `1` |
| `limit` | integer | Non | Résultats par page (défaut: 20, max: 100) | `20` |
| `category` | integer | Non | Filtrer par ID catégorie | `5` |
| `city` | string | Non | Filtrer par ville | `Casablanca` |
| `region` | string | Non | Filtrer par région | `Casablanca-Settat` |
| `lat` | float | Non | Latitude pour recherche proximité | `33.5731` |
| `lng` | float | Non | Longitude pour recherche proximité | `-7.5898` |
| `radius` | integer | Non | Rayon en km (défaut: 10, max: 100) | `10` |
| `min_rating` | float | Non | Note minimale (1-5) | `4.0` |
| `price_range` | string | Non | BUDGET, MODERATE, EXPENSIVE, LUXURY | `MODERATE` |
| `is_featured` | boolean | Non | Sites mis en avant uniquement | `true` |
| `freshness` | string | Non | FRESH, RECENT, OLD, OBSOLETE | `FRESH` |
| `search` | string | Non | Recherche full-text | `restaurant` |
| `sort` | string | Non | Tri: `rating`, `distance`, `name`, `freshness` | `rating` |
| `order` | string | Non | Ordre: `asc`, `desc` (défaut: desc) | `desc` |

**Response 200** :

```json
{
  "success": true,
  "data": [
    {
      "id": 123,
      "name": "Rick's Café",
      "name_ar": "مقهى ريك",
      "description": "Restaurant emblématique de Casablanca...",
      "category": {
        "id": 1,
        "name": "Restaurant",
        "name_ar": "مطعم",
        "icon": "restaurant"
      },
      "location": {
        "latitude": 33.5731,
        "longitude": -7.5898,
        "address": "248 Bd Sour Jdid, Casablanca",
        "city": "Casablanca",
        "region": "Casablanca-Settat"
      },
      "ratings": {
        "average_rating": 4.5,
        "total_reviews": 342
      },
      "price_range": "EXPENSIVE",
      "cover_photo": "https://s3.../cover.jpg",
      "photos_count": 156,
      "freshness": {
        "score": 85,
        "status": "FRESH",
        "last_verified_at": "2026-01-16T10:00:00.000Z"
      },
      "is_featured": false,
      "distance": 1.2,
      "created_at": "2025-01-10T09:00:00.000Z"
    }
  ],
  "pagination": {
    "page": 1,
    "limit": 20,
    "total": 150,
    "total_pages": 8,
    "has_next": true,
    "has_prev": false
  }
}
```

---

### 5.2 GET /sites/:id

**Description** : Détails complets d'un site

**Authentification** : Non requise

**Response 200** :

```json
{
  "success": true,
  "data": {
    "id": 123,
    "name": "Rick's Café",
    "name_ar": "مقهى ريك",
    "description": "Restaurant emblématique inspiré du film Casablanca...",
    "description_ar": "مطعم شهير مستوحى من فيلم الدار البيضاء...",
    "category": {
      "id": 1,
      "name": "Restaurant",
      "name_ar": "مطعم",
      "icon": "restaurant",
      "color": "#FF5722"
    },
    "subcategory": "Moroccan Cuisine",
    "location": {
      "latitude": 33.5731,
      "longitude": -7.5898,
      "address": "248 Bd Sour Jdid",
      "city": "Casablanca",
      "region": "Casablanca-Settat",
      "postal_code": "20000",
      "country": "MA"
    },
    "contact": {
      "phone_number": "+212522274207",
      "email": "info@rickscafe.ma",
      "website": "https://rickscafe.ma",
      "social_media": {
        "facebook": "https://facebook.com/rickscafe",
        "instagram": "https://instagram.com/rickscafe"
      }
    },
    "opening_hours": [
      {
        "day": "MONDAY",
        "is_open": true,
        "periods": [
          {
            "open": "12:00",
            "close": "00:00"
          }
        ]
      }
    ],
    "pricing": {
      "price_range": "EXPENSIVE",
      "average_price": 250,
      "currency": "MAD"
    },
    "amenities": {
      "accepts_card_payment": true,
      "has_wifi": true,
      "has_parking": true,
      "is_accessible": false,
      "features": ["wifi", "parking", "air_conditioning", "terrace"]
    },
    "ratings": {
      "average_rating": 4.5,
      "total_reviews": 342,
      "rating_breakdown": {
        "5_stars": 210,
        "4_stars": 95,
        "3_stars": 25,
        "2_stars": 8,
        "1_star": 4
      }
    },
    "freshness": {
      "score": 85,
      "status": "FRESH",
      "last_verified_at": "2026-01-16T10:00:00.000Z",
      "total_checkins": 523,
      "unique_visitors": 412
    },
    "media": {
      "cover_photo": "https://s3.../cover.jpg",
      "photos": [
        {
          "id": 1001,
          "url": "https://s3.../photo1.jpg",
          "thumbnail_url": "https://s3.../thumb1.jpg",
          "caption": "Beautiful terrace view",
          "is_primary": true,
          "likes_count": 42
        }
      ],
      "photos_count": 156
    },
    "owner": {
      "id": 456,
      "is_professional_claimed": true,
      "subscription_plan": "PRO"
    },
    "statistics": {
      "views_count": 15234,
      "favorites_count": 342,
      "checkins_count": 523,
      "photos_count": 156
    },
    "status": "PUBLISHED",
    "is_featured": false,
    "created_at": "2025-01-10T09:00:00.000Z",
    "updated_at": "2026-01-15T14:00:00.000Z"
  }
}
```

---

### 5.3 POST /sites

**Description** : Créer un nouveau site

**Authentification** : Requise (PROFESSIONAL, ADMIN)

**Request Body** :

```json
{
  "name": "New Restaurant",
  "name_ar": "مطعم جديد",
  "description": "Description here...",
  "description_ar": "الوصف هنا...",
  "category_id": 1,
  "subcategory": "Italian Cuisine",
  "latitude": 33.5731,
  "longitude": -7.5898,
  "address": "123 Bd Mohammed V",
  "city": "Casablanca",
  "region": "Casablanca-Settat",
  "postal_code": "20000",
  "phone_number": "+212522123456",
  "email": "contact@restaurant.ma",
  "website": "https://restaurant.ma",
  "price_range": "MODERATE",
  "amenities": {
    "accepts_card_payment": true,
    "has_wifi": true,
    "has_parking": false,
    "is_accessible": true
  }
}
```

**Response 201** :

```json
{
  "success": true,
  "message": "Site created successfully",
  "data": {
    "id": 789,
    "name": "New Restaurant",
    "status": "PENDING_REVIEW",
    "verification_status": "PENDING"
  }
}
```

---

### 5.4 PUT /sites/:id

**Description** : Mettre à jour un site

**Authentification** : Requise (PROFESSIONAL owner, ADMIN)

**Request Body** : Partiel (mêmes champs que POST)

**Response 200** : Site mis à jour

---

### 5.5 DELETE /sites/:id

**Description** : Supprimer un site (soft delete)

**Authentification** : Requise (PROFESSIONAL owner, ADMIN)

**Response 204** : No Content

---

### 5.6 GET /sites/:id/reviews

**Description** : Avis d'un site avec pagination

**Query Parameters** :
- `page`, `limit`
- `rating` : Filtrer par note (1-5)
- `sort` : `recent`, `helpful`, `rating`

**Response 200** : Liste d'avis paginée

---

### 5.7 GET /sites/:id/photos

**Description** : Photos d'un site

**Response 200** : Liste de photos paginée

---

### 5.8 POST /sites/:id/claim

**Description** : Revendiquer la propriété d'un site

**Authentification** : Requise (PROFESSIONAL)

**Request Body** :

```json
{
  "documents": [
    {
      "type": "BUSINESS_LICENSE",
      "url": "https://s3.../license.pdf"
    }
  ],
  "message": "I am the owner of this restaurant..."
}
```

**Response 200** :

```json
{
  "success": true,
  "message": "Claim request submitted for review"
}
```

---

## 6. Endpoints Check-ins

### 6.1 POST /checkins

**Description** : Effectuer un check-in GPS

**Authentification** : Requise (CONTRIBUTOR+)

**Request Body** :

```json
{
  "site_id": 123,
  "status": "OPEN",
  "comment": "Site magnifique et bien entretenu",
  "verification_notes": "Horaires confirmés",
  "latitude": 33.5732,
  "longitude": -7.5899,
  "accuracy": 5.2,
  "photo": {
    "data": "base64_encoded_image",
    "mime_type": "image/jpeg"
  }
}
```

**Validation** :
- `site_id` : Existe
- `status` : OPEN, CLOSED_TEMPORARILY, CLOSED_PERMANENTLY, RENOVATING, RELOCATED, NO_CHANGE
- `comment` : Max 500 caractères
- `latitude`, `longitude` : Coordonnées valides
- `accuracy` : Précision GPS en mètres
- Distance calculée doit être <= 100m
- Cooldown : 1 check-in par site par jour

**Response 201** :

```json
{
  "success": true,
  "message": "Check-in recorded successfully",
  "data": {
    "checkin": {
      "id": 5678,
      "user_id": 12345,
      "site_id": 123,
      "status": "OPEN",
      "comment": "Site magnifique...",
      "distance": 12.5,
      "has_photo": true,
      "points_earned": 15,
      "validation_status": "PENDING",
      "created_at": "2026-01-16T14:30:00.000Z"
    },
    "rewards": {
      "points_earned": 15,
      "total_points": 1265,
      "new_level": null,
      "new_badges": [
        {
          "id": 5,
          "name": "Explorer",
          "description": "10 check-ins completed",
          "icon": "https://s3.../badge5.png",
          "points_reward": 50
        }
      ]
    },
    "site_updated": {
      "freshness_score": 87,
      "freshness_status": "FRESH",
      "last_verified_at": "2026-01-16T14:30:00.000Z"
    }
  }
}
```

**Errors** :
- `400` : Distance trop grande (>100m)
- `409` : Check-in already done today for this site
- `422` : Invalid GPS coordinates

---

### 6.2 GET /checkins

**Description** : Liste des check-ins de l'utilisateur

**Authentification** : Requise

**Query Parameters** :
- `page`, `limit`
- `site_id` : Filtrer par site
- `status` : Filtrer par statut
- `from_date`, `to_date` : Filtrer par période

**Response 200** :

```json
{
  "success": true,
  "data": [
    {
      "id": 5678,
      "site": {
        "id": 123,
        "name": "Rick's Café",
        "cover_photo": "https://s3.../cover.jpg"
      },
      "status": "OPEN",
      "comment": "Site magnifique...",
      "has_photo": true,
      "points_earned": 15,
      "validation_status": "APPROVED",
      "created_at": "2026-01-16T14:30:00.000Z"
    }
  ],
  "pagination": { ... }
}
```

---

### 6.3 GET /checkins/:id

**Description** : Détails d'un check-in

**Authentification** : Requise

**Response 200** : Check-in complet avec photo si disponible

---

### 6.4 DELETE /checkins/:id

**Description** : Supprimer son check-in

**Authentification** : Requise (owner only)

**Response 204** : No Content

---

## 7. Endpoints Reviews

### 7.1 POST /reviews

**Description** : Créer un avis sur un site

**Authentification** : Requise (CONTRIBUTOR+)

**Request Body** :

```json
{
  "site_id": 123,
  "overall_rating": 4.5,
  "service_rating": 5.0,
  "cleanliness_rating": 4.5,
  "value_rating": 4.0,
  "location_rating": 5.0,
  "title": "Excellent restaurant",
  "content": "L'ambiance est incroyable, la nourriture délicieuse...",
  "visit_date": "2026-01-15",
  "visit_type": "COUPLE",
  "recommendations": [
    "Réservez à l'avance",
    "Essayez le tajine"
  ],
  "photos": [
    {
      "data": "base64_encoded_image",
      "mime_type": "image/jpeg",
      "caption": "Vue de la terrasse"
    }
  ]
}
```

**Validation** :
- `site_id` : Existe
- `overall_rating` : 1.0 - 5.0 (requis)
- `service_rating`, etc. : 1.0 - 5.0 (optionnel)
- `title` : Max 255 caractères
- `content` : Min 20, max 2000 caractères
- `visit_type` : BUSINESS, COUPLE, FAMILY, FRIENDS, SOLO
- `photos` : Max 10 photos

**Response 201** :

```json
{
  "success": true,
  "message": "Review submitted successfully",
  "data": {
    "review": {
      "id": 9012,
      "user_id": 12345,
      "site_id": 123,
      "overall_rating": 4.5,
      "title": "Excellent restaurant",
      "content": "L'ambiance est incroyable...",
      "visit_date": "2026-01-15",
      "photos_count": 3,
      "points_earned": 20,
      "status": "PENDING",
      "moderation_status": "PENDING",
      "created_at": "2026-01-16T14:30:00.000Z"
    },
    "rewards": {
      "points_earned": 20,
      "total_points": 1285
    }
  }
}
```

---

### 7.2 GET /reviews

**Description** : Liste des avis de l'utilisateur

**Authentification** : Requise

**Response 200** : Liste d'avis avec pagination

---

### 7.3 GET /reviews/:id

**Description** : Détails d'un avis

**Response 200** :

```json
{
  "success": true,
  "data": {
    "id": 9012,
    "user": {
      "id": 12345,
      "first_name": "Ahmed",
      "last_name": "B.",
      "profile_picture": "https://s3.../profile.jpg",
      "level": 5,
      "rank": "GOLD",
      "reviews_count": 42
    },
    "site": {
      "id": 123,
      "name": "Rick's Café",
      "cover_photo": "https://s3.../cover.jpg"
    },
    "ratings": {
      "overall_rating": 4.5,
      "service_rating": 5.0,
      "cleanliness_rating": 4.5,
      "value_rating": 4.0,
      "location_rating": 5.0
    },
    "title": "Excellent restaurant",
    "content": "L'ambiance est incroyable...",
    "visit_date": "2026-01-15",
    "visit_type": "COUPLE",
    "recommendations": ["Réservez à l'avance"],
    "photos": [
      {
        "id": 2001,
        "url": "https://s3.../photo1.jpg",
        "thumbnail_url": "https://s3.../thumb1.jpg",
        "caption": "Vue de la terrasse"
      }
    ],
    "helpful_count": 28,
    "not_helpful_count": 2,
    "user_vote": "helpful",
    "has_owner_response": true,
    "owner_response": {
      "content": "Merci pour votre visite !",
      "date": "2026-01-17T09:00:00.000Z"
    },
    "status": "PUBLISHED",
    "created_at": "2026-01-16T14:30:00.000Z"
  }
}
```

---

### 7.4 PUT /reviews/:id

**Description** : Modifier son avis

**Authentification** : Requise (owner only)

**Request Body** : Partiel

**Response 200** : Avis mis à jour

---

### 7.5 DELETE /reviews/:id

**Description** : Supprimer son avis

**Authentification** : Requise (owner only)

**Response 204** : No Content

---

### 7.6 POST /reviews/:id/vote

**Description** : Voter pour un avis (utile/pas utile)

**Authentification** : Requise

**Request Body** :

```json
{
  "vote": "helpful"
}
```

**Values** : `helpful`, `not_helpful`

**Response 200** :

```json
{
  "success": true,
  "data": {
    "helpful_count": 29,
    "not_helpful_count": 2
  }
}
```

---

### 7.7 POST /reviews/:id/report

**Description** : Signaler un avis

**Authentification** : Requise

**Request Body** :

```json
{
  "reason": "SPAM",
  "details": "This is fake advertising"
}
```

**Reasons** : SPAM, INAPPROPRIATE, FAKE, OFFENSIVE, OTHER

**Response 200** :

```json
{
  "success": true,
  "message": "Review reported for moderation"
}
```

---

## 8. Endpoints Users

### 8.1 GET /users/me

**Description** : Profil de l'utilisateur connecté

**Authentification** : Requise

**Response 200** :

```json
{
  "success": true,
  "data": {
    "id": 12345,
    "email": "user@example.com",
    "first_name": "Ahmed",
    "last_name": "Benali",
    "phone_number": "+212612345678",
    "date_of_birth": "1990-05-15",
    "gender": "MALE",
    "nationality": "MA",
    "profile_picture": "https://s3.../profile.jpg",
    "bio": "Travel enthusiast...",
    "role": "CONTRIBUTOR",
    "status": "ACTIVE",
    "is_email_verified": true,
    "is_phone_verified": false,
    "points": 1285,
    "level": 5,
    "experience_points": 2500,
    "rank": "GOLD",
    "stats": {
      "checkins_count": 42,
      "reviews_count": 15,
      "photos_count": 68,
      "badges_count": 8,
      "favorites_count": 23
    },
    "created_at": "2025-12-01T10:00:00.000Z",
    "last_login_at": "2026-01-16T14:00:00.000Z"
  }
}
```

---

### 8.2 PUT /users/me

**Description** : Mettre à jour son profil

**Authentification** : Requise

**Request Body** :

```json
{
  "first_name": "Ahmed",
  "last_name": "Benali",
  "phone_number": "+212612345678",
  "bio": "Updated bio...",
  "profile_picture": "base64_encoded_image"
}
```

**Response 200** : Profil mis à jour

---

### 8.3 PUT /users/me/password

**Description** : Changer son mot de passe

**Authentification** : Requise

**Request Body** :

```json
{
  "current_password": "OldPass123!",
  "new_password": "NewPass456!"
}
```

**Response 200** :

```json
{
  "success": true,
  "message": "Password updated successfully"
}
```

---

### 8.4 GET /users/me/stats

**Description** : Statistiques détaillées de l'utilisateur

**Authentification** : Requise

**Response 200** :

```json
{
  "success": true,
  "data": {
    "points": {
      "total": 1285,
      "level": 5,
      "rank": "GOLD",
      "next_level_at": 2500,
      "progress_to_next_level": 52
    },
    "activity": {
      "checkins_count": 42,
      "reviews_count": 15,
      "photos_count": 68
    },
    "achievements": {
      "badges_earned": 8,
      "total_badges": 25,
      "completion_percentage": 32
    },
    "social": {
      "favorites_count": 23,
      "reviews_helpful_count": 156
    },
    "recent_activity": [
      {
        "type": "CHECKIN",
        "site_name": "Rick's Café",
        "points_earned": 15,
        "created_at": "2026-01-16T14:30:00.000Z"
      }
    ]
  }
}
```

---

### 8.5 GET /users/:id

**Description** : Profil public d'un utilisateur

**Authentification** : Non requise

**Response 200** : Profil public (sans données sensibles)

---

## 9. Endpoints Gamification

### 9.1 GET /badges

**Description** : Liste de tous les badges disponibles

**Response 200** :

```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "name": "First Steps",
      "name_ar": "الخطوات الأولى",
      "description": "Complete your first check-in",
      "description_ar": "أكمل أول تسجيل وصول",
      "icon": "https://s3.../badge1.png",
      "color": "#FFD700",
      "type": "CHECKIN_MILESTONE",
      "category": "EXPLORATION",
      "rarity": "COMMON",
      "requirements": {
        "required_checkins": 1
      },
      "points_reward": 10,
      "total_awarded": 5234,
      "is_active": true
    }
  ]
}
```

---

### 9.2 GET /users/me/badges

**Description** : Badges de l'utilisateur

**Authentification** : Requise

**Response 200** :

```json
{
  "success": true,
  "data": {
    "earned": [
      {
        "badge": {
          "id": 1,
          "name": "First Steps",
          "icon": "https://s3.../badge1.png"
        },
        "earned_at": "2025-12-05T10:30:00.000Z",
        "is_displayed": true
      }
    ],
    "progress": [
      {
        "badge": {
          "id": 2,
          "name": "Explorer",
          "requirements": { "required_checkins": 10 }
        },
        "current_progress": 8,
        "completion_percentage": 80
      }
    ]
  }
}
```

---

### 9.3 GET /leaderboard

**Description** : Classement des utilisateurs

**Query Parameters** :
- `timeframe` : `all_time`, `monthly`, `weekly` (défaut: all_time)
- `limit` : Max 100 (défaut: 50)

**Response 200** :

```json
{
  "success": true,
  "data": {
    "current_user": {
      "rank": 42,
      "points": 1285
    },
    "leaderboard": [
      {
        "rank": 1,
        "user": {
          "id": 789,
          "first_name": "Fatima",
          "last_name": "A.",
          "profile_picture": "https://s3.../profile.jpg",
          "level": 8,
          "rank": "PLATINUM"
        },
        "points": 12500,
        "stats": {
          "checkins_count": 523,
          "reviews_count": 198,
          "badges_count": 24
        }
      }
    ]
  }
}
```

---

## 10. Endpoints Subscriptions & Payments

### 10.1 GET /subscriptions/plans

**Description** : Plans d'abonnement disponibles

**Response 200** :

```json
{
  "success": true,
  "data": [
    {
      "id": "basic",
      "name": "Basic",
      "description": "For small businesses",
      "price": {
        "monthly": 199.00,
        "quarterly": 499.00,
        "yearly": 1799.00,
        "currency": "MAD"
      },
      "features": {
        "max_photos": 50,
        "can_respond": true,
        "has_analytics": false,
        "has_priority_support": false,
        "is_featured": false
      }
    },
    {
      "id": "pro",
      "name": "Pro",
      "description": "For growing businesses",
      "price": {
        "monthly": 399.00,
        "quarterly": 999.00,
        "yearly": 3599.00,
        "currency": "MAD"
      },
      "features": {
        "max_photos": 200,
        "can_respond": true,
        "has_analytics": true,
        "has_priority_support": false,
        "is_featured": true
      }
    }
  ]
}
```

---

### 10.2 POST /subscriptions

**Description** : Créer un abonnement

**Authentification** : Requise (PROFESSIONAL)

**Request Body** :

```json
{
  "plan": "PRO",
  "billing_cycle": "MONTHLY",
  "site_id": 123,
  "payment_method_id": "pm_1A2B3C4D"
}
```

**Response 201** :

```json
{
  "success": true,
  "message": "Subscription created successfully",
  "data": {
    "subscription": {
      "id": 456,
      "plan": "PRO",
      "billing_cycle": "MONTHLY",
      "price": 399.00,
      "status": "ACTIVE",
      "start_date": "2026-01-16T14:30:00.000Z",
      "end_date": "2026-02-16T14:30:00.000Z",
      "next_billing_date": "2026-02-16T00:00:00.000Z"
    },
    "payment": {
      "id": 789,
      "amount": 399.00,
      "status": "SUCCEEDED",
      "receipt_url": "https://stripe.com/receipts/..."
    }
  }
}
```

---

### 10.3 GET /subscriptions/me

**Description** : Abonnements de l'utilisateur

**Authentification** : Requise (PROFESSIONAL)

**Response 200** : Liste des abonnements

---

### 10.4 PUT /subscriptions/:id

**Description** : Modifier un abonnement

**Request Body** :

```json
{
  "plan": "PREMIUM",
  "billing_cycle": "YEARLY"
}
```

**Response 200** : Abonnement mis à jour

---

### 10.5 DELETE /subscriptions/:id

**Description** : Annuler un abonnement

**Response 200** :

```json
{
  "success": true,
  "message": "Subscription will be cancelled at the end of billing period",
  "data": {
    "cancelled_at": "2026-01-16T14:30:00.000Z",
    "end_date": "2026-02-16T14:30:00.000Z"
  }
}
```

---

### 10.6 GET /payments

**Description** : Historique des paiements

**Authentification** : Requise (PROFESSIONAL)

**Response 200** : Liste des paiements avec pagination

---

## 11. Endpoints Admin

### 11.1 GET /admin/sites

**Description** : Liste des sites (avec filtres admin)

**Authentification** : Requise (MODERATOR, ADMIN)

**Query Parameters** :
- `status` : DRAFT, PENDING_REVIEW, PUBLISHED, ARCHIVED, REPORTED
- `verification_status` : PENDING, VERIFIED, REJECTED

**Response 200** : Liste complète avec statuts

---

### 11.2 PUT /admin/sites/:id/validate

**Description** : Valider un site

**Authentification** : Requise (MODERATOR, ADMIN)

**Request Body** :

```json
{
  "verification_status": "VERIFIED",
  "notes": "Site verified, all information correct"
}
```

**Response 200** : Site validé

---

### 11.3 GET /admin/reviews

**Description** : Avis à modérer

**Authentification** : Requise (MODERATOR, ADMIN)

**Query Parameters** :
- `moderation_status` : PENDING, APPROVED, REJECTED, FLAGGED, SPAM

**Response 200** : Liste des avis

---

### 11.4 PUT /admin/reviews/:id/moderate

**Description** : Modérer un avis

**Request Body** :

```json
{
  "moderation_status": "APPROVED",
  "moderation_notes": "Content is appropriate"
}
```

**Response 200** : Avis modéré

---

### 11.5 GET /admin/users

**Description** : Liste des utilisateurs

**Authentification** : Requise (ADMIN)

**Response 200** : Liste des utilisateurs avec filtres

---

### 11.6 PUT /admin/users/:id/suspend

**Description** : Suspendre un utilisateur

**Request Body** :

```json
{
  "reason": "Spam content",
  "duration_days": 30
}
```

**Response 200** : Utilisateur suspendu

---

## 12. Schémas de Données

### User Schema

```yaml
User:
  type: object
  properties:
    id:
      type: integer
    email:
      type: string
      format: email
    first_name:
      type: string
    last_name:
      type: string
    role:
      type: string
      enum: [TOURIST, CONTRIBUTOR, PROFESSIONAL, MODERATOR, ADMIN]
    status:
      type: string
      enum: [ACTIVE, INACTIVE, SUSPENDED, BANNED, PENDING_VERIFICATION]
    points:
      type: integer
    level:
      type: integer
    rank:
      type: string
      enum: [BRONZE, SILVER, GOLD, PLATINUM]
    created_at:
      type: string
      format: date-time
```

### Site Schema

```yaml
TouristSite:
  type: object
  properties:
    id:
      type: integer
    name:
      type: string
    category:
      $ref: '#/components/schemas/Category'
    location:
      $ref: '#/components/schemas/Location'
    ratings:
      $ref: '#/components/schemas/Ratings'
    freshness:
      $ref: '#/components/schemas/Freshness'
```

---

## 13. Codes d'Erreur

| Code | Message | Description |
|------|---------|-------------|
| `VALIDATION_ERROR` | Invalid input data | Données de validation échouée |
| `AUTHENTICATION_REQUIRED` | Authentication required | Token manquant/invalide |
| `PERMISSION_DENIED` | Insufficient permissions | Permissions insuffisantes |
| `RESOURCE_NOT_FOUND` | Resource not found | Ressource introuvable |
| `DUPLICATE_ENTRY` | Duplicate entry | Entrée dupliquée (email, etc.) |
| `RATE_LIMIT_EXCEEDED` | Too many requests | Rate limit dépassé |
| `COOLDOWN_ACTIVE` | Action on cooldown | Cooldown actif (check-in) |
| `DISTANCE_TOO_LARGE` | GPS distance too large | Distance GPS >100m |
| `INTERNAL_ERROR` | Internal server error | Erreur serveur |

---

## 14. Exemples cURL

### Register

```bash
curl -X POST https://api.moroccocheck.com/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "user@example.com",
    "password": "SecurePass123!",
    "first_name": "Ahmed",
    "last_name": "Benali"
  }'
```

### Login

```bash
curl -X POST https://api.moroccocheck.com/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "user@example.com",
    "password": "SecurePass123!"
  }'
```

### Get Sites

```bash
curl -X GET "https://api.moroccocheck.com/v1/sites?city=Casablanca&min_rating=4.0&limit=10" \
  -H "Accept: application/json"
```

### Create Check-in

```bash
curl -X POST https://api.moroccocheck.com/v1/checkins \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <access_token>" \
  -d '{
    "site_id": 123,
    "status": "OPEN",
    "comment": "Great place!",
    "latitude": 33.5732,
    "longitude": -7.5899,
    "accuracy": 5.2
  }'
```

### Create Review

```bash
curl -X POST https://api.moroccocheck.com/v1/reviews \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <access_token>" \
  -d '{
    "site_id": 123,
    "overall_rating": 4.5,
    "title": "Excellent!",
    "content": "Amazing experience, highly recommended..."
  }'
```

---

## Conclusion

Cette API REST fournit toutes les fonctionnalités nécessaires pour :

✅ **Authentification** - JWT + OAuth 2.0 (Google, Facebook, Apple)
✅ **Gestion Sites** - CRUD complet avec recherche avancée
✅ **Check-ins GPS** - Validation stricte distance + cooldown
✅ **Avis & Notes** - Système de review complet avec modération
✅ **Gamification** - Points, badges, niveaux, classement
✅ **Abonnements** - Plans professionnels avec Stripe
✅ **Administration** - Modération et gestion utilisateurs

**Total Endpoints** : 60+

---

**Document créé le 16 janvier 2026**  
**MoroccoCheck - Phase 3.4 : Spécifications API**  
**Version 1.0 - Complet**
