import 'package:go_router/go_router.dart';
import '../../splash/splash_screen.dart';
import '../../features/auth/presentation/auth_provider.dart';
import '../../features/auth/presentation/welcome_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../features/auth/presentation/forgot_password_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/map/presentation/map_screen.dart';
import '../../features/professional/presentation/create_site_screen.dart';
import '../../features/professional/presentation/professional_site_detail_screen.dart';
import '../../features/professional/presentation/professional_sites_screen.dart';
import '../../features/professional/models/professional_site.dart';
import '../../features/profile/presentation/badges_catalog_screen.dart';
import '../../features/profile/presentation/edit_profile_screen.dart';
import '../../features/profile/presentation/leaderboard_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../shared/models/user.dart';
import '../../features/sites/presentation/sites_list_screen.dart';
import '../../features/sites/presentation/site_detail_screen.dart';
import '../../features/sites/presentation/checkin_screen.dart';
import '../../features/sites/presentation/add_review_screen.dart';
import '../../debug/debug_home.dart';

class AppRouter {
  static GoRouter createRouter(
    AuthProvider authProvider, {
    String initialLocation = '/',
  }) {
    bool canAccessSiteManagement(String? role) {
      return role == 'PROFESSIONAL' || role == 'MODERATOR' || role == 'ADMIN';
    }

    bool isProtectedRoute(String location) {
      return location == '/profile' ||
          location == '/profile/edit' ||
          location == '/profile/badges' ||
          location == '/leaderboard' ||
          location.startsWith('/professional/sites') ||
          location.startsWith('/checkin/') ||
          location.startsWith('/review/');
    }

    bool isProfessionalRoute(String location) {
      return location.startsWith('/professional/sites');
    }

    bool isAuthRoute(String location) {
      return location == '/welcome' ||
          location == '/login' ||
          location == '/register';
    }

    return GoRouter(
      initialLocation: initialLocation,
      refreshListenable: authProvider,
      redirect: (context, state) {
        final location = state.matchedLocation;
        final isAuthenticated = authProvider.isAuthenticated;

        if (location == '/') {
          return null;
        }

        if (!isAuthenticated && isProtectedRoute(location)) {
          return '/login';
        }

        if (isAuthenticated &&
            isProfessionalRoute(location) &&
            !canAccessSiteManagement(authProvider.user?.role)) {
          return '/home';
        }

        if (isAuthenticated && isAuthRoute(location)) {
          return '/home';
        }

        return null;
      },
      routes: [
        GoRoute(
          path: '/welcome',
          name: 'welcome',
          builder: (context, state) => const WelcomeScreen(),
        ),
        GoRoute(
          path: '/',
          name: 'splash',
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: '/login',
          name: 'login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/register',
          name: 'register',
          builder: (context, state) => const RegisterScreen(),
        ),
        GoRoute(
          path: '/forgot-password',
          name: 'forgot-password',
          builder: (context, state) => const ForgotPasswordScreen(),
        ),
        GoRoute(
          path: '/home',
          name: 'home',
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: '/map',
          name: 'map',
          builder: (context, state) => const MapScreen(),
        ),
        GoRoute(
          path: '/profile',
          name: 'profile',
          builder: (context, state) => const ProfileScreen(),
        ),
        GoRoute(
          path: '/profile/edit',
          name: 'profile-edit',
          builder: (context, state) {
            final user = state.extra as User;
            return EditProfileScreen(initialUser: user);
          },
        ),
        GoRoute(
          path: '/profile/badges',
          name: 'profile-badges-catalog',
          builder: (context, state) => const BadgesCatalogScreen(),
        ),
        GoRoute(
          path: '/leaderboard',
          name: 'leaderboard',
          builder: (context, state) => const LeaderboardScreen(),
        ),
        GoRoute(
          path: '/professional/sites',
          name: 'professional-sites',
          builder: (context, state) => const ProfessionalSitesScreen(),
        ),
        GoRoute(
          path: '/professional/sites/new',
          name: 'professional-site-create',
          builder: (context, state) => const CreateSiteScreen(),
        ),
        GoRoute(
          path: '/professional/sites/:id/edit',
          name: 'professional-site-edit',
          builder: (context, state) {
            final site = state.extra as ProfessionalSite?;
            return CreateSiteScreen(initialSite: site);
          },
        ),
        GoRoute(
          path: '/professional/sites/:id',
          name: 'professional-site-detail',
          builder: (context, state) {
            final siteId = state.pathParameters['id']!;
            return ProfessionalSiteDetailScreen(siteId: siteId);
          },
        ),
        GoRoute(
          path: '/sites',
          name: 'sites',
          builder: (context, state) => const SitesListScreen(),
        ),
        GoRoute(
          path: '/sites/:id',
          name: 'site-detail',
          builder: (context, state) {
            final siteId = state.pathParameters['id'];
            return SiteDetailScreen(siteId: siteId);
          },
        ),
        GoRoute(
          path: '/site/:id',
          name: 'site-detail-alt',
          builder: (context, state) {
            final siteId = state.pathParameters['id'];
            return SiteDetailScreen(siteId: siteId);
          },
        ),
        GoRoute(
          path: '/checkin/:id',
          name: 'checkin',
          builder: (context, state) {
            final siteId = state.pathParameters['id'];
            return CheckinScreen(siteId: siteId);
          },
        ),
        GoRoute(
          path: '/review/:id',
          name: 'add-review',
          builder: (context, state) {
            final siteId = state.pathParameters['id'];
            return AddReviewScreen(siteId: siteId);
          },
        ),
        GoRoute(
          path: '/debug',
          name: 'debug',
          builder: (context, state) => const DebugHomeScreen(),
        ),
      ],
    );
  }
}
