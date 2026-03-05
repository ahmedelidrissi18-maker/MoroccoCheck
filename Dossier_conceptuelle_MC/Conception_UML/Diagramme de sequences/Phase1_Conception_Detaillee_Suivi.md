# Phase 1 : Conception Détaillée - Suivi et Progression

## 📊 Vue d'ensemble

**Durée estimée** : 3-4 jours  
**Date de début** : 15 janvier 2026  
**Statut** : 🟡 En cours

---

## ✅ Diagrammes de Séquence

### ✓ Diagrammes COMPLÉTÉS

#### 1. Inscription Utilisateur (`seq_01_inscription.svg`)
**Statut** : ✅ Terminé  
**Acteurs impliqués** :
- Utilisateur
- Application Mobile (Flutter)
- API Gateway (Express.js)
- AuthController
- Base de Données (MySQL)
- Email Service (SendGrid)

**Flux couvert** :
1. Affichage formulaire d'inscription
2. Saisie des informations (email, password, name)
3. Validation côté client
4. Envoi requête API POST /api/auth/register
5. Vérification email unique en BD
6. Hashage du mot de passe (bcrypt, 10 rounds)
7. Insertion en base de données
8. Génération token JWT
9. Envoi email de bienvenue (asynchrone)
10. Retour succès à l'utilisateur

**Points clés** :
- ⚠️ Alternative : Gestion du cas "email déjà utilisé" (409 Conflict)
- 🔒 Sécurité : Hashage bcrypt avec 10 rounds
- 📧 Email asynchrone : Non bloquant pour l'utilisateur
- 🎫 JWT : Token valide 24h

---

#### 2. Check-in GPS (`seq_02_checkin_gps.svg`)
**Statut** : ✅ Terminé  
**Acteurs impliqués** :
- Contributeur
- Application Mobile (Flutter)
- GPS Service (Device)
- Google Maps API
- API Backend (Node.js)
- Base de Données (MySQL)
- Gamification Service

**Flux couvert** :
1. Consultation fiche d'un site
2. Clic sur "Vérifier maintenant"
3. Demande permission localisation
4. Récupération position GPS actuelle
5. Calcul distance avec Google Maps API (Haversine)
6. **Validation distance** (ALT : > 100m = erreur, ≤ 100m = OK)
7. Affichage formulaire check-in
8. Saisie (statut, commentaire, photo optionnelle)
9. Soumission POST /api/checkins
10. Enregistrement en base de données
11. Calcul des points (10 + 5 si photo)
12. Retour succès avec points gagnés
13. Affichage confirmation à l'utilisateur

**Points clés** :
- 📍 Validation GPS : Rayon de 100 mètres MAXIMUM
- 🎯 Points : 10 de base + 5 bonus si photo ajoutée
- 📸 Photo optionnelle : Upload vers AWS S3
- 🔄 Mise à jour fraîcheur : Recalcul automatique du score

---

### 🔄 Diagrammes À CRÉER (Priorité HAUTE)

#### 3. Connexion Utilisateur
**Fichier** : `seq_03_connexion.svg`  
**Estimation** : 2-3 heures  
**Priorité** : 🔴 CRITIQUE

**Flux à couvrir** :
1. Saisie email et mot de passe
2. Validation format
3. POST /api/auth/login
4. Recherche utilisateur en BD
5. Vérification mot de passe (bcrypt.compare)
6. Génération JWT token
7. Mise à jour last_login_at
8. Retour user + token
9. Redirection selon rôle (touriste/pro/admin)

**Scénarios alternatifs** :
- Email inexistant
- Mot de passe incorrect
- Compte désactivé
- Trop de tentatives échouées (rate limiting)

**OAuth à inclure** :
- Connexion Google
- Connexion Facebook

---

#### 4. Dépôt d'Avis
**Fichier** : `seq_04_depot_avis.svg`  
**Estimation** : 2-3 heures  
**Priorité** : 🔴 CRITIQUE

**Flux à couvrir** :
1. Sélection d'un site
2. Clic "Laisser un avis"
3. Vérification : pas d'avis existant pour ce site
4. Affichage formulaire
5. Saisie (note 1-5, titre, commentaire, photos)
6. Upload photos (max 5)
7. POST /api/reviews
8. Enregistrement en BD
9. Recalcul note moyenne du site
10. Attribution 20 points
11. Vérification badges (Critique, Influenceur)
12. Retour succès

