# Plan De Livraison Et Publication

Ce document propose une feuille de route concrete pour rendre MoroccoCheck pret a livrer, puis a publier.

Le projet couvre actuellement trois briques:

- `back-end`: API Node.js / Express + MySQL
- `front-end`: application Flutter
- `admin-web`: interface admin React/Vite

L objectif de ce plan est de transformer l etat actuel en version stable, testee, securisee, documentee et deployable.

## Hypotheses

- duree d un sprint: 1 a 2 semaines
- equipe cible: 1 a 3 developpeurs
- priorite: livrer une V1 fiable avant d ajouter de nouvelles features
- environnement cible: `dev`, `staging`, `prod`

## Definition De Pret A Livrer

Le projet est considere pret a livrer quand:

- les 3 applications demarrent et buildent sans erreur
- les flux critiques sont testes
- les roles et permissions sont valides
- la base de donnees est versionnee et migrable
- les configurations `dev/staging/prod` sont claires
- la securite minimum production est en place
- le deploiement backend/admin-web est documente
- l application mobile est prete pour build de release
- la documentation fonctionnelle et technique est a jour

## Sprint 1 - Stabilisation Technique

### Objectif

Mettre le projet dans un etat stable, coherent et comprehensible avant la phase de securisation et de livraison.

### Taches

- creer un `README` racine du projet avec architecture globale, prerequis et mode de lancement
- corriger et aligner [back-end/README.md](/C:/Users/User/App_Touriste/back-end/README.md), [front-end/README.md](/C:/Users/User/App_Touriste/front-end/README.md) et [admin-web/README.md](/C:/Users/User/App_Touriste/admin-web/README.md) avec l etat reel du code
- definir officiellement le scope V1
- documenter les roles metier finaux: `TOURIST`, `CONTRIBUTOR`, `PROFESSIONAL`, `ADMIN`
- lister les flux critiques a proteger avant publication:
  - inscription / connexion
  - profil
  - check-in
  - avis
  - moderation admin
  - demande `TOURIST -> CONTRIBUTOR`
- supprimer ou archiver les documents devenus obsoletes ou contradictoires
- verifier les scripts de lancement locaux et clarifier leur usage
- nettoyer les references de dev qui peuvent perturber une release

### Livrables

- documentation projet coherente
- scope V1 valide
- liste des flux critiques et des priorites de recette

### Critere De Fin De Sprint

- un nouveau membre peut comprendre la structure du projet et lancer les trois applications sans ambiguite

## Sprint 2 - Securite Et Robustesse Backend

### Objectif

Mettre en place le socle minimum de securite et de fiabilite pour exposer l API a un environnement reel.

### Taches

- restreindre CORS par environnement dans [back-end/server.js](/C:/Users/User/App_Touriste/back-end/server.js)
- ajouter un vrai middleware de rate limiting sur:
  - login
  - refresh token
  - endpoints sensibles admin
- verifier la gestion des tokens JWT et du refresh token
- definir une politique d expiration et de deconnexion propre
- verifier les validations Joi sur tous les endpoints critiques
- uniformiser les codes d erreur API et les messages de retour
- revoir la securite des uploads:
  - taille
  - type MIME
  - nommage
  - stockage
- ajouter des logs serveur plus exploitables pour la production
- definir un plan de gestion des secrets:
  - `JWT_SECRET`
  - DB credentials
  - variables par environnement

### Livrables

- backend durci pour `staging/prod`
- politique de securite technique minimum documentee

### Critere De Fin De Sprint

- l API ne repose plus sur une configuration permissive de developpement

## Sprint 3 - Base De Donnees, Migrations Et Tests Backend

### Objectif

Rendre la base et les tests reproductibles, afin d avoir une release fiable et repetable.

### Taches

- definir une vraie strategie de migration SQL
- separer clairement:
  - schema
  - seed de demo
  - seed de test
- ajouter une procedure simple pour reconstruire une base locale et une base staging
- completer les tests backend sur les flux critiques
- ajouter des tests sur le parcours `TOURIST -> CONTRIBUTOR`
- verifier les tests admin
- faire en sorte que `npm test` soit executable de facon stable avec une base de test preparee
- documenter le setup de test dans un guide unique
- verifier les contraintes SQL et coherences entre schema et code

### Livrables

- base versionnable et recreable
- suite backend fiable sur les cas critiques

### Critere De Fin De Sprint

- un environnement neuf peut reconstruire la base et lancer les tests sans bricolage manuel important

## Sprint 4 - Qualite Frontend Et Admin Web

### Objectif

Fiabiliser les interfaces utilisateurs et l interface admin avant recette finale.

### Taches

