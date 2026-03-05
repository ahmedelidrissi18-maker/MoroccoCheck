# Diagrammes de Cas d'Utilisation - MoroccoCheck

## Vue d'ensemble

Ce document présente les diagrammes de cas d'utilisation pour chaque acteur du système MoroccoCheck, une application mobile touristique intelligente pour le Maroc.

---

## 1. Acteur: Touriste

**Type:** Utilisateur humain visiteur  
**Fichier:** `use_case_touriste.svg`

### Description
Le Touriste est un utilisateur qui consulte les informations touristiques sans nécessairement créer de compte. Il peut utiliser l'application en mode visiteur.

### Cas d'utilisation principaux:
- **CU01:** S'inscrire
- **CU02:** Se connecter  
- **CU05:** Consulter la carte interactive
- **CU06:** Rechercher un site touristique
- **CU07:** Filtrer les sites par catégorie
- **CU08:** Consulter les détails d'un site
- **CU09:** Obtenir un itinéraire vers un site
- **CU13:** Marquer un site comme favori

### Note importante
Le Touriste peut devenir Contributeur en créant un compte. Il peut utiliser l'application en mode visiteur sans inscription.

---

## 2. Acteur: Contributeur

**Type:** Utilisateur humain actif (hérite du Touriste)  
**Fichier:** `use_case_contributeur.svg`

### Description
Le Contributeur est un touriste authentifié qui participe activement à la mise à jour des informations via des check-ins GPS et des avis. Il bénéficie du système de gamification.

### Cas d'utilisation principaux:
- **CU01:** S'inscrire
- **CU02:** Se connecter
- **CU04:** Modifier le profil utilisateur
- **CU10:** Effectuer un check-in GPS ⭐ (cas principal)
- **CU11:** Laisser un avis sur un site ⭐ (cas principal)
- **CU12:** Ajouter une photo à un check-in/avis
- **CU14:** Consulter son profil et statistiques
- **CU15:** Voir ses badges obtenus
- **CU16:** Consulter le leaderboard
- **CU17:** Gagner des points (cas inclus)

### Système de Gamification:
- **Points:**
  - Check-in: 10 points (+5 avec photo)
  - Avis déposé: 20 points
- **Niveaux:** Bronze (0), Argent (100), Or (500), Platine (1000)
- **Badges:** Explorateur, Guide, Expert, Photographe, Critique, Influenceur
- **Leaderboards:** Hebdomadaire, Mensuel, Global

---

## 3. Acteur: Professionnel