**Points clés** :
- ⭐ Note obligatoire (1-5 étoiles)
- 📝 Commentaire optionnel mais recommandé
- 📸 Max 5 photos par avis
- 🎯 20 points par avis
- 🚫 1 seul avis par site par utilisateur

---

#### 5. Paiement Stripe (Abonnement Pro)
**Fichier** : `seq_05_paiement_stripe.svg`  
**Estimation** : 3-4 heures  
**Priorité** : 🟡 HAUTE

**Flux à couvrir** :
1. Consultation plans d'abonnement
2. Sélection plan (Pro 29€ ou Premium 99€)
3. Clic "S'abonner"
4. Création session Stripe Checkout
5. Redirection vers Stripe
6. Saisie informations carte
7. Traitement paiement par Stripe
8. Webhook de confirmation
9. Activation abonnement en BD
10. Email de confirmation
11. Redirection dashboard avec nouvelles fonctionnalités

**Points clés** :
- 💳 Paiement sécurisé via Stripe (PCI DSS)
- 🔄 Abonnement mensuel récurrent
- 📧 Webhooks signés pour validation
- 💰 Plans : Basic (gratuit), Pro (29€), Premium (99€)

---

#### 6. Recherche de Sites
**Fichier** : `seq_06_recherche_sites.svg`  
**Estimation** : 2 heures  
**Priorité** : 🟢 MOYENNE

**Flux à couvrir** :
1. Saisie recherche textuelle
2. Application filtres (catégorie, distance, note)
3. GET /api/sites/search?q=...&filters=...
4. Recherche en BD avec index full-text
5. Tri par pertinence/distance/note
6. Pagination des résultats
7. Affichage liste avec markers carte
8. Mise en cache Redis (5 min)

---

#### 7. Modération de Contenu (Admin)
**Fichier** : `seq_07_moderation.svg`  
**Estimation** : 2-3 heures  
**Priorité** : 🟢 MOYENNE

**Flux à couvrir** :
1. Admin consulte contenus signalés
2. Visualisation avis/photo
3. Décision : Approuver / Rejeter / Bannir utilisateur
4. UPDATE status en BD
5. Notification à l'utilisateur
6. Ajout dans historique modération

---

### 📊 Progression Diagrammes de Séquence

| Diagramme | Statut | Priorité | Temps estimé | Temps réel |
|-----------|--------|----------|--------------|------------|
| 1. Inscription | ✅ Complété | 🔴 Critique | 2-3h | 2h30 |
| 2. Check-in GPS | ✅ Complété | 🔴 Critique | 3-4h | 3h00 |
| 3. Connexion | ⏳ À faire | 🔴 Critique | 2-3h | - |
| 4. Dépôt d'avis | ⏳ À faire | 🔴 Critique | 2-3h | - |
| 5. Paiement Stripe | ⏳ À faire | 🟡 Haute | 3-4h | - |
| 6. Recherche sites | ⏳ À faire | 🟢 Moyenne | 2h | - |
| 7. Modération | ⏳ À faire | 🟢 Moyenne | 2-3h | - |

**Progression globale** : 2/7 (29%) ✅

---

## 🏗️ Diagrammes de Classes

### Structure à créer

#### Classes Entités (Domain Layer)

```
User
├── id: int
├── email: string
├── password_hash: string
├── name: string
├── role: enum
├── points: int
├── level: enum
└── Méthodes:
    ├── addPoints(amount)
    ├── checkLevel()
    └── hasPermission(action)

TouristSite
├── id: int
├── name: string
├── latitude: double
├── longitude: double
├── category_id: int
├── freshness_score: int
├── average_rating: double
└── Méthodes:
    ├── calculateFreshness()
    ├── updateRating()
    └── getDistance(location)

CheckIn
├── id: int
├── user_id: int
├── site_id: int
├── status: enum
├── comment: string
├── photo_url: string
├── points_earned: int
└── Méthodes:
    └── validate(userLocation, siteLocation)

Review
├── id: int
├── user_id: int
├── site_id: int
├── rating: int (1-5)
├── title: string
├── comment: string
└── Méthodes:
    └── markAsHelpful(userId)
```

#### Classes Services