- passer une revue UX des ecrans Flutter:
  - login
  - inscription
  - liste des sites
  - detail site
  - check-in
  - avis
  - profil
  - demande contributeur
- verifier les etats d erreur, chargement et vide
- ajouter tests Flutter minimum:
  - auth provider
  - appels API critiques
  - ecrans/flows essentiels
- verifier la strategie des URLs backend dans [app_constants.dart](/C:/Users/User/App_Touriste/front-end/lib/core/constants/app_constants.dart)
- preparer un mode `dev/staging/prod` pour Flutter
- verifier completement l admin web:
  - login
  - stats
  - moderation sites
  - moderation avis
  - gestion utilisateurs
  - demandes contributor
- ajouter tests React minimum sur les composants critiques du dashboard
- gerer proprement les cas `401/403/500` dans l admin web
- verifier le responsive des interfaces admin

### Livrables

- interfaces plus robustes et coherentes
- qualite percue plus proche d un produit livrable

### Critere De Fin De Sprint

- les principaux flux utilisateur et admin passent sans blocage visible ni erreur non geree

## Sprint 5 - CI/CD Et Environnements

### Objectif

Automatiser la verification qualite et preparer le chemin de deploiement.

### Taches

- creer une pipeline CI pour:
  - backend: install, test
  - admin-web: install, build
  - front-end: `flutter analyze`, `flutter test`
- ajouter une verification automatique a chaque push / pull request
- preparer l environnement `staging`
- documenter les variables d environnement par application
- definir la strategie de build:
  - backend
  - admin-web
  - APK/IPA ou builds Flutter de pre-release
- preparer les scripts de deploiement backend/admin-web
- definir la gestion des logs et des artefacts de build
- documenter rollback et redemarrage

### Livrables

- pipeline d integration continue
- environnement de staging exploitable

### Critere De Fin De Sprint

- chaque modification importante est verifiee automatiquement avant livraison

## Sprint 6 - Recette Metier, Monitoring Et Go-Live

### Objectif

Finaliser la release, valider le comportement metier et preparer la mise en production.

### Taches

- preparer une checklist de recette fonctionnelle par role:
  - TOURIST
  - CONTRIBUTOR
  - PROFESSIONAL
  - ADMIN
- executer une recette complete sur `staging`
- corriger les bugs restants issus de la recette
- preparer le monitoring minimum:
  - health checks
  - logs d erreurs
  - disponibilite API
  - erreurs front/admin
- preparer sauvegarde et restauration de la base
- verifier HTTPS, domaine, CORS, variables prod
- preparer les contenus de publication mobile:
  - nom app
  - description
  - captures
  - privacy policy
  - support
- preparer les elements web/admin de production:
  - build final
  - regles SPA rewrite
  - acces admin securise
- faire un go/no-go final

### Livrables

- release candidate
- checklist go-live signee
- dossier de mise en production

### Critere De Fin De Sprint

- le projet peut etre deploye en production avec un risque maitrise

## Backlog Transverse

Ces sujets peuvent avancer en parallele selon la taille de l equipe:

- observabilite plus avancee
- audit trail admin
- analytics produit
- optimisation performance API
- optimisation performance Flutter/web
- internationalisation plus complete
- nettoyage des anciens documents projet

## Priorites Absolues Avant Publication

Si le temps est court, il faut absolument terminer ceci:

1. documentation propre et scope V1
2. securisation backend minimale
3. tests backend critiques
4. verification Flutter/admin web sur les flux critiques
5. CI/CD minimum
6. staging + recette metier
7. deploiement documente

## Repartition Possible Des Taches

### Profil Backend

- securite API
- migrations SQL
- tests backend
- deploiement serveur

### Profil Frontend Mobile

- qualite Flutter
- gestion des environnements
- recette UX mobile
- build release Android/iOS

### Profil Frontend Web/Admin

- dashboard admin
- gestion des erreurs et sessions
- responsive
- build et livraison web

### Profil Tech Lead / Chef De Projet

- cadrage V1
- priorisation sprint
- suivi recette
- validation go/no-go

## Proposition De Calendrier

Si vous travaillez rapidement, une trajectoire realiste est:

- Sprint 1: stabilisation et documentation
- Sprint 2: securite backend
- Sprint 3: base de donnees et tests backend
- Sprint 4: qualite Flutter et admin web
- Sprint 5: CI/CD et staging
- Sprint 6: recette finale et go-live

Soit environ 6 a 10 semaines selon la taille de l equipe et le nombre de corrections de recette.

## Prochaine Etape Recommandee

Commencer par Sprint 1 et ouvrir ensuite un board de suivi avec:

- `Todo`
- `In Progress`
- `Review`
- `Done`

Chaque tache ci-dessus peut etre transformee en ticket.
