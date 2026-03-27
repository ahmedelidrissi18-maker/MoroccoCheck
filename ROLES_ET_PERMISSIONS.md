# Roles Et Permissions

Ce document sert de reference metier et technique pour les roles actifs du projet.

## Roles Actifs

- `TOURIST`
- `CONTRIBUTOR`
- `PROFESSIONAL`
- `ADMIN`

## TOURIST

### Usage

Role de base attribue a l inscription.

### Peut

- creer un compte et se connecter
- consulter les sites
- consulter les details, avis et photos
- gerer son profil
- consulter badges, stats et leaderboard
- publier un avis si autorise par le flux courant
- demander le passage en `CONTRIBUTOR` si les conditions sont remplies

### Ne Peut Pas

- effectuer de check-in si le role n est pas encore promu
- gerer des sites professionnels
- acceder a l admin web

## CONTRIBUTOR

### Usage

Utilisateur approuve pour contribuer davantage sur le terrain.

### Peut

- faire tout ce qu un `TOURIST` peut faire
- effectuer des check-ins
- contribuer davantage a la verification communautaire

### Ne Peut Pas

- gerer des sites professionnels
- acceder a l admin web

## PROFESSIONAL

### Usage

Compte destine a la gestion ou revendication de sites.

### Peut

- faire tout ce qu un compte utilisateur standard peut faire selon le code actuel
- revendiquer un site
- consulter ses sites
- soumettre ou mettre a jour des fiches de sites
- acceder a l espace professionnel

### Ne Peut Pas

- acceder a l admin web
- modifier les statuts utilisateurs

## ADMIN

### Usage

Compte de pilotage, moderation et administration.

### Peut

- acceder a l admin web
- voir les stats globales
- moderer les sites
- moderer les avis
- consulter les utilisateurs
- mettre a jour le statut des utilisateurs
- traiter les demandes contributor

## Regle TOURIST -> CONTRIBUTOR

Les conditions metier actuelles sont:

1. compte `ACTIVE`
2. email verifie
3. profil minimum complete
4. demande explicite de l utilisateur
5. validation par `ADMIN`

## Profil Minimum Pour Demande Contributor

Le profil minimum controle actuellement:

- `phone_number`
- `nationality`
- `bio`

## Source Technique Principale

- [constants.js](/C:/Users/User/App_Touriste/back-end/src/config/constants.js)
- [contributor-request.service.js](/C:/Users/User/App_Touriste/back-end/src/services/contributor-request.service.js)
- [admin.routes.js](/C:/Users/User/App_Touriste/back-end/src/routes/admin.routes.js)
- [users.routes.js](/C:/Users/User/App_Touriste/back-end/src/routes/users.routes.js)

