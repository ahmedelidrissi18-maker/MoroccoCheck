# Board Sprint 2

Ce document organise le Sprint 2 en board de travail directement exploitable.

## Theme Du Sprint

Securite et robustesse backend.

## Objectif

Mettre en place le socle minimum de securite et de fiabilite pour preparer le projet a un environnement `staging`, sans chercher encore a finaliser toute l infrastructure production.

## Resultat Attendu En Fin De Sprint

- CORS n est plus ouvert sans restriction
- un rate limiting minimum protege les routes sensibles
- la gestion des secrets et variables d environnement est clarifiee
- les erreurs API critiques sont plus coherentes
- les uploads critiques sont mieux controles
- le backend est plus solide pour la suite des tests et de la livraison

## Colonnes Du Board

### Todo

Tickets non demarres.

### In Progress

Tickets en cours de traitement.

### Review

Tickets implementes et en attente de verification fonctionnelle ou technique.

### Done

Tickets termines et verifies.

## Tickets Sprint 2

## Todo

- aucun ticket pour le moment

## In Progress

- aucun ticket pour le moment

## Review

- aucun ticket pour le moment

## Done

### S2-BE-01

- priorite: `P1`
- lot: `Security`
- titre: Restreindre CORS par environnement
- objectif: remplacer la configuration permissive actuelle par une whitelist dev / staging / prod
- statut: termine et verifie localement

### S2-BE-03

- priorite: `P1`
- lot: `Security`
- titre: Clarifier la gestion des secrets et variables d environnement
- objectif: rendre explicites les variables critiques et leur usage
- statut: termine et documente

### S2-BE-02

- priorite: `P1`
- lot: `Security`
- titre: Ajouter un rate limiting sur les routes sensibles
- objectif: proteger les endpoints critiques contre l abus de requetes
- statut: termine et verifie localement

### S2-BE-04

- priorite: `P1`
- lot: `Auth`
- titre: Verifier et durcir la gestion JWT / refresh token
- objectif: consolider le cycle de session pour preparer la production
- statut: termine et verifie par tests et smoke tests runtime

### S2-BE-05

- priorite: `P2`
- lot: `Validation`
- titre: Uniformiser les erreurs API sur les routes critiques
- objectif: renvoyer des erreurs stables et exploitables pour mobile et admin
- statut: termine et verifie sur auth et admin

### S2-BE-06

- priorite: `P2`
- lot: `Upload`
- titre: Durcir les uploads backend
- objectif: mieux controler taille, type et stockage des fichiers
- statut: termine et verifie sur routes check-ins et reviews

### S2-BE-07

- priorite: `P2`
- lot: `Observability`
- titre: Ameliorer les logs backend pour l exploitation
- objectif: rendre les erreurs et actions critiques plus lisibles
- statut: termine et verifie avec logs structures et request IDs

### S2-QA-01

- priorite: `P1`
- lot: `QA`
- titre: Definir les cas de validation Sprint 2
- objectif: preparer la verification des changements de securite
- statut: termine et documente

## Ordre D Execution Recommande

### Lot 1 - Fondations

- `S2-BE-03`
- `S2-BE-01`
- `S2-BE-04`

### Lot 2 - Protection Active

- `S2-BE-02`
- `S2-BE-06`
- `S2-BE-05`

### Lot 3 - Stabilisation

- `S2-BE-07`
- `S2-QA-01`

## Repartition Conseillee

### Backend

- `S2-BE-01`
- `S2-BE-02`
- `S2-BE-03`
- `S2-BE-04`
- `S2-BE-05`
- `S2-BE-06`
- `S2-BE-07`

### QA

- `S2-QA-01`
- verification des tickets passes en `Review`

### Mobile Et Admin

- relire les impacts de format d erreur
- verifier que les changements backend ne cassent pas les flows existants

## Definition De Fin De Sprint

Le Sprint 2 est considere termine si:

- les tickets `P1` sont termines
- les tests manuels critiques de securite sont executes
- les regressions majeures sur mobile et admin sont absentes
- la documentation d environnement et de securite minimale est a jour

## Prochaine Action Recommandee

Demarrer par `S2-BE-03` puis `S2-BE-01`.

Cela permet de poser le cadre de configuration avant d introduire les restrictions de securite dans le code.
