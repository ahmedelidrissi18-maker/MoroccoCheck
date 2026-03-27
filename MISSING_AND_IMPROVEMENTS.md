# MISSING_AND_IMPROVEMENTS

Audit complet du repository `App_Touriste`.

Applications detectees:
- Mobile app: Flutter (`front-end/pubspec.yaml`)
- Admin web dashboard: React 18 + Vite (`admin-web/package.json`)
- Backend API: Node.js / Express / MySQL (`back-end/package.json`, `back-end/server.js`)

Verification rapide executee pendant l'audit:
- `flutter analyze` dans `front-end`: OK
- `npm run build` dans `admin-web`: OK
- `npm test` dans `back-end`: 11 tests en echec, principalement sur des routes authentifiees / admin qui retournent `401`

---

## SECTION 1 - MISSING FEATURES (Mobile App)

Total issues found: **8**

| # | Missing Feature | File/Component | Priority (High/Med/Low) | Notes |
|---|----------------|---------------|------------------------|-------|
| 1 | Real password reset / forgot-password flow | `front-end/lib/features/auth/presentation/forgot_password_screen.dart:43-95` | High | Ecran placeholder uniquement. Le texte dit explicitement que la fonction n'est pas disponible et qu'aucun email n'est envoye. Test associe: `front-end/test/features/auth/forgot_password_screen_test.dart:6-19`. Effort: ~0.5-1 day si l'API existe, sinon ~1-2 days avec backend. |
| 2 | Push notifications / reminders reelles | `front-end/lib/features/settings/presentation/settings_screen.dart:71-83`, `front-end/lib/core/storage/storage_service.dart:309-314`, `front-end/pubspec.yaml:40-44` | High | Le toggle "Notifications" ne fait qu'enregistrer un bool en local. Aucun package de notifications/push (`firebase_messaging`, `flutter_local_notifications`, etc.) n'est present. Effort: ~2-4 days. |
| 3 | Real localization / i18n system | `front-end/lib/features/settings/presentation/settings_screen.dart:58-68`, `front-end/lib/core/storage/storage_service.dart:301-306` | Medium | La langue est memorisee, mais le message confirme que la traduction complete arrivera plus tard. Pas de `flutter_localizations`, pas d'ARB, pas de delegates. Effort: ~2-5 days selon nombre d'ecrans. |
| 4 | Deep linking / app links / universal links | `front-end/pubspec.yaml`, `front-end/lib/core/router/app_router.dart` | Medium | `go_router` est present, mais aucun package ou config de deep linking (`app_links`, `uni_links`) n'est detecte. Manque classique pour une app production. Effort: ~1-2 days. |
| 5 | Biometric re-authentication | `front-end/pubspec.yaml:40-44`, `front-end/lib/features/auth`, `front-end/lib/core/storage/storage_service.dart` | Low | Les tokens sont stockes proprement, mais aucune re-auth locale (`local_auth`) n'est presente pour proteger l'acces au compte ou aux actions sensibles. Effort: ~1 day. |
| 6 | Offline write support beyond check-ins | `front-end/lib/core/offline/pending_checkin_service.dart:85-125`, `front-end/lib/main.dart:40-46`, `front-end/lib/features/sites/presentation/add_review_screen.dart` | Medium | L'offline existe pour les check-ins seulement. Les avis, editions de profil et formulaires pro ne disposent pas d'une queue equivalente. Effort: ~2-4 days. |
| 7 | Professional site form still misses backend-supported fields | `front-end/lib/features/professional/presentation/create_site_screen.dart:23-39`, `front-end/lib/features/professional/presentation/create_site_screen.dart:243-266`, `back-end/src/utils/validators.js:38-67`, `back-end/src/services/site.service.js:549-579` | Medium | Le backend accepte deja `name_ar`, `description_ar`, `subcategory`, `postal_code`, `amenities`, `cover_photo`, mais le formulaire Flutter ne les expose pas encore. Le flux est deja bien avance, il reste surtout l'UI et le mapping. Effort: ~1-2 days. |
| 8 | Production release readiness for mobile | `front-end/android/app/build.gradle.kts:23-37`, `front-end/README.md:182-184` | High | Build Android encore en `applicationId` placeholder et signature release sur cle debug. Le README confirme aussi que la publication store et les environnements `staging/prod` ne sont pas prets. Effort: ~1-3 days pour la base, plus le packaging store. |

---

## SECTION 2 - MISSING FEATURES (Admin Web Dashboard)

