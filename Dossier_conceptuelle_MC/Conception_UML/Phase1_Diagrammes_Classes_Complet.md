# Phase 1 : Conception Détaillée - Diagrammes de Classes
## MoroccoCheck - Application Mobile Touristique

*Document créé le 16 janvier 2026*

---

## Table des Matières

1. [Introduction](#1-introduction)
2. [Diagrammes de Classes - Couche Domain](#2-diagrammes-de-classes---couche-domain)
3. [Diagrammes de Classes - Couche Services](#3-diagrammes-de-classes---couche-services)
4. [Diagrammes de Classes - Couche Controllers](#4-diagrammes-de-classes---couche-controllers)
5. [Diagrammes de Classes - Couche Providers](#5-diagrammes-de-classes---couche-providers-flutter)
6. [Relations et Cardinalités](#6-relations-et-cardinalités)
7. [Patterns de Conception](#7-patterns-de-conception-utilisés)
8. [Résumé](#8-résumé-des-classes-par-couche)

---

## 1. Introduction

### 1.1 Objectif

Ce document présente les **diagrammes de classes détaillés** du système MoroccoCheck, organisés par couches architecturales conformément aux meilleures pratiques de développement logiciel.

### 1.2 Organisation

Les classes sont organisées en **4 couches principales** :

- **Domain (Modèles)** : Entités métier représentant les données
- **Services** : Logique métier et règles business  
- **Controllers** : Gestion des requêtes HTTP (Backend Node.js)
- **Providers** : Gestion d'état (Frontend Flutter)

### 1.3 Conventions UML

- `+` : Attribut/Méthode publique
- `-` : Attribut/Méthode privée
- `#` : Attribut/Méthode protégée
- `{abstract}` : Classe abstraite
- `<<interface>>` : Interface
- `1..N` : Cardinalité (un à plusieurs)
- `N..M` : Cardinalité (plusieurs à plusieurs)

---

## 2. Diagrammes de Classes - Couche Domain

Les classes de la couche Domain représentent les entités métier du système. Elles correspondent directement aux tables de la base de données.

### 2.1 Classe User

**Description** : Représente un utilisateur du système (touriste, contributeur, professionnel, modérateur ou admin).

```
┌─────────────────────────────────────────────────────────────────┐
│                            User                                  │
├─────────────────────────────────────────────────────────────────┤
│ ATTRIBUTS IDENTITÉ                                               │
│ - id: int                                                        │
│ - email: string                                                  │
│ - password: string (hashed avec bcrypt)                          │
│ - firstName: string                                              │
│ - lastName: string                                               │
│ - role: UserRole (enum)                                          │
│                                                                   │
│ ATTRIBUTS PROFIL                                                 │
│ - phoneNumber: string?                                           │
│ - profilePicture: string? (URL S3)                               │
│ - dateOfBirth: Date?                                             │
│ - gender: Gender? (enum)                                         │
│ - nationality: string?                                           │
│ - bio: string? (max 500 caractères)                              │
│                                                                   │
│ ATTRIBUTS VÉRIFICATION                                           │
│ - isEmailVerified: boolean                                       │
│ - isPhoneVerified: boolean                                       │
│ - status: UserStatus (enum)                                      │
│ - lastLoginAt: Date?                                             │
│                                                                   │
│ ATTRIBUTS GAMIFICATION                                           │
│ - points: int (défaut: 0)                                        │
│ - level: int (défaut: 1)                                         │
│ - experiencePoints: int                                          │
│ - rank: string (Bronze/Argent/Or/Platine)                        │
│ - checkinsCount: int                                             │
│ - reviewsCount: int                                              │
│ - photosCount: int                                               │
│                                                                   │
│ ATTRIBUTS OAUTH                                                  │
│ - googleId: string?                                              │
│ - facebookId: string?                                            │
│ - appleId: string?                                               │
│                                                                   │
│ MÉTADONNÉES                                                      │
│ - createdAt: Date                                                │
│ - updatedAt: Date                                                │
├─────────────────────────────────────────────────────────────────┤
│ MÉTHODES PUBLIQUES                                               │
│ + constructor(data: UserData)                                    │
│ + getFullName(): string                                          │
│ + getAge(): int                                                  │
│ + isContributor(): boolean                                       │
│ + isProfessional(): boolean                                      │
│ + isAdmin(): boolean                                             │
│ + isModerator(): boolean                                         │
│ + canCheckIn(): boolean                                          │
│ + canReview(): boolean                                           │
│ + calculateLevel(): int                                          │
│ + getNextLevelPoints(): int                                      │
│ + getLevelProgress(): float (0-1)                                │
│ + getRankBadge(): string                                         │
│ + addPoints(points: int): void                                   │
│ + removePoints(points: int): void                                │
│ + updateLastLogin(): void                                        │
│ + verifyEmail(): void                                            │
│ + verifyPhone(): void                                            │
│ + toJSON(): object                                               │
│ + fromJSON(json: object): User                                   │
└─────────────────────────────────────────────────────────────────┘
```

**Enums associés** :

```
┌──────────────────────┐
│     UserRole         │
├──────────────────────┤
│ TOURIST              │
│ CONTRIBUTOR          │
│ PROFESSIONAL         │
│ MODERATOR            │
│ ADMIN                │
└──────────────────────┘

┌──────────────────────┐
│     UserStatus       │
├──────────────────────┤
│ ACTIVE               │
│ INACTIVE             │
│ SUSPENDED            │
│ BANNED               │
│ PENDING_VERIFICATION │
└──────────────────────┘

┌──────────────────────┐
│       Gender         │
├──────────────────────┤
│ MALE                 │
│ FEMALE               │
│ OTHER                │
│ PREFER_NOT_TO_SAY    │
└──────────────────────┘
```

### 2.2 Classe TouristSite

**Description** : Représente un site touristique (restaurant, hôtel, musée, etc.).

```
┌─────────────────────────────────────────────────────────────────┐
│                         TouristSite                              │
├─────────────────────────────────────────────────────────────────┤
│ ATTRIBUTS BASIQUES                                               │
│ - id: int                                                        │
│ - name: string                                                   │
│ - nameAr: string? (nom en arabe)                                 │
│ - description: string                                            │
│ - descriptionAr: string?                                         │
│ - category: SiteCategory (enum)                                  │
│ - subcategory: string?                                           │
│                                                                   │
│ ATTRIBUTS LOCALISATION                                           │
│ - latitude: double                                               │
│ - longitude: double                                              │
│ - address: string                                                │
│ - city: string                                                   │
│ - region: string                                                 │
│ - postalCode: string?                                            │
│ - country: string (défaut: "Morocco")                            │
│                                                                   │
│ ATTRIBUTS CONTACT                                                │
│ - phoneNumber: string?                                           │
│ - email: string?                                                 │
│ - website: string?                                               │
│ - socialMedia: SocialMediaLinks? (JSON)                          │
│                                                                   │
│ ATTRIBUTS BUSINESS                                               │
│ - openingHours: OpeningHours[] (JSON)                            │
│ - priceRange: PriceRange (enum)                                  │
│ - acceptsCardPayment: boolean                                    │
│ - hasWifi: boolean                                               │
│ - hasParking: boolean                                            │
│ - isAccessible: boolean                                          │
│ - amenities: string[] (JSON)                                     │
│                                                                   │
│ ATTRIBUTS RATINGS & FRAÎCHEUR                                    │
│ - averageRating: double (0-5)                                    │
│ - totalReviews: int                                              │
│ - freshnessScore: int (0-100)                                    │
│ - freshnessStatus: FreshnessStatus (enum)                        │
│ - lastVerifiedAt: Date?                                          │
│ - lastUpdatedAt: Date?                                           │
│                                                                   │
│ ATTRIBUTS MÉDIA                                                  │
│ - coverPhoto: string? (URL)                                      │
│ - photos: Photo[] (relation 1:N)                                 │
│                                                                   │
│ ATTRIBUTS PROFESSIONNEL                                          │
│ - ownerId: int? (User ID du propriétaire)                        │
│ - isProfessionalClaimed: boolean                                 │
│ - subscriptionPlan: SubscriptionPlan? (enum)                     │
│                                                                   │
│ ATTRIBUTS STATUT                                                 │
│ - status: SiteStatus (enum)                                      │
│ - verificationStatus: VerificationStatus (enum)                  │
│ - isActive: boolean                                              │
│ - isFeatured: boolean                                            │
│ - viewsCount: int                                                │
│ - favoritesCount: int                                            │
│                                                                   │
│ MÉTADONNÉES                                                      │
│ - createdAt: Date                                                │
│ - updatedAt: Date                                                │
├─────────────────────────────────────────────────────────────────┤
│ MÉTHODES PUBLIQUES                                               │
│ + constructor(data: SiteData)                                    │
│                                                                   │
│ FRAÎCHEUR                                                        │
│ + calculateFreshness(): int                                      │
│ + updateFreshnessStatus(): void                                  │
│ + getFreshnessColor(): string (#00FF00, #FFA500, #FF0000, #808080)│
│ + getFreshnessLabel(): string                                    │
│ + getDaysSinceLastVerification(): int                            │
│ + needsVerification(): boolean                                   │
│                                                                   │
│ RATINGS                                                          │
│ + updateRating(newRating: double): void                          │
│                                                                   │
│ GÉOLOCALISATION                                                  │
│ + getDistance(userLat: double, userLng: double): double          │
│ + isWithinRadius(userLat: double, userLng: double,               │
│   radius: int): boolean                                          │
│                                                                   │
│ HORAIRES                                                         │
│ + isOpen(): boolean                                              │
│ + isOpenAt(datetime: Date): boolean                              │
│ + getCurrentOpeningHours(): OpeningHours?                        │
│ + getTodaySchedule(): string                                     │
│                                                                   │
│ MÉDIA                                                            │
│ + addPhoto(photo: Photo): void                                   │
│ + removePhoto(photoId: int): void                                │
│                                                                   │
│ STATISTIQUES                                                     │
│ + incrementViews(): void                                         │
│ + incrementFavorites(): void                                     │
│                                                                   │
│ PROFESSIONNEL                                                    │
│ + claimByProfessional(userId: int): void                         │
│ + upgradePlan(plan: SubscriptionPlan): void                      │
│                                                                   │
│ SÉRIALISATION                                                    │
│ + toJSON(): object                                               │
│ + fromJSON(json: object): TouristSite                            │
└─────────────────────────────────────────────────────────────────┘
```

**Enums et Types associés** :

```
┌──────────────────────┐         ┌──────────────────────┐
│   SiteCategory       │         │  FreshnessStatus     │
├──────────────────────┤         ├──────────────────────┤
│ RESTAURANT           │         │ FRESH (< 24h)        │
│ HOTEL                │         │ RECENT (< 7 days)    │
│ MUSEUM               │         │ OLD (< 30 days)      │
│ HISTORICAL_SITE      │         │ OBSOLETE (> 30 days) │
│ BEACH                │         └──────────────────────┘
│ PARK                 │
│ SHOPPING             │         ┌──────────────────────┐
│ ENTERTAINMENT        │         │    PriceRange        │
│ RELIGIOUS_SITE       │         ├──────────────────────┤
│ NATURAL_SITE         │         │ BUDGET ($)           │
│ ACTIVITY             │         │ MODERATE ($$)        │
│ TRANSPORT            │         │ EXPENSIVE ($$$)      │
│ OTHER                │         │ LUXURY ($$$$)        │
└──────────────────────┘         └──────────────────────┘

┌──────────────────────┐         ┌──────────────────────┐
│    SiteStatus        │         │ VerificationStatus   │
├──────────────────────┤         ├──────────────────────┤
│ DRAFT                │         │ PENDING              │
│ PENDING_REVIEW       │         │ VERIFIED             │
│ PUBLISHED            │         │ REJECTED             │
│ ARCHIVED             │         └──────────────────────┘
│ REPORTED             │
└──────────────────────┘
```

---


### 2.3 Classe CheckIn

**Description** : Représente une vérification/validation d'un site touristique par un utilisateur sur place.

```
┌─────────────────────────────────────────────────────────────────┐
│                           CheckIn                                │
├─────────────────────────────────────────────────────────────────┤
│ ATTRIBUTS BASIQUES                                               │
│ - id: int                                                        │
│ - userId: int (FK → users.id)                                    │
│ - siteId: int (FK → tourist_sites.id)                            │
│                                                                   │
│ ATTRIBUTS STATUT                                                 │
│ - status: CheckInStatus (enum)                                   │
│ - comment: string? (max 500 caractères)                          │
│ - verificationNotes: string?                                     │
│                                                                   │
│ ATTRIBUTS LOCALISATION                                           │
│ - latitude: double                                               │
│ - longitude: double                                              │
│ - accuracy: double (précision en mètres)                         │
│ - distance: double (distance du site en mètres)                  │
│ - isLocationVerified: boolean                                    │
│                                                                   │
│ ATTRIBUTS MÉDIA                                                  │
│ - photos: Photo[] (relation 1:N)                                 │
│ - hasPhoto: boolean                                              │
│                                                                   │
│ ATTRIBUTS GAMIFICATION                                           │
│ - pointsEarned: int (10 points base + 5 si photo)                │
│ - badgesEarned: Badge[]                                          │
│                                                                   │
│ ATTRIBUTS VALIDATION                                             │
│ - validationStatus: ValidationStatus (enum)                      │
│ - validatedBy: int? (FK → users.id moderator)                    │
│ - validatedAt: Date?                                             │
│ - rejectionReason: string?                                       │
│                                                                   │
│ MÉTADONNÉES                                                      │
│ - deviceInfo: DeviceInfo? (JSON)                                 │
│ - ipAddress: string?                                             │
│ - createdAt: Date                                                │
│ - updatedAt: Date                                                │
├─────────────────────────────────────────────────────────────────┤
│ MÉTHODES PUBLIQUES                                               │
│ + constructor(data: CheckInData)                                 │
│                                                                   │
│ VALIDATION GÉOLOCALISATION                                       │
│ + validateLocation(siteLat: double, siteLng: double): boolean    │
│ + calculateDistance(lat1: double, lng1: double,                  │
│   lat2: double, lng2: double): double                            │
│ + isWithinAllowedRadius(): boolean (rayon 100m)                  │
│                                                                   │
│ GAMIFICATION                                                     │
│ + calculatePoints(): int                                         │
│                                                                   │
│ MÉDIA                                                            │
│ + addPhoto(photo: Photo): void                                   │
│ + removePhoto(photoId: int): void                                │
│                                                                   │
│ MODÉRATION                                                       │
│ + approve(moderatorId: int): void                                │
│ + reject(moderatorId: int, reason: string): void                 │
│                                                                   │
│ MISE À JOUR                                                      │
│ + updateSiteFreshness(): void                                    │
│ + notifyUser(): void                                             │
│                                                                   │
│ SÉRIALISATION                                                    │
│ + toJSON(): object                                               │
│ + fromJSON(json: object): CheckIn                                │
└─────────────────────────────────────────────────────────────────┘
```

**Enums associés** :

```
┌──────────────────────┐         ┌──────────────────────┐
│  CheckInStatus       │         │  ValidationStatus    │
├──────────────────────┤         ├──────────────────────┤
│ OPEN                 │         │ PENDING              │
│ CLOSED_TEMPORARILY   │         │ APPROVED             │
│ CLOSED_PERMANENTLY   │         │ REJECTED             │
│ RENOVATING           │         │ FLAGGED              │
│ RELOCATED            │         └──────────────────────┘
│ NO_CHANGE            │
└──────────────────────┘
```

### 2.4 Classe Review

**Description** : Représente un avis détaillé sur un site touristique.

```
┌─────────────────────────────────────────────────────────────────┐
│                            Review                                │
├─────────────────────────────────────────────────────────────────┤
│ ATTRIBUTS BASIQUES                                               │
│ - id: int                                                        │
│ - userId: int (FK → users.id)                                    │
│ - siteId: int (FK → tourist_sites.id)                            │
│                                                                   │
│ ATTRIBUTS RATING                                                 │
│ - overallRating: double (1-5, requis)                            │
│ - serviceRating: double? (1-5)                                   │
│ - cleanlinessRating: double? (1-5)                               │
│ - valueRating: double? (1-5, rapport qualité/prix)               │
│ - locationRating: double? (1-5)                                  │
│                                                                   │
│ ATTRIBUTS CONTENU                                                │
│ - title: string? (max 100 caractères)                            │
│ - content: string (min 20, max 2000 caractères)                  │
│ - visitDate: Date?                                               │
│ - visitType: VisitType? (enum)                                   │
│ - recommendations: string[]? (JSON)                              │
│                                                                   │
│ ATTRIBUTS MÉDIA                                                  │
│ - photos: Photo[] (max 10 photos)                                │
│                                                                   │
│ ATTRIBUTS ENGAGEMENT                                             │
│ - helpfulCount: int (nombre de votes "utile")                    │
│ - notHelpfulCount: int                                           │
│ - reportsCount: int                                              │
│                                                                   │
│ ATTRIBUTS MODÉRATION                                             │
│ - status: ReviewStatus (enum)                                    │
│ - moderationStatus: ModerationStatus (enum)                      │
│ - moderatedBy: int? (FK → users.id)                              │
│ - moderatedAt: Date?                                             │
│ - moderationNotes: string?                                       │
│                                                                   │
│ ATTRIBUTS RÉPONSE PROPRIÉTAIRE                                   │
│ - hasOwnerResponse: boolean                                      │
│ - ownerResponse: string? (max 1000 caractères)                   │
│ - ownerResponseDate: Date?                                       │
│                                                                   │
│ ATTRIBUTS GAMIFICATION                                           │
│ - pointsEarned: int (15 points + 5 par photo)                    │
│                                                                   │
│ MÉTADONNÉES                                                      │
│ - createdAt: Date                                                │
│ - updatedAt: Date                                                │
├─────────────────────────────────────────────────────────────────┤
│ MÉTHODES PUBLIQUES                                               │
│ + constructor(data: ReviewData)                                  │
│                                                                   │
│ RATING                                                           │
│ + calculateAverageRating(): double                               │
│                                                                   │
│ MÉDIA                                                            │
│ + addPhoto(photo: Photo): void                                   │
│ + removePhoto(photoId: int): void                                │
│                                                                   │
│ ENGAGEMENT                                                       │
│ + markAsHelpful(userId: int): void                               │
│ + markAsNotHelpful(userId: int): void                            │
│ + reportReview(userId: int, reason: string): void                │
│                                                                   │
│ RÉPONSE PROPRIÉTAIRE                                             │
│ + addOwnerResponse(response: string, ownerId: int): void         │
│ + updateOwnerResponse(response: string): void                    │
│ + deleteOwnerResponse(): void                                    │
│                                                                   │
│ MODÉRATION                                                       │
│ + approve(moderatorId: int): void                                │
│ + reject(moderatorId: int, reason: string): void                 │
│                                                                   │
│ GAMIFICATION                                                     │
│ + calculatePoints(): int                                         │
│                                                                   │
│ VALIDATION                                                       │
│ + isRecent(): boolean (< 30 jours)                               │
│ + isVerifiedReview(): boolean                                    │
│                                                                   │
│ SÉRIALISATION                                                    │
│ + toJSON(): object                                               │
│ + fromJSON(json: object): Review                                 │
└─────────────────────────────────────────────────────────────────┘
```

**Enums associés** :

```
┌──────────────────────┐
│    VisitType         │
├──────────────────────┤
│ BUSINESS             │
│ COUPLE               │
│ FAMILY               │
│ FRIENDS              │
│ SOLO                 │
└──────────────────────┘

┌──────────────────────┐
│   ReviewStatus       │
├──────────────────────┤
│ PENDING              │
│ PUBLISHED            │
│ HIDDEN               │
│ DELETED              │
└──────────────────────┘

┌──────────────────────┐
│  ModerationStatus    │
├──────────────────────┤
│ PENDING              │
│ APPROVED             │
│ REJECTED             │
│ FLAGGED              │
│ SPAM                 │
└──────────────────────┘
```

---

## 6. Relations et Cardinalités

### 6.1 Diagramme de Relations Entités (ERD)

```
                    ┌──────────────┐
                    │     USER     │
                    └──────┬───────┘
                           │
        ┌──────────────────┼──────────────────────┐
        │                  │                      │
        │ 1                │ 1                    │ 1
        ▼ N                ▼ N                    ▼ N
  ┌──────────┐      ┌──────────┐           ┌─────────────┐
  │ CHECKIN  │      │  REVIEW  │           │NOTIFICATION │
  └────┬─────┘      └────┬─────┘           └─────────────┘
       │ N               │ N
       │                 │
       │ 1               │ 1
       ▼                 ▼
    ┌──────────────────────────┐
    │    TOURIST_SITE          │
    └──────────┬───────────────┘
               │ 1
               ▼ N
        ┌──────────┐
        │  PHOTO   │
        └──────────┘

┌──────────┐      ┌────────────┐
│   USER   │  N:M │   BADGE    │
└────┬─────┘      └─────┬──────┘
     │                  │
     └────► ┌──────────┐◄┘
          1 │USER_BADGE│ 1
            └──────────┘

┌──────────────┐
│     USER     │
│(Professional)│
└──────┬───────┘
       │ 1
       ▼ N
┌────────────────┐
│ SUBSCRIPTION   │
└────────┬───────┘
         │ 1
         ▼ N
    ┌──────────┐
    │ PAYMENT  │
    └──────────┘
```

### 6.2 Cardinalités Détaillées

| Relation | De | Vers | Cardinalité | Description |
|----------|-----|------|-------------|-------------|
| User → CheckIn | User | CheckIn | 1:N | Un utilisateur peut faire plusieurs check-ins |
| User → Review | User | Review | 1:N | Un utilisateur peut écrire plusieurs avis |
| User ↔ Badge | User | Badge | N:M | Association via UserBadge |
| User → Subscription | User | Subscription | 1:N | Historique d'abonnements |
| User → Payment | User | Payment | 1:N | Plusieurs paiements |
| User → Notification | User | Notification | 1:N | Plusieurs notifications |
| TouristSite → CheckIn | TouristSite | CheckIn | 1:N | Un site a plusieurs check-ins |
| TouristSite → Review | TouristSite | Review | 1:N | Un site a plusieurs avis |
| TouristSite → Photo | TouristSite | Photo | 1:N | Un site a plusieurs photos |
| Review → Photo | Review | Photo | 1:N | Un avis peut avoir jusqu'à 10 photos |
| CheckIn → Photo | CheckIn | Photo | 1:N | Un check-in peut avoir des photos |
| Subscription → Payment | Subscription | Payment | 1:N | Un abonnement a plusieurs paiements |

---

## 7. Patterns de Conception Utilisés

### 7.1 Repository Pattern

**Objectif** : Abstraction de la couche d'accès aux données

**Application** :
```
UserRepository
├─ findById(id: int): Promise<User>
├─ findByEmail(email: string): Promise<User>
├─ create(userData: UserData): Promise<User>
├─ update(id: int, data: UpdateUserDTO): Promise<User>
├─ delete(id: int): Promise<boolean>
└─ findAll(filters: UserFilters): Promise<User[]>
```

**Avantages** :
- Séparation claire entre logique métier et accès données
- Facilite les tests unitaires (mocking)
- Permet de changer de base de données facilement

### 7.2 Service Layer Pattern

**Objectif** : Encapsulation de la logique métier

**Architecture** :
```
Controller ──► Service ──► Repository ──► Database

Exemple :
CheckInController
    └──► CheckInService
            ├──► CheckInRepository
            ├──► SiteRepository
            ├──► UserRepository
            └──► GamificationService
```

**Avantages** :
- Logique métier centralisée
- Réutilisabilité des services
- Testabilité améliorée

### 7.3 Provider Pattern (Flutter)

**Objectif** : Gestion d'état réactive

**Utilisation** :
```dart
class AuthProvider extends ChangeNotifier {
  User? _currentUser;
  
  Future<void> login(String email, String password) async {
    // Login logic
    _currentUser = user;
    notifyListeners(); // Update UI
  }
}
```

**Avantages** :
- State management simplifié
- UI mise à jour automatiquement
- Performance optimisée

### 7.4 DTO (Data Transfer Object) Pattern

**Objectif** : Objets pour transférer des données entre couches

**Exemples** :
```typescript
// Création d'un site
interface CreateSiteDTO {
  name: string;
  category: SiteCategory;
  latitude: number;
  longitude: number;
  description: string;
  // ... autres champs
}

// Inscription utilisateur
interface RegisterDTO {
  email: string;
  password: string;
  firstName: string;
  lastName: string;
}
```

**Avantages** :
- Validation des données d'entrée
- Sécurité (ne pas exposer tous les champs)
- Documentation claire des API

### 7.5 Strategy Pattern

**Objectif** : Algorithmes interchangeables

**Application - Calcul de fraîcheur** :
```typescript
interface FreshnessStrategy {
  calculate(site: TouristSite): number;
}

class TimeBasedStrategy implements FreshnessStrategy {
  calculate(site: TouristSite): number {
    const daysSinceUpdate = 
      (Date.now() - site.lastVerifiedAt) / (1000 * 60 * 60 * 24);
    
    if (daysSinceUpdate < 1) return 100;
    if (daysSinceUpdate < 7) return 80;
    if (daysSinceUpdate < 30) return 50;
    return 20;
  }
}

class ActivityBasedStrategy implements FreshnessStrategy {
  calculate(site: TouristSite): number {
    // Calcul basé sur l'activité (check-ins, avis)
    const recentActivity = site.checkinsCount + site.reviewsCount;
    return Math.min(100, recentActivity * 5);
  }
}
```

### 7.6 Factory Pattern

**Objectif** : Création d'objets complexes

**Application - Notifications** :
```typescript
class NotificationFactory {
  static createBadgeNotification(
    userId: number, 
    badge: Badge
  ): Notification {
    return new Notification({
      userId,
      type: NotificationType.BADGE_EARNED,
      title: `Nouveau badge: ${badge.name}`,
      message: badge.description,
      icon: badge.icon,
      relatedEntityType: 'badge',
      relatedEntityId: badge.id
    });
  }
  
  static createLevelUpNotification(
    userId: number, 
    newLevel: number
  ): Notification {
    return new Notification({
      userId,
      type: NotificationType.LEVEL_UP,
      title: `Niveau ${newLevel} atteint!`,
      message: `Félicitations! Vous êtes maintenant niveau ${newLevel}`,
      // ...
    });
  }
}
```

### 7.7 Singleton Pattern

**Objectif** : Une seule instance de classe

**Application** :
```typescript
class ApiService {
  private static instance: ApiService;
  
  private constructor() {
    // Configuration
  }
  
  public static getInstance(): ApiService {
    if (!ApiService.instance) {
      ApiService.instance = new ApiService();
    }
    return ApiService.instance;
  }
}
```

**Classes utilisant Singleton** :
- ApiService
- DatabaseConnection
- CacheService
- ConfigService

### 7.8 Middleware Pattern

**Objectif** : Chaîne de traitement des requêtes HTTP

**Application Express.js** :
```typescript
app.post('/api/sites',
  authMiddleware,           // Vérifie JWT token
  roleMiddleware(['CONTRIBUTOR']), // Vérifie rôle
  validationMiddleware,     // Valide données
  SiteController.createSite // Traite requête
);
```

**Middlewares disponibles** :
- `authMiddleware` - Authentification JWT
- `roleMiddleware` - Autorisation par rôle
- `validationMiddleware` - Validation données
- `rateLimitMiddleware` - Limitation taux requêtes
- `errorMiddleware` - Gestion erreurs
- `loggingMiddleware` - Logs requêtes

---

## 8. Résumé des Classes par Couche

### 8.1 Couche Domain (10 classes principales)

| Classe | Responsabilité | Relations clés |
|--------|---------------|----------------|
| User | Utilisateur système | 1:N avec CheckIn, Review, Notification |
| TouristSite | Site touristique | 1:N avec CheckIn, Review, Photo |
| CheckIn | Vérification site | N:1 avec User, TouristSite |
| Review | Avis détaillé | N:1 avec User, TouristSite |
| Badge | Badge gamification | N:M avec User via UserBadge |
| UserBadge | Association User-Badge | N:1 avec User et Badge |
| Subscription | Abonnement pro | N:1 avec User |
| Payment | Paiement | N:1 avec User, Subscription |
| Photo | Image | N:1 avec Site, Review, CheckIn |
| Notification | Notification | N:1 avec User |

### 8.2 Couche Services (10 services)

| Service | Responsabilité |
|---------|---------------|
| AuthService | Authentification, JWT, OAuth |
| SiteService | CRUD sites, recherche, géolocalisation |
| CheckInService | Validation GPS, check-ins |
| ReviewService | Gestion avis, modération |
| GamificationService | Points, badges, niveaux |
| SubscriptionService | Abonnements professionnels |
| PaymentService | Paiements Stripe |
| NotificationService | Push, email, in-app |
| StorageService | Upload S3, images |
| AnalyticsService | Statistiques, analytics |

### 8.3 Couche Controllers (5 controllers)

| Controller | Endpoints gérés |
|------------|-----------------|
| AuthController | /api/auth/* |
| SiteController | /api/sites/* |
| CheckInController | /api/checkins/* |
| ReviewController | /api/reviews/* |
| SubscriptionController | /api/subscriptions/* |

### 8.4 Couche Providers Flutter (5 providers)

| Provider | État géré |
|----------|-----------|
| AuthProvider | Authentification utilisateur |
| SitesProvider | Liste sites, favoris |
| MapProvider | Carte, géolocalisation |
| GamificationProvider | Points, badges, leaderboard |
| CheckInProvider | Check-ins utilisateur |

---

## 9. Conclusion

### 9.1 Points Clés de l'Architecture

✅ **Séparation des responsabilités** - Chaque couche a un rôle bien défini  
✅ **Réutilisabilité** - Services et providers réutilisables  
✅ **Maintenabilité** - Code organisé et modulaire  
✅ **Testabilité** - Classes indépendantes faciles à tester  
✅ **Scalabilité** - Architecture prête pour la croissance  
✅ **Sécurité** - Validation à chaque niveau  

### 9.2 Prochaines Étapes de la Phase 1

Après ce document, vous devriez compléter :

1. ✅ **Diagrammes de Classes** (ce document)
2. ⏭️ **Diagrammes d'Activité** - Flux de travail détaillés
3. ⏭️ **Diagrammes de Composants** - Architecture logicielle
4. ⏭️ **Diagrammes d'États** - États des objets
5. ⏭️ **Diagrammes de Séquence** - Interactions temporelles

### 9.3 Validation

Avant de passer à la phase suivante, assurez-vous que :

- [ ] Tous les attributs de classe sont définis
- [ ] Toutes les méthodes principales sont listées
- [ ] Les relations entre classes sont claires
- [ ] Les enums et types sont documentés
- [ ] Les patterns de conception sont appropriés
- [ ] Le document est validé par l'équipe/encadrant

---

**Document créé le 16 janvier 2026**  
**MoroccoCheck - Phase 1.2 : Diagrammes de Classes Détaillés**  
**Version 1.0 - Complet**

