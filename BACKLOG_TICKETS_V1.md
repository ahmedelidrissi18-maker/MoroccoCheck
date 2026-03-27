# Backlog Tickets V1

Ce document transforme la checklist de recette V1 en backlog de tickets actionnables.

## Convention

- prefixe `BE`: Backend
- prefixe `MO`: Mobile Flutter
- prefixe `AD`: Admin Web
- prefixe `QA`: Recette / validation
- priorites:
  - `P1`: critique
  - `P2`: important
  - `P3`: utile mais non bloquant pour avancer

## Backend

### BE-01

- priorite: `P1`
- titre: Verifier le flux inscription / connexion / refresh / logout
- objectif: confirmer que le socle auth V1 fonctionne de bout en bout
- definition de done:
  - inscription fonctionnelle
  - login fonctionnel
  - refresh fonctionnel
  - logout fonctionnel
  - recuperation du profil fonctionnelle

### BE-02

- priorite: `P1`
- titre: Verifier les endpoints sites publics
- objectif: garantir que la consultation des sites est stable
- definition de done:
  - liste des sites accessible
  - detail d un site accessible
  - avis d un site accessibles
  - photos d un site accessibles

### BE-03

- priorite: `P1`
- titre: Verifier le flux check-in GPS
- objectif: valider la creation d un check-in sur un role autorise
- definition de done:
  - un `CONTRIBUTOR` peut creer un check-in valide
  - un role non autorise est bloque
  - les erreurs de distance ou de permission remontent proprement

### BE-04

- priorite: `P1`
- titre: Verifier le flux avis
- objectif: confirmer creation, mise a jour et lecture des avis
- definition de done:
  - creation avis fonctionnelle
  - mise a jour avis fonctionnelle
  - suppression avis fonctionnelle si prevue
  - reponse proprietaire fonctionnelle si applicable

### BE-05

- priorite: `P1`
- titre: Verifier le flux TOURIST vers CONTRIBUTOR
- objectif: confirmer la regle metier et les transitions de statut
- definition de done:
  - l eligibilite est lisible via API
  - un compte eligible peut envoyer une demande
  - un compte non eligible est bloque
  - un `ADMIN` peut approuver ou rejeter
  - l approbation met bien a jour le role final

### BE-06

- priorite: `P2`
- titre: Verifier les routes espace professionnel
- objectif: confirmer les permissions et le comportement principal pour `PROFESSIONAL`
- definition de done:
  - acces a `mine`
  - detail d un site possede
  - revendication de site
  - creation de site

### BE-07

- priorite: `P2`
- titre: Verifier les stats, badges et leaderboard
- objectif: stabiliser les endpoints de gamification et profil enrichi
- definition de done:
  - stats utilisateur fonctionnelles
  - badges utilisateur fonctionnels
  - leaderboard fonctionnel

### BE-08

- priorite: `P1`
- titre: Verifier les routes admin critiques
- objectif: garantir que le back admin supporte le dashboard V1
- definition de done:
  - stats admin
  - moderation sites
  - moderation avis
  - consultation utilisateurs
  - mise a jour de statut utilisateur
  - traitement des demandes contributor

## Mobile Flutter

### MO-01

- priorite: `P1`
- titre: Valider le parcours TOURIST de base
- objectif: confirmer qu un utilisateur standard peut utiliser le coeur de l application
- definition de done:
  - inscription
  - connexion
  - consultation de liste et detail site
  - profil accessible
  - deconnexion

### MO-02

- priorite: `P1`
- titre: Valider l affichage du profil et des stats
- objectif: rendre le profil V1 fiable
- definition de done:
  - affichage des stats
  - affichage badges
  - affichage activite recente
  - edition du profil fonctionnelle

### MO-03

- priorite: `P1`
- titre: Valider le flux contributor cote profil
- objectif: verifier l experience mobile du passage `TOURIST -> CONTRIBUTOR`
- definition de done:
  - affichage des pre-requis
  - blocage si profil incomplet
  - envoi de demande si eligible
  - affichage du statut de la demande

### MO-04

- priorite: `P1`
- titre: Valider le flux check-in mobile
- objectif: confirmer que le check-in est utilisable sur role autorise
- definition de done:
  - acces visible pour `CONTRIBUTOR`
  - acces bloque pour `TOURIST`
  - message de succes sur check-in valide
  - message d erreur sur cas non valides

### MO-05

- priorite: `P2`
- titre: Valider le flux avis mobile
- objectif: verifier la publication et edition d avis depuis l application
- definition de done:
  - creation avis
  - edition avis si disponible
  - retour utilisateur lisible

### MO-06

- priorite: `P2`
- titre: Valider l espace professionnel mobile
- objectif: verifier le comportement principal pour `PROFESSIONAL`
- definition de done:
  - hub professionnel accessible
  - acces aux etablissements
  - revendication ou soumission de site testee si ecran disponible

### MO-07