Total issues found: **9**

| # | Missing Feature | File/Component | Priority (High/Med/Low) | Notes |
|---|----------------|---------------|------------------------|-------|
| 1 | Categories admin module | `admin-web/README.md:86` | Medium | Le README dit explicitement que le module categories admin n'existe pas encore. Effort: ~1-2 days pour liste + CRUD simple. |
| 2 | Badges admin module | `admin-web/README.md:86` | Medium | Aucun ecran admin pour gerer badges / gamification alors que le produit expose deja des badges cote app/backend. Effort: ~1-2 days. |
| 3 | Advanced analytics module | `admin-web/README.md:86`, `back-end/README.md:157` | Medium | Le dashboard expose des stats globales, mais pas de vues analytiques avancees, exports ou tendances. Effort: ~2-4 days. |
| 4 | Search / filters on pending sites queue | `admin-web/src/App.jsx:642-672`, `admin-web/src/App.jsx:335-380` | High | La page "Sites en attente" ne propose que pagination + moderation. Aucun filtre texte, ville, categorie, statut secondaire, tri. Effort: ~0.5-1 day. |
| 5 | Search / filters on pending reviews queue | `admin-web/src/App.jsx:861-891`, `admin-web/src/App.jsx:335-380` | High | Meme situation pour les avis en attente: page paginatee uniquement, sans recherche auteur/site/niveau de signalement. Effort: ~0.5-1 day. |
| 6 | Search / filters on contributor requests | `admin-web/src/App.jsx:896-927`, `admin-web/src/App.jsx:356-360` | Medium | La page charge seulement `status=PENDING`, sans recherche par utilisateur, email, date, ni tri operateur. Effort: ~0.5-1 day. |
| 7 | CSV / PDF export on admin tables | `admin-web/src/App.jsx`, `admin-web/src/lib/api.js` | Medium | Aucun export detecte sur les vues operateur avec tableaux ou files d'attente. Manque classique pour exploitation. Effort: ~1 day. |
| 8 | Review photo deletion UI, despite backend endpoint existing | `back-end/src/routes/admin.routes.js:29`, `back-end/src/services/admin.service.js:279-300`, `admin-web/src/App.jsx:981-1098`, `admin-web/src/lib/api.js:106-181` | High | Le backend sait supprimer une photo d'avis en moderation, mais l'UI admin n'affiche ni action ni client API correspondant. Effort: ~0.5 day. |
| 9 | User management limited to status only | `admin-web/src/App.jsx:1732-1751`, `admin-web/src/lib/api.js:175-178` | Medium | Le dashboard permet seulement de changer le statut utilisateur. Pas de changement de role, details enrichis, journal d'action, reset, export ou audit. Effort: ~1-2 days selon perimetre. |

---

## SECTION 3 - BUGS & BROKEN FUNCTIONALITY

Total issues found: **7**

| # | Bug Description | File | Severity (Critical/High/Med/Low) | Fix Suggestion |
|---|----------------|------|----------------------------------|----------------|
| 1 | Backend test suite currently fails on authenticated/admin flows with `401 Unauthorized` where `200/403/404` are expected | `back-end/tests/test-admin.js:117,139,152`, `back-end/tests/test-middleware.js:47,98,114,129`, `back-end/tests/test-sites.js:175,197,210,219` | Critical | Investigate `auth.middleware.js` session lookup vs token issuance/rotation. This is launch-blocking because owner/admin flows are not trustworthy. Effort: ~0.5-1 day. |
| 2 | Deep-linking to `/dashboard/users/:id` can render an empty detail panel if the selected user is not present in the currently loaded page | `admin-web/src/App.jsx:1105-1153` | High | `selectedUser` is derived only from `users.find(...)` on the current paginated page. Add dedicated user detail fetch or auto-load the target page. Effort: ~2-4h. |
| 3 | Forgot-password route is wired but functionally dead for end users | `front-end/lib/core/router/app_router.dart:100-104`, `front-end/lib/features/auth/presentation/forgot_password_screen.dart:43-95` | High | Either remove/hide the route until supported or implement the actual recovery flow. Effort: ~2-6h to disable safely, longer to implement. |
| 4 | Mobile debug screen is reachable in the main app router | `front-end/lib/core/router/app_router.dart:258-262` | Medium | Gate `/debug` behind `kDebugMode`, a build flag, or remove it from production routing. Effort: ~1h. |
| 5 | Admin web has no token refresh / expiry recovery path, so an expired session will bubble API errors into the UI until manual logout/reload | `admin-web/src/lib/api.js:9-32`, `admin-web/src/lib/api.js:36-47` | High | Add refresh flow similar to Flutter client or catch `401` globally and redirect to login with clear messaging. Effort: ~0.5-1 day. |
| 6 | Android release configuration is still non-production and can block shipping or produce invalid builds | `front-end/android/app/build.gradle.kts:23-37` | High | Replace placeholder `applicationId`, add real signing config, and remove debug signing from release. Effort: ~2-4h. |
| 7 | Support contact is not real and the settings screen can direct users to a non-routable support email | `front-end/lib/core/constants/app_constants.dart:89`, `front-end/lib/features/settings/presentation/settings_screen.dart:215`, `front-end/lib/features/settings/presentation/settings_screen.dart:470` | Low | Replace `.local` address with a real support channel or hide the entry until operational. Effort: ~30m. |

