# IMPLEMENTATION_PLAN

Plan d'implementation derive exclusivement de [MISSING_AND_IMPROVEMENTS.md](c:/Users/User/App_Touriste/MISSING_AND_IMPROVEMENTS.md).

Principe de ce document:
- chaque tache provient d'un point deja audite
- chaque tache reference sa source via `[Sx-#y]`
- les phases sont ordonnees par dependance
- les criteres d'acceptation sont verifiables sans ambiguite

---

## PHASE 0 - Security & Critical Blockers

**Goal:** Eliminate launch-blocking security risks and broken test infrastructure.  
**Target duration:** 1-2 days  
**Must be completed before any other phase begins.**

### P0-01 - Rotate and remove the committed JWT secret

**What to do:** Rotate the JWT secret currently committed in the backend `.env`, remove the tracked secret from the repository, and keep only the example/env-template workflow for local setup. Align `.gitignore` and backend env documentation so secrets are never committed again.

**File(s) to touch:** `back-end/.env`, `.gitignore`, `back-end/.env.example`

**Audit reference:** [S4-#1]

**Estimated effort:** ~1-2h

**Acceptance criteria:**
- `back-end/.env` is no longer tracked with a real secret value
- a new JWT secret has been generated outside the repo
- `back-end/.env.example` still documents the required variables without real values
- the repository no longer contains the leaked JWT secret in tracked files

### P0-02 - Fix the backend `401` regression on protected/admin flows

**What to do:** Resolve the auth/session regression causing owner/admin flows to return `401` in tests that should return `200`, `403`, or `404`. Start from the auth-protected failing suites, then fix the underlying session/token validation path and rerun the backend test suite.

**File(s) to touch:** `back-end/tests/test-admin.js`, `back-end/tests/test-middleware.js`, `back-end/tests/test-sites.js`, `back-end/src/middleware/auth.middleware.js`

**Audit reference:** [S3-#1]

**Estimated effort:** ~0.5-1 day

**Acceptance criteria:**
- the previously failing auth-protected tests no longer return unexpected `401`
- `npm test` in `back-end` passes for `test-admin`, `test-middleware`, and `test-sites`
- admin and owner routes behave according to expected status codes

### P0-03 - Remove hardcoded demo credentials from the admin UI

**What to do:** Remove the prefilled admin email/password and the visible credential hints from the admin login screen. Keep any seed/demo data out of the shipped UI.

**File(s) to touch:** `admin-web/src/App.jsx`, `back-end/sql/seed_data.sql`

**Audit reference:** [S4-#3]

**Estimated effort:** ~30m

**Acceptance criteria:**
- the admin login form no longer preloads demo credentials
- the admin login screen no longer displays a demo email/password pair
- seed/demo credentials, if still needed for local testing, are not exposed in production UI

### P0-04 - Replace Android placeholder release configuration

**What to do:** Replace the placeholder Android `applicationId`, remove debug-signing from release, and wire a real signing configuration suitable for release builds.

**File(s) to touch:** `front-end/android/app/build.gradle.kts`

**Audit reference:** [S1-#8], [S3-#6]

**Estimated effort:** ~2-4h

**Acceptance criteria:**
- `applicationId` is no longer the placeholder value
- release builds do not use the debug signing config
- a release build can be produced with the intended application identity

### P0-05 - Gate the mobile `/debug` route behind debug-only behavior

**What to do:** Prevent the debug screen from being reachable in production builds by guarding the route with `kDebugMode` or by removing it from the production router.

**File(s) to touch:** `front-end/lib/core/router/app_router.dart`

**Audit reference:** [S3-#4]

**Estimated effort:** ~1h

**Acceptance criteria:**
- `/debug` is not reachable in production builds
- debug tooling remains available only in debug/development contexts

### P0-06 - Apply a production CORS + HTTPS baseline

**What to do:** Tighten the backend production CORS defaults, remove permissive no-origin behavior from the production baseline, and make production client configuration target HTTPS endpoints only.

**File(s) to touch:** `back-end/src/config/runtime.js`, `back-end/src/config/cors.js`, `back-end/.env.example`, `front-end/lib/core/constants/app_constants.dart`, `admin-web/src/lib/api.js`

**Audit reference:** [S4-#6], [S4-#8], [S7-#7]

**Estimated effort:** ~1 day

**Acceptance criteria:**
- production defaults no longer allow permissive `CORS_ALLOW_NO_ORIGIN=true`
- backend env example documents a production-safe CORS configuration
- production-facing client config uses HTTPS base URLs
- local development remains usable without weakening production defaults

**Definition of Done (Phase 0):**
- all P0 tasks are merged
- no real secret remains committed
- backend auth-protected tests are green
- admin UI no longer exposes demo credentials
- production mobile build no longer exposes `/debug`

---

## PHASE 1 - Auth, Session & Core Reliability

**Goal:** Make all authentication and session flows trustworthy end-to-end.  
**Target duration:** 2-3 days  
**Depends on:** Phase 0

### P1-01 - Replace the dead forgot-password route with a real flow or disable it safely

**What to do:** Remove the current dead-end password recovery experience from the shipped app unless a real reset flow is implemented. Update the router, screen, login entry points, and the associated widget test to reflect the chosen behavior.

**File(s) to touch:** `front-end/lib/core/router/app_router.dart`, `front-end/lib/features/auth/presentation/forgot_password_screen.dart`, `front-end/lib/features/auth/presentation/login_screen.dart`, `front-end/test/features/auth/forgot_password_screen_test.dart`

**Audit reference:** [S1-#1], [S3-#3], [S5-#1], [S5-#2]

**Estimated effort:** ~0.5-2 days

**Acceptance criteria:**
- users no longer land on a dead-end password recovery path
- either the reset flow is operational, or all user-facing access to the dead route is removed/disabled
- login UI no longer promises a recovery action that does not exist
- related widget test expectations match the shipped behavior

### P1-02 - Add admin session expiry recovery

**What to do:** Handle expired admin sessions centrally so the dashboard either refreshes the session or redirects cleanly to login with explicit feedback instead of surfacing raw request failures.

**File(s) to touch:** `admin-web/src/lib/api.js`, `admin-web/src/App.jsx`

**Audit reference:** [S3-#5]

**Estimated effort:** ~0.5-1 day

**Acceptance criteria:**
- expired admin sessions do not leave the UI in a broken state
- a `401` response triggers a controlled recovery path
- the dashboard returns the user to a valid authenticated or logged-out state

### P1-03 - Add rate limiting to public registration

**What to do:** Apply a registration-specific rate limiter to `/api/auth/register`, using the same middleware pattern already used for login and refresh.

**File(s) to touch:** `back-end/src/routes/auth.routes.js`, `back-end/src/middleware/rate-limit.middleware.js`

**Audit reference:** [S4-#4]

**Estimated effort:** ~1-2h

**Acceptance criteria:**
- `/api/auth/register` is protected by rate limiting
- rate-limit headers and error responses are returned consistently with the existing middleware behavior
- login, refresh, and register all have explicit anti-abuse coverage

### P1-04 - Move rate limiting to a shared store for multi-instance safety

**What to do:** Replace the in-memory rate-limit store with a shared backing store so limits continue to work correctly when the backend is scaled beyond a single process.

**File(s) to touch:** `back-end/src/middleware/rate-limit.middleware.js`, `back-end/src/config/runtime.js`

**Audit reference:** [S4-#5]

**Estimated effort:** ~0.5-1 day

**Acceptance criteria:**
- rate-limit counters no longer rely on process-local memory only
- the backend can enforce limits consistently across multiple instances
- configuration for the shared rate-limit store is documented and environment-driven

### P1-05 - Fix direct navigation to `/dashboard/users/:id`

**What to do:** Make the admin user detail panel load correctly when a user lands directly on `/dashboard/users/:id`, even if that user is not part of the currently loaded paginated list.

**File(s) to touch:** `admin-web/src/App.jsx`

**Audit reference:** [S3-#2]

**Estimated effort:** ~2-4h

**Acceptance criteria:**
- direct navigation to `/dashboard/users/:id` always shows a valid detail panel or a clear not-found state
- the page no longer depends on the selected user already being present in the current table page

**Definition of Done (Phase 1):**
- password recovery is no longer a dead route
- admin sessions recover cleanly from expiry
- register/login/refresh all have trustworthy request protection
- direct user-detail navigation works reliably

---

## PHASE 2 - Admin Dashboard Completeness

**Goal:** Make the admin web dashboard fully operational for daily moderation work.  
**Target duration:** 3-5 days  
**Depends on:** Phase 1

### P2-01 - Add search and filters to the pending sites queue

**What to do:** Add operator-facing filters for the pending sites moderation queue, starting with a search field and basic moderation-friendly filters, and thread them through the dashboard loading logic.

**File(s) to touch:** `admin-web/src/App.jsx`, `admin-web/src/lib/api.js`

**Audit reference:** [S2-#4], [S5-#4]

**Estimated effort:** ~0.5-1 day

**Acceptance criteria:**
- moderators can narrow the pending sites list without paging manually through all results
- filters are reflected in the request/query layer
- pagination still works correctly with active filters

### P2-02 - Add search and filters to the pending reviews queue

**What to do:** Add search/filter controls to the pending reviews moderation queue so moderators can target reviews by relevant criteria instead of scrolling page by page.

**File(s) to touch:** `admin-web/src/App.jsx`, `admin-web/src/lib/api.js`

**Audit reference:** [S2-#5], [S5-#4]

**Estimated effort:** ~0.5-1 day

**Acceptance criteria:**
- moderators can filter/search the pending reviews list
- the queue remains paginated and filterable at the same time
- moderation actions continue to work after filtering

### P2-03 - Add search and filters to contributor requests

**What to do:** Add search/filter controls to the contributor requests queue so admins can process requests by user/date/status more efficiently than the current pending-only list.

**File(s) to touch:** `admin-web/src/App.jsx`, `admin-web/src/lib/api.js`

**Audit reference:** [S2-#6], [S5-#4]

**Estimated effort:** ~0.5-1 day

**Acceptance criteria:**
- contributor requests can be filtered/searched from the UI
- current pagination still works with active filters
- admins can process filtered requests without reloading the whole dashboard manually

### P2-04 - Wire review-photo deletion to the existing admin moderation endpoint

**What to do:** Expose photo deletion controls on the admin review detail screen and connect them to the already available backend endpoint for deleting review photos.

**File(s) to touch:** `admin-web/src/App.jsx`, `admin-web/src/lib/api.js`, `back-end/src/routes/admin.routes.js`, `back-end/src/services/admin.service.js`

**Audit reference:** [S2-#8]

**Estimated effort:** ~0.5 day

**Acceptance criteria:**
- admins can delete a review photo from the review detail UI
- the deletion hits the existing backend endpoint successfully
- the review detail view refreshes so the removed photo is no longer shown

### P2-05 - Expand user management beyond status-only controls

**What to do:** Extend the user management area beyond status changes so it is no longer limited to one operation. Keep the scope anchored to the audited gap: role change support and/or richer audit-style management information, depending on the backend path chosen during implementation.

**File(s) to touch:** `admin-web/src/App.jsx`, `admin-web/src/lib/api.js`

**Audit reference:** [S2-#9]

**Estimated effort:** ~1-2 days

**Acceptance criteria:**
- the user management area is no longer limited to status updates only
- at least one additional audited management capability is available from the dashboard
- the added capability is reflected clearly in the UI and handled safely

### P2-06 - Add CSV/PDF export to admin tables

**What to do:** Add export actions for the main admin data tables/queues so operational data can be reused outside the dashboard.

**File(s) to touch:** `admin-web/src/App.jsx`, `admin-web/src/lib/api.js`

**Audit reference:** [S2-#7], [S5-#5]

**Estimated effort:** ~1 day

**Acceptance criteria:**
- admins can export relevant table data from the UI
- export actions work on the targeted moderation/user tables defined for the release
- exported files reflect the currently selected data set or documented default scope

**Definition of Done (Phase 2):**
- all moderation queues support search/filter workflows
- review photo deletion is usable from the dashboard
- user management is no longer status-only
- admins can export operational data from the agreed tables

---

## PHASE 3 - Mobile App Completeness

**Goal:** Close all placeholder or missing user-facing features in the Flutter app.  
**Target duration:** 4-7 days  
**Depends on:** Phase 1

### P3-01 - Expand the professional site form to match supported backend fields

**What to do:** Add the remaining backend-supported site fields to the professional create/edit form: `name_ar`, `description_ar`, `subcategory`, `postal_code`, `amenities`, and `cover_photo`. Ensure they are validated and submitted consistently with the existing payload.

**File(s) to touch:** `front-end/lib/features/professional/presentation/create_site_screen.dart`, `back-end/src/utils/validators.js`, `back-end/src/services/site.service.js`

**Audit reference:** [S1-#7]

**Estimated effort:** ~1-2 days

**Acceptance criteria:**
- each missing field is visible in the professional form
- the submitted payload includes the newly exposed fields
- create and edit flows both accept the expanded field set

### P3-02 - Replace misleading settings UX for notifications and language

**What to do:** Update the settings experience so notifications and language no longer imply a fully implemented feature when they are currently local-only. If a real integration is chosen for the release, wire it here; otherwise, ship accurate copy and state handling.

**File(s) to touch:** `front-end/lib/features/settings/presentation/settings_screen.dart`, `front-end/lib/core/storage/storage_service.dart`, `front-end/pubspec.yaml`

**Audit reference:** [S1-#2], [S1-#3], [S5-#3]

**Estimated effort:** ~0.5-1 day

**Acceptance criteria:**
- settings copy matches the actual shipped behavior
- users are not told that notifications/i18n exist when they do not
- local preference storage still behaves predictably

### P3-03 - Replace the fake support contact with a real channel or hide it

**What to do:** Remove the `.local` support contact from the shipped app and either replace it with a real support address/channel or hide the support action until one exists.

**File(s) to touch:** `front-end/lib/core/constants/app_constants.dart`, `front-end/lib/features/settings/presentation/settings_screen.dart`

**Audit reference:** [S3-#7]

**Estimated effort:** ~30m

**Acceptance criteria:**
- the app no longer surfaces `support@moroccocheck.local`
- support UI points to a real channel or is not shown in production

### P3-04 - Implement deep linking / app links with `go_router`

**What to do:** Add deep-link support to the Flutter app so key routes already managed by `go_router` can be opened via platform links.

**File(s) to touch:** `front-end/pubspec.yaml`, `front-end/lib/core/router/app_router.dart`

**Audit reference:** [S1-#4]

**Estimated effort:** ~1-2 days

**Acceptance criteria:**
- selected app routes can be opened from deep links/app links
- route handling works without breaking existing in-app navigation
- link handling is documented for the supported platforms

**Definition of Done (Phase 3):**
- no placeholder/misleading mobile UX remains in the shipped settings/auth surfaces covered by this phase
- the professional form exposes the audited missing fields
- support contact is production-safe
- deep links resolve into the intended app routes

---

## PHASE 4 - Production Hardening & Release Prep

**Goal:** Make both clients and the backend safe and deployable to production.  
**Target duration:** 3-5 days  
**Depends on:** Phases 0-3

### P4-01 - Finalize Android release readiness

**What to do:** Complete the remaining mobile release-prep work around Android packaging, signing, and documented release expectations so the app is ready for production distribution.

**File(s) to touch:** `front-end/android/app/build.gradle.kts`, `front-end/README.md`

**Audit reference:** [S1-#8], [S7-#8]

**Estimated effort:** ~1-3 days

**Acceptance criteria:**
- release signing and application identity are fully documented and usable
- the README reflects the real release preparation steps
- Android release output is no longer blocked by placeholder config

### P4-02 - Add env templates for the mobile app and admin dashboard

**What to do:** Create client-side env templates and align them with the already documented backend example so local/staging/prod setup is reproducible.

**File(s) to touch:** `front-end`, `admin-web`, `back-end/.env.example`

**Audit reference:** [S7-#3]

**Estimated effort:** ~1h

**Acceptance criteria:**
- both client apps provide a documented example env/template path
- required runtime variables are listed alongside expected defaults/examples
- setup instructions match the templates that ship in the repo

### P4-03 - Set up CI/CD for analyze, build, and backend tests

**What to do:** Add a repository-level pipeline that runs Flutter static checks/build steps, the admin web build, and the backend test suite automatically.

**File(s) to touch:** `Repository root`, `front-end`, `admin-web`, `back-end`

**Audit reference:** [S7-#1]

**Estimated effort:** ~0.5-1 day

**Acceptance criteria:**
- a CI pipeline exists at the repository root
- the pipeline runs Flutter checks, admin build, and backend tests
- pull requests/commits fail visibly when any of these checks fail

### P4-04 - Add error monitoring across mobile, admin, and backend

**What to do:** Introduce a production error-monitoring solution and hook it into the mobile app bootstrap, admin web bootstrap, and backend package/runtime path.

**File(s) to touch:** `front-end/pubspec.yaml`, `front-end/lib/main.dart`, `admin-web/package.json`, `admin-web/src/main.jsx`, `back-end/package.json`

**Audit reference:** [S7-#4]

**Estimated effort:** ~0.5-1 day

**Acceptance criteria:**
- errors from mobile, admin, and backend are reported to the chosen monitoring tool
- monitoring is environment-aware and can be disabled/configured per environment
- the integration is documented for local and production usage

### P4-05 - Formalize staging vs production environments

**What to do:** Replace the current ad-hoc environment posture with explicit staging/production configuration and documentation across mobile, admin, and backend.

**File(s) to touch:** `front-end/README.md`, `admin-web/README.md`, `front-end/lib/core/constants/app_constants.dart`, `admin-web/src/lib/api.js`, `back-end/.env.example`, `back-end/src/config/runtime.js`

**Audit reference:** [S7-#7]

**Estimated effort:** ~1-3 days

**Acceptance criteria:**
- staging and production configuration are both documented
- base URLs and env-driven settings are explicit for each app
- developers can start each target environment without guessing hidden config

### P4-06 - Add a database migration runner around the existing SQL assets

**What to do:** Introduce a migration execution/versioning workflow so schema evolution no longer depends on manually applying raw SQL files from `back-end/sql/*`.

**File(s) to touch:** `back-end/sql/*`

**Audit reference:** [S7-#6]

**Estimated effort:** ~1-2 days

**Acceptance criteria:**
- schema changes can be applied in a repeatable, ordered way
- migration state is trackable across environments
- existing SQL assets are integrated into the chosen migration workflow or clearly superseded

**Definition of Done (Phase 4):**
- release and environment setup are documented and reproducible
- CI exists and runs the core repo checks
- monitoring is active
- database changes are applied via a repeatable migration workflow

---

## PHASE 5 - Quality, Refactoring & Observability

**Goal:** Reduce technical debt and improve maintainability without blocking launch.  
**Target duration:** 4-8 days  
**Can be parallelized with Phase 4 or done post-launch**

**Status:** Completed

**Completion notes:**
- `admin-web/src/App.jsx` has already been partially decomposed into extracted dashboard/moderation components, with the main file reduced and shared UI moved into dedicated modules.
- `front-end/lib/core/network/api_service.dart` has been split by domain using dedicated partial files while preserving the existing `ApiService` public contract for the rest of the app and test fakes.
- `front-end/lib/features/sites/presentation/site_detail_screen.dart` and `front-end/lib/features/sites/presentation/checkin_screen.dart` have been reduced substantially, with large UI sections extracted into dedicated widgets.
- Duplicate/dead presentation artifacts were cleaned up, including removal of the duplicate `SiteCard` file and the stray empty `review_card.dart`.
- `admin-web` now has a stronger validation baseline with `lint`, `typecheck`, `build`, and a first executable `test` script.
- Verification completed successfully with `npm run lint`, `npm run typecheck`, and `npm run build` in `admin-web`, plus `flutter analyze` in `front-end`. A rerun of targeted Flutter widget tests may still require clearing locally locked Windows `build/unit_test_assets` files if the Flutter tool keeps them open.

### P5-01 - Split `App.jsx` into route/domain-level modules

**What to do:** Break the oversized admin root component into route-level and domain-level modules so login, dashboard state, moderation pages, and user management are not all maintained in one file.

**File(s) to touch:** `admin-web/src/App.jsx`

**Audit reference:** [S6-#1]

**Estimated effort:** ~1-2 days

**Acceptance criteria:**
- `admin-web/src/App.jsx` no longer concentrates the entire dashboard implementation
- extracted modules have clear ownership by route/domain
- behavior remains unchanged after the split

### P5-02 - Split `api_service.dart` into domain-oriented services/repositories

**What to do:** Refactor the monolithic Flutter API layer into smaller domain-oriented units so auth, profile, sites, reviews, and professional operations are easier to test and maintain.

**File(s) to touch:** `front-end/lib/core/network/api_service.dart`

**Audit reference:** [S6-#2]

**Estimated effort:** ~1-2 days

**Acceptance criteria:**
- the current monolithic API service is split into smaller units by domain
- network behavior remains compatible with the existing screens
- the codebase becomes easier to test and navigate

### P5-03 - Refactor oversized Flutter screens into smaller UI units

**What to do:** Split the large site detail and check-in screens into extracted sections/widgets/view models so responsibilities are separated cleanly.

**File(s) to touch:** `front-end/lib/features/sites/presentation/site_detail_screen.dart`, `front-end/lib/features/sites/presentation/checkin_screen.dart`

**Audit reference:** [S6-#3], [S6-#4]

**Estimated effort:** ~2 days

**Acceptance criteria:**
- both screens are materially smaller and easier to review
- complex UI blocks are extracted into dedicated widgets/helpers
- functional behavior remains unchanged

### P5-04 - Consolidate duplicate card components and remove dead review card code

**What to do:** Keep one `SiteCard` implementation as the source of truth and remove the empty/stray `review_card.dart` artifact so the presentation layer has no misleading duplicates.

**File(s) to touch:** `front-end/lib/features/sites/presentation/site_card.dart`, `front-end/lib/features/sites/presentation/widgets/site_card.dart`, `front-end/lib/features/sites/presentation/sites_list_screen.dart`, `front-end/lib/features/sites/presentation/review_card.dart`, `front-end/lib/features/sites/presentation/reviews_list.dart`

**Audit reference:** [S6-#5], [S6-#6]

**Estimated effort:** ~1-2h

**Acceptance criteria:**
- only one active `SiteCard` implementation remains
- the empty `review_card.dart` file is removed or repurposed intentionally
- all imports point to the intended presentation components

### P5-05 - Add linting and a stronger static baseline to `admin-web`

**What to do:** Introduce a lint/test/type-safety baseline for the admin dashboard so growth is no longer happening on plain JS without tooling guardrails.

**File(s) to touch:** `admin-web/package.json`, `admin-web/src/App.jsx`

**Audit reference:** [S6-#7]

**Estimated effort:** ~1-2 days

**Acceptance criteria:**
- `admin-web` exposes linting and validation scripts
- the admin codebase is checked by a stronger static baseline than today
- the new scripts can be run locally and in CI

### P5-06 - Expand automated test coverage across all three apps

**What to do:** Improve coverage where the audit found gaps: Flutter widget tests, admin component/page tests, and backend integration tests with emphasis on auth-protected routes.

**File(s) to touch:** `front-end/README.md`, `front-end/pubspec.yaml`, `admin-web/package.json`, `back-end/package.json`, `back-end/tests/test-admin.js`, `back-end/tests/test-middleware.js`, `back-end/tests/test-sites.js`

**Audit reference:** [S6-#8]

**Estimated effort:** ~2-5 days

**Acceptance criteria:**
- Flutter, admin, and backend all have meaningful automated coverage additions
- auth-protected backend routes are covered by passing tests
- the added tests are wired into the repo's CI workflow

**Definition of Done (Phase 5):**
- the major oversized files have been broken down
- duplicate/dead UI artifacts have been cleaned up
- `admin-web` now has a stronger static/lint/test baseline
- automated coverage has been improved with new admin test coverage and retained backend auth-protected coverage, while Flutter test execution remains subject only to clearing local Windows file locks when they occur

---

## PHASE 6 - Feature Enhancements (Post-Launch)

**Goal:** Add value-add features once the app is stable in production.  
**Target duration:** 8-14 days  
**Depends on:** All previous phases

### P6-01 - Add push notifications and local reminders

**What to do:** Turn the current local-only notifications preference into a real notification capability with delivery/reminder behavior.

**File(s) to touch:** `front-end/lib/features/settings/presentation/settings_screen.dart`, `front-end/lib/core/storage/storage_service.dart`, `front-end/pubspec.yaml`

**Audit reference:** [S1-#2]

**Estimated effort:** ~2-4 days

**Acceptance criteria:**
- the notifications toggle controls a real notification capability
- the app can register and receive/send the chosen notification type
- user-facing copy matches actual delivery behavior

### P6-02 - Add biometric re-authentication

**What to do:** Add biometric re-authentication for sensitive account/session access on mobile.

**File(s) to touch:** `front-end/pubspec.yaml`, `front-end/lib/features/auth`, `front-end/lib/core/storage/storage_service.dart`

**Audit reference:** [S1-#5]

**Estimated effort:** ~1 day

**Acceptance criteria:**
- users can re-authenticate with biometrics on supported devices
- biometric gating fails safely and falls back cleanly when unavailable

### P6-03 - Add a full localization/i18n system

**What to do:** Replace the current stored-language placeholder behavior with a real localization system and translated resources.

**File(s) to touch:** `front-end/lib/features/settings/presentation/settings_screen.dart`, `front-end/lib/core/storage/storage_service.dart`, `front-end/pubspec.yaml`

**Audit reference:** [S1-#3]

**Estimated effort:** ~2-5 days

**Acceptance criteria:**
- changing language affects actual translated UI strings
- language selection persists correctly
- localization resources and setup are documented

### P6-04 - Extend the offline write queue beyond check-ins

**What to do:** Reuse the current offline queue pattern so reviews and professional forms also benefit from deferred sync instead of online-only submission.

**File(s) to touch:** `front-end/lib/core/offline/pending_checkin_service.dart`, `front-end/lib/main.dart`, `front-end/lib/features/sites/presentation/add_review_screen.dart`, `front-end/lib/features/professional/presentation/create_site_screen.dart`

**Audit reference:** [S1-#6]

**Estimated effort:** ~2-4 days

**Acceptance criteria:**
- reviews and professional submissions can be queued and retried offline
- pending actions sync successfully when connectivity returns
- users receive clear feedback about queued vs sent actions

### P6-05 - Add the admin categories module

**What to do:** Build the missing admin categories area for listing and maintaining categories from the admin dashboard.

**File(s) to touch:** `admin-web/README.md`

**Audit reference:** [S2-#1]

**Estimated effort:** ~1-2 days

**Acceptance criteria:**
- an admin categories area exists in the dashboard
- category list and maintenance actions required for the release are available

### P6-06 - Add the admin badges/gamification module

**What to do:** Build the missing admin area for badge/gamification management.

**File(s) to touch:** `admin-web/README.md`

**Audit reference:** [S2-#2]

**Estimated effort:** ~1-2 days

**Acceptance criteria:**
- admins can manage the badge/gamification scope defined for the release
- the module is accessible from the dashboard navigation

### P6-07 - Add advanced analytics views

**What to do:** Expand the admin dashboard beyond summary stats into analytics-oriented views with trends and export-friendly outputs.

**File(s) to touch:** `admin-web/README.md`, `back-end/README.md`

**Audit reference:** [S2-#3]

**Estimated effort:** ~2-4 days

**Acceptance criteria:**
- analytics views expose more than top-level counters
- the agreed trend/export views are available in the dashboard

### P6-08 - Add Docker-based deployment scaffolding

**What to do:** Introduce Docker-based scaffolding for reproducible local/prod deployment once the apps are stable.

**File(s) to touch:** `Repository root`

**Audit reference:** [S7-#2]

**Estimated effort:** ~0.5-1 day

**Acceptance criteria:**
- the repository includes Docker-based scaffolding for the agreed services
- local/prod startup steps are documented and reproducible

### P6-09 - Add product analytics SDK integration and mobile HTTPS hardening strategy

**What to do:** Add analytics instrumentation to the mobile app and admin dashboard, and define/implement the mobile HTTPS hardening path identified in the audit.

**File(s) to touch:** `front-end/pubspec.yaml`, `admin-web/package.json`, `front-end/lib/core/constants/app_constants.dart`, `admin-web/src/lib/api.js`

**Audit reference:** [S7-#5], [S4-#8]

**Estimated effort:** ~1-3 days

**Acceptance criteria:**
- product analytics events can be captured from mobile and admin
- the mobile HTTPS hardening strategy is implemented or fully documented and enforced

**Definition of Done (Phase 6):**
- post-launch value-add features are production-integrated
- enhancements no longer rely on placeholder settings or manual workarounds
- deployment and observability capabilities exceed launch minimums

---

## Summary Table

| Phase | Name | Est. Duration | Depends On | # Tasks |
|-------|------|--------------|------------|---------|
| 0 | Security & Critical Blockers | 1-2 days | - | 6 |
| 1 | Auth, Session & Core Reliability | 2-3 days | P0 | 5 |
| 2 | Admin Dashboard Completeness | 3-5 days | P1 | 6 |
| 3 | Mobile App Completeness | 4-7 days | P1 | 4 |
| 4 | Production Hardening & Release Prep | 3-5 days | P0-P3 | 6 |
| 5 | Quality, Refactoring & Observability | 4-8 days | P4 | 6 |
| 6 | Feature Enhancements (Post-Launch) | 8-14 days | P5 | 9 |
| **Total** |  | **~25-44 days** |  | **42** |
