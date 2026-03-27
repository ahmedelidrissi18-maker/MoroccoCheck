# Flux Critiques V1

Ce document liste les parcours a considerer comme prioritaires pour les tests, la recette et la stabilisation.

## Flux 1 - Inscription Et Connexion

- inscription d un nouveau compte
- connexion
- refresh token
- logout
- recuperation du profil

## Flux 2 - Consultation D Un Site

- affichage de la liste
- filtrage ou pagination si disponible
- ouverture d un detail de site
- affichage des avis
- affichage des photos

## Flux 3 - Check-In GPS

- utilisateur autorise
- position valide
- creation du check-in
- verification des erreurs de distance ou de permission

## Flux 4 - Avis

- creation d un avis
- mise a jour d un avis
- suppression d un avis
- reponse proprietaire si applicable

## Flux 5 - Profil Et Gamification

- affichage du profil
- affichage des stats
- affichage des badges
- affichage du leaderboard

## Flux 6 - Passage TOURIST -> CONTRIBUTOR

- verification des pre-requis
- affichage de l eligibilite
- envoi d une demande
- affichage de la demande cote admin
- approbation ou rejet
- changement de role apres approbation

## Flux 7 - Professionnel

- acces a l espace professionnel
- affichage des sites possedes
- revendication d un site
- soumission d un nouveau site

## Flux 8 - Administration

- connexion admin
- chargement du dashboard
- moderation d un site
- moderation d un avis
- consultation utilisateur
- mise a jour de statut utilisateur
- traitement d une demande contributor

## Priorite De Test

### P1

- connexion
- detail site
- check-in
- avis
- demande contributor
- moderation admin

### P2

- badges
- leaderboard
- parcours professionnel

### P3

- parcours secondaires ou cosmetiques

## Definition D Un Flux Valide

Un flux est considere valide si:

- il demarre depuis l interface attendue
- il atteint le backend sans erreur bloquante
- il respecte les permissions
- il renvoie un resultat visible et coherent