---

## SECTION 4 - SECURITY ISSUES

Total issues found: **8**

| # | Security Issue | File | Risk Level | Recommended Fix |
|---|---------------|------|------------|-----------------|
| 1 | Committed backend `.env` file contains a real JWT secret | `back-end/.env:7`, `.gitignore:4-7` | Critical | Rotate the exposed secret immediately, remove the tracked `.env` from version control, keep only `.env.example`. Effort: ~1-2h plus secret rotation coordination. |
| 2 | Admin JWT/session data stored in `localStorage` | `admin-web/src/lib/api.js:183-198` | High | Prefer `HttpOnly` secure cookies or at minimum reduce XSS exposure with stronger CSP and session hardening. Effort: ~1 day with backend alignment. |
| 3 | Admin login page ships hardcoded demo credentials and pre-fills them in the form | `admin-web/src/App.jsx:179-180`, `admin-web/src/App.jsx:248-253`, `back-end/sql/seed_data.sql:28,35` | High | Remove seeded values from UI, keep demo data only in non-production fixtures, and never expose credentials in the interface. Effort: ~30m. |
| 4 | Public register endpoint is not rate-limited while login/refresh are | `back-end/src/routes/auth.routes.js:35`, `back-end/src/routes/auth.routes.js:42-44` | High | Apply a dedicated registration limiter and anti-abuse controls on `/api/auth/register`. Effort: ~1-2h. |
| 5 | Rate limiter is process-local in memory and will not protect a multi-instance deployment consistently | `back-end/src/middleware/rate-limit.middleware.js:1-95` | Medium | Move counters to Redis or another shared store before scale-out. Effort: ~0.5-1 day. |
| 6 | CORS defaults allow requests with no `Origin` header | `back-end/src/config/runtime.js:107`, `back-end/src/config/cors.js:14-25`, `back-end/.env.example:22` | Medium | Keep this disabled by default in production and scope it to explicit non-browser clients only when necessary. Effort: ~1h. |
| 7 | Mobile settings let a user override the backend base URL at runtime, including auth traffic destination | `front-end/lib/features/settings/presentation/settings_screen.dart:110-163`, `front-end/lib/core/constants/app_constants.dart:49-59` | Medium | Restrict this to debug builds/admin-only profiles, or validate against an allowlist. Effort: ~1-2h. |
| 8 | No HTTPS enforcement / certificate pinning strategy is visible for mobile or admin clients | `front-end/lib/core/constants/app_constants.dart:32-59`, `admin-web/src/lib/api.js:1-3` | Medium | Enforce HTTPS in production config and add cert pinning / trust strategy for mobile if risk profile requires it. Effort: ~1-2 days depending on infrastructure. |

---

## SECTION 5 - UX/UI GAPS

Total issues found: **6**

