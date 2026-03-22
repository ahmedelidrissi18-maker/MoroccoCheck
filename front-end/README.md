# MoroccoCheck Frontend

Frontend Flutter de l'application MoroccoCheck, branché sur le backend local dans `../back-end`.

## Etat actuel

Le frontend est maintenant partiellement intégré au backend réel pour les flux principaux:

- authentification: `register`, `login`, `auto-login`, `logout`
- profil: données utilisateur, stats, badges, activité récente
- sites: liste réelle, détail réel, avis réels, photos réelles
- carte: markers basés sur les sites backend
- check-in: payload compatible backend
- review: payload texte compatible backend

Fonctionnalité encore limitée:

- upload de photo review: non activé côté backend, donc masqué côté frontend

## Prérequis

- Flutter stable
- Dart compatible avec le projet
- backend MoroccoCheck lancé localement
- base de données importée et connectée côté backend

## Important: version SDK

Le projet demande actuellement dans [pubspec.yaml](./pubspec.yaml):

```yaml
environment:
  sdk: ^3.10.8
```

Si ta machine est en `Dart 3.10.7`, alors:

- `flutter pub get` échoue
- `flutter analyze` échoue
- `dart format` peut aussi échouer

Solution recommandée:

1. mettre à jour Flutter/Dart vers une version compatible
2. relancer `flutter pub get`

## Configuration backend locale

Le frontend utilise automatiquement les URLs suivantes dans [app_constants.dart](./lib/core/constants/app_constants.dart):

- Web / desktop: `http://127.0.0.1:5001/api`
- Android emulator: `http://10.0.2.2:5001/api`

Le backend doit donc être démarré sur le port `5001`.

## Lancer le backend

Depuis le dossier racine du projet:

```bash
cd back-end
npm install
npm test
npm run dev
```

Vérifie ensuite:

- `GET http://127.0.0.1:5001/api/health`
- `GET http://127.0.0.1:5001/api/health/db`

## Lancer le frontend

```bash
cd front-end
flutter pub get
flutter run
```

Exemples:

```bash
flutter run -d chrome
flutter run -d emulator-5554
```

## Contrat API utilisé

Le frontend suppose le format backend suivant:

### Succès

```json
{
  "success": true,
  "data": {},
  "message": "..."
}
```

### Pagination

```json
{
  "success": true,
  "data": [],
  "meta": {
    "pagination": {
      "page": 1,
      "limit": 10,
      "total": 3
    }
  }
}
```

### Erreur

```json
{
  "success": false,
  "message": "..."
}
```

## Endpoints déjà branchés

- `POST /api/auth/register`
- `POST /api/auth/login`
- `GET /api/auth/profile`
- `POST /api/auth/logout`
- `GET /api/sites`
- `GET /api/sites/:id`
- `GET /api/sites/:id/reviews`
- `GET /api/sites/:id/photos`
- `POST /api/checkins`
- `POST /api/reviews`
- `GET /api/users/me/stats`
- `GET /api/users/me/badges`

## Fichiers clés

- [lib/core/network/api_service.dart](./lib/core/network/api_service.dart)
- [lib/core/constants/app_constants.dart](./lib/core/constants/app_constants.dart)
- [lib/features/auth/data/auth_remote_datasource.dart](./lib/features/auth/data/auth_remote_datasource.dart)
- [lib/features/sites/presentation/sites_provider.dart](./lib/features/sites/presentation/sites_provider.dart)
- [lib/features/sites/presentation/site_detail_screen.dart](./lib/features/sites/presentation/site_detail_screen.dart)
- [lib/features/map/presentation/map_screen.dart](./lib/features/map/presentation/map_screen.dart)
- [lib/features/profile/presentation/profile_screen.dart](./lib/features/profile/presentation/profile_screen.dart)

## Limitations connues

- l'environnement Flutter local peut être bloqué par la version SDK
- l'upload de photo pour les avis n'est pas encore disponible côté backend
- il reste des améliorations de qualité à faire:
  - analyse statique
  - tests Flutter
  - documentation écran par écran

## Vérifications recommandées

Après mise à jour du SDK Flutter/Dart:

```bash
flutter pub get
flutter analyze
flutter test
```

Puis vérifier manuellement:

1. inscription
2. connexion
3. ouverture de la liste des sites
4. ouverture du détail d'un site
5. ajout d'un check-in
6. ajout d'un avis texte
7. consultation du profil, badges et stats

## Suite logique

Les prochaines étapes recommandées sont:

1. rétablir un environnement Flutter compatible pour relancer `analyze` et `test`
2. ajouter une vraie gestion du refresh token
3. brancher l'upload photo review quand le backend exposera la route
4. compléter la documentation fonctionnelle et les tests widget
