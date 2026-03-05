# Code Source UML - Diagrammes de Composants MoroccoCheck
## Codes PlantUML pour tous les diagrammes de composants

*Document créé le 16 janvier 2026*

---

## Table des Matières

1. [Architecture Globale du Système](#1-architecture-globale-du-système)
2. [Architecture Frontend Flutter](#2-architecture-frontend-flutter)
3. [Architecture Backend Node.js](#3-architecture-backend-nodejs)
4. [Architecture Base de Données](#4-architecture-base-de-données)
5. [Intégrations Services Externes](#5-intégrations-services-externes)
6. [Architecture de Déploiement](#6-architecture-de-déploiement)
7. [Composants par Module Métier](#7-composants-par-module-métier)
8. [Architecture de Cache](#8-architecture-de-cache)
9. [Architecture de Sécurité](#9-architecture-de-sécurité)
10. [Architecture de Notifications](#10-architecture-de-notifications)

---

## 1. Architecture Globale du Système

```plantuml
@startuml SystemArchitecture

!define RECTANGLE class

skinparam componentStyle rectangle
skinparam package {
  BackgroundColor LightBlue
  BorderColor DarkBlue
  FontSize 14
}

package "Client Layer" {
  [Flutter Mobile App\niOS & Android] as MobileApp
  [Web Browser\n(Admin Panel)] as WebBrowser
}

package "API Gateway Layer" {
  [Nginx\nReverse Proxy] as Nginx
  [Rate Limiter] as RateLimit
  [Load Balancer] as LoadBalancer
}

package "Application Layer" {
  [Node.js Backend\nExpress.js] as Backend
  [WebSocket Server\nReal-time] as WebSocket
}

package "Business Logic Layer" {
  package "Core Services" {
    [Auth Service] as AuthSvc
    [Site Service] as SiteSvc
    [CheckIn Service] as CheckInSvc
    [Review Service] as ReviewSvc
    [Gamification Service] as GamSvc
  }
  
  package "Support Services" {
    [Payment Service] as PaymentSvc
    [Notification Service] as NotifSvc
    [Storage Service] as StorageSvc
    [Analytics Service] as AnalyticsSvc
  }
}

package "Data Layer" {
  database "MySQL\nPrimary DB" as MySQL
  database "MySQL\nRead Replica" as MySQLReplica
  database "Redis\nCache & Sessions" as Redis
  database "Elasticsearch\nSearch Engine" as Elastic
}

package "External Services" {
  [Google Maps API] as GMaps
  [Stripe API] as Stripe
  [AWS S3] as S3
  [Firebase\nFCM Push] as Firebase
  [SendGrid\nEmail] as SendGrid
}

' Connections Client -> Gateway
MobileApp --> Nginx : HTTPS
WebBrowser --> Nginx : HTTPS

' Gateway -> Application
Nginx --> RateLimit
RateLimit --> LoadBalancer
LoadBalancer --> Backend
LoadBalancer --> WebSocket

' Application -> Business Logic
Backend --> AuthSvc
Backend --> SiteSvc
Backend --> CheckInSvc
Backend --> ReviewSvc
Backend --> GamSvc
Backend --> PaymentSvc
Backend --> NotifSvc
Backend --> StorageSvc
Backend --> AnalyticsSvc

' Business Logic -> Data
AuthSvc --> MySQL
AuthSvc --> Redis
SiteSvc --> MySQL
SiteSvc --> Elastic
SiteSvc --> Redis
CheckInSvc --> MySQL
ReviewSvc --> MySQL
GamSvc --> MySQL
GamSvc --> Redis
AnalyticsSvc --> MySQL
AnalyticsSvc --> Redis

' Read operations
SiteSvc ..> MySQLReplica : Read Only
ReviewSvc ..> MySQLReplica : Read Only

' External Services
SiteSvc --> GMaps : Geocoding
PaymentSvc --> Stripe : Payments
StorageSvc --> S3 : File Storage
NotifSvc --> Firebase : Push Notifications
NotifSvc --> SendGrid : Emails

note right of Nginx
  - SSL/TLS Termination
  - Request Routing
  - Static Content
end note

note right of Redis
  - Session Storage
  - Cache Layer
  - Rate Limiting
  - Real-time Data
end note

note right of Elastic
  - Full-Text Search
  - Fuzzy Matching
  - Geospatial Queries
end note

@enduml
```

---

## 2. Architecture Frontend Flutter

```plantuml
@startuml FlutterArchitecture

!define RECTANGLE class

skinparam componentStyle rectangle
skinparam package {
  BackgroundColor #E3F2FD
  BorderColor #1976D2
}

package "Presentation Layer" {
  
  package "Screens" {
    [Auth Screens] as AuthScreens
    [Home Screen] as HomeScreen
    [Map Screen] as MapScreen
    [Site Details Screen] as SiteScreen
    [Profile Screen] as ProfileScreen
    [CheckIn Screen] as CheckInScreen
    [Review Screen] as ReviewScreen
    [Professional Dashboard] as ProDashboard
  }
  
  package "Widgets" {
    [Common Widgets] as CommonWidgets
    [Site Card Widget] as SiteCard
    [Map Marker Widget] as MapMarker
    [Rating Widget] as RatingWidget
    [Badge Widget] as BadgeWidget
    [Chart Widget] as ChartWidget
  }
}

package "State Management Layer" {
  
  package "Providers" {
    [Auth Provider] as AuthProvider
    [Sites Provider] as SitesProvider
    [Map Provider] as MapProvider
    [CheckIn Provider] as CheckInProvider
    [Review Provider] as ReviewProvider
    [Gamification Provider] as GamProvider
    [Subscription Provider] as SubProvider
  }
  
  [Provider Package\nChangeNotifier] as ProviderPkg
}

package "Business Logic Layer" {
  
  package "Services" {
    [API Service] as APIService
    [Auth Service] as AuthService
    [Location Service] as LocationService
    [Storage Service] as StorageService
    [Notification Service] as NotificationService
    [Image Service] as ImageService
  }
  
  package "Repositories" {
    [Site Repository] as SiteRepo
    [User Repository] as UserRepo
    [CheckIn Repository] as CheckInRepo
  }
}

package "Data Layer" {
  
  package "Models" {
    [User Model] as UserModel
    [Site Model] as SiteModel
    [CheckIn Model] as CheckInModel
    [Review Model] as ReviewModel
    [Badge Model] as BadgeModel
  }
  
  package "Local Storage" {
    [SQLite\nLocal DB] as SQLite
    [SharedPreferences\nKey-Value Store] as SharedPrefs
    [Secure Storage\nEncrypted] as SecureStorage
  }
  
  package "Network" {
    [HTTP Client\nDio] as Dio
    [WebSocket Client] as WSClient
  }
}

package "Core Layer" {
  [Constants] as Constants
  [Utils] as Utils
  [Validators] as Validators
  [Formatters] as Formatters
  [Theme] as Theme
  [Routes] as Routes
}

' Presentation -> State Management
AuthScreens --> AuthProvider
HomeScreen --> SitesProvider
MapScreen --> MapProvider
SiteScreen --> SitesProvider
ProfileScreen --> AuthProvider
ProfileScreen --> GamProvider
CheckInScreen --> CheckInProvider
ReviewScreen --> ReviewProvider
ProDashboard --> SubProvider

CommonWidgets --> ProviderPkg
SiteCard --> SitesProvider
MapMarker --> MapProvider
RatingWidget --> ReviewProvider
BadgeWidget --> GamProvider

' State Management -> Business Logic
AuthProvider --> AuthService
SitesProvider --> SiteRepo
MapProvider --> LocationService
CheckInProvider --> CheckInRepo
GamProvider --> APIService

' Providers connection
AuthProvider ..> ProviderPkg
SitesProvider ..> ProviderPkg
MapProvider ..> ProviderPkg
CheckInProvider ..> ProviderPkg
ReviewProvider ..> ProviderPkg
GamProvider ..> ProviderPkg

' Business Logic -> Data
APIService --> Dio
APIService --> UserModel
APIService --> SiteModel
AuthService --> SecureStorage
AuthService --> APIService
LocationService --> MapProvider
StorageService --> SharedPrefs
NotificationService --> FirebaseMessaging

SiteRepo --> APIService
SiteRepo --> SQLite
UserRepo --> APIService
UserRepo --> SQLite
CheckInRepo --> APIService

' Data Layer
Dio --> Backend : REST API
WSClient --> Backend : WebSocket

' Core Layer connections
AuthScreens ..> Routes
HomeScreen ..> Theme
Utils ..> Formatters
AuthService ..> Validators

package "External Packages" {
  [google_maps_flutter] as GMapsFlutter
  [geolocator] as Geolocator
  [image_picker] as ImagePicker
  [firebase_messaging] as FirebaseMessaging
  [cached_network_image] as CachedImage
}

MapScreen --> GMapsFlutter
LocationService --> Geolocator
ImageService --> ImagePicker
SiteCard --> CachedImage

cloud "Backend API" as Backend

note right of ProviderPkg
  State Management:
  - ChangeNotifier pattern
  - Reactive updates
  - Efficient rebuilds
end note

note right of SQLite
  Offline Support:
  - Cache sites
  - Save favorites
  - Queue pending actions
end note

note bottom of Dio
  HTTP Client Features:
  - Interceptors
  - Token refresh
  - Error handling
  - Retry logic
end note

@enduml
```

---

## 3. Architecture Backend Node.js

```plantuml
@startuml BackendArchitecture

!define RECTANGLE class

skinparam componentStyle rectangle
skinparam package {
  BackgroundColor #FFF3E0
  BorderColor #F57C00
}

package "API Layer" {
  
  [Express App] as ExpressApp
  
  package "Routes" {
    [Auth Routes] as AuthRoutes
    [Site Routes] as SiteRoutes
    [CheckIn Routes] as CheckInRoutes
    [Review Routes] as ReviewRoutes
    [User Routes] as UserRoutes
    [Subscription Routes] as SubRoutes
    [Admin Routes] as AdminRoutes
  }
  
  package "Middlewares" {
    [Auth Middleware] as AuthMW
    [Validation Middleware] as ValidationMW
    [Error Middleware] as ErrorMW
    [Rate Limit Middleware] as RateLimitMW
    [CORS Middleware] as CORSMW
    [Logger Middleware] as LoggerMW
    [Upload Middleware] as UploadMW
  }
}

package "Controller Layer" {
  [Auth Controller] as AuthCtrl
  [Site Controller] as SiteCtrl
  [CheckIn Controller] as CheckInCtrl
  [Review Controller] as ReviewCtrl
  [User Controller] as UserCtrl
  [Subscription Controller] as SubCtrl
  [Admin Controller] as AdminCtrl
}

package "Service Layer" {
  
  package "Core Services" {
    [Auth Service] as AuthSvc
    [Site Service] as SiteSvc
    [CheckIn Service] as CheckInSvc
    [Review Service] as ReviewSvc
    [User Service] as UserSvc
    [Gamification Service] as GamSvc
  }
  
  package "Infrastructure Services" {
    [Email Service] as EmailSvc
    [SMS Service] as SMSSvc
    [Storage Service] as StorageSvc
    [Notification Service] as NotifSvc
    [Cache Service] as CacheSvc
    [Queue Service] as QueueSvc
  }
  
  package "Integration Services" {
    [Payment Service] as PaymentSvc
    [Maps Service] as MapsSvc
    [Analytics Service] as AnalyticsSvc
  }
}

package "Repository Layer" {
  [User Repository] as UserRepo
  [Site Repository] as SiteRepo
  [CheckIn Repository] as CheckInRepo
  [Review Repository] as ReviewRepo
  [Badge Repository] as BadgeRepo
  [Subscription Repository] as SubRepo
  [Payment Repository] as PaymentRepo
}

package "Model Layer" {
  [User Model] as UserModel
  [Site Model] as SiteModel
  [CheckIn Model] as CheckInModel
  [Review Model] as ReviewModel
  [Badge Model] as BadgeModel
  [Subscription Model] as SubModel
  [Payment Model] as PaymentModel
}

package "Data Access Layer" {
  [MySQL Connection Pool] as MySQLPool
  [Redis Client] as RedisClient
  [Elasticsearch Client] as ElasticClient
}

package "Utility Layer" {
  [Logger] as Logger
  [Validator] as Validator
  [Error Handler] as ErrorHandler
  [JWT Utils] as JWTUtils
  [Crypto Utils] as CryptoUtils
  [Date Utils] as DateUtils
}

package "Config Layer" {
  [Database Config] as DBConfig
  [Redis Config] as RedisConfig
  [AWS Config] as AWSConfig
  [Stripe Config] as StripeConfig
  [Email Config] as EmailConfig
}

' API Layer connections
ExpressApp --> AuthRoutes
ExpressApp --> SiteRoutes
ExpressApp --> CheckInRoutes
ExpressApp --> ReviewRoutes
ExpressApp --> UserRoutes
ExpressApp --> SubRoutes
ExpressApp --> AdminRoutes

ExpressApp --> AuthMW
ExpressApp --> ValidationMW
ExpressApp --> ErrorMW
ExpressApp --> RateLimitMW
ExpressApp --> CORSMW
ExpressApp --> LoggerMW

' Routes to Controllers
AuthRoutes --> AuthCtrl
SiteRoutes --> SiteCtrl
CheckInRoutes --> CheckInCtrl
ReviewRoutes --> ReviewCtrl
UserRoutes --> UserCtrl
SubRoutes --> SubCtrl
AdminRoutes --> AdminCtrl

' Middlewares
AuthMW --> JWTUtils
ValidationMW --> Validator
RateLimitMW --> RedisClient
LoggerMW --> Logger
UploadMW --> StorageSvc

' Controllers to Services
AuthCtrl --> AuthSvc
SiteCtrl --> SiteSvc
CheckInCtrl --> CheckInSvc
ReviewCtrl --> ReviewSvc
UserCtrl --> UserSvc
SubCtrl --> PaymentSvc

' Core Services to Repositories
AuthSvc --> UserRepo
SiteSvc --> SiteRepo
CheckInSvc --> CheckInRepo
CheckInSvc --> GamSvc
ReviewSvc --> ReviewRepo
ReviewSvc --> GamSvc
UserSvc --> UserRepo
GamSvc --> BadgeRepo

' Services to Infrastructure
AuthSvc --> EmailSvc
AuthSvc --> CacheSvc
CheckInSvc --> NotifSvc
ReviewSvc --> QueueSvc
PaymentSvc --> NotifSvc

' Services to Integrations
SiteSvc --> MapsSvc
CheckInSvc --> MapsSvc
PaymentSvc --> StripeAPI
NotifSvc --> FirebaseAPI
EmailSvc --> SendGridAPI
StorageSvc --> S3API

' Repositories to Models
UserRepo --> UserModel
SiteRepo --> SiteModel
CheckInRepo --> CheckInModel
ReviewRepo --> ReviewModel
BadgeRepo --> BadgeModel
SubRepo --> SubModel
PaymentRepo --> PaymentModel

' Models to Data Access
UserModel --> MySQLPool
SiteModel --> MySQLPool
SiteModel --> ElasticClient
CheckInModel --> MySQLPool
ReviewModel --> MySQLPool
BadgeModel --> MySQLPool

' Cache Service
CacheSvc --> RedisClient
GamSvc --> RedisClient

' Config connections
MySQLPool ..> DBConfig
RedisClient ..> RedisConfig
StorageSvc ..> AWSConfig
PaymentSvc ..> StripeConfig
EmailSvc ..> EmailConfig

' External APIs
cloud "Stripe API" as StripeAPI
cloud "Firebase FCM" as FirebaseAPI
cloud "SendGrid API" as SendGridAPI
cloud "AWS S3" as S3API
cloud "Google Maps API" as MapsAPI

MapsSvc --> MapsAPI

note right of ExpressApp
  Entry Point:
  - Port 3000
  - JSON API
  - REST endpoints
  - WebSocket support
end note

note right of MySQLPool
  Connection Pool:
  - Min: 5 connections
  - Max: 20 connections
  - Timeout: 30s
end note

note right of RedisClient
  Redis Usage:
  - Session store
  - Cache layer
  - Rate limiting
  - Job queue
  - Leaderboard
end note

note bottom of QueueSvc
  Background Jobs:
  - Email sending
  - Image processing
  - Analytics
  - Freshness calculation
end note

@enduml
```

---

## 4. Architecture Base de Données

```plantuml
@startuml DatabaseArchitecture

!define RECTANGLE class

skinparam componentStyle rectangle

package "Application Servers" {
  [Node.js Server 1] as App1
  [Node.js Server 2] as App2
  [Node.js Server 3] as App3
}

package "Database Layer" {
  
  package "MySQL Cluster" {
    database "MySQL Master\n(Write)" as MySQLMaster {
      [users]
      [tourist_sites]
      [check_ins]
      [reviews]
      [badges]
      [subscriptions]
      [payments]
      [notifications]
    }
    
    database "MySQL Replica 1\n(Read)" as MySQLReplica1
    database "MySQL Replica 2\n(Read)" as MySQLReplica2
  }
  
  package "Cache Layer" {
    database "Redis Master" as RedisMaster {
      [Session Store]
      [Cache Store]
      [Rate Limiting]
      [Leaderboard]
      [Job Queue]
    }
    
    database "Redis Replica" as RedisReplica
  }
  
  package "Search Layer" {
    database "Elasticsearch\nCluster" as Elastic {
      [sites_index]
      [reviews_index]
    }
  }
}

package "Backup & Recovery" {
  [MySQL Backup\nDaily] as MySQLBackup
  [Redis Snapshot\nHourly] as RedisBackup
  [Elasticsearch Snapshot\nDaily] as ElasticBackup
}

package "Monitoring" {
  [Database Metrics] as DBMetrics
  [Query Performance] as QueryPerf
  [Connection Pool Monitor] as PoolMonitor
}

' Application to Database
App1 --> MySQLMaster : Write Operations
App2 --> MySQLMaster : Write Operations
App3 --> MySQLMaster : Write Operations

App1 --> MySQLReplica1 : Read Operations
App2 --> MySQLReplica1 : Read Operations
App1 --> MySQLReplica2 : Read Operations
App3 --> MySQLReplica2 : Read Operations

' MySQL Replication
MySQLMaster --> MySQLReplica1 : Binary Log\nReplication
MySQLMaster --> MySQLReplica2 : Binary Log\nReplication

' Redis connections
App1 --> RedisMaster
App2 --> RedisMaster
App3 --> RedisMaster

RedisMaster --> RedisReplica : Async\nReplication

' Elasticsearch
App1 --> Elastic : Search Queries
App2 --> Elastic : Search Queries
MySQLMaster ..> Elastic : Index Updates\n(via Logstash)

' Backup connections
MySQLMaster ..> MySQLBackup : Daily Dump
RedisMaster ..> RedisBackup : RDB Snapshot
Elastic ..> ElasticBackup : Snapshot

' Monitoring
MySQLMaster --> DBMetrics
MySQLReplica1 --> DBMetrics
RedisMaster --> DBMetrics
Elastic --> DBMetrics

App1 --> QueryPerf
App2 --> PoolMonitor

note right of MySQLMaster
  Write Operations:
  - INSERT, UPDATE, DELETE
  - Transactions
  - Primary key generation
  
  Tables:
  - InnoDB engine
  - UTF8MB4 charset
  - Row-level locking
end note

note right of MySQLReplica1
  Read Operations:
  - SELECT queries
  - Reports
  - Analytics
  
  Lag: < 1 second
  Load balancing: Round-robin
end note

note right of RedisMaster
  Data Structures:
  - Strings: Sessions, Cache
  - Hash: User profiles
  - Sorted Sets: Leaderboard
  - Lists: Job queue
  - Sets: Rate limiting
  
  Persistence:
  - RDB + AOF
  - Save every 5 minutes
end note

note right of Elastic
  Indices:
  - sites_index (10 shards)
  - reviews_index (5 shards)
  
  Features:
  - Full-text search
  - Fuzzy matching
  - Geospatial queries
  - Aggregations
end note

note bottom of MySQLBackup
  Backup Strategy:
  - Full backup: Daily 2 AM
  - Incremental: Every 6h
  - Retention: 30 days
  - Location: AWS S3
end note

@enduml
```

---

## 5. Intégrations Services Externes

```plantuml
@startuml ExternalIntegrations

!define RECTANGLE class

skinparam componentStyle rectangle

package "MoroccoCheck Backend" {
  [Payment Service] as PaymentSvc
  [Maps Service] as MapsSvc
  [Storage Service] as StorageSvc
  [Notification Service] as NotifSvc
  [Email Service] as EmailSvc
  [SMS Service] as SMSSvc
  [Analytics Service] as AnalyticsSvc
}

package "Payment Integration" {
  cloud "Stripe API" as Stripe {
    [Payment Intents]
    [Customers]
    [Subscriptions]
    [Webhooks]
    [Invoices]
  }
}

package "Maps Integration" {
  cloud "Google Maps Platform" as GMaps {
    [Geocoding API]
    [Places API]
    [Distance Matrix API]
    [Maps Static API]
    [Directions API]
  }
}

package "Storage Integration" {
  cloud "AWS Services" as AWS {
    [S3 Buckets]
    [CloudFront CDN]
    [Lambda Functions]
  }
  
  folder "S3 Buckets" {
    [morocco-check-photos]
    [morocco-check-documents]
    [morocco-check-backups]
  }
}

package "Notification Integration" {
  cloud "Firebase" as Firebase {
    [FCM (Push Notifications)]
    [Cloud Messaging]
    [Analytics]
  }
}

package "Email Integration" {
  cloud "SendGrid" as SendGrid {
    [Transactional Emails]
    [Email Templates]
    [Email Analytics]
    [Webhooks]
  }
}

package "SMS Integration" {
  cloud "Twilio" as Twilio {
    [SMS API]
    [Phone Verification]
    [2FA]
  }
}

package "Analytics Integration" {
  cloud "Google Analytics" as GA {
    [GA4]
    [Events Tracking]
    [User Behavior]
  }
  
  cloud "Mixpanel" as Mixpanel {
    [Event Analytics]
    [Funnels]
    [Retention]
  }
}

package "Monitoring Integration" {
  cloud "Sentry" as Sentry {
    [Error Tracking]
    [Performance Monitoring]
  }
  
  cloud "New Relic" as NewRelic {
    [APM]
    [Infrastructure]
  }
}

' Payment Service Integration
PaymentSvc --> Stripe : HTTPS/REST
PaymentSvc --> [Payment Intents] : Create Payment
PaymentSvc --> [Subscriptions] : Manage Subscriptions
PaymentSvc --> [Customers] : Customer Management
Stripe --> PaymentSvc : Webhook Events

' Maps Service Integration
MapsSvc --> [Geocoding API] : Address → Coordinates
MapsSvc --> [Places API] : Place Search
MapsSvc --> [Distance Matrix API] : Calculate Distance
MapsSvc --> [Directions API] : Get Directions

' Storage Service Integration
StorageSvc --> [S3 Buckets] : Upload/Download
StorageSvc --> [CloudFront CDN] : Serve Static Content
[S3 Buckets] --> [Lambda Functions] : Image Processing

' Notification Service Integration
NotifSvc --> [FCM (Push Notifications)] : Send Push
NotifSvc --> Firebase : Device Token Management

' Email Service Integration
EmailSvc --> SendGrid : Send Email
EmailSvc --> [Email Templates] : Use Templates
SendGrid --> EmailSvc : Delivery Webhooks

' SMS Service Integration
SMSSvc --> Twilio : Send SMS
SMSSvc --> [Phone Verification] : Verify Phone

' Analytics Service Integration
AnalyticsSvc --> GA : Track Events
AnalyticsSvc --> Mixpanel : User Analytics

' Monitoring
[All Services] --> Sentry : Error Reporting
[All Services] --> NewRelic : Performance Metrics

note right of Stripe
  Stripe Integration:
  - API Version: 2023-10-16
  - Webhook secret validation
  - Idempotency keys
  - Test mode for development
  
  Payment Flow:
  1. Create Payment Intent
  2. Confirm Payment
  3. Handle Webhook
  4. Update Subscription
end note

note right of GMaps
  Google Maps Quotas:
  - Geocoding: 50 req/sec
  - Places: 100 req/sec
  - Distance Matrix: 100 req/sec
  
  Features Used:
  - Autocomplete
  - Place Details
  - Nearby Search
  - Geocoding
end note

note right of AWS
  S3 Configuration:
  - Bucket Policy: Private
  - CDN: CloudFront
  - Lifecycle: 90 days
  
  Lambda Triggers:
  - Image compression
  - Thumbnail generation
  - EXIF data extraction
end note

note right of Firebase
  FCM Implementation:
  - Topic Subscriptions
  - User Segments
  - Notification Priority
  - Data Payload
  
  Notification Types:
  - Badge earned
  - Level up
  - New review
  - Subscription expiring
end note

note bottom of SendGrid
  Email Templates:
  - Welcome email
  - Email verification
  - Password reset
  - Receipt/Invoice
  - Weekly digest
  
  Tracking:
  - Opens
  - Clicks
  - Bounces
  - Unsubscribes
end note

@enduml
```

---

## 6. Architecture de Déploiement

```plantuml
@startuml DeploymentArchitecture

!define RECTANGLE class

skinparam nodeStyle rectangle

node "Load Balancer" {
  [Nginx Load Balancer] as LB
}

node "Application Servers" {
  node "Server 1 (us-east-1a)" {
    [Node.js App] as App1
    [PM2 Process Manager] as PM2_1
  }
  
  node "Server 2 (us-east-1b)" {
    [Node.js App] as App2
    [PM2 Process Manager] as PM2_2
  }
  
  node "Server 3 (us-east-1c)" {
    [Node.js App] as App3
    [PM2 Process Manager] as PM2_3
  }
}

node "Database Cluster" {
  node "Primary DB (us-east-1a)" {
    database "MySQL Master" as DBMaster
  }
  
  node "Replica DB 1 (us-east-1b)" {
    database "MySQL Replica" as DBReplica1
  }
  
  node "Replica DB 2 (us-east-1c)" {
    database "MySQL Replica" as DBReplica2
  }
}

node "Cache Cluster" {
  node "Redis Master (us-east-1a)" {
    database "Redis Primary" as RedisMaster
  }
  
  node "Redis Replica (us-east-1b)" {
    database "Redis Standby" as RedisReplica
  }
}

node "Search Cluster" {
  node "Elasticsearch Node 1" {
    [Elasticsearch] as ES1
  }
  
  node "Elasticsearch Node 2" {
    [Elasticsearch] as ES2
  }
}

cloud "CDN" {
  [CloudFront] as CDN
}

cloud "Storage" {
  [AWS S3] as S3
}

cloud "Mobile Clients" {
  [iOS App] as iOS
  [Android App] as Android
}

cloud "Web Clients" {
  [Admin Panel] as WebAdmin
}

' Client connections
iOS --> CDN : Static Assets
Android --> CDN : Static Assets
iOS --> LB : API Requests
Android --> LB : API Requests
WebAdmin --> LB : Admin API

' Load Balancer
LB --> App1 : Round Robin
LB --> App2 : Round Robin
LB --> App3 : Round Robin

' PM2 Management
PM2_1 --> App1 : Manage Process
PM2_2 --> App2 : Manage Process
PM2_3 --> App3 : Manage Process

' Application to Database
App1 --> DBMaster : Write
App2 --> DBMaster : Write
App3 --> DBMaster : Write

App1 --> DBReplica1 : Read
App2 --> DBReplica1 : Read
App3 --> DBReplica2 : Read

' Database Replication
DBMaster --> DBReplica1 : Replication
DBMaster --> DBReplica2 : Replication

' Application to Cache
App1 --> RedisMaster
App2 --> RedisMaster
App3 --> RedisMaster

RedisMaster --> RedisReplica : Replication

' Application to Search
App1 --> ES1
App2 --> ES2
App3 --> ES1

ES1 <--> ES2 : Cluster Sync

' Static Assets
CDN --> S3 : Origin
App1 --> S3 : Upload
App2 --> S3 : Upload

node "Monitoring & Logs" {
  [CloudWatch] as CloudWatch
  [Log Aggregator] as Logs
  [Metrics Dashboard] as Metrics
}

App1 --> CloudWatch : Logs & Metrics
App2 --> CloudWatch : Logs & Metrics
App3 --> CloudWatch : Logs & Metrics
DBMaster --> CloudWatch : DB Metrics
RedisMaster --> CloudWatch : Cache Metrics

CloudWatch --> Logs
CloudWatch --> Metrics

node "CI/CD Pipeline" {
  [GitHub Actions] as GitHub
  [Docker Registry] as DockerReg
}

GitHub --> DockerReg : Build & Push
DockerReg --> App1 : Deploy
DockerReg --> App2 : Deploy
DockerReg --> App3 : Deploy

note right of LB
  Load Balancer Config:
  - Algorithm: Round Robin
  - Health Check: /health
  - Timeout: 30s
  - SSL/TLS Termination
  - Rate Limiting
end note

note right of App1
  Application Config:
  - Runtime: Node.js 18
  - Process Manager: PM2
  - Instances: 4 (cluster mode)
  - Memory: 2GB
  - CPU: 2 vCPUs
end note

note right of DBMaster
  Database Config:
  - Instance: db.r5.xlarge
  - Storage: 100GB SSD
  - Backup: Daily
  - Multi-AZ: Yes
end note

note right of RedisMaster
  Redis Config:
  - Instance: cache.r5.large
  - Memory: 13GB
  - Persistence: RDB + AOF
  - Eviction: allkeys-lru
end note

note bottom of S3
  S3 Buckets:
  - morocco-check-photos
  - morocco-check-documents
  - morocco-check-backups
  
  Lifecycle:
  - Photos: 90 days
  - Documents: Indefinite
  - Backups: 30 days
end note

@enduml
```

---

## 7. Composants par Module Métier

### 7.1 Module Authentification

```plantuml
@startuml AuthModule

!define RECTANGLE class

package "Auth Module" {
  
  [Auth Controller] as AuthCtrl
  
  package "Auth Services" {
    [JWT Service] as JWTSvc
    [OAuth Service] as OAuthSvc
    [Password Service] as PasswordSvc
    [Email Verification Service] as EmailVerifSvc
    [2FA Service] as TwoFASvc
  }
  
  package "Auth Middlewares" {
    [JWT Middleware] as JWTMiddleware
    [Role Middleware] as RoleMiddleware
    [Rate Limit Middleware] as RateLimitMiddleware
  }
  
  [User Repository] as UserRepo
  [Session Repository] as SessionRepo
  
  database "MySQL" as DB
  database "Redis" as Cache
}

cloud "External Auth Providers" {
  [Google OAuth] as GoogleAuth
  [Facebook OAuth] as FacebookAuth
  [Apple OAuth] as AppleAuth
}

' Controller to Services
AuthCtrl --> JWTSvc
AuthCtrl --> OAuthSvc
AuthCtrl --> PasswordSvc
AuthCtrl --> EmailVerifSvc
AuthCtrl --> TwoFASvc

' Services to Repositories
JWTSvc --> SessionRepo
OAuthSvc --> UserRepo
PasswordSvc --> UserRepo
EmailVerifSvc --> UserRepo

' Repositories to Storage
UserRepo --> DB
SessionRepo --> Cache

' OAuth Integration
OAuthSvc --> GoogleAuth
OAuthSvc --> FacebookAuth
OAuthSvc --> AppleAuth

' Middleware usage
[API Routes] --> JWTMiddleware
JWTMiddleware --> JWTSvc
[Protected Routes] --> RoleMiddleware
[Auth Routes] --> RateLimitMiddleware
RateLimitMiddleware --> Cache

note right of JWTSvc
  JWT Management:
  - Generate access token (15min)
  - Generate refresh token (7 days)
  - Verify token
  - Revoke token
  - Blacklist management
end note

note right of OAuthSvc
  OAuth Providers:
  - Google Sign-In
  - Facebook Login
  - Apple Sign-In
  
  Flow:
  1. Get authorization code
  2. Exchange for access token
  3. Fetch user profile
  4. Create/update user
  5. Generate JWT
end note

note bottom of SessionRepo
  Session Storage:
  - Key: session:{userId}
  - TTL: 7 days
  - Data: { deviceId, ip, userAgent }
  - Cleanup: Automatic expiration
end note

@enduml
```

### 7.2 Module Sites Touristiques

```plantuml
@startuml SitesModule

!define RECTANGLE class

package "Sites Module" {
  
  [Site Controller] as SiteCtrl
  
  package "Site Services" {
    [Site Service] as SiteSvc
    [Search Service] as SearchSvc
    [Geocoding Service] as GeocodingSvc
    [Freshness Service] as FreshnessSvc
    [Photo Service] as PhotoSvc
  }
  
  package "Repositories" {
    [Site Repository] as SiteRepo
    [Category Repository] as CategoryRepo
    [Photo Repository] as PhotoRepo
    [Favorite Repository] as FavoriteRepo
  }
  
  database "MySQL" as DB
  database "Elasticsearch" as Search
  database "Redis" as Cache
}

cloud "External Services" {
  [Google Maps API] as GMaps
  [AWS S3] as S3
}

' Controller to Services
SiteCtrl --> SiteSvc
SiteCtrl --> SearchSvc
SiteCtrl --> GeocodingSvc
SiteCtrl --> PhotoSvc

' Services interactions
SiteSvc --> FreshnessSvc
SiteSvc --> SiteRepo
SearchSvc --> SiteRepo
SearchSvc --> Search
GeocodingSvc --> GMaps
PhotoSvc --> PhotoRepo
PhotoSvc --> S3

' Repositories to Storage
SiteRepo --> DB
SiteRepo --> Cache
CategoryRepo --> DB
PhotoRepo --> DB
FavoriteRepo --> DB

' Freshness Service
FreshnessSvc --> SiteRepo
FreshnessSvc --> Cache

note right of SiteSvc
  Site Management:
  - Create site
  - Update site
  - Claim site (professional)
  - Get site details
  - List sites (filtered)
  - Toggle favorite
  - Report site
end note

note right of SearchSvc
  Search Features:
  - Full-text search
  - Fuzzy matching
  - Category filter
  - Location-based search
  - Price range filter
  - Rating filter
  - Freshness filter
  
  Powered by Elasticsearch
end note

note right of FreshnessSvc
  Freshness Calculation:
  - Time-based score (40%)
  - Activity score (40%)
  - Review score (20%)
  
  Scheduled Job:
  - Runs every 6 hours
  - Updates all sites
  - Caches results
end note

note bottom of Cache
  Cached Data:
  - Popular sites (1 hour)
  - Featured sites (6 hours)
  - Site details (30 minutes)
  - Search results (15 minutes)
  - Categories (24 hours)
end note

@enduml
```

### 7.3 Module Gamification

```plantuml
@startuml GamificationModule

!define RECTANGLE class

package "Gamification Module" {
  
  [Gamification Controller] as GamCtrl
  
  package "Gamification Services" {
    [Points Service] as PointsSvc
    [Level Service] as LevelSvc
    [Badge Service] as BadgeSvc
    [Leaderboard Service] as LeaderboardSvc
    [Achievement Service] as AchievementSvc
    [Streak Service] as StreakSvc
  }
  
  package "Repositories" {
    [Points Repository] as PointsRepo
    [Badge Repository] as BadgeRepo
    [UserBadge Repository] as UserBadgeRepo
    [Leaderboard Repository] as LeaderboardRepo
  }
  
  database "MySQL" as DB
  database "Redis" as Cache
}

[Notification Service] as NotifSvc

' Controller to Services
GamCtrl --> PointsSvc
GamCtrl --> LevelSvc
GamCtrl --> BadgeSvc
GamCtrl --> LeaderboardSvc

' Services interactions
PointsSvc --> LevelSvc : Check Level Up
LevelSvc --> BadgeSvc : Check New Badges
BadgeSvc --> NotifSvc : Badge Notification
LevelSvc --> NotifSvc : Level Up Notification

' Services to Repositories
PointsSvc --> PointsRepo
LevelSvc --> PointsRepo
BadgeSvc --> BadgeRepo
BadgeSvc --> UserBadgeRepo
LeaderboardSvc --> LeaderboardRepo
StreakSvc --> Cache

' Repositories to Storage
PointsRepo --> DB
BadgeRepo --> DB
UserBadgeRepo --> DB
LeaderboardRepo --> Cache

note right of PointsSvc
  Points Management:
  - Award points (with reason)
  - Deduct points
  - Get points history
  - Calculate total points
  
  Points Structure:
  - Check-in: 10 points
  - Review: 15 points
  - Photo: 5 points
  - Badge bonus: Variable
end note

note right of LevelSvc
  Level System:
  - Calculate level from points
  - Level thresholds
  - Level rewards
  - Rank assignment
  
  Ranks:
  - Bronze (1-4)
  - Silver (5-9)
  - Gold (10-19)
  - Platinum (20+)
end note

note right of BadgeSvc
  Badge System:
  - Check eligibility
  - Award badge
  - Badge progress
  - Badge categories
  
  Badge Types:
  - Milestone badges
  - Category expert
  - Region explorer
  - Streak badges
  - Special events
end note

note bottom of LeaderboardRepo
  Leaderboard Storage:
  - Global leaderboard
  - Weekly leaderboard
  - Monthly leaderboard
  - Category leaderboard
  
  Data Structure (Redis):
  - Sorted Set
  - Score: points
  - Member: userId
  - Refresh: Real-time
end note

@enduml
```

---

## 8. Architecture de Cache

```plantuml
@startuml CacheArchitecture

!define RECTANGLE class

package "Application Layer" {
  [API Endpoints] as API
  [Background Jobs] as Jobs
}

package "Cache Layer" {
  
  package "Cache Manager" {
    [Cache Service] as CacheSvc
    [Cache Invalidator] as CacheInvalidator
  }
  
  package "Cache Strategies" {
    [Write-Through Cache] as WriteThrough
    [Write-Behind Cache] as WriteBehind
    [Cache-Aside] as CacheAside
    [Read-Through Cache] as ReadThrough
  }
  
  database "Redis Cluster" as Redis {
    [Session Store]
    [Data Cache]
    [Query Cache]
    [Rate Limiting]
    [Leaderboard]
    [Job Queue]
  }
}

database "MySQL Database" as DB

' API to Cache
API --> CacheSvc
Jobs --> CacheSvc

' Cache Service to Strategies
CacheSvc --> WriteThrough
CacheSvc --> WriteBehind
CacheSvc --> CacheAside
CacheSvc --> ReadThrough

' Strategies to Redis
WriteThrough --> Redis
WriteBehind --> Redis
CacheAside --> Redis
ReadThrough --> Redis

' Strategies to Database
WriteThrough --> DB : Write
ReadThrough --> DB : Read on miss
WriteBehind ..> DB : Async write

' Cache Invalidation
CacheInvalidator --> Redis : Invalidate
DB --> CacheInvalidator : On Update

note right of Redis
  Redis Data Types Used:
  
  STRING:
  - User sessions
  - API responses
  - Configuration
  
  HASH:
  - User profiles
  - Site details
  
  LIST:
  - Recent activities
  - Job queue
  
  SET:
  - User favorites
  - Tags
  
  SORTED SET:
  - Leaderboards
  - Time-based data
  
  TTL Strategy:
  - Sessions: 7 days
  - User data: 1 hour
  - Site data: 30 minutes
  - Search: 15 minutes
  - Leaderboard: Real-time
end note

note left of WriteThrough
  Write-Through:
  - Write to cache
  - Write to DB
  - Return success
  
  Use Cases:
  - User profile updates
  - Site information
end note

note left of CacheAside
  Cache-Aside (Lazy Loading):
  1. Check cache
  2. If miss, read from DB
  3. Store in cache
  4. Return data
  
  Use Cases:
  - Site details
  - User profiles
  - Reviews
end note

note left of ReadThrough
  Read-Through:
  - Cache handles DB reads
  - Transparent to application
  
  Use Cases:
  - Configuration
  - Static data
end note

note left of WriteBehind
  Write-Behind (Write-Back):
  - Write to cache
  - Return immediately
  - Async write to DB
  
  Use Cases:
  - Analytics events
  - Page views
  - Click tracking
end note

package "Cache Invalidation Strategies" {
  [TTL Expiration] as TTL
  [Event-Based Invalidation] as EventInv
  [Manual Invalidation] as ManualInv
  [Version-Based Invalidation] as VersionInv
}

CacheInvalidator --> TTL
CacheInvalidator --> EventInv
CacheInvalidator --> ManualInv
CacheInvalidator --> VersionInv

note bottom of CacheInvalidator
  Invalidation Triggers:
  
  1. Site updated → Invalidate:
     - site:{id}
     - sites:category:{category}
     - sites:nearby:{lat}:{lng}
  
  2. Review added → Invalidate:
     - site:{id}:reviews
     - site:{id}:rating
     - user:{id}:reviews
  
  3. User updated → Invalidate:
     - user:{id}
     - user:{id}:profile
  
  4. Badge earned → Invalidate:
     - user:{id}:badges
     - leaderboard:*
end note

@enduml
```

---

## 9. Architecture de Sécurité

```plantuml
@startuml SecurityArchitecture

!define RECTANGLE class

cloud "Internet" as Internet

package "Security Perimeter" {
  
  package "DDoS Protection" {
    [CloudFlare] as CloudFlare
    [WAF Rules] as WAF
  }
  
  package "Load Balancer Layer" {
    [Nginx] as Nginx
    [SSL/TLS Termination] as SSL
    [Rate Limiting] as RateLimit
  }
}

package "Application Security" {
  
  package "Authentication" {
    [JWT Authentication] as JWT
    [OAuth 2.0] as OAuth
    [2FA Module] as TwoFA
    [Session Management] as SessionMgmt
  }
  
  package "Authorization" {
    [RBAC Module] as RBAC
    [Permission Checker] as PermCheck
    [Resource Access Control] as ResourceAccess
  }
  
  package "Input Validation" {
    [Request Validator] as ReqValidator
    [SQL Injection Prevention] as SQLInjPrev
    [XSS Prevention] as XSSPrev
    [CSRF Protection] as CSRFProt
  }
  
  package "Data Protection" {
    [Encryption Service] as Encryption
    [Password Hashing] as PasswordHash
    [Data Masking] as DataMask
    [Secure Storage] as SecureStorage
  }
}

package "Backend Services" {
  [API Endpoints] as API
  [Business Logic] as Business
}

database "MySQL" as DB
database "Redis" as Cache

package "Monitoring & Audit" {
  [Security Logs] as SecLogs
  [Intrusion Detection] as IDS
  [Audit Trail] as Audit
  [Alert System] as Alerts
}

' Internet to Security Perimeter
Internet --> CloudFlare
CloudFlare --> WAF
WAF --> Nginx

' Nginx Layer
Nginx --> SSL
Nginx --> RateLimit
RateLimit --> JWT

' Authentication Flow
JWT --> SessionMgmt
OAuth --> SessionMgmt
SessionMgmt --> Cache

' Authorization
JWT --> RBAC
RBAC --> PermCheck
PermCheck --> ResourceAccess

' Validation
API --> ReqValidator
ReqValidator --> SQLInjPrev
ReqValidator --> XSSPrev
ReqValidator --> CSRFProt

' After validation, go to business logic
SQLInjPrev --> Business
XSSPrev --> Business
CSRFProt --> Business

' Business to Data Protection
Business --> Encryption
Business --> PasswordHash
PasswordHash --> DB
Encryption --> SecureStorage

' Resource Access
ResourceAccess --> Business

' Security Monitoring
Nginx --> SecLogs
JWT --> Audit
Business --> Audit
API --> IDS
IDS --> Alerts

note right of CloudFlare
  DDoS Protection:
  - Layer 3/4 protection
  - Layer 7 protection
  - Bot detection
  - Geo-blocking
  
  WAF Rules:
  - OWASP Top 10
  - Custom rules
  - IP whitelist/blacklist
end note

note right of SSL
  SSL/TLS Config:
  - TLS 1.3
  - Strong ciphers only
  - HSTS enabled
  - Certificate: Let's Encrypt
  - Auto-renewal
end note

note right of RateLimit
  Rate Limiting:
  
  Global:
  - 1000 req/hour per IP
  
  Authentication:
  - 5 login attempts/15min
  - 3 password reset/hour
  
  API Endpoints:
  - 100 req/minute (authenticated)
  - 20 req/minute (anonymous)
  
  Storage: Redis
  Algorithm: Sliding window
end note

note right of JWT
  JWT Security:
  - Algorithm: HS256
  - Secret: Environment variable
  - Access token TTL: 15 minutes
  - Refresh token TTL: 7 days
  - Token rotation
  - Blacklist support
  
  Claims:
  - userId
  - role
  - permissions
  - iat, exp
end note

note right of RBAC
  Roles:
  - ADMIN: Full access
  - MODERATOR: Content moderation
  - PROFESSIONAL: Manage sites
  - CONTRIBUTOR: Create content
  - TOURIST: Read-only + favorites
  
  Permissions:
  - sites:create
  - sites:update
  - sites:delete
  - reviews:moderate
  - users:manage
  etc.
end note

note right of PasswordHash
  Password Security:
  - Algorithm: bcrypt
  - Salt rounds: 12
  - Min length: 8 characters
  - Requirements:
    - 1 uppercase
    - 1 lowercase
    - 1 number
    - 1 special char
  
  Storage: Hashed only
  Never log passwords
end note

note right of Encryption
  Encryption Methods:
  
  At Rest:
  - Database: AES-256
  - Files: AES-256
  - Backups: Encrypted
  
  In Transit:
  - HTTPS/TLS 1.3
  - Secure WebSocket
  
  Sensitive Data:
  - Credit cards: Not stored
  - Phone numbers: Encrypted
  - Email: Hashed for search
end note

note bottom of Audit
  Audit Logging:
  
  Tracked Events:
  - Login attempts
  - Password changes
  - Permission changes
  - Data access
  - Data modifications
  - Failed authentications
  - API errors
  
  Log Retention: 1 year
  Storage: Encrypted
  Access: Admin only
end note

@enduml
```

---

## 10. Architecture de Notifications

```plantuml
@startuml NotificationArchitecture

!define RECTANGLE class

package "Notification Triggers" {
  [User Actions] as UserActions
  [System Events] as SystemEvents
  [Scheduled Jobs] as ScheduledJobs
  [Webhook Events] as WebhookEvents
}

package "Notification Module" {
  
  [Notification Controller] as NotifCtrl
  
  package "Notification Services" {
    [Notification Service] as NotifSvc
    [Template Service] as TemplateSvc
    [Delivery Service] as DeliverySvc
    [Preferences Service] as PrefSvc
  }
  
  package "Channel Managers" {
    [Push Notification Manager] as PushMgr
    [Email Manager] as EmailMgr
    [SMS Manager] as SMSMgr
    [In-App Manager] as InAppMgr
  }
  
  package "Notification Queue" {
    queue "High Priority Queue" as HighQueue
    queue "Normal Priority Queue" as NormalQueue
    queue "Low Priority Queue" as LowQueue
  }
  
  [Notification Repository] as NotifRepo
}

database "MySQL" as DB
database "Redis" as Cache

cloud "External Services" {
  [Firebase FCM] as FCM
  [SendGrid] as SendGrid
  [Twilio] as Twilio
}

package "Delivery Workers" {
  [Push Worker] as PushWorker
  [Email Worker] as EmailWorker
  [SMS Worker] as SMSWorker
}

' Triggers to Service
UserActions --> NotifSvc
SystemEvents --> NotifSvc
ScheduledJobs --> NotifSvc
WebhookEvents --> NotifSvc

' Service workflow
NotifSvc --> TemplateSvc : Get Template
TemplateSvc --> NotifSvc : Rendered Content
NotifSvc --> PrefSvc : Check Preferences
PrefSvc --> NotifSvc : User Preferences
NotifSvc --> DeliverySvc : Send Notification

' Delivery to Channel Managers
DeliverySvc --> PushMgr
DeliverySvc --> EmailMgr
DeliverySvc --> SMSMgr
DeliverySvc --> InAppMgr

' Channel Managers to Queues
PushMgr --> HighQueue
PushMgr --> NormalQueue
EmailMgr --> NormalQueue
EmailMgr --> LowQueue
SMSMgr --> HighQueue
InAppMgr --> DB

' Workers consume queues
HighQueue --> PushWorker
HighQueue --> SMSWorker
NormalQueue --> PushWorker
NormalQueue --> EmailWorker
LowQueue --> EmailWorker

' Workers to External Services
PushWorker --> FCM
EmailWorker --> SendGrid
SMSWorker --> Twilio

' Storage
NotifRepo --> DB
PrefSvc --> Cache
TemplateSvc --> DB

note right of NotifSvc
  Notification Types:
  
  User Events:
  - Badge earned
  - Level up
  - Review response
  - Check-in validated
  
  System Events:
  - Subscription expiring
  - Payment failed
  - Account suspended
  
  Marketing:
  - Weekly digest
  - Promotional offers
  - New features
end note

note right of PrefSvc
  User Preferences:
  
  Channels:
  - Push: enabled/disabled
  - Email: enabled/disabled
  - SMS: enabled/disabled
  - In-App: always enabled
  
  Frequency:
  - Real-time
  - Daily digest
  - Weekly digest
  - Never
  
  Categories:
  - Gamification: On
  - Reviews: On
  - Subscriptions: On
  - Marketing: Off
  
  Stored in: Redis cache
end note

note right of TemplateSvc
  Template System:
  
  Variables:
  - {{user.name}}
  - {{badge.name}}
  - {{points}}
  - {{level}}
  - etc.
  
  Localization:
  - English (default)
  - Arabic
  - French
  
  Templates:
  - HTML (Email)
  - Plain text (SMS)
  - JSON (Push)
end note

note left of HighQueue
  Queue Priorities:
  
  HIGH (0-5 sec):
  - OTP codes
  - Payment confirmations
  - Security alerts
  
  NORMAL (1-5 min):
  - Badge notifications
  - Review responses
  - Check-in validations
  
  LOW (5-60 min):
  - Digests
  - Marketing
  - Reports
end note

note bottom of FCM
  Push Notification Structure:
  
  {
    "notification": {
      "title": "New Badge!",
      "body": "You earned Explorer badge",
      "icon": "badge_icon.png"
    },
    "data": {
      "type": "BADGE_EARNED",
      "badgeId": "123",
      "points": "50"
    },
    "priority": "high",
    "ttl": 86400
  }
  
  Features:
  - Topic subscriptions
  - User segmentation
  - A/B testing
  - Analytics
end note

note bottom of SendGrid
  Email Features:
  
  - Dynamic templates
  - Personalization
  - A/B testing
  - Link tracking
  - Open tracking
  - Unsubscribe handling
  - Bounce handling
  - Spam scoring
  
  Limits:
  - 100,000 emails/month (free)
  - Rate: 100 emails/second
end note

package "Notification Analytics" {
  [Delivery Metrics] as Metrics
  [Engagement Tracking] as Engagement
  [Error Monitoring] as ErrorMon
}

PushWorker --> Metrics
EmailWorker --> Metrics
SMSWorker --> Metrics

FCM --> Engagement : Click tracking
SendGrid --> Engagement : Open/Click tracking

PushWorker --> ErrorMon : Failed deliveries
EmailWorker --> ErrorMon : Bounces
SMSWorker --> ErrorMon : Failed SMS

note bottom of Metrics
  Tracked Metrics:
  
  - Total sent
  - Delivered
  - Failed
  - Opened (email)
  - Clicked (email/push)
  - Unsubscribed
  - Bounced (email)
  
  Stored in: MySQL + Redis
  Dashboards: Real-time
end note

@enduml
```

---

## Instructions d'utilisation

### Génération des diagrammes

**Option 1 - PlantUML Online** :
```
1. Allez sur http://www.plantuml.com/plantuml/
2. Copiez le code UML
3. Collez dans l'éditeur
4. Cliquez "Submit"
5. Téléchargez en PNG/SVG/PDF
```

**Option 2 - VS Code** :
```
1. Installez l'extension "PlantUML"
2. Créez un fichier .puml
3. Collez le code
4. Appuyez Alt+D pour prévisualiser
5. Clic droit → Export pour sauvegarder
```

**Option 3 - Ligne de commande** :
```bash
# Installation (macOS)
brew install plantuml

# Installation (Linux)
sudo apt-get install plantuml

# Génération PNG
plantuml architecture.puml

# Génération SVG (recommandé pour qualité)
plantuml -tsvg architecture.puml

# Génération multiple
plantuml *.puml
```

### Personnalisation des styles

Ajoutez au début de chaque diagramme pour personnaliser :

```plantuml
@startuml
' Couleurs personnalisées
skinparam backgroundColor #FEFEFE
skinparam componentStyle rectangle

skinparam component {
  BackgroundColor #E3F2FD
  BorderColor #1976D2
  FontSize 12
  FontColor #000000
}

skinparam package {
  BackgroundColor #F3E5F5
  BorderColor #7B1FA2
  FontSize 14
}

skinparam database {
  BackgroundColor #E8F5E9
  BorderColor #388E3C
}

skinparam cloud {
  BackgroundColor #FFF3E0
  BorderColor #F57C00
}

' Flèches
skinparam ArrowColor #1976D2
skinparam ArrowThickness 2

@enduml
```

### Export en haute qualité

Pour des diagrammes en haute résolution :

```bash
# Export SVG (vectoriel, meilleure qualité)
plantuml -tsvg diagram.puml

# Export PNG haute résolution
plantuml -tpng -Sdpi=300 diagram.puml

# Export PDF
plantuml -tpdf diagram.puml
```

---

## Récapitulatif des Diagrammes

| Diagramme | Description | Utilisation |
|-----------|-------------|-------------|
| Architecture Globale | Vue d'ensemble du système | Comprendre l'architecture complète |
| Frontend Flutter | Structure application mobile | Développement frontend |
| Backend Node.js | Structure API REST | Développement backend |
| Base de Données | Infrastructure de données | Setup et optimisation DB |
| Services Externes | Intégrations tierces | Configuration APIs |
| Déploiement | Infrastructure cloud | DevOps et déploiement |
| Modules Métier | Composants par domaine | Organisation du code |
| Cache | Stratégies de mise en cache | Performance |
| Sécurité | Architecture de sécurité | Audit et compliance |
| Notifications | Système de notifications | Engagement utilisateur |

---

**Document créé le 16 janvier 2026**  
**MoroccoCheck - Codes Source UML Diagrammes de Composants**  
**Version 1.0 - Complet**
