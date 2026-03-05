# Code Source UML - Diagrammes de Classes MoroccoCheck
## Codes PlantUML pour tous les diagrammes

---

## Table des Matières

1. [Classe User](#1-classe-user)
2. [Classe TouristSite](#2-classe-touristsite)
3. [Classe CheckIn](#3-classe-checkin)
4. [Classe Review](#4-classe-review)
5. [Classe Badge](#5-classe-badge)
6. [Classe UserBadge](#6-classe-userbadge)
7. [Classe Subscription](#7-classe-subscription)
8. [Classe Payment](#8-classe-payment)
9. [Classe Photo](#9-classe-photo)
10. [Classe Notification](#10-classe-notification)
11. [Services Backend](#11-services-backend)
12. [Controllers Backend](#12-controllers-backend)
13. [Providers Flutter](#13-providers-flutter)
14. [Diagramme de Relations Complet](#14-diagramme-de-relations-complet)

---

## 1. Classe User

```plantuml
@startuml User

class User {
  ' ATTRIBUTS IDENTITÉ
  - id: int
  - email: string
  - password: string
  - firstName: string
  - lastName: string
  - role: UserRole
  
  ' ATTRIBUTS PROFIL
  - phoneNumber: string
  - profilePicture: string
  - dateOfBirth: Date
  - gender: Gender
  - nationality: string
  - bio: string
  
  ' ATTRIBUTS VÉRIFICATION
  - isEmailVerified: boolean
  - isPhoneVerified: boolean
  - status: UserStatus
  - lastLoginAt: Date
  
  ' ATTRIBUTS GAMIFICATION
  - points: int
  - level: int
  - experiencePoints: int
  - rank: string
  - checkinsCount: int
  - reviewsCount: int
  - photosCount: int
  
  ' ATTRIBUTS OAUTH
  - googleId: string
  - facebookId: string
  - appleId: string
  
  ' MÉTADONNÉES
  - createdAt: Date
  - updatedAt: Date
  
  ' MÉTHODES
  + constructor(data: UserData)
  + getFullName(): string
  + getAge(): int
  + isContributor(): boolean
  + isProfessional(): boolean
  + isAdmin(): boolean
  + isModerator(): boolean
  + canCheckIn(): boolean
  + canReview(): boolean
  + calculateLevel(): int
  + getNextLevelPoints(): int
  + getLevelProgress(): float
  + getRankBadge(): string
  + addPoints(points: int): void
  + removePoints(points: int): void
  + updateLastLogin(): void
  + verifyEmail(): void
  + verifyPhone(): void
  + toJSON(): object
  + fromJSON(json: object): User
}

enum UserRole {
  TOURIST
  CONTRIBUTOR
  PROFESSIONAL
  MODERATOR
  ADMIN
}

enum UserStatus {
  ACTIVE
  INACTIVE
  SUSPENDED
  BANNED
  PENDING_VERIFICATION
}

enum Gender {
  MALE
  FEMALE
  OTHER
  PREFER_NOT_TO_SAY
}

User --> UserRole
User --> UserStatus
User --> Gender

@enduml
```

---

## 2. Classe TouristSite

```plantuml
@startuml TouristSite

class TouristSite {
  ' ATTRIBUTS BASIQUES
  - id: int
  - name: string
  - nameAr: string
  - description: string
  - descriptionAr: string
  - category: SiteCategory
  - subcategory: string
  
  ' ATTRIBUTS LOCALISATION
  - latitude: double
  - longitude: double
  - address: string
  - city: string
  - region: string
  - postalCode: string
  - country: string
  
  ' ATTRIBUTS CONTACT
  - phoneNumber: string
  - email: string
  - website: string
  - socialMedia: SocialMediaLinks
  
  ' ATTRIBUTS BUSINESS
  - openingHours: OpeningHours[]
  - priceRange: PriceRange
  - acceptsCardPayment: boolean
  - hasWifi: boolean
  - hasParking: boolean
  - isAccessible: boolean
  - amenities: string[]
  
  ' ATTRIBUTS RATINGS & FRAÎCHEUR
  - averageRating: double
  - totalReviews: int
  - freshnessScore: int
  - freshnessStatus: FreshnessStatus
  - lastVerifiedAt: Date
  - lastUpdatedAt: Date
  
  ' ATTRIBUTS MÉDIA
  - coverPhoto: string
  - photos: Photo[]
  
  ' ATTRIBUTS PROFESSIONNEL
  - ownerId: int
  - isProfessionalClaimed: boolean
  - subscriptionPlan: SubscriptionPlan
  
  ' ATTRIBUTS STATUT
  - status: SiteStatus
  - verificationStatus: VerificationStatus
  - isActive: boolean
  - isFeatured: boolean
  - viewsCount: int
  - favoritesCount: int
  
  ' MÉTADONNÉES
  - createdAt: Date
  - updatedAt: Date
  
  ' MÉTHODES
  + constructor(data: SiteData)
  + calculateFreshness(): int
  + updateFreshnessStatus(): void
  + getFreshnessColor(): string
  + getFreshnessLabel(): string
  + getDaysSinceLastVerification(): int
  + needsVerification(): boolean
  + updateRating(newRating: double): void
  + getDistance(userLat: double, userLng: double): double
  + isWithinRadius(userLat: double, userLng: double, radius: int): boolean
  + isOpen(): boolean
  + isOpenAt(datetime: Date): boolean
  + getCurrentOpeningHours(): OpeningHours
  + getTodaySchedule(): string
  + addPhoto(photo: Photo): void
  + removePhoto(photoId: int): void
  + incrementViews(): void
  + incrementFavorites(): void
  + claimByProfessional(userId: int): void
  + upgradePlan(plan: SubscriptionPlan): void
  + toJSON(): object
  + fromJSON(json: object): TouristSite
}

enum SiteCategory {
  RESTAURANT
  HOTEL
  MUSEUM
  HISTORICAL_SITE
  BEACH
  PARK
  SHOPPING
  ENTERTAINMENT
  RELIGIOUS_SITE
  NATURAL_SITE
  ACTIVITY
  TRANSPORT
  OTHER
}

enum FreshnessStatus {
  FRESH
  RECENT
  OLD
  OBSOLETE
}

enum PriceRange {
  BUDGET
  MODERATE
  EXPENSIVE
  LUXURY
}

enum SiteStatus {
  DRAFT
  PENDING_REVIEW
  PUBLISHED
  ARCHIVED
  REPORTED
}

enum VerificationStatus {
  PENDING
  VERIFIED
  REJECTED
}

TouristSite --> SiteCategory
TouristSite --> FreshnessStatus
TouristSite --> PriceRange
TouristSite --> SiteStatus
TouristSite --> VerificationStatus

@enduml
```

---

## 3. Classe CheckIn

```plantuml
@startuml CheckIn

class CheckIn {
  ' ATTRIBUTS BASIQUES
  - id: int
  - userId: int
  - siteId: int
  
  ' ATTRIBUTS STATUT
  - status: CheckInStatus
  - comment: string
  - verificationNotes: string
  
  ' ATTRIBUTS LOCALISATION
  - latitude: double
  - longitude: double
  - accuracy: double
  - distance: double
  - isLocationVerified: boolean
  
  ' ATTRIBUTS MÉDIA
  - photos: Photo[]
  - hasPhoto: boolean
  
  ' ATTRIBUTS GAMIFICATION
  - pointsEarned: int
  - badgesEarned: Badge[]
  
  ' ATTRIBUTS VALIDATION
  - validationStatus: ValidationStatus
  - validatedBy: int
  - validatedAt: Date
  - rejectionReason: string
  
  ' MÉTADONNÉES
  - deviceInfo: DeviceInfo
  - ipAddress: string
  - createdAt: Date
  - updatedAt: Date
  
  ' MÉTHODES
  + constructor(data: CheckInData)
  + validateLocation(siteLat: double, siteLng: double): boolean
  + calculateDistance(lat1: double, lng1: double, lat2: double, lng2: double): double
  + isWithinAllowedRadius(): boolean
  + calculatePoints(): int
  + addPhoto(photo: Photo): void
  + removePhoto(photoId: int): void
  + approve(moderatorId: int): void
  + reject(moderatorId: int, reason: string): void
  + updateSiteFreshness(): void
  + notifyUser(): void
  + toJSON(): object
  + fromJSON(json: object): CheckIn
}

enum CheckInStatus {
  OPEN
  CLOSED_TEMPORARILY
  CLOSED_PERMANENTLY
  RENOVATING
  RELOCATED
  NO_CHANGE
}

enum ValidationStatus {
  PENDING
  APPROVED
  REJECTED
  FLAGGED
}

CheckIn --> CheckInStatus
CheckIn --> ValidationStatus

@enduml
```

---

## 4. Classe Review

```plantuml
@startuml Review

class Review {
  ' ATTRIBUTS BASIQUES
  - id: int
  - userId: int
  - siteId: int
  
  ' ATTRIBUTS RATING
  - overallRating: double
  - serviceRating: double
  - cleanlinessRating: double
  - valueRating: double
  - locationRating: double
  
  ' ATTRIBUTS CONTENU
  - title: string
  - content: string
  - visitDate: Date
  - visitType: VisitType
  - recommendations: string[]
  
  ' ATTRIBUTS MÉDIA
  - photos: Photo[]
  
  ' ATTRIBUTS ENGAGEMENT
  - helpfulCount: int
  - notHelpfulCount: int
  - reportsCount: int
  
  ' ATTRIBUTS MODÉRATION
  - status: ReviewStatus
  - moderationStatus: ModerationStatus
  - moderatedBy: int
  - moderatedAt: Date
  - moderationNotes: string
  
  ' ATTRIBUTS RÉPONSE PROPRIÉTAIRE
  - hasOwnerResponse: boolean
  - ownerResponse: string
  - ownerResponseDate: Date
  
  ' ATTRIBUTS GAMIFICATION
  - pointsEarned: int
  
  ' MÉTADONNÉES
  - createdAt: Date
  - updatedAt: Date
  
  ' MÉTHODES
  + constructor(data: ReviewData)
  + calculateAverageRating(): double
  + addPhoto(photo: Photo): void
  + removePhoto(photoId: int): void
  + markAsHelpful(userId: int): void
  + markAsNotHelpful(userId: int): void
  + reportReview(userId: int, reason: string): void
  + addOwnerResponse(response: string, ownerId: int): void
  + updateOwnerResponse(response: string): void
  + deleteOwnerResponse(): void
  + approve(moderatorId: int): void
  + reject(moderatorId: int, reason: string): void
  + calculatePoints(): int
  + isRecent(): boolean
  + isVerifiedReview(): boolean
  + toJSON(): object
  + fromJSON(json: object): Review
}

enum VisitType {
  BUSINESS
  COUPLE
  FAMILY
  FRIENDS
  SOLO
}

enum ReviewStatus {
  PENDING
  PUBLISHED
  HIDDEN
  DELETED
}

enum ModerationStatus {
  PENDING
  APPROVED
  REJECTED
  FLAGGED
  SPAM
}

Review --> VisitType
Review --> ReviewStatus
Review --> ModerationStatus

@enduml
```

---

## 5. Classe Badge

```plantuml
@startuml Badge

class Badge {
  ' ATTRIBUTS BASIQUES
  - id: int
  - name: string
  - nameAr: string
  - description: string
  - descriptionAr: string
  - icon: string
  - color: string
  
  ' TYPE & CATÉGORIE
  - type: BadgeType
  - category: BadgeCategory
  - rarity: BadgeRarity
  
  ' REQUIREMENTS
  - requiredCheckIns: int
  - requiredReviews: int
  - requiredPhotos: int
  - requiredPoints: int
  - requiredLevel: int
  - specificConditions: string
  
  ' REWARDS
  - pointsReward: int
  - specialPerks: string[]
  
  ' MÉTADONNÉES
  - isActive: boolean
  - displayOrder: int
  - totalAwarded: int
  - createdAt: Date
  - updatedAt: Date
  
  ' MÉTHODES
  + constructor(data: BadgeData)
  + checkRequirements(user: User): boolean
  + awardToUser(userId: int): UserBadge
  + getProgressPercentage(user: User): double
  + getNextMilestone(user: User): int
  + isUnlockedBy(userId: int): boolean
  + incrementTotalAwarded(): void
  + toJSON(): object
  + fromJSON(json: object): Badge
}

enum BadgeType {
  CHECKIN_MILESTONE
  REVIEW_MILESTONE
  PHOTO_MILESTONE
  LEVEL_ACHIEVEMENT
  SPECIAL_EVENT
  CATEGORY_EXPERT
  REGION_EXPLORER
  STREAK
}

enum BadgeCategory {
  CONTRIBUTION
  EXPLORATION
  EXPERTISE
  ACHIEVEMENT
  SPECIAL
}

enum BadgeRarity {
  COMMON
  UNCOMMON
  RARE
  EPIC
  LEGENDARY
}

Badge --> BadgeType
Badge --> BadgeCategory
Badge --> BadgeRarity

@enduml
```

---

## 6. Classe UserBadge

```plantuml
@startuml UserBadge

class UserBadge {
  - id: int
  - userId: int
  - badgeId: int
  - earnedAt: Date
  - progress: double
  - isDisplayed: boolean
  - notificationSent: boolean
  
  + constructor(userId: int, badgeId: int)
  + markAsDisplayed(): void
  + markAsNotified(): void
  + updateProgress(progress: double): void
  + toJSON(): object
}

@enduml
```

---

## 7. Classe Subscription

```plantuml
@startuml Subscription

class Subscription {
  ' ATTRIBUTS BASIQUES
  - id: int
  - userId: int
  - siteId: int
  
  ' PLAN DETAILS
  - plan: SubscriptionPlan
  - billingCycle: BillingCycle
  - price: double
  - currency: string
  
  ' DATES
  - startDate: Date
  - endDate: Date
  - nextBillingDate: Date
  - cancelledAt: Date
  - pausedAt: Date
  - resumedAt: Date
  
  ' STATUT
  - status: SubscriptionStatus
  - autoRenew: boolean
  
  ' PAYMENT
  - stripeSubscriptionId: string
  - stripeCustomerId: string
  - paymentMethodId: string
  
  ' FEATURES
  - maxPhotos: int
  - canRespond: boolean
  - hasAnalytics: boolean
  - hasPrioritySupport: boolean
  - isFeatured: boolean
  
  ' MÉTADONNÉES
  - createdAt: Date
  - updatedAt: Date
  
  ' MÉTHODES
  + constructor(data: SubscriptionData)
  + isActive(): boolean
  + isExpired(): boolean
  + isCancelled(): boolean
  + isPaused(): boolean
  + getDaysRemaining(): int
  + cancel(): void
  + pause(): void
  + resume(): void
  + upgrade(newPlan: SubscriptionPlan): void
  + downgrade(newPlan: SubscriptionPlan): void
  + renew(): void
  + calculateProration(): double
  + sendExpirationReminder(): void
  + toJSON(): object
  + fromJSON(json: object): Subscription
}

enum SubscriptionPlan {
  FREE
  BASIC
  PRO
  PREMIUM
}

enum BillingCycle {
  MONTHLY
  QUARTERLY
  YEARLY
}

enum SubscriptionStatus {
  ACTIVE
  EXPIRED
  CANCELLED
  PAUSED
  PENDING_PAYMENT
  PAST_DUE
}

Subscription --> SubscriptionPlan
Subscription --> BillingCycle
Subscription --> SubscriptionStatus

@enduml
```

---

## 8. Classe Payment

```plantuml
@startuml Payment

class Payment {
  ' ATTRIBUTS BASIQUES
  - id: int
  - userId: int
  - subscriptionId: int
  
  ' AMOUNT
  - amount: double
  - currency: string
  - tax: double
  - totalAmount: double
  
  ' PAYMENT INFO
  - paymentMethod: PaymentMethod
  - stripePaymentIntentId: string
  - stripeChargeId: string
  - transactionId: string
  
  ' STATUT
  - status: PaymentStatus
  - failureReason: string
  - refundedAmount: double
  - refundedAt: Date
  
  ' BILLING DETAILS
  - billingName: string
  - billingEmail: string
  - billingAddress: Address
  
  ' RECEIPT
  - receiptUrl: string
  - invoiceUrl: string
  - invoiceNumber: string
  
  ' MÉTADONNÉES
  - createdAt: Date
  - updatedAt: Date
  
  ' MÉTHODES
  + constructor(data: PaymentData)
  + isSuccessful(): boolean
  + isPending(): boolean
  + isFailed(): boolean
  + isRefunded(): boolean
  + processPayment(): Promise<boolean>
  + refund(amount: double, reason: string): Promise<boolean>
  + generateReceipt(): string
  + sendReceiptEmail(): void
  + toJSON(): object
  + fromJSON(json: object): Payment
}

enum PaymentMethod {
  CREDIT_CARD
  DEBIT_CARD
  BANK_TRANSFER
  MOBILE_MONEY
  PAYPAL
  OTHER
}

enum PaymentStatus {
  PENDING
  PROCESSING
  SUCCEEDED
  FAILED
  CANCELLED
  REFUNDED
  PARTIALLY_REFUNDED
}

Payment --> PaymentMethod
Payment --> PaymentStatus

@enduml
```

---

## 9. Classe Photo

```plantuml
@startuml Photo

class Photo {
  ' ATTRIBUTS BASIQUES
  - id: int
  - url: string
  - thumbnailUrl: string
  - filename: string
  - originalFilename: string
  - mimeType: string
  - size: int
  - width: int
  - height: int
  
  ' OWNERSHIP
  - userId: int
  - entityType: PhotoEntityType
  - entityId: int
  
  ' MÉTADONNÉES
  - caption: string
  - altText: string
  - exifData: ExifData
  - location: Location
  
  ' STATUT
  - status: PhotoStatus
  - moderationStatus: ModerationStatus
  - viewsCount: int
  - likesCount: int
  
  ' ORDER
  - displayOrder: int
  - isPrimary: boolean
  
  ' MÉTADONNÉES
  - uploadedAt: Date
  - createdAt: Date
  - updatedAt: Date
  
  ' MÉTHODES
  + constructor(data: PhotoData)
  + generateThumbnail(): string
  + optimize(): void
  + getAspectRatio(): double
  + isLandscape(): boolean
  + isPortrait(): boolean
  + incrementViews(): void
  + incrementLikes(): void
  + markAsPrimary(): void
  + moderate(status: ModerationStatus): void
  + delete(): void
  + toJSON(): object
  + fromJSON(json: object): Photo
}

enum PhotoEntityType {
  SITE
  REVIEW
  CHECKIN
  USER_PROFILE
}

enum PhotoStatus {
  ACTIVE
  HIDDEN
  DELETED
  FLAGGED
}

Photo --> PhotoEntityType
Photo --> PhotoStatus

@enduml
```

---

## 10. Classe Notification

```plantuml
@startuml Notification

class Notification {
  ' ATTRIBUTS BASIQUES
  - id: int
  - userId: int
  - type: NotificationType
  - title: string
  - message: string
  - icon: string
  
  ' RELATED ENTITY
  - relatedEntityType: string
  - relatedEntityId: int
  
  ' ACTIONS
  - actionUrl: string
  - actionLabel: string
  
  ' STATUT
  - isRead: boolean
  - readAt: Date
  - isSent: boolean
  - sentAt: Date
  
  ' CHANNELS
  - sendPush: boolean
  - sendEmail: boolean
  - sendInApp: boolean
  
  ' PRIORITY
  - priority: NotificationPriority
  - expiresAt: Date
  
  ' MÉTADONNÉES
  - createdAt: Date
  - updatedAt: Date
  
  ' MÉTHODES
  + constructor(data: NotificationData)
  + markAsRead(): void
  + markAsUnread(): void
  + send(): Promise<boolean>
  + isExpired(): boolean
  + toJSON(): object
  + fromJSON(json: object): Notification
}

enum NotificationType {
  BADGE_EARNED
  LEVEL_UP
  REVIEW_LIKED
  REVIEW_RESPONSE
  CHECKIN_VALIDATED
  SUBSCRIPTION_EXPIRING
  NEW_FOLLOWER
  SYSTEM_ANNOUNCEMENT
  MODERATION_RESULT
}

enum NotificationPriority {
  LOW
  NORMAL
  HIGH
  URGENT
}

Notification --> NotificationType
Notification --> NotificationPriority

@enduml
```

---

## 11. Services Backend

### 11.1 AuthService

```plantuml
@startuml AuthService

class AuthService {
  - jwtSecret: string
  - jwtExpiresIn: string
  - refreshTokenExpiresIn: string
  - bcryptSaltRounds: int
  - redisClient: RedisClient
  
  + register(userData: RegisterDTO): Promise<AuthResponse>
  + login(email: string, password: string): Promise<AuthResponse>
  + loginWithGoogle(token: string): Promise<AuthResponse>
  + loginWithFacebook(token: string): Promise<AuthResponse>
  + loginWithApple(token: string): Promise<AuthResponse>
  + logout(userId: int, token: string): Promise<void>
  + refreshToken(refreshToken: string): Promise<AuthResponse>
  + verifyToken(token: string): Promise<User>
  + changePassword(userId: int, oldPassword: string, newPassword: string): Promise<boolean>
  + resetPassword(email: string): Promise<boolean>
  + confirmPasswordReset(token: string, newPassword: string): Promise<boolean>
  + verifyEmail(token: string): Promise<boolean>
  + resendVerificationEmail(userId: int): Promise<boolean>
  + verifyPhoneNumber(userId: int, code: string): Promise<boolean>
  + sendPhoneVerificationCode(userId: int): Promise<boolean>
  + updateProfile(userId: int, data: UpdateProfileDTO): Promise<User>
  - hashPassword(password: string): Promise<string>
  - comparePassword(password: string, hash: string): Promise<boolean>
  - generateToken(user: User): string
  - generateRefreshToken(user: User): string
  - validateToken(token: string): Promise<TokenPayload>
  - storeRefreshToken(userId: int, token: string): Promise<void>
  - revokeRefreshToken(token: string): Promise<void>
  - generateEmailVerificationToken(userId: int): string
  - generatePasswordResetToken(userId: int): string
}

@enduml
```

### 11.2 SiteService

```plantuml
@startuml SiteService

class SiteService {
  - googleMapsApiKey: string
  - maxSearchRadius: int
  - defaultPageSize: int
  
  + getAllSites(filters: SiteFilters, page: int, pageSize: int): Promise<PaginatedResult<TouristSite>>
  + getSiteById(siteId: int): Promise<TouristSite>
  + getSitesByCategory(category: SiteCategory, page: int): Promise<PaginatedResult<TouristSite>>
  + searchSites(query: string, filters: SiteFilters): Promise<TouristSite[]>
  + getNearbySites(latitude: double, longitude: double, radius: int, filters: SiteFilters): Promise<TouristSite[]>
  + createSite(siteData: CreateSiteDTO, userId: int): Promise<TouristSite>
  + updateSite(siteId: int, siteData: UpdateSiteDTO, userId: int): Promise<TouristSite>
  + deleteSite(siteId: int, userId: int): Promise<boolean>
  + claimSite(siteId: int, userId: int, proof: ClaimProof): Promise<boolean>
  + getPopularSites(limit: int): Promise<TouristSite[]>
  + getFeaturedSites(): Promise<TouristSite[]>
  + getRecentlyAddedSites(limit: int): Promise<TouristSite[]>
  + getSitePhotos(siteId: int): Promise<Photo[]>
  + addSitePhoto(siteId: int, photo: Photo): Promise<Photo>
  + deleteSitePhoto(photoId: int, userId: int): Promise<boolean>
  + updateFreshnessScores(): Promise<void>
  + calculateFreshnessScore(site: TouristSite): int
  + verifyLocation(siteId: int, latitude: double, longitude: double): boolean
  + incrementSiteViews(siteId: int): void
  + toggleFavorite(siteId: int, userId: int): Promise<boolean>
  + getUserFavorites(userId: int): Promise<TouristSite[]>
  + reportSite(siteId: int, userId: int, reason: string): Promise<boolean>
  - calculateDistance(lat1: double, lng1: double, lat2: double, lng2: double): double
  - geocodeAddress(address: string): Promise<Coordinates>
  - reverseGeocode(latitude: double, longitude: double): Promise<Address>
}

@enduml
```

### 11.3 CheckInService

```plantuml
@startuml CheckInService

class CheckInService {
  - maxCheckInRadius: int
  - checkInCooldown: int
  - basePoints: int
  - photoBonus: int
  
  + createCheckIn(checkInData: CreateCheckInDTO, userId: int): Promise<CheckIn>
  + validateCheckIn(siteId: int, latitude: double, longitude: double): ValidationResult
  + getUserCheckIns(userId: int, page: int): Promise<PaginatedResult<CheckIn>>
  + getSiteCheckIns(siteId: int, page: int): Promise<PaginatedResult<CheckIn>>
  + getCheckInById(checkInId: int): Promise<CheckIn>
  + updateCheckIn(checkInId: int, data: UpdateCheckInDTO): Promise<CheckIn>
  + deleteCheckIn(checkInId: int, userId: int): Promise<boolean>
  + canUserCheckIn(userId: int, siteId: int): Promise<boolean>
  + getLastCheckIn(userId: int, siteId: int): Promise<CheckIn>
  + approveCheckIn(checkInId: int, moderatorId: int): Promise<boolean>
  + rejectCheckIn(checkInId: int, moderatorId: int, reason: string): Promise<boolean>
  + getPendingCheckIns(page: int): Promise<PaginatedResult<CheckIn>>
  + calculatePoints(checkIn: CheckIn): int
  + awardPoints(userId: int, checkInId: int): Promise<void>
  + updateSiteFreshness(siteId: int): Promise<void>
  + getCheckInStatistics(userId: int): Promise<CheckInStats>
  + getCheckInHeatmap(siteId: int): Promise<HeatmapData>
  - validateLocation(siteLat: double, siteLng: double, userLat: double, userLng: double): boolean
  - checkCooldownPeriod(userId: int, siteId: int): Promise<boolean>
  - notifyModerators(checkIn: CheckIn): void
}

@enduml
```

### 11.4 GamificationService

```plantuml
@startuml GamificationService

class GamificationService {
  - levelThresholds: int[]
  - rankTitles: string[]
  
  + addPoints(userId: int, points: int, reason: string): Promise<PointsTransaction>
  + removePoints(userId: int, points: int, reason: string): Promise<PointsTransaction>
  + getUserPoints(userId: int): Promise<int>
  + getUserLevel(userId: int): Promise<int>
  + calculateLevel(points: int): int
  + getNextLevelPoints(currentLevel: int): int
  + getLevelProgress(userId: int): Promise<LevelProgress>
  + checkLevelUp(userId: int): Promise<boolean>
  + awardBadge(userId: int, badgeId: int): Promise<UserBadge>
  + getUserBadges(userId: int): Promise<Badge[]>
  + checkBadgeEligibility(userId: int): Promise<Badge[]>
  + getAvailableBadges(): Promise<Badge[]>
  + getBadgeProgress(userId: int, badgeId: int): Promise<BadgeProgress>
  + getLeaderboard(period: LeaderboardPeriod, limit: int): Promise<LeaderboardEntry[]>
  + getUserRank(userId: int, period: LeaderboardPeriod): Promise<int>
  + getStreakInfo(userId: int): Promise<StreakInfo>
  + updateStreak(userId: int): Promise<void>
  + getAchievements(userId: int): Promise<Achievement[]>
  + unlockAchievement(userId: int, achievementId: int): Promise<Achievement>
  + getGamificationStats(userId: int): Promise<GamificationStats>
  + getPointsHistory(userId: int, page: int): Promise<PaginatedResult<PointsTransaction>>
  - notifyLevelUp(userId: int, newLevel: int): void
  - notifyBadgeEarned(userId: int, badge: Badge): void
}

@enduml
```

---

## 12. Controllers Backend

### 12.1 AuthController

```plantuml
@startuml AuthController

class AuthController {
  - authService: AuthService
  - validationService: ValidationService
  
  + register(req: Request, res: Response): Promise<Response>
  + login(req: Request, res: Response): Promise<Response>
  + loginWithGoogle(req: Request, res: Response): Promise<Response>
  + loginWithFacebook(req: Request, res: Response): Promise<Response>
  + loginWithApple(req: Request, res: Response): Promise<Response>
  + logout(req: Request, res: Response): Promise<Response>
  + refreshToken(req: Request, res: Response): Promise<Response>
  + getProfile(req: Request, res: Response): Promise<Response>
  + updateProfile(req: Request, res: Response): Promise<Response>
  + changePassword(req: Request, res: Response): Promise<Response>
  + resetPassword(req: Request, res: Response): Promise<Response>
  + confirmPasswordReset(req: Request, res: Response): Promise<Response>
  + verifyEmail(req: Request, res: Response): Promise<Response>
  + resendVerificationEmail(req: Request, res: Response): Promise<Response>
  + verifyPhone(req: Request, res: Response): Promise<Response>
  + sendPhoneVerification(req: Request, res: Response): Promise<Response>
  - validateRegistration(data: object): ValidationResult
  - validateLogin(data: object): ValidationResult
  - handleError(error: Error, res: Response): Response
}

@enduml
```

### 12.2 SiteController

```plantuml
@startuml SiteController

class SiteController {
  - siteService: SiteService
  - validationService: ValidationService
  
  + getAllSites(req: Request, res: Response): Promise<Response>
  + getSiteById(req: Request, res: Response): Promise<Response>
  + getSitesByCategory(req: Request, res: Response): Promise<Response>
  + searchSites(req: Request, res: Response): Promise<Response>
  + getNearbySites(req: Request, res: Response): Promise<Response>
  + createSite(req: Request, res: Response): Promise<Response>
  + updateSite(req: Request, res: Response): Promise<Response>
  + deleteSite(req: Request, res: Response): Promise<Response>
  + claimSite(req: Request, res: Response): Promise<Response>
  + getPopularSites(req: Request, res: Response): Promise<Response>
  + getFeaturedSites(req: Request, res: Response): Promise<Response>
  + getSitePhotos(req: Request, res: Response): Promise<Response>
  + addSitePhoto(req: Request, res: Response): Promise<Response>
  + deleteSitePhoto(req: Request, res: Response): Promise<Response>
  + toggleFavorite(req: Request, res: Response): Promise<Response>
  + getFavorites(req: Request, res: Response): Promise<Response>
  + reportSite(req: Request, res: Response): Promise<Response>
  - validateSiteData(data: object): ValidationResult
  - validateLocation(lat: double, lng: double): boolean
  - handleError(error: Error, res: Response): Response
}

@enduml
```

---

## 13. Providers Flutter

### 13.1 AuthProvider

```plantuml
@startuml AuthProvider

class AuthProvider {
  - _apiService: ApiService
  - _storageService: StorageService
  - _currentUser: User
  - _token: string
  - _isAuthenticated: boolean
  - _isLoading: boolean
  - _error: string
  
  + get currentUser: User
  + get isAuthenticated: boolean
  + get isLoading: boolean
  + get error: string
  
  + register(email: string, password: string, name: string): Future<bool>
  + login(email: string, password: string): Future<bool>
  + loginWithGoogle(): Future<bool>
  + loginWithFacebook(): Future<bool>
  + loginWithApple(): Future<bool>
  + logout(): Future<void>
  + checkAuthStatus(): Future<bool>
  + refreshToken(): Future<bool>
  + updateProfile(data: Map<String, dynamic>): Future<bool>
  + changePassword(oldPassword: string, newPassword: string): Future<bool>
  + resetPassword(email: string): Future<bool>
  + verifyEmail(token: string): Future<bool>
  + resendVerificationEmail(): Future<bool>
  - _saveToken(token: string): Future<void>
  - _loadToken(): Future<string>
  - _clearToken(): Future<void>
  - _saveUser(user: User): Future<void>
  - _loadUser(): Future<User>
  - _clearUser(): Future<void>
  - _setLoading(loading: boolean): void
  - _setError(error: string): void
}

note right of AuthProvider
  extends ChangeNotifier
end note

@enduml
```

### 13.2 SitesProvider

```plantuml
@startuml SitesProvider

class SitesProvider {
  - _apiService: ApiService
  - _sites: List<TouristSite>
  - _currentSite: TouristSite
  - _nearbySites: List<TouristSite>
  - _favoriteSites: List<TouristSite>
  - _isLoading: boolean
  - _error: string
  - _currentPage: int
  - _hasMore: boolean
  
  + get sites: List<TouristSite>
  + get currentSite: TouristSite
  + get nearbySites: List<TouristSite>
  + get favoriteSites: List<TouristSite>
  + get isLoading: boolean
  + get error: string
  + get hasMore: boolean
  
  + fetchSites(filters: SiteFilters): Future<void>
  + fetchSiteById(siteId: int): Future<void>
  + fetchSitesByCategory(category: SiteCategory): Future<void>
  + searchSites(query: string, filters: SiteFilters): Future<void>
  + fetchNearbySites(latitude: double, longitude: double, radius: int): Future<void>
  + fetchMoreSites(): Future<void>
  + refreshSites(): Future<void>
  + createSite(siteData: Map<String, dynamic>): Future<bool>
  + updateSite(siteId: int, siteData: Map<String, dynamic>): Future<bool>
  + deleteSite(siteId: int): Future<bool>
  + toggleFavorite(siteId: int): Future<bool>
  + fetchFavorites(): Future<void>
  + reportSite(siteId: int, reason: string): Future<bool>
  + clearCurrentSite(): void
  + clearSites(): void
  - _setLoading(loading: boolean): void
  - _setError(error: string): void
  - _updateSiteInList(updatedSite: TouristSite): void
  - _removeSiteFromList(siteId: int): void
}

note right of SitesProvider
  extends ChangeNotifier
end note

@enduml
```

### 13.3 MapProvider

```plantuml
@startuml MapProvider

class MapProvider {
  - _locationService: LocationService
  - _currentPosition: LatLng
  - _mapController: GoogleMapController
  - _markers: Set<Marker>
  - _selectedSite: TouristSite
  - _isLoadingLocation: boolean
  - _locationPermissionGranted: boolean
  - _mapType: MapType
  - _zoom: double
  
  + get currentPosition: LatLng
  + get markers: Set<Marker>
  + get selectedSite: TouristSite
  + get isLoadingLocation: boolean
  + get locationPermissionGranted: boolean
  + get mapType: MapType
  + get zoom: double
  
  + initializeMap(controller: GoogleMapController): void
  + getCurrentLocation(): Future<LatLng>
  + requestLocationPermission(): Future<bool>
  + updateCurrentPosition(position: LatLng): void
  + addSiteMarkers(sites: List<TouristSite>): void
  + selectSite(site: TouristSite): void
  + deselectSite(): void
  + centerMapOnSite(site: TouristSite): void
  + centerMapOnCurrentLocation(): void
  + setMapType(mapType: MapType): void
  + setZoom(zoom: double): void
  + calculateDistance(from: LatLng, to: LatLng): double
  + getDirections(destination: LatLng): Future<void>
  + clearMarkers(): void
  - _createMarker(site: TouristSite): Marker
  - _getMarkerIcon(category: SiteCategory): BitmapDescriptor
  - _animateCamera(target: CameraPosition): Future<void>
}

note right of MapProvider
  extends ChangeNotifier
end note

@enduml
```

### 13.4 GamificationProvider

```plantuml
@startuml GamificationProvider

class GamificationProvider {
  - _apiService: ApiService
  - _userPoints: int
  - _userLevel: int
  - _experiencePoints: int
  - _badges: List<Badge>
  - _leaderboard: List<LeaderboardEntry>
  - _levelProgress: LevelProgress
  - _isLoading: boolean
  
  + get userPoints: int
  + get userLevel: int
  + get badges: List<Badge>
  + get leaderboard: List<LeaderboardEntry>
  + get levelProgress: LevelProgress
  + get isLoading: boolean
  
  + fetchUserStats(): Future<void>
  + fetchBadges(): Future<void>
  + fetchLeaderboard(period: LeaderboardPeriod): Future<void>
  + checkNewBadges(): Future<List<Badge>>
  + addPoints(points: int): void
  + showBadgeAnimation(badge: Badge): void
  + showLevelUpAnimation(newLevel: int): void
  + getNextLevelPoints(): int
  + getLevelProgressPercentage(): double
  + getUserRank(): Future<int>
  - _setLoading(loading: boolean): void
  - _calculateLevelProgress(): void
}

note right of GamificationProvider
  extends ChangeNotifier
end note

@enduml
```

---

## 14. Diagramme de Relations Complet

```plantuml
@startuml RelationsCompletes

' Entities
class User {
  - id: int
  - email: string
  - role: UserRole
  - points: int
  - level: int
}

class TouristSite {
  - id: int
  - name: string
  - latitude: double
  - longitude: double
  - freshnessScore: int
}

class CheckIn {
  - id: int
  - userId: int
  - siteId: int
  - status: CheckInStatus
  - pointsEarned: int
}

class Review {
  - id: int
  - userId: int
  - siteId: int
  - overallRating: double
  - content: string
}

class Badge {
  - id: int
  - name: string
  - type: BadgeType
  - pointsReward: int
}

class UserBadge {
  - userId: int
  - badgeId: int
  - earnedAt: Date
}

class Subscription {
  - id: int
  - userId: int
  - plan: SubscriptionPlan
  - status: SubscriptionStatus
}

class Payment {
  - id: int
  - userId: int
  - subscriptionId: int
  - amount: double
  - status: PaymentStatus
}

class Photo {
  - id: int
  - url: string
  - entityType: PhotoEntityType
  - entityId: int
}

class Notification {
  - id: int
  - userId: int
  - type: NotificationType
  - message: string
}

' Relations
User "1" -- "0..*" CheckIn : creates >
User "1" -- "0..*" Review : writes >
User "0..*" -- "0..*" Badge : earns >
(User, Badge) .. UserBadge

TouristSite "1" -- "0..*" CheckIn : has >
TouristSite "1" -- "0..*" Review : has >
TouristSite "1" -- "0..*" Photo : contains >

CheckIn "1" -- "0..*" Photo : includes >
Review "1" -- "0..*" Photo : includes >

User "1" -- "0..*" Subscription : subscribes >
Subscription "1" -- "0..*" Payment : requires >

User "1" -- "0..*" Notification : receives >
User "1" -- "0..*" Photo : uploads >

TouristSite "0..1" -- "1" User : owned by >

@enduml
```

---

## 15. Diagramme d'Architecture Complète

```plantuml
@startuml ArchitectureComplete

package "Frontend - Flutter" {
  [Screens] as screens
  [Widgets] as widgets
  [Providers] as providers
  [Services] as fservices
  [Models] as fmodels
}

package "Backend - Node.js" {
  package "Routes Layer" {
    [Express Router] as router
  }
  
  package "Controllers Layer" {
    [AuthController] as authController
    [SiteController] as siteController
    [CheckInController] as checkinController
    [ReviewController] as reviewController
  }
  
  package "Services Layer" {
    [AuthService] as authService
    [SiteService] as siteService
    [CheckInService] as checkinService
    [ReviewService] as reviewService
    [GamificationService] as gamificationService
  }
  
  package "Models Layer" {
    [User] as userModel
    [TouristSite] as siteModel
    [CheckIn] as checkinModel
    [Review] as reviewModel
  }
}

package "Database" {
  database "MySQL" as mysql
  database "Redis" as redis
}

package "External Services" {
  [Google Maps API] as gmaps
  [Stripe] as stripe
  [AWS S3] as s3
  [Firebase] as firebase
}

' Frontend connections
screens --> providers
screens --> widgets
providers --> fservices
providers --> fmodels
fservices --> router : HTTP/REST

' Backend connections
router --> authController
router --> siteController
router --> checkinController
router --> reviewController

authController --> authService
siteController --> siteService
checkinController --> checkinService
reviewController --> reviewService

authService --> userModel
siteService --> siteModel
checkinService --> checkinModel
reviewService --> reviewModel

checkinService --> gamificationService
reviewService --> gamificationService

userModel --> mysql
siteModel --> mysql
checkinModel --> mysql
reviewModel --> mysql

authService --> redis
authService --> firebase

siteService --> gmaps
siteService --> s3
authService --> stripe

@enduml
```

---

## 16. Diagramme de Packages

```plantuml
@startuml Packages

package "MoroccoCheck Backend" {
  
  package "api" {
    package "controllers" {
      class AuthController
      class SiteController
      class CheckInController
      class ReviewController
      class SubscriptionController
    }
    
    package "middlewares" {
      class AuthMiddleware
      class ValidationMiddleware
      class RateLimitMiddleware
    }
    
    package "routes" {
      class AuthRoutes
      class SiteRoutes
      class CheckInRoutes
      class ReviewRoutes
    }
  }
  
  package "services" {
    class AuthService
    class SiteService
    class CheckInService
    class ReviewService
    class GamificationService
    class PaymentService
    class NotificationService
    class StorageService
  }
  
  package "models" {
    class User
    class TouristSite
    class CheckIn
    class Review
    class Badge
    class Subscription
    class Payment
  }
  
  package "database" {
    class DatabaseConnection
    class UserRepository
    class SiteRepository
    class CheckInRepository
  }
  
  package "utils" {
    class Validator
    class Logger
    class EmailSender
    class FileUploader
  }
}

controllers ..> services : uses
services ..> models : uses
services ..> database : uses
controllers ..> middlewares : protected by
routes ..> controllers : calls
database ..> models : manages

@enduml
```

---

## Instructions d'utilisation

### Pour générer les diagrammes :

1. **En ligne** :
   - Allez sur http://www.plantuml.com/plantuml/
   - Copiez-collez le code UML
   - Cliquez sur "Submit" pour générer le diagramme

2. **VS Code** :
   - Installez l'extension "PlantUML"
   - Créez un fichier `.puml`
   - Collez le code
   - Faites Alt+D pour prévisualiser

3. **IntelliJ IDEA / PyCharm** :
   - Installez le plugin "PlantUML integration"
   - Créez un fichier `.puml`
   - Le diagramme s'affiche automatiquement

4. **CLI** :
   ```bash
   # Installer PlantUML
   brew install plantuml  # macOS
   sudo apt-get install plantuml  # Linux
   
   # Générer le diagramme
   plantuml diagram.puml
   ```

### Formats de sortie disponibles :
- PNG
- SVG
- PDF
- EPS
- LaTeX

---

**Document créé le 16 janvier 2026**  
**MoroccoCheck - Codes Source UML PlantUML**  
**Version 1.0**
