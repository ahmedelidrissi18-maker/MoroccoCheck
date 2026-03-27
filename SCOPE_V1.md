# Scope V1

Ce document definit le perimetre fonctionnel vise pour une premiere livraison stable de MoroccoCheck.

## Objectif V1

Livrer une version exploitable du produit permettant:

- la consultation de sites touristiques
- la contribution communautaire controlee
- la moderation centrale via un espace admin
- une base technique suffisamment stable pour une mise en staging

## Inclus Dans V1

### Authentification

- inscription
- connexion
- refresh token
- logout
- recuperation du profil
- mise a jour du profil

### Cote Utilisateur

- consultation de la liste des sites
- consultation du detail d un site
- consultation des avis et photos d un site
- creation de check-ins
- creation et mise a jour d avis
- consultation des badges, stats et leaderboard

### Roles

- `TOURIST`
- `CONTRIBUTOR`
- `PROFESSIONAL`
- `ADMIN`

### Evolution TOURIST -> CONTRIBUTOR

- compte `ACTIVE`
- email verifie
- profil minimum complete
- demande explicite
- validation par `ADMIN`

### Cote Professionnel

- consultation des sites rattaches
- consultation du detail d un site possede
- revendication d un site
- creation d une fiche de site

### Cote Admin

- dashboard de pilotage
- moderation des sites
- moderation des avis
- consultation des utilisateurs
- mise a jour de statut utilisateur
- traitement des demandes contributor

## Hors Scope V1

- analytics avances
- categories admin complets
- badges admin complets
- notifications push
- publication stores mobile finalisee
- observabilite avancee
- audit trail admin complet
- infrastructure multi-region
- automatisation de moderation par IA

## Critere D Entree En V1

Une fonctionnalite fait partie de la V1 si:

- le backend est disponible
- le frontend ou l admin ont un ecran exploitable
- le flux principal peut etre execute jusqu au bout
- les permissions sont claires

## Critere De Sortie De V1

La V1 est consideree prete si:

- les builds backend, Flutter et admin web passent
- les flux critiques sont valides
- les roles sont appliques correctement
- la documentation de lancement et de recette est a jour