- priorite: `P2`
- titre: Verifier les permissions visibles par role dans le mobile
- objectif: s assurer que l UI ne propose pas des actions interdites
- definition de done:
  - `TOURIST` sans acces check-in
  - `CONTRIBUTOR` avec acces check-in
  - `PROFESSIONAL` avec acces espace professionnel
  - pas d acces admin depuis l app mobile

## Admin Web

### AD-01

- priorite: `P1`
- titre: Valider la connexion admin
- objectif: garantir l acces stable a l interface d administration
- definition de done:
  - login admin fonctionnel
  - redirection dashboard correcte
  - gestion d erreur login correcte

### AD-02

- priorite: `P1`
- titre: Valider le dashboard overview
- objectif: confirmer l affichage des stats et files critiques
- definition de done:
  - stats globales visibles
  - chargement sans erreur reseau
  - navigation vers les zones critiques fonctionnelle

### AD-03

- priorite: `P1`
- titre: Valider la moderation des sites
- objectif: verifier la file d attente sites
- definition de done:
  - liste chargee
  - detail d un site accessible
  - approbation site fonctionnelle
  - rejet ou archivage site fonctionnel

### AD-04

- priorite: `P1`
- titre: Valider la moderation des avis
- objectif: verifier la file d attente avis
- definition de done:
  - liste chargee
  - detail avis accessible
  - approbation avis fonctionnelle
  - rejet ou signalement fonctionnel

### AD-05

- priorite: `P1`
- titre: Valider la gestion utilisateurs
- objectif: confirmer le parcours admin sur les comptes
- definition de done:
  - liste utilisateurs chargee
  - detail utilisateur visible
  - changement de statut utilisateur fonctionnel

### AD-06

- priorite: `P1`
- titre: Valider le traitement des demandes contributor
- objectif: confirmer l ecran admin du flux `TOURIST -> CONTRIBUTOR`
- definition de done:
  - liste des demandes visible
  - detail utile dans la carte
  - approbation fonctionnelle
  - rejet fonctionnel

### AD-07

- priorite: `P2`
- titre: Verifier les permissions admin web
- objectif: s assurer que seul `ADMIN` accede a l interface
- definition de done:
  - un compte non admin est refuse
  - retour login ou message d erreur coherent

## QA / Recette

### QA-01

- priorite: `P1`
- titre: Preparer les comptes et donnees de recette
- objectif: disposer d un jeu de test stable pour V1
- definition de done:
  - compte `ADMIN` disponible
  - compte `CONTRIBUTOR` disponible
  - compte `PROFESSIONAL` disponible
  - scenario `TOURIST` defini

### QA-02

- priorite: `P1`
- titre: Executer la recette TOURIST
- objectif: valider tout le parcours utilisateur standard
- definition de done:
  - tous les cas TOURIST de la checklist sont executes
  - chaque cas est marque `OK` ou `KO`
  - les anomalies sont documentees

### QA-03

- priorite: `P1`
- titre: Executer la recette CONTRIBUTOR
- objectif: valider les flux terrain et contribution
- definition de done:
  - check-in teste
  - avis teste
  - permissions verifiees

### QA-04

- priorite: `P1`
- titre: Executer la recette PROFESSIONAL
- objectif: valider l espace professionnel
- definition de done:
  - hub professionnel teste
  - parcours etablissements teste
  - restrictions de role verifiees

### QA-05

- priorite: `P1`
- titre: Executer la recette ADMIN
- objectif: valider la console d administration
- definition de done:
  - dashboard teste
  - moderation sites testee
  - moderation avis testee
  - gestion utilisateurs testee
  - demandes contributor testees

### QA-06

- priorite: `P1`
- titre: Executer la verification croisee des permissions
- objectif: confirmer que chaque role voit seulement ce qui lui est autorise
- definition de done:
  - tous les cas de permission sont verifies
  - aucun acces critique indu n est observe

### QA-07

- priorite: `P2`
- titre: Verifier les prerequis techniques de recette
- objectif: confirmer que l environnement de recette est sain
- definition de done:
  - `GET /api/health` repond `200`
  - admin web charge correctement
  - logs backend relus
  - erreurs bloquantes remontees

## Ordre Recommande Pour Le Suivi

### Lot 1

- `BE-01`
- `BE-02`
- `BE-03`
- `BE-04`
- `BE-05`
- `AD-01`
- `AD-02`
- `AD-03`
- `AD-04`
- `AD-05`
- `AD-06`
- `MO-01`
- `MO-02`
- `MO-03`
- `MO-04`
- `QA-01`

### Lot 2

- `BE-06`
- `BE-07`
- `BE-08`
- `MO-05`
- `MO-06`
- `MO-07`
- `AD-07`
- `QA-02`
- `QA-03`
- `QA-04`
- `QA-05`
- `QA-06`
- `QA-07`

## Sortie Sprint 1

Le Sprint 1 peut etre clos quand:

- la documentation de reference est stabilisee
- le backlog de tickets est pret
- la checklist de recette est exploitable
- les responsables peuvent commencer les lots Sprint 2 sans ambiguite

