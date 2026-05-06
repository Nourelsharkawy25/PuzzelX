import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';
import 'services/firestore_service.dart';
import 'providers/settings_provider.dart';
import 'providers/auth_provider.dart';
import 'services/auth_service.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Try to initialize Firebase. If it fails (e.g. no config file), fallback to Mock services.
  bool useFirebase = false;
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    useFirebase = true;
  } catch (e) {
    debugPrint('Firebase initialization failed, falling back to mock services: $e');
  }

  // Setup services
  if (useFirebase) {
    FirestoreService.instance = RealFirestoreService();
  } else {
    FirestoreService.instance = MockFirestoreService();
  }

  runApp(
    ProviderScope(
      overrides: [
        if (!useFirebase) authServiceProvider.overrideWithValue(MockAuthService())
        else authServiceProvider.overrideWithValue(FirebaseAuthService())
      ],
      child: const PuzzelXApp(),
    ),
  );
}

class PuzzelXApp extends ConsumerWidget {
  const PuzzelXApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final settings = ref.watch(settingsProvider);

    return MaterialApp.router(
      title: 'Puzzel X Puzzel',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: settings.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