| # | Gap | File/Component | Impact | Notes |
|---|-----|----------------|--------|-------|
| 1 | Password recovery experience is informational only, not actionable | `front-end/lib/features/auth/presentation/forgot_password_screen.dart:43-95` | High | Users hit a dead-end instead of recovering access. Effort: ~0.5-1 day for interim support CTA, longer for full flow. |
| 2 | Login screen warns that reset is unavailable but does not provide a real fallback path (support, web fallback, contact flow) | `front-end/lib/features/auth/presentation/login_screen.dart:153` | Medium | The warning sets expectation but does not solve the task. Effort: ~1-2h. |
| 3 | Settings screen gives success feedback for language and notifications even though both are largely local-only preferences today | `front-end/lib/features/settings/presentation/settings_screen.dart:58-83` | Medium | This can mislead users into expecting translated UI or actual notifications. Effort: ~1-2h copy update, more if implementing features. |
| 4 | Admin moderation queues are usable but operator UX is still weak without search/filter shortcuts | `admin-web/src/App.jsx:642-672`, `admin-web/src/App.jsx:861-891`, `admin-web/src/App.jsx:896-927` | High | Moderators will spend more time scrolling page by page. Effort: ~0.5-1 day per queue for a good first pass. |
| 5 | No export actions on admin lists for offline review/reporting | `admin-web/src/App.jsx`, `admin-web/src/lib/api.js` | Medium | Common admin need missing on user/moderation data. Effort: ~1 day. |
| 6 | Accessibility coverage looks minimal in admin web: almost no ARIA/keyboard affordances beyond one nav label; clickable table rows rely on mouse interaction | `admin-web/src/App.jsx:511`, `admin-web/src/App.jsx:1760-1763` | Medium | Add keyboard handlers, focus states, semantic buttons/links and broader ARIA labeling. Effort: ~1-2 days. |

---

## SECTION 6 - CODE QUALITY & TECHNICAL DEBT

Total issues found: **8**

| # | Issue | File | Impact | Notes |
|---|------|------|--------|-------|
| 1 | Admin app is concentrated in one very large component file (`1880` lines) | `admin-web/src/App.jsx` | High | Harder onboarding, review and regression control. Split by route/domain/hooks. Effort: ~1-2 days. |
| 2 | Flutter API layer is too large and monolithic (`1090` lines) | `front-end/lib/core/network/api_service.dart` | High | Hard to test and evolve; split by domain services or repositories. Effort: ~1-2 days incremental refactor. |
| 3 | Site detail screen is oversized (`1227` lines) | `front-end/lib/features/sites/presentation/site_detail_screen.dart` | Medium | Strong signal to extract sections/widgets/view models. Effort: ~1 day. |
| 4 | Check-in screen is oversized (`981` lines) | `front-end/lib/features/sites/presentation/checkin_screen.dart` | Medium | Also carries location, upload, queue and UI responsibilities together. Effort: ~1 day. |
| 5 | Duplicate `SiteCard` implementations increase divergence risk | `front-end/lib/features/sites/presentation/site_card.dart:6`, `front-end/lib/features/sites/presentation/widgets/site_card.dart:6`, `front-end/lib/features/sites/presentation/sites_list_screen.dart:8` | Medium | One modern card is used, another older implementation still exists. Consolidate into one source of truth. Effort: ~1-2h. |
| 6 | Stray/empty review card file suggests dead code or abandoned refactor | `front-end/lib/features/sites/presentation/review_card.dart:1`, `front-end/lib/features/sites/presentation/reviews_list.dart:6` | Low | The real widget lives under `widgets/review_card.dart`; remove or repurpose the empty file. Effort: ~30m. |
| 7 | Admin web has no lint/typecheck/test tooling in scripts and is fully plain JS | `admin-web/package.json` | High | No `test`, no `lint`, no TypeScript/static typing. This raises regression risk as the dashboard grows. Effort: ~1-2 days to set a baseline. |
| 8 | Test coverage posture is uneven across the repo | `front-end/README.md:183`, `front-end/pubspec.yaml:49-55`, `admin-web/package.json`, `back-end/package.json` | Medium | Flutter README says tests remain incomplete; admin has no tests at all; backend has tests but some are failing. Effort: ~2-5 days for meaningful coverage uplift. |

---

## SECTION 7 - INFRASTRUCTURE & DEPLOYMENT GAPS

Total issues found: **8**