```
AuthService
├── register(userData)
├── login(email, password)
├── generateJWT(user)
├── validateToken(token)
└── refreshToken(refreshToken)

GamificationService
├── calculatePoints(action, hasBonus)
├── checkLevelUp(userId)
├── unlockBadge(userId, badgeType)
└── getLeaderboard(period)

LocationService
├── getCurrentLocation()
├── calculateDistance(point1, point2)
├── validateProximity(userPos, sitePos, maxDistance)
└── geocodeAddress(address)

PaymentService
├── createCheckoutSession(plan)
├── handleWebhook(event)
├── cancelSubscription(userId)
└── updateSubscription(userId, newPlan)
```

**Fichier à créer** : `class_diagram_domain.svg` et `class_diagram_services.svg`  
**Estimation** : 4-5 heures  
**Priorité** : 🔴 CRITIQUE

---

## 🔄 Diagrammes d'Activité

### Diagrammes À CRÉER

#### 1. Processus de Check-in Complet
**Fichier** : `activity_01_checkin_process.svg`  
**Estimation** : 2-3 heures

**Flux** :
```
[Début]
  ↓
[Utilisateur sur un site]
  ↓
[Demander permission GPS]
  ↓
<Permission accordée?> ─NO→ [Message erreur] → [Fin]
  ↓ YES
[Récupérer position GPS]
  ↓
[Calculer distance avec Google Maps]
  ↓
<Distance ≤ 100m?> ─NO→ [Message: trop éloigné] → [Fin]
  ↓ YES
[Afficher formulaire]
  ↓
[Utilisateur saisit statut]
  ↓
<Ajouter photo?> ─YES→ [Prendre/Sélectionner photo]
  ↓ NO              ↓
[Valider formulaire] ←┘
  ↓
[Envoyer à API]
  ↓
[Enregistrer check-in BD]
  ↓
[Calculer points: 10 + (photo ? 5 : 0)]
  ↓
[Mettre à jour profil utilisateur]
  ↓
[Recalculer score fraîcheur site]
  ↓
<Nouveau badge débloqué?> ─YES→ [Afficher animation badge]
  ↓ NO                            ↓
[Afficher succès + points] ←──────┘
  ↓
[Fin]
```

#### 2. Calcul du Score de Fraîcheur
**Fichier** : `activity_02_freshness_calculation.svg`  
**Estimation** : 1-2 heures

**Logique** :
```
Fonction: calculateFreshnessScore(siteId)

1. Récupérer dernier check-in du site
2. Calculer durée depuis dernier check-in (heures)
3. SI durée < 24h ALORS
     score = 100 (VERT)
   SINON SI durée < 168h (7 jours) ALORS
     score = 75 (ORANGE)
   SINON SI durée < 720h (30 jours) ALORS
     score = 50 (ROUGE)
   SINON
     score = 25 (GRIS)
4. Mettre à jour tourist_sites.freshness_score
5. Retourner score
```

#### 3. Processus de Gamification
**Fichier** : `activity_03_gamification.svg`  
**Estimation** : 2-3 heures

**Flux** :
- Attribution points
- Vérification niveau (Bronze/Argent/Or/Platine)
- Déblocage badges
- Mise à jour leaderboard

---

## 📦 Diagrammes de Composants

### Architecture Flutter (Frontend)

**Fichier** : `component_diagram_flutter.svg`  
**Estimation** : 2-3 heures

```
┌─────────────────────────────────────────┐
│      Presentation Layer                 │
│  ┌──────────────┐  ┌──────────────┐    │
│  │   Screens    │  │   Widgets    │    │
│  │              │  │              │    │
│  │ - HomeScreen │  │ - SiteCard   │    │
│  │ - MapScreen  │  │ - CheckinBtn │    │
│  │ - Profile    │  │ - RatingBar  │    │
│  └──────┬───────┘  └──────┬───────┘    │
└─────────┼──────────────────┼────────────┘
          │                  │
┌─────────┼──────────────────┼────────────┐
│      Business Logic Layer               │
│     ┌────▼──────────────────▼───────┐   │
│     │      State Management         │   │
│     │      (Provider/Riverpod)      │   │
│     │                                │   │
│     │ - AuthProvider                │   │
│     │ - SiteProvider                │   │
│     │ - CheckinProvider             │   │
│     │ - GamificationProvider        │   │
│     └────────────┬──────────────────┘   │
└──────────────────┼──────────────────────┘
                   │
┌──────────────────┼──────────────────────┐
│        Data Layer                       │
│  ┌─────▼────────┐  ┌──────────────┐    │
│  │   Services   │  │    Models    │    │
│  │              │  │              │    │
│  │ - ApiService │  │ - User       │    │
│  │ - AuthServ.  │  │ - Site       │    │
│  │ - LocationS. │  │ - CheckIn    │    │
│  │ - StorageS.  │  │ - Review     │    │
│  └──────────────┘  └──────────────┘    │
└─────────────────────────────────────────┘
```

