import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'core/storage/storage_service.dart';
import 'features/auth/presentation/auth_provider.dart';
import 'features/map/presentation/map_provider.dart';
import 'features/sites/presentation/sites_provider.dart';

final AuthProvider appAuthProvider = AuthProvider();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageService().init();
  runApp(MoroccoCheckApp(authProvider: appAuthProvider));
}

class MoroccoCheckApp extends StatelessWidget {
  final AuthProvider authProvider;

  const MoroccoCheckApp({super.key, required this.authProvider});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
        ChangeNotifierProvider(create: (_) => MapProvider()),
        ChangeNotifierProvider(create: (_) => SitesProvider()),
      ],
      child: MaterialApp.router(
        title: 'MoroccoCheck',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        routerConfig: AppRouter.createRouter(authProvider),
      ),
    );
  }
}