| # | Gap | File | Impact | Notes |
|---|-----|------|--------|-------|
| 1 | No CI/CD pipeline configuration in the repository | Repository root | High | No `.github/workflows`, GitLab CI, Azure pipeline or equivalent detected outside dependencies. Effort: ~0.5-1 day for basic analyze/build/test pipeline. |
| 2 | No Dockerfile / docker-compose / deployment containerization detected | Repository root | Medium | Makes onboarding and reproducible deployment harder. Effort: ~0.5-1 day. |
| 3 | Missing `.env.example` equivalents for `front-end` and `admin-web` | `front-end`, `admin-web`, `back-end/.env.example` | Medium | Backend is documented, but the clients do not provide a standard env template for runtime config. Effort: ~1h. |
| 4 | No error monitoring integration visible | `front-end/pubspec.yaml`, `admin-web/package.json`, `back-end/package.json`, `front-end/lib/main.dart`, `admin-web/src/main.jsx` | High | No Sentry/Bugsnag/Crashlytics style setup detected. Effort: ~0.5-1 day. |
| 5 | No analytics integration visible | `front-end/pubspec.yaml`, `admin-web/package.json` | Medium | No product analytics SDK detected on mobile or admin. Effort: ~0.5-1 day. |
| 6 | No formal database migration system; schema changes rely on raw SQL scripts | `back-end/sql/*` | High | Good SQL coverage exists, but no migration runner/versioning workflow was detected. Effort: ~1-2 days. |
| 7 | Staging / production environments are not formalized yet | `front-end/README.md:184`, `admin-web/README.md:87` | High | Both docs acknowledge unfinished production hardening. Effort: ~1-3 days depending on hosting. |
| 8 | Mobile store/deployment preparation is still incomplete | `front-end/README.md:182`, `front-end/android/app/build.gradle.kts:23-37` | High | Shipping pipeline, release signing and store prep are still unfinished. Effort: ~1-3 days plus store submission time. |

---

## SECTION 8 - PRIORITIZED ACTION PLAN

### 🔴 Must Fix Before Launch (Blockers)

- [ ] Fix the backend auth/session regression causing `401` failures in owner/admin tests (`back-end/tests/test-admin.js`, `back-end/tests/test-middleware.js`, `back-end/tests/test-sites.js`) - **~0.5-1 day**
- [ ] Rotate and remove the committed JWT secret from `back-end/.env`, then purge tracked secrets from the repo history if needed - **~1-2h**
- [ ] Replace Android placeholder release config (`applicationId`, debug signing) in `front-end/android/app/build.gradle.kts` - **~2-4h**
- [ ] Remove hardcoded demo credentials from `admin-web/src/App.jsx` and stop exposing them in production builds - **~30m**
- [ ] Add protection or removal for the mobile `/debug` route in production - **~1h**
- [ ] Finalize minimum production environment setup: HTTPS endpoints, CORS production values, real support contact, release envs - **~1 day**

### 🟠 Should Fix Soon (High Impact)

- [ ] Implement a real forgot-password flow or remove the dead route until backend support exists - **~0.5-2 days**
- [ ] Add registration rate limiting and move rate limiting to a shared store for production - **~0.5-1 day**
- [ ] Add admin session expiry recovery / token refresh behavior - **~0.5-1 day**
- [ ] Add search/filter controls to admin moderation queues (sites, reviews, contributor requests) - **~1-2 days**
- [ ] Wire the admin review-photo deletion flow already exposed by the backend - **~0.5 day**
- [ ] Replace local-only notification/language messaging with either real integrations or clearer UX copy - **~0.5-1 day**
- [ ] Add CI for `flutter analyze`, admin build and backend tests - **~0.5-1 day**

### 🟡 Nice to Have (Improvements)

- [ ] Add push notifications and local reminders with actual delivery - **~2-4 days**
- [ ] Add deep linking / app links for mobile navigation and shared URLs - **~1-2 days**
- [ ] Expand the professional site form with remaining backend-supported fields - **~1-2 days**
- [ ] Add CSV/PDF export from admin data tables - **~1 day**
- [ ] Improve admin accessibility (keyboard nav, semantics, ARIA coverage) - **~1-2 days**
- [ ] Refactor monolithic screens/services (`App.jsx`, `api_service.dart`, `site_detail_screen.dart`, `checkin_screen.dart`) - **~2-4 days incremental**

### 🟢 Future Enhancements

- [ ] Add biometric re-authentication on mobile - **~1 day**
- [ ] Add categories/badges/advanced analytics modules to the admin dashboard - **~3-6 days depending on scope**
- [ ] Introduce a formal migration tool for backend schema changes - **~1-2 days**
- [ ] Add error monitoring and analytics across mobile, admin and backend - **~1-2 days**
- [ ] Add Docker-based local/prod deployment scaffolding - **~0.5-1 day**

---

## Short Conclusion

The codebase is already materially advanced:
- Flutter app analyzes cleanly
- Admin web builds cleanly
- Backend covers many business flows already

The main pre-launch risks are not "missing everything"; they are concentrated in:
- auth/session reliability on protected backend flows
- security hygiene around secrets and admin sessions
- production readiness of mobile release/deployment
- a few still-placeholder user journeys

This means the project is much closer to "stabilize and harden" than to "rewrite".
