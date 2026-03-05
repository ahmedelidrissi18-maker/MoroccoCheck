# Phase 4 : Planning et Organisation du Projet
## MoroccoCheck - Roadmap et Gestion de Projet

*Document créé le 16 janvier 2026*

---

## Table des Matières

1. [Vue d'Ensemble du Projet](#1-vue-densemble-du-projet)
2. [Structure de l'Équipe](#2-structure-de-léquipe)
3. [Méthodologie Agile](#3-méthodologie-agile)
4. [Découpage en Sprints](#4-découpage-en-sprints)
5. [Estimation des Charges](#5-estimation-des-charges)
6. [Roadmap Détaillée](#6-roadmap-détaillée)
7. [Jalons et Livrables](#7-jalons-et-livrables)
8. [Gestion des Risques](#8-gestion-des-risques)
9. [Outils et Communication](#9-outils-et-communication)
10. [Budget et Ressources](#10-budget-et-ressources)

---

## 1. Vue d'Ensemble du Projet

### 1.1 Objectifs du Projet

**Vision** : Créer la plateforme mobile de référence pour découvrir et vérifier l'état des sites touristiques au Maroc.

**Objectifs SMART** :

✅ **Spécifique** : Application mobile iOS/Android avec système de check-in GPS, avis, gamification et abonnements professionnels

✅ **Mesurable** : 
- 10,000 utilisateurs actifs en 3 mois
- 5,000 sites référencés
- 20,000 check-ins par mois
- 50 abonnements professionnels

✅ **Atteignable** : Stack technique moderne et éprouvée (Flutter, Node.js, MySQL)

✅ **Réaliste** : Budget de 50,000 USD, équipe de 6 personnes, 6 mois de développement

✅ **Temporel** : 
- Développement : 6 mois (Février - Juillet 2026)
- Bêta publique : Juin 2026
- Lancement officiel : Août 2026

### 1.2 Périmètre du Projet

#### In Scope ✅

**MVP (Version 1.0)** :
- Application mobile iOS/Android (Flutter)
- Backend API REST (Node.js)
- Base de données relationnelle (MySQL)
- Authentification (JWT + OAuth Google/Facebook/Apple)
- CRUD Sites touristiques complet
- Check-in GPS avec validation stricte
- Système d'avis et notes
- Gamification (points, badges, niveaux, classement)
- Abonnements professionnels (Stripe)
- Interface d'administration web
- Recherche avancée avec filtres
- Photos et galeries
- Notifications push
- Système de fraîcheur des données

**Fonctionnalités Principales** :
- 60+ endpoints API
- 14 tables base de données
- 8 rôles et permissions
- 25 badges à débloquer
- 4 plans d'abonnement
- Support FR/AR/EN

#### Out of Scope ❌

**Non inclus dans MVP** :
- Application web complète (seulement admin)
- Réservations en ligne
- Paiement sur place
- Système de messagerie interne
- Réalité augmentée
- Intégration réseaux sociaux avancée
- Application desktop
- Support d'autres langues (ES, DE, etc.)
- Marketplace tiers
- API publique pour développeurs

**Potentiel V2** (après lancement) :
- Itinéraires personnalisés avec IA
- Recommandations ML
- Chat bot support
- Programme d'affiliation
- Widgets web pour sites partenaires

### 1.3 Contraintes

**Techniques** :
- Technologies imposées : Flutter, Node.js, MySQL
- Compatibilité : iOS 13+, Android 8+
- Performance : < 200ms latence API
- Disponibilité : 99.5% uptime

**Budget** :
- Budget total : 50,000 USD
- Développement : 35,000 USD
- Infrastructure : 5,000 USD
- Marketing : 10,000 USD

**Délais** :
- Date de début : 1er Février 2026
- Date de fin développement : 31 Juillet 2026
- Durée : 6 mois (26 semaines)

**Qualité** :
- Code coverage : minimum 80%
- Code review obligatoire
- Pas de bugs critiques en production
- Conformité RGPD

---

## 2. Structure de l'Équipe

### 2.1 Composition de l'Équipe

**Équipe Minimale (6 personnes)** :

```
                    ┌─────────────────────────┐
                    │   PRODUCT OWNER (PO)    │
                    │   - Vision produit      │
                    │   - Priorisation        │
                    │   - Stakeholders        │
                    └───────────┬─────────────┘
                                │
                    ┌───────────▼─────────────┐
                    │   SCRUM MASTER / PM     │
                    │   - Facilitation        │
                    │   - Suivi projet        │
                    │   - Blockers removal    │
                    └───────────┬─────────────┘
                                │
        ┌───────────────────────┼───────────────────────┐
        │                       │                       │
┌───────▼────────┐  ┌──────────▼──────────┐  ┌────────▼────────┐
│ LEAD DEVELOPER │  │  MOBILE DEVELOPERS  │  │ BACKEND DEV     │
│ (Full-Stack)   │  │  (Flutter × 2)      │  │ (Node.js)       │
│                │  │                     │  │                 │
│ - Architecture │  │ - UI/UX implement   │  │ - API REST      │
│ - Code Review  │  │ - State management  │  │ - Database      │
│ - DevOps       │  │ - Native features   │  │ - Integration   │
└────────────────┘  └─────────────────────┘  └─────────────────┘
```

### 2.2 Rôles et Responsabilités

#### Product Owner (PO) - 1 personne

**Responsabilités** :
- Définir et prioriser le Product Backlog
- Valider les user stories
- Acceptance testing
- Communication avec stakeholders
- Décisions produit finales

**Profil** :
- Expérience e-commerce ou marketplace
- Connaissance marché marocain
- Compétences UX/UI appréciées

**Charge** : 50% (mi-temps)

---

#### Scrum Master / Project Manager - 1 personne

**Responsabilités** :
- Faciliter les cérémonies Scrum
- Suivre l'avancement (burndown charts)
- Identifier et résoudre les blockers
- Reporting management
- Documentation projet

**Profil** :
- Certification Scrum Master (CSM) ou équivalent
- Expérience gestion projets agiles
- Excellente communication

**Charge** : 100% (temps plein)

---

#### Lead Developer (Full-Stack) - 1 personne

**Responsabilités** :
- Architecture technique globale
- Code reviews (toutes les PR)
- DevOps et CI/CD
- Choix technologiques
- Mentorat équipe
- Résolution bugs critiques

**Compétences** :
- Expert Flutter + Node.js
- Expérience architecture cloud (AWS/DO)
- Docker, Kubernetes
- CI/CD (GitHub Actions)
- 5+ ans expérience

**Charge** : 100% (temps plein)

---

#### Mobile Developers (Flutter) - 2 personnes

**Responsabilités** :
- Développement UI/UX Flutter
- State management (Provider/Riverpod)
- Intégration API REST
- Features natives (GPS, Camera, Notifications)
- Tests unitaires et widgets
- Optimisation performance

**Compétences** :
- Flutter 3.19+, Dart
- Expérience apps production
- Google Maps, Firebase
- iOS et Android natif (bonus)
- 2-3 ans expérience

**Charge** : 100% chacun (temps plein)

---

#### Backend Developer (Node.js) - 1 personne

**Responsabilités** :
- Développement API REST
- Modèles et requêtes base de données
- Intégrations tierces (Stripe, SendGrid, etc.)
- Background jobs (Bull)
- Tests API (Jest, Supertest)
- Documentation API (Swagger)

**Compétences** :
- Node.js 20+, Express
- MySQL (Sequelize ORM)
- Redis, Elasticsearch
- JWT, OAuth 2.0
- 3+ ans expérience

**Charge** : 100% (temps plein)

---

### 2.3 Organisation du Travail

**Horaires** :
- Lundi - Vendredi : 9h00 - 18h00
- Pause déjeuner : 12h30 - 14h00
- Réunions : Préférablement matin (10h-12h)

**Télétravail** :
- 2 jours bureau / 3 jours remote (flexible)
- Réunions Sprint en présentiel obligatoires

**Communication** :
- Slack : Communication quotidienne
- Zoom/Meet : Daily standup, réunions
- Jira : Suivi tâches et sprints
- Confluence : Documentation
- GitHub : Code, PRs, reviews

---

## 3. Méthodologie Agile

### 3.1 Framework Scrum

**Sprints** :
- Durée : 2 semaines (10 jours ouvrés)
- Total : 13 sprints sur 6 mois
- Releases : toutes les 2-3 sprints

**Cérémonies** :

#### Sprint Planning (4h - début de sprint)
- **Quand** : Lundi matin, semaine impaire
- **Participants** : Toute l'équipe
- **Objectif** : Sélectionner et estimer les user stories du sprint
- **Outputs** : Sprint Backlog, Sprint Goal

#### Daily Standup (15 min - quotidien)
- **Quand** : Chaque matin 10h00
- **Participants** : Équipe dev (PO optionnel)
- **Format** : 
  - Qu'ai-je fait hier ?
  - Que vais-je faire aujourd'hui ?
  - Y a-t-il des blockers ?

#### Sprint Review (2h - fin de sprint)
- **Quand** : Vendredi après-midi, semaine paire
- **Participants** : Équipe + Stakeholders
- **Objectif** : Démo des fonctionnalités complétées
- **Outputs** : Feedback, ajustements backlog

#### Sprint Retrospective (1h30 - fin de sprint)
- **Quand** : Vendredi fin de journée, semaine paire
- **Participants** : Équipe uniquement
- **Objectif** : Amélioration continue
- **Format** : Start, Stop, Continue

#### Backlog Refinement (1h - mi-sprint)
- **Quand** : Mercredi semaine paire
- **Participants** : PO + Lead Dev + volontaires
- **Objectif** : Préparer les prochains sprints

### 3.2 Definition of Ready (DoR)

Une user story est "Ready" si :

✅ Titre clair et concis
✅ Description au format : "En tant que [rôle], je veux [action] afin de [bénéfice]"
✅ Critères d'acceptance définis (Given/When/Then)
✅ Maquettes UI disponibles (si applicable)
✅ Dépendances identifiées
✅ Estimée en story points
✅ Validée par le PO

**Exemple** :

```
Titre: Créer un check-in GPS

En tant qu'utilisateur contributeur,
Je veux effectuer un check-in sur un site touristique,
Afin de contribuer à la fraîcheur des données et gagner des points.

Critères d'acceptance:
- Given: Je suis authentifié et proche d'un site (<100m)
- When: Je clique sur "Check-in" et confirme le statut du site
- Then: Mon check-in est enregistré, j'obtiens 10-15 points, et le site est mis à jour

- Given: J'ai déjà fait un check-in aujourd'hui sur ce site
- When: Je tente un nouveau check-in
- Then: Je reçois un message "Cooldown actif, revenez demain"

Maquettes: Figma #245
Estimation: 5 points
Dépendances: US-023 (Authentification GPS)
```

### 3.3 Definition of Done (DoD)

Une user story est "Done" si :

✅ Code écrit et respecte les standards
✅ Tests unitaires écrits (coverage ≥ 80%)
✅ Tests d'intégration passent
✅ Code review approuvée (min 1 approbation)
✅ Documentation mise à jour (README, API docs)
✅ Déployé sur environnement staging
✅ Acceptance testing réussie par le PO
✅ Pas de bugs critiques ou bloquants
✅ Performance acceptable (< 200ms API)
✅ Accessibilité validée (si UI)

---

## 4. Découpage en Sprints

### 4.1 Vue d'Ensemble des Sprints

```
Durée totale: 26 semaines (6 mois)
Nombre de sprints: 13 sprints × 2 semaines

┌─────────────────────────────────────────────────────────────────────┐
│                        TIMELINE PROJET                              │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  FÉV 2026        MARS        AVR        MAI        JUIN      JUIL  │
│  │───│───│───│───│───│───│───│───│───│───│───│───│───│          │
│  S0  S1  S2  S3  S4  S5  S6  S7  S8  S9  S10 S11 S12 S13         │
│                                                                     │
│  ┌──────────┐ ┌──────────────────────────┐ ┌─────────┐           │
│  │  SETUP   │ │   DÉVELOPPEMENT CORE     │ │  POLISH │           │
│  └──────────┘ └──────────────────────────┘ └─────────┘           │
│                                                                     │
│               R1                    R2              R3             │
│             (Alpha)             (Beta)          (RC)               │
└─────────────────────────────────────────────────────────────────────┘

R = Release
S = Sprint
```

### 4.2 Sprints Détaillés

#### Sprint 0 : Setup et Fondations (Sem 1-2)

**Dates** : 3-14 Février 2026 | **SP** : 40

**Livrables** :
✅ Infrastructure (GitHub, CI/CD, Envs)
✅ Structure projet (Backend + Mobile)
✅ Outils configurés (Jira, Slack, Figma)

---

#### Sprint 1 : Authentication Backend (Sem 3-4)

**Dates** : 17-28 Février 2026 | **SP** : 39

**Stories** : JWT, OAuth (Google/Facebook/Apple), Reset password

---

#### Sprint 2 : Mobile App Foundation (Sem 5-6)

**Dates** : 3-14 Mars 2026 | **SP** : 44

**Stories** : Splash, Onboarding, Auth screens, Navigation

---

#### Sprint 3 : Sites CRUD Backend (Sem 7-8)

**Dates** : 17-28 Mars 2026 | **SP** : 47

**Stories** : GET/POST/PUT/DELETE sites, Upload photos S3, Search

---

#### Sprint 4 : Sites Mobile UI (Sem 9-10)

**Dates** : 31 Mars - 11 Avril 2026 | **SP** : 47

**Stories** : Liste sites, Détails, Filtres, Carte Google Maps

---

#### Sprint 5 : Check-ins GPS (Sem 11-12)

**Dates** : 14-25 Avril 2026 | **SP** : 50

**Stories** : POST /checkins GPS validation, UI mobile, Photos

**🚀 RELEASE 1 (Alpha) - 30 Avril**

---

#### Sprint 6 : Système d'Avis (Sem 13-14)

**Dates** : 28 Avril - 9 Mai 2026 | **SP** : 50

**Stories** : CRUD reviews, Votes, Reports, UI mobile

---

#### Sprint 7 : Gamification (Sem 15-16)

**Dates** : 12-23 Mai 2026 | **SP** : 55

**Stories** : Points, Badges, Niveaux, Leaderboard

---

#### Sprint 8 : Abonnements Stripe (Sem 17-18)

**Dates** : 26 Mai - 6 Juin 2026 | **SP** : 52

**Stories** : Stripe integration, Plans, Webhooks, UI paiement

---

#### Sprint 9 : Administration Web (Sem 19-20)

**Dates** : 9-20 Juin 2026 | **SP** : 42

**Stories** : Dashboard admin, Modération, Analytics

**🧪 RELEASE 2 (Beta) - 20 Juin**

---

#### Sprint 10 : Notifications (Sem 21-22)

**Dates** : 23 Juin - 4 Juillet 2026 | **SP** : 42

**Stories** : Firebase FCM, Push notifs, Emails, Préférences

---

#### Sprints 11-13 : Testing & Polish (Sem 23-26)

**Dates** : 7-25 Juillet 2026 | **SP** : 80

**Activités** :
✅ Tests E2E complets
✅ Bug fixing
✅ Optimisation performance
✅ Documentation finale
✅ App Store submission

**✅ RELEASE 3 (RC) - 25 Juillet**

---

## 5. Estimation des Charges

### 5.1 Système de Story Points

**Échelle de Fibonacci** : 1, 2, 3, 5, 8, 13, 21

| SP | Complexité | Exemple | Durée |
|----|------------|---------|-------|
| 1 | Trivial | Champ simple | 1-2h |
| 2 | Très simple | CRUD basique | 2-4h |
| 3 | Simple | Endpoint validé | 4-6h |
| 5 | Moyen | Feature simple | 1 jour |
| 8 | Complexe | Integration | 1.5-2j |
| 13 | Très complexe | Feature majeure | 2-3j |
| 21 | Épique | À découper | > 3j |

### 5.2 Vélocité de l'Équipe

**Vélocité Moyenne** : 47 SP/sprint

**Capacité par Dev** :
- Lead Dev : 13 SP (code + reviews)
- Backend Dev : 15 SP
- Mobile Dev 1 : 15 SP
- Mobile Dev 2 : 15 SP
- **Total** : 58 SP théorique

**Overhead** : ~45% (réunions, reviews, bugs, docs)

**Vélocité réelle** : 58 × 0.55 = 47 SP ✅

### 5.3 Total Story Points

| Phase | Sprints | SP | % |
|-------|---------|-----|---|
| Setup | Sprint 0 | 40 | 6% |
| Backend Core | S1,3,5-8 | 283 | 44% |
| Mobile UI | S2,4,6-8,10 | 232 | 36% |
| Admin & Test | S9,11-13 | 122 | 19% |
| **TOTAL** | **13** | **637** | **100%** |

---

## 6. Roadmap Détaillée

### 6.1 Timeline Visuelle

```
FÉVRIER 2026
├─ S0  │ Setup Infrastructure
├─ S1  │ Authentication Backend

MARS 2026
├─ S2  │ Mobile App Foundation
├─ S3  │ Sites CRUD Backend

AVRIL 2026
├─ S4  │ Sites Mobile UI
├─ S5  │ Check-ins GPS
│         └──► 🚀 RELEASE 1 (Alpha) - 30 Avril

MAI 2026
├─ S6  │ Système d'Avis
├─ S7  │ Gamification
├─ S8  │ Abonnements Stripe

JUIN 2026
├─ S9  │ Administration Web
├─ S10 │ Notifications
│         └──► 🧪 RELEASE 2 (Beta) - 20 Juin

JUILLET 2026
├─ S11-13 │ Testing & Polish
│            └──► ✅ RELEASE 3 (RC) - 25 Juillet

AOÛT 2026
└─ 🎉 LANCEMENT PUBLIC - 1er Août
```

### 6.2 Releases Majeures

**Release 1 : Alpha (30 Avril)**
- Tests internes uniquement
- Auth + Sites + Check-ins

**Release 2 : Beta (20 Juin)**
- 100-200 beta testers
- + Reviews + Gamification + Paiements

**Release 3 : RC (25 Juillet)**
- 500+ utilisateurs beta
- Toutes fonctionnalités MVP

**Lancement Public (1er Août)**
- App Store + Play Store
- Campagne marketing

---

## 7. Jalons et Livrables

| Jalon | Date | Critères |
|-------|------|----------|
| 🏁 Kick-off | 3 Fév | Équipe assemblée |
| 📱 First Build | 14 Mars | App installable |
| 📍 Check-in Live | 25 Avr | GPS OK |
| 🚀 Alpha | 30 Avr | Tests internes |
| 🎮 Gamification | 23 Mai | Points & badges |
| 🧪 Beta | 20 Juin | 100 testers |
| ✅ RC | 25 Juil | Production ready |
| 🎉 Launch | 1 Août | App stores live |

---

## 8. Gestion des Risques

| Risque | Prob | Impact | Mitigation |
|--------|------|--------|------------|
| Retard dev | Élevée | Élevé | Buffer 2 sem, priorisation |
| Bugs critiques | Moyenne | Élevé | Tests 80%, code review |
| Budget dépassé | Moyenne | Moyen | Suivi hebdo |
| Turnover | Faible | Élevé | Documentation, pair prog |
| Rejection stores | Faible | Élevé | Guidelines Apple/Google |

---

## 9. Outils et Communication

**Gestion** : Jira, Confluence, Miro
**Dev** : GitHub, VS Code, Postman, Docker
**Comm** : Slack, Zoom, Loom
**Design** : Figma, Zeplin
**Monitoring** : Datadog, Sentry

**Channels Slack** :
- #general, #dev-backend, #dev-mobile
- #qa-testing, #deployments, #monitoring

---

## 10. Budget et Ressources

**TOTAL : 50,000 USD**

### Ressources Humaines (35,000 USD)

**Option Optimisée** :
- Lead Dev (moonlighting) : 12,000 USD
- 2 Devs mid-level : 20,000 USD (10k chacun)
- PM part-time : 3,000 USD
- **Total** : 35,000 USD ✅

### Infrastructure (5,000 USD)

- Cloud (DigitalOcean) : 1,500 USD
- SaaS (Datadog, Sentry, etc.) : 2,000 USD
- Outils dev (Jira, GitHub) : 1,000 USD
- Licenses (Apple, Google) : 124 USD
- Marge imprévus : 376 USD

### Marketing (10,000 USD)

- Branding & Video : 2,500 USD
- Campagne social media : 3,000 USD
- Influenceurs : 2,000 USD
- ASO & PR : 1,500 USD
- Support setup : 1,000 USD

### ROI Prévisionnel

**Année 1** :
- Revenus abonnements : ~15,000 USD
- Revenus publicité : ~10,000 USD
- **Total** : ~25,000 USD

**Année 2** :
- 100k users, 500 abonnés
- Revenus : ~230,000 USD
- **Break-even** : Mois 15-18

---

## Conclusion

✅ **Roadmap structurée** - 13 sprints, 6 mois
✅ **Équipe optimisée** - 6 personnes
✅ **Méthodologie Scrum** - Cérémonies complètes
✅ **637 Story Points** - Vélocité 47 SP/sprint
✅ **Budget 50k USD** - Réparti intelligemment
✅ **3 Releases** - Alpha, Beta, RC
✅ **Risques maîtrisés** - Plans de mitigation

**Lancement prévu : 1er Août 2026** 🚀

---

**Document créé le 16 janvier 2026**  
**MoroccoCheck - Phase 4 : Planning et Organisation**  
**Version 1.0 - Complet**
