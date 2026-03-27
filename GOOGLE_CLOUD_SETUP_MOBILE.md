# Configuration Google Cloud Mobile

Ce document prepare la configuration Google Cloud exacte necessaire pour activer Google Sign-In dans l application Flutter `front-end/`.

## Contexte Actuel Du Projet

Identifiants actuellement declares dans le code:

- Android package name: `com.example.mor_che_frontend`
- Android namespace: `com.example.mor_che_frontend`
- iOS bundle identifier: `com.example.morCheFrontend`

Fichiers sources:

- `front-end/android/app/build.gradle.kts`
- `front-end/ios/Runner.xcodeproj/project.pbxproj`

Important:

- ces identifiants sont encore des IDs de travail `com.example.*`
- avant publication, il faudra figer les vrais IDs definitifs puis recreer les clients OAuth correspondants

## Empreintes Android Actuelles

Empreintes trouvees sur cette machine a partir du debug keystore local `~/.android/debug.keystore`:

- SHA1: `84:41:5C:09:38:05:B8:45:FA:66:C5:66:CB:C7:99:5E:58:D8:1A:A1`
- SHA256: `D0:D0:B8:1D:C8:0E:A6:B3:86:6C:CF:89:A6:67:11:41:AD:1C:C6:41:37:1C:4B:A1:76:FC:0B:B0:82:1F:3E:44`

Commande utilisee sur cette machine:

```powershell
& 'C:\Program Files\Android\Android Studio\jbr\bin\keytool.exe' `
  -list -v `
  -alias androiddebugkey `
  -keystore "$env:USERPROFILE\.android\debug.keystore" `
  -storepass android `
  -keypass android
```

## Ce Qu Il Faut Creer Dans Google Cloud

Dans `Google Cloud Console -> APIs & Services -> OAuth consent screen`:

1. creer ou selectionner le projet `MoroccoCheck`
2. configurer l ecran de consentement OAuth
3. ajouter les test users si l application reste en mode test

Dans `Google Cloud Console -> APIs & Services -> Credentials`, creer 3 clients OAuth:

1. un client `Web application`
   - nom recommande: `MoroccoCheck Backend`
   - ce client sert de `serverClientId`
   - son client ID sera reutilise dans le backend et dans Flutter

2. un client `Android`
   - nom recommande: `MoroccoCheck Android Debug`
   - package name: `com.example.mor_che_frontend`
   - SHA1: `84:41:5C:09:38:05:B8:45:FA:66:C5:66:CB:C7:99:5E:58:D8:1A:A1`

3. un client `iOS`
   - nom recommande: `MoroccoCheck iOS`
   - bundle ID: `com.example.morCheFrontend`
   - App Store ID: laisser vide tant que l application n est pas publiee
   - Team ID: ajouter plus tard si vous activez les protections iOS avancees

## Valeurs A Recuperer Apres Creation

Une fois les 3 clients crees, recuperer:

- `WEB_CLIENT_ID`
- `ANDROID_CLIENT_ID`
- `IOS_CLIENT_ID`
- `IOS_REVERSED_CLIENT_ID`

Correspondances:

- `WEB_CLIENT_ID`: client ID du client OAuth `Web application`
- `ANDROID_CLIENT_ID`: client ID du client OAuth Android
- `IOS_CLIENT_ID`: client ID du client OAuth iOS
- `IOS_REVERSED_CLIENT_ID`: version inversee du `IOS_CLIENT_ID`, visible dans `GoogleService-Info.plist` si vous en telechargez un exemplaire ou dans la configuration iOS associee

## Injection Dans Ce Projet

### Backend

Dans `back-end/.env`:

```env
GOOGLE_CLIENT_IDS=WEB_CLIENT_ID
```

Si plusieurs clients doivent etre acceptes explicitement par le backend plus tard:

```env
GOOGLE_CLIENT_IDS=WEB_CLIENT_ID,ANOTHER_ALLOWED_CLIENT_ID
```

### Flutter

Le code Flutter attend ces `dart-define`:

```bash
flutter run \
  --dart-define=GOOGLE_SERVER_CLIENT_ID=WEB_CLIENT_ID \
  --dart-define=GOOGLE_IOS_CLIENT_ID=IOS_CLIENT_ID
```

Pour Android:

- `GOOGLE_SERVER_CLIENT_ID` est requis

Pour iOS:

- `GOOGLE_SERVER_CLIENT_ID` est requis
- `GOOGLE_IOS_CLIENT_ID` est requis

## Etape iOS Native A Ne Pas Oublier

Le plugin officiel `google_sign_in_ios` indique que meme si `clientId` et `serverClientId` sont fournis en Dart, l etape `CFBundleURLTypes` reste obligatoire dans `ios/Runner/Info.plist`.

Section a ajouter avec vos vraies valeurs:

```xml
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleTypeRole</key>
    <string>Editor</string>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>IOS_REVERSED_CLIENT_ID</string>
    </array>
  </dict>
</array>
```

Optionnellement, vous pouvez aussi ajouter:

```xml
<key>GIDClientID</key>
<string>IOS_CLIENT_ID</string>
<key>GIDServerClientID</key>
<string>WEB_CLIENT_ID</string>
```

## Verification Recommandee

### Android

1. lancer le backend avec `GOOGLE_CLIENT_IDS=WEB_CLIENT_ID`
2. lancer Flutter avec `--dart-define=GOOGLE_SERVER_CLIENT_ID=WEB_CLIENT_ID`
3. ouvrir l ecran login
4. cliquer `Continuer avec Google`
5. verifier qu un `POST /api/auth/google` arrive bien cote backend
6. verifier que l utilisateur est cree ou lie puis redirige

### iOS

1. ajouter `CFBundleURLTypes` avec `IOS_REVERSED_CLIENT_ID`
2. lancer Flutter avec:
   - `--dart-define=GOOGLE_SERVER_CLIENT_ID=WEB_CLIENT_ID`
   - `--dart-define=GOOGLE_IOS_CLIENT_ID=IOS_CLIENT_ID`
3. retester le parcours Google

## Point Important Avant Publication

Le projet Android local est encore configure ainsi:

- `applicationId = "com.example.mor_che_frontend"`
- le build `release` utilise encore la signature `debug`

Cela veut dire:

- la configuration Google Cloud que vous faites maintenant est valable pour le dev local
- avant publication Play Store, il faudra:
  - definir le package name final
  - definir la vraie signature release
  - recalculer le SHA1/SHA256 release
  - creer ou mettre a jour le client OAuth Android release

## Checklist Courte

- creer le projet Google Cloud
- configurer l ecran de consentement OAuth
- creer le client Web
- creer le client Android avec le package `com.example.mor_che_frontend` et le SHA1 debug
- creer le client iOS avec le bundle `com.example.morCheFrontend`
- reporter `WEB_CLIENT_ID` dans `back-end/.env`
- lancer Flutter avec `GOOGLE_SERVER_CLIENT_ID`
- ajouter `CFBundleURLTypes` sur iOS avec `IOS_REVERSED_CLIENT_ID`
- tester Android puis iOS