### Architecture Backend (Node.js)

**Fichier** : `component_diagram_backend.svg`  
**Estimation** : 2-3 heures

```
┌────────────────────────────────────────┐
│       Routes Layer                     │
│   (Express Router)                     │
│                                        │
│  - authRoutes.js                       │
│  - siteRoutes.js                       │
│  - checkinRoutes.js                    │
│  - reviewRoutes.js                     │
└────────────┬───────────────────────────┘
             │
┌────────────▼───────────────────────────┐
│    Controllers Layer                   │
│  (Request Handling)                    │
│                                        │
│  - AuthController                      │
│  - SiteController                      │
│  - CheckinController                   │
│  - ReviewController                    │
└────────────┬───────────────────────────┘
             │
┌────────────▼───────────────────────────┐
│     Services Layer                     │
│  (Business Logic)                      │
│                                        │
│  - AuthService                         │
│  - GamificationService                 │
│  - LocationService                     │
│  - EmailService                        │
│  - PaymentService                      │
└────────────┬───────────────────────────┘
             │
┌────────────▼───────────────────────────┐
│      Models Layer                      │
│  (Data Access - ORM)                   │
│                                        │
│  - User.model.js                       │
│  - TouristSite.model.js               │
│  - CheckIn.model.js                    │
│  - Review.model.js                     │
└────────────────────────────────────────┘
```

---

## 🔀 Diagrammes d'États

### États à modéliser

#### 1. États d'un Check-in
**Fichier** : `state_diagram_checkin.svg`

```
[Initial] → [En création]
              ↓
         [Validation GPS]
              ↓
    <Distance valide?> ─NO→ [Rejeté]
              ↓ YES
         [Formulaire rempli]
              ↓
         [En soumission]
              ↓
    <Erreur API?> ─YES→ [Échoué] → [Retry]
              ↓ NO
         [Enregistré]
              ↓
         [Points attribués]
              ↓
         [Actif]
```

#### 2. États d'un Abonnement Professionnel
**Fichier** : `state_diagram_subscription.svg`

```
[Nouveau] → [En attente paiement]
                    ↓
          <Paiement réussi?> ─NO→ [Échoué]
                    ↓ YES
                [Actif]
                    ↓
          <Date échéance?> ─YES→ [En renouvellement]
                    ↓               ↓
                [Actif] ←YES─ <Paiement OK?>
                                    ↓ NO
                              [Expiré] → [Suspendu]
```

---

## 📋 Checklist de Progression Phase 1

### Semaine 1 - Jours 1-2 : Diagrammes de Séquence

- [x] 1. Inscription utilisateur ✅
- [x] 2. Check-in GPS ✅
- [ ] 3. Connexion utilisateur
- [ ] 4. Dépôt d'avis
- [ ] 5. Paiement Stripe
- [ ] 6. Recherche de sites
- [ ] 7. Modération de contenu

**Progression** : 2/7 (29%) ✅

### Semaine 1 - Jours 3-4 : Diagrammes de Classes

- [ ] Diagramme de classes - Entités (Domain)
- [ ] Diagramme de classes - Services
- [ ] Diagramme de classes - Relations et héritage

**Progression** : 0/3 (0%)

### Semaine 1 - Jours 5-6 : Diagrammes d'Activité

- [ ] Processus check-in complet
- [ ] Calcul score de fraîcheur
- [ ] Processus gamification
- [ ] Validation établissement pro

**Progression** : 0/4 (0%)

### Semaine 1 - Jour 7 : Review et Diagrammes Complémentaires

- [ ] Diagramme de composants - Flutter
- [ ] Diagramme de composants - Backend
- [ ] Diagrammes d'états (3 diagrammes)
- [ ] Review globale de cohérence
- [ ] Documentation des choix techniques

**Progression** : 0/5 (0%)

---

## 📊 Statistiques Globales Phase 1