**Type:** Utilisateur humain (propriétaire d'établissement)  
**Fichier:** `use_case_professionnel.svg`

### Description
Le Professionnel est un propriétaire ou gestionnaire d'établissement touristique qui utilise l'application pour gérer sa présence en ligne et interagir avec sa clientèle.

### Cas d'utilisation principaux:
- **CU02:** Se connecter
- **CU18:** Gérer son établissement ⭐ (cas principal)
- **CU19:** Consulter les analytics de l'établissement ⭐ (cas principal)
- **CU20:** Répondre à un avis client
- **CU21:** S'abonner à un plan professionnel
- **CU22:** Créer une promotion ou offre spéciale

### Sous-fonctionnalités (CU18 - Gérer établissement):
- Modifier informations établissement
- Gérer horaires et prix
- Gérer les photos (jusqu'à 20)
- Consulter dashboard avec statistiques

### Plans d'Abonnement:
- **Basic (Gratuit):** Gestion basique, statistiques limitées
- **Pro (29€/mois):** Analytics avancés, réponse aux avis, promotions
- **Premium (99€/mois):** Toutes fonctionnalités + priorité + support dédié

**Paiement:** Sécurisé via Stripe • Facturation automatique • Annulation à tout moment

---

## 4. Acteur: Administrateur

**Type:** Utilisateur humain (équipe MoroccoCheck)  
**Fichier:** `use_case_administrateur.svg`

### Description
L'Administrateur est responsable de la modération, de la gestion des utilisateurs et de la maintenance du système. Il dispose d'un accès complet à la plateforme.

### Cas d'utilisation principaux:
- **CU23:** Modérer le contenu utilisateur ⭐
- **CU24:** Valider un établissement professionnel ⭐
- **CU25:** Gérer les utilisateurs ⭐
- Gérer les sites touristiques
- Consulter statistiques globales

### Sous-fonctionnalités de modération (CU23):
- Supprimer un avis inapproprié
- Supprimer des photos inappropriées

### Sous-fonctionnalités de gestion utilisateurs (CU25):
- Suspendre un compte
- Supprimer un compte
- Modifier les rôles utilisateur

⚠️ **Note importante:** Accès complet au système - Responsable de la modération et maintenance

---

## 5. Acteurs Systèmes Externes

**Fichier:** `use_case_systemes_externes.svg`

### 5.1 Stripe (Système de Paiement)

**Type:** Système externe

#### Cas d'utilisation:
- Traiter les paiements d'abonnement
- Gérer les abonnements récurrents
- Envoyer des webhooks de confirmation
- Gérer les remboursements (extend)

#### Caractéristiques:
- Paiements sécurisés PCI DSS compliant
- Webhooks signés
- Gestion automatique des renouvellements

---

### 5.2 Google Maps API (Service de Cartographie)

**Type:** Système externe

#### Cas d'utilisation:
- Fournir les cartes interactives
- Valider la géolocalisation GPS (rayon 100m)
- Calculer les distances et itinéraires
- Geocoding / Reverse Geocoding (extend)

#### Caractéristiques:
- Markers colorés selon fraîcheur
- Clustering des sites
- Validation de proximité pour check-ins

---

### 5.3 Firebase Cloud Messaging (Notifications)

**Type:** Système externe

#### Cas d'utilisation:
- Envoyer des notifications push aux utilisateurs
- Gérer les tokens de notification
- Planifier les notifications (extend)

#### Types de notifications:
- Nouveaux badges/niveaux
- Réponses aux avis
- Nouvelles promotions
- Nouveaux sites à proximité

---

## 6. Diagramme Global

**Fichier:** `use_case_global.svg`

Ce diagramme présente une vue d'ensemble de tous les acteurs et leurs cas d'utilisation principaux, montrant les interactions entre:

### Acteurs Humains:
- 🔵 **Touriste** (visiteur)
- 🔴 **Contributeur** (actif)
- 🟣 **Professionnel**
- 🟠 **Administrateur**

### Acteurs Systèmes:
- 🟣 **Stripe** (paiement)
- 🔵 **Google Maps** (cartographie)
- 🟡 **Firebase** (notifications)

### Modules principaux:
1. **Module Consultation** (Touriste)
2. **Module Contribution** (Contributeur) avec gamification
3. **Module Professionnel** avec analytics et abonnements
4. **Module Administration** avec modération
5. **Services Externes** intégrés

---

## Hiérarchie des Acteurs

```
Acteurs Humains
├── Touriste
│   └── Contributeur (hérite de Touriste)
├── Professionnel
└── Administrateur

Acteurs Externes
├── Stripe (Paiement)
├── Google Maps (Cartographie)
└── Firebase (Notifications)
```

---

## Matrice des Interactions

| Acteur | Interagit avec |
|--------|----------------|
| Touriste | Application, Google Maps, Firebase |
| Contributeur | Application, Google Maps, Firebase, Système de gamification |
| Professionnel | Application, Stripe, Firebase |
| Administrateur | Tous les modules de l'application |
| Stripe | Module professionnel (abonnements) |
| Google Maps | Tous les modules nécessitant géolocalisation |
| Firebase | Tous les acteurs (notifications) |

---

## Légende des Relations UML

- **Trait plein** → Association directe
- **Trait pointillé** → Association conditionnelle ou système externe
- **«include»** → Relation d'inclusion (toujours exécuté)
- **«extend»** → Relation d'extension (optionnel)
- **Ellipse remplie** → Cas d'utilisation principal
- **Ellipse en pointillé** → Cas d'utilisation secondaire/optionnel

---

## Priorisation des Cas d'Utilisation

### Priorité HAUTE (MVP - Must Have):
- CU01, CU02, CU05, CU08, CU10, CU11, CU18

### Priorité MOYENNE (Should Have):
- CU03, CU04, CU06, CU07, CU09, CU12, CU14, CU19, CU20, CU21

### Priorité BASSE (Nice to Have):
- CU13, CU15, CU16, CU22, CU23, CU24, CU25

---

## Statistiques du Projet

- **Total d'acteurs:** 7 (4 humains + 3 systèmes)
- **Total de cas d'utilisation principaux:** 25
- **Modules fonctionnels:** 8
- **Services externes intégrés:** 3 (Stripe, Google Maps, Firebase)
- **Technologies:** Flutter, Node.js, MySQL, Redis

---

## Notes Techniques

### Validation GPS
- Rayon de validation: **100 mètres**
- Calcul: Formule de Haversine
- Timeout GPS: 10 secondes maximum

### Système de Fraîcheur
- 🟢 VERT (< 24h): Information très récente
- 🟠 ORANGE (< 7 jours): Information récente
- 🔴 ROUGE (< 30 jours): À vérifier
- ⚪ GRIS (> 30 jours): Obsolète

### Objectifs de Performance
- Temps de chargement: < 2 secondes
- Temps de réponse API: < 500ms
- Capacité: 10,000 utilisateurs simultanés
- Disponibilité: 99.9% (uptime)

---

**Date de création:** 15 janvier 2026  
**Projet:** MoroccoCheck - Application Mobile Touristique  
**Version:** 1.0  
**Durée du projet:** 4 mois
