# QA Validation Sprint 2 Backend

Ce document liste les cas de validation a executer pour cloturer le Sprint 2.

Le Sprint 2 couvre:

- configuration d environnement
- CORS par whitelist
- rate limiting
- durcissement auth / refresh token
- uniformisation des erreurs API
- durcissement uploads
- logs backend structures

## Objectif

Verifier que les mecanismes de securite backend introduits pendant le Sprint 2 fonctionnent reellement sans casser les flux principaux.

## Preconditions

- backend demarre
- base de donnees disponible
- admin web ou client API disponible pour certains tests
- un compte `ADMIN` valide disponible
- au moins un compte utilisateur standard disponible

Comptes utiles:

- `admin@moroccocheck.com` / `password123`
- `contributor@test.com` / `password123`
- `pro@test.com` / `password123`

## Regle D Execution

Pour chaque cas:

- marquer `OK` si le comportement est conforme
- marquer `KO` si le comportement est incorrect
- capturer le code HTTP, le code metier et le message retour si echec

## Bloc 1 - Configuration Et Environnement

### QA-S2-01

- verifier que le backend demarre avec les variables de `.env`
- resultat attendu:
  - demarrage sans erreur fatale
  - logs de demarrage lisibles

### QA-S2-02

- verifier que les variables suivantes sont reconnues:
  - `CORS_ALLOWED_ORIGINS`
  - `CORS_ALLOW_NO_ORIGIN`
  - `RATE_LIMIT_ENABLED`
  - `RATE_LIMIT_WINDOW_MS`
  - `RATE_LIMIT_LOGIN_MAX`
  - `RATE_LIMIT_ADMIN_MAX`
  - `REFRESH_TOKEN_TTL_DAYS`
- resultat attendu:
  - la configuration runtime reflète bien ces valeurs

## Bloc 2 - CORS

### QA-S2-03

- appeler `GET /api/health` avec une origine autorisee locale
- resultat attendu:
  - statut `200`
  - header `Access-Control-Allow-Origin` present et coherent

### QA-S2-04

- appeler `GET /api/health` avec une origine non autorisee
- resultat attendu:
  - statut `403`
  - code `CORS_ORIGIN_NOT_ALLOWED`
  - message clair

### QA-S2-05

- appeler une route backend sans header `Origin` via Postman ou script
- resultat attendu:
  - requete acceptee si `CORS_ALLOW_NO_ORIGIN=true`

## Bloc 3 - Rate Limiting

### QA-S2-06

- effectuer plusieurs tentatives de login invalides successives
- resultat attendu:
  - les premieres tentatives echouent en `401 INVALID_CREDENTIALS`
  - au dela du seuil, reponse `429 RATE_LIMIT_LOGIN`
  - header `Retry-After` present

### QA-S2-07

- effectuer plusieurs appels `POST /api/auth/refresh`
- resultat attendu:
  - reponse `429 RATE_LIMIT_REFRESH` au dela du seuil si le test est pousse assez loin

### QA-S2-08

- effectuer plusieurs appels admin sur `/api/admin/*`
- resultat attendu:
  - reponse `429 RATE_LIMIT_ADMIN` au dela du seuil

## Bloc 4 - Auth, Sessions Et Refresh Token

### QA-S2-09

- se connecter avec un compte valide
- resultat attendu:
  - `200`
  - `token` present
  - `refresh_token` present

### QA-S2-10

- utiliser `POST /api/auth/refresh` avec un refresh token valide
- resultat attendu:
  - `200`
  - nouveau `token`
  - nouveau `refresh_token`

### QA-S2-11

- reutiliser l ancien access token apres refresh
- resultat attendu:
  - `401`
  - code `SESSION_INACTIVE`

### QA-S2-12

- utiliser le nouveau token apres refresh
- resultat attendu:
  - acces autorise sur une route protegee

### QA-S2-13

- appeler `POST /api/auth/logout`
- resultat attendu:
  - `200`
  - `logged_out=true`

### QA-S2-14

- reutiliser le token apres logout
- resultat attendu:
  - `401`
  - code `SESSION_INACTIVE`

### QA-S2-15

- tester un token absent
- resultat attendu:
  - `401 TOKEN_MISSING`

### QA-S2-16

- tester un token invalide
- resultat attendu:
  - `401 TOKEN_INVALID`

## Bloc 5 - Format D Erreur API

### QA-S2-17

- envoyer un payload auth invalide sur `POST /api/auth/register`
- resultat attendu:
  - `400`
  - code `VALIDATION_ERROR`
  - `errors` present
  - `details.validation` present

### QA-S2-18

- envoyer un payload admin invalide sur `PATCH /api/admin/users/:id/status`
- resultat attendu:
  - meme format d erreur que ci-dessus

### QA-S2-19

- verifier qu une erreur metier conserve son code specifique
- exemple:
  - `INVALID_CREDENTIALS`
  - `SESSION_INACTIVE`
  - `FORBIDDEN`
- resultat attendu:
  - le code metier n est pas ecrase par `VALIDATION_ERROR`

## Bloc 6 - Uploads

### QA-S2-20

- envoyer une image valide JPG, PNG ou WEBP
- resultat attendu:
  - upload accepte si le reste du payload est valide

### QA-S2-21

- envoyer une image avec extension non autorisee
- resultat attendu:
  - `400`
  - code `UNSUPPORTED_IMAGE_EXTENSION`

### QA-S2-22

- envoyer un fichier avec MIME type non autorise
- resultat attendu:
  - `400`
  - code `UNSUPPORTED_IMAGE_TYPE`

### QA-S2-23

- envoyer un fichier depassant la taille max
- resultat attendu:
  - `400`
  - message clair lie a la taille max

### QA-S2-24

- verifier qu un echec d upload ne laisse pas de fichiers residuels inutiles
- resultat attendu:
  - pas de fichier orphelin attendu apres echec

## Bloc 7 - Logs Et Observabilite

### QA-S2-25

- executer une requete backend normale
- resultat attendu:
  - header `X-Request-Id` present

### QA-S2-26

- verifier les logs HTTP
- resultat attendu:
  - log JSON `http_request`
  - methode, path, status, request_id visibles

### QA-S2-27

- verifier les logs auth
- resultat attendu:
  - `auth_login_success`
  - `auth_refresh_success`
  - `auth_logout_success`

### QA-S2-28

- verifier les logs admin
- resultat attendu:
  - logs d audit sur moderation ou mise a jour de statut

### QA-S2-29

- provoquer une erreur backend connue
- resultat attendu:
  - log `request_failed`
  - `request_id` present
  - `status_code` visible

## Criteres De Validation Finale Sprint 2

Le Sprint 2 peut etre considere comme valide si:

- tous les cas `P1` du sprint passent
- les mecanismes CORS, rate limiting et auth sont verifies
- le format d erreur est coherent
- les uploads rejetent proprement les fichiers non conformes
- les logs backend sont exploitables

## Synthese A Produire Apres Execution

Le rapport de validation doit contenir:

- nombre de cas executes
- nombre de cas `OK`
- nombre de cas `KO`
- liste des anomalies
- severite de chaque anomalie
- decision finale:
  - `GO`
  - `GO WITH FIXES`
  - `NO GO`

