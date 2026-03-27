# Environnements De Deploiement

Ce document formalise les environnements `development`, `staging` et `production`
pour les trois applications MoroccoCheck.

## Vue D Ensemble

| Surface | Development | Staging | Production |
|---|---|---|---|
| Backend | `.env` local | secrets separes + DB de preproduction | secrets separes + DB production |
| Flutter | `flutter run --flavor staging` avec `--dart-define` locaux | `flutter build apk --flavor staging` | `flutter build apk --flavor production` |
| Admin web | `npm run dev` | `VITE_APP_ENV=staging npm run build` | `VITE_APP_ENV=production npm run build` |

## Backend

Fichier modele:

- [back-end/.env.example](/C:/Users/User/App_Touriste/back-end/.env.example)

Variables critiques:

- `NODE_ENV`
- `DB_*`
- `JWT_SECRET`
- `CORS_ALLOWED_ORIGINS`
- `RATE_LIMIT_STORE`
- `RATE_LIMIT_REDIS_URL`
- `SENTRY_DSN`
- `SENTRY_ENVIRONMENT`

Commandes:

```bash
cd back-end
npm install
npm run migrate
npm run dev
```

## Flutter Mobile

Fichier modele:

- [front-end/.env.example](/C:/Users/User/App_Touriste/front-end/.env.example)

Le front Flutter consomme ces valeurs via `--dart-define`.

Exemple staging:

```bash
cd front-end
flutter build apk \
  --flavor staging \
  --dart-define=APP_ENV=staging \
  --dart-define=API_BASE_URL=https://api-staging.example.com/api \
  --dart-define=SENTRY_DSN=your-mobile-sentry-dsn
```

Exemple production:

```bash
cd front-end
flutter build apk \
  --flavor production \
  --dart-define=APP_ENV=production \
  --dart-define=API_BASE_URL=https://api.example.com/api \
  --dart-define=SENTRY_DSN=your-mobile-sentry-dsn
```

## Admin Web

Fichier modele:

- [admin-web/.env.example](/C:/Users/User/App_Touriste/admin-web/.env.example)

Exemple staging:

```bash
cd admin-web
npm install
set VITE_APP_ENV=staging
set VITE_API_BASE_URL=https://admin-api-staging.example.com/api
npm run build
```

Exemple production:

```bash
cd admin-web
set VITE_APP_ENV=production
set VITE_API_BASE_URL=https://admin-api.example.com/api
npm run build
```

## Monitoring

Les trois surfaces supportent maintenant un DSN Sentry optionnel:

- backend: `SENTRY_DSN`
- admin web: `VITE_SENTRY_DSN`
- mobile Flutter: `SENTRY_DSN` via `--dart-define`

Si aucun DSN n est fourni, l application continue de fonctionner sans
monitoring externe.

## Migrations

Les migrations SQL incrementales du backend vivent dans:

- [back-end/sql/migrations/README.md](/C:/Users/User/App_Touriste/back-end/sql/migrations/README.md)

Commandes:

```bash
cd back-end
npm run migrate
npm run migrate:status
```