| Catégorie | Complété | En cours | À faire | Total | % |
|-----------|----------|----------|---------|-------|---|
| Diagrammes de séquence | 2 | 0 | 5 | 7 | 29% |
| Diagrammes de classes | 0 | 0 | 3 | 3 | 0% |
| Diagrammes d'activité | 0 | 0 | 4 | 4 | 0% |
| Diagrammes de composants | 0 | 0 | 2 | 2 | 0% |
| Diagrammes d'états | 0 | 0 | 3 | 3 | 0% |
| **TOTAL** | **2** | **0** | **17** | **19** | **11%** |

---

## 🎯 Prochaines Actions Prioritaires

### ⏰ Aujourd'hui (15 janvier 2026)

1. ✅ Terminer diagrammes de séquence critiques :
   - [ ] Connexion utilisateur (2-3h)
   - [ ] Dépôt d'avis (2-3h)

### 📅 Demain (16 janvier 2026)

2. Compléter diagrammes de séquence restants :
   - [ ] Paiement Stripe (3-4h)
   - [ ] Recherche de sites (2h)

3. Commencer diagrammes de classes :
   - [ ] Entités du domaine (2-3h)

### 📅 Jour 3 (17 janvier 2026)

4. Finaliser diagrammes de classes :
   - [ ] Services et contrôleurs (2h)
   - [ ] Relations et dépendances (1-2h)

5. Commencer diagrammes d'activité :
   - [ ] Processus check-in (2h)

### 📅 Jour 4 (18 janvier 2026)

6. Compléter diagrammes d'activité :
   - [ ] Calcul fraîcheur (1-2h)
   - [ ] Gamification (2-3h)

7. Diagrammes de composants :
   - [ ] Architecture Flutter (2h)
   - [ ] Architecture Backend (2h)

---

## 💡 Conseils et Bonnes Pratiques

### Pour les Diagrammes de Séquence

✅ **À faire** :
- Numéroter toutes les étapes
- Inclure les cas alternatifs [ALT]
- Montrer les appels asynchrones (pointillés)
- Indiquer les boîtes d'activation
- Documenter les retours d'erreur

❌ **À éviter** :
- Trop de détails techniques
- Messages non explicites
- Oublier les acteurs externes
- Négliger les cas d'erreur

### Pour les Diagrammes de Classes

✅ **À faire** :
- Définir clairement les responsabilités
- Utiliser l'héritage quand pertinent
- Indiquer les cardinalités
- Documenter les méthodes principales

### Pour les Diagrammes d'Activité

✅ **À faire** :
- Utiliser des losanges pour les décisions
- Montrer les chemins alternatifs
- Indiquer début et fin
- Être explicite sur les conditions

---

## 📚 Ressources

### Outils Utilisés

- **Diagrammes SVG** : Créés manuellement pour contrôle total
- **Alternative** : Draw.io, Lucidchart, PlantUML
- **Validation** : Revue par pairs recommandée

### Standards UML

- UML 2.5.1 (OMG)
- Notation standard pour tous les diagrammes
- Cohérence entre diagrammes

---

## 📝 Notes Techniques Importantes

### Règles de Gestion Identifiées

**RG01** : Un utilisateur ne peut faire qu'un check-in par site par jour  
**RG02** : Distance maximale check-in : 100 mètres  
**RG03** : Points check-in : 10 de base + 5 si photo  
**RG04** : Points avis : 20 points  
**RG05** : Un seul avis par utilisateur par site  
**RG06** : Note obligatoire (1-5 étoiles)  
**RG07** : Maximum 5 photos par avis  
**RG08** : Maximum 20 photos par établissement  
**RG09** : Score de fraîcheur recalculé après chaque check-in  
**RG10** : JWT expire après 24h

### Décisions Architecturales

1. **Architecture en couches** : Séparation claire Présentation / Business / Data
2. **State Management** : Provider/Riverpod pour Flutter
3. **API REST** : Express.js avec architecture MVC
4. **Authentification** : JWT avec refresh tokens
5. **Validation GPS** : Formule de Haversine via Google Maps API
6. **Paiements** : Stripe avec webhooks signés
7. **Stockage images** : AWS S3 avec compression
8. **Cache** : Redis pour sessions et requêtes fréquentes

---

**Dernière mise à jour** : 15 janvier 2026, 16:00  
**Prochaine revue** : 16 janvier 2026

---

_Document vivant - Mise à jour quotidienne recommandée_
