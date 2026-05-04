import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/auth_provider.dart';
import '../screens/login_screen.dart';
import '../screens/signup_screen.dart';
import '../screens/home_screen.dart';
import '../screens/game_board_screen.dart';
import '../screens/ai_solve_result_screen.dart';
import '../screens/solution_path_screen.dart';
import '../screens/leaderboard_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/help_screen.dart';
import '../ai/puzzle_solver.dart'; // Needed for passing result payload if using state

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
      (dynamic _) => notifyListeners(),
    );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final authStream = ref.watch(authServiceProvider).authStateChanges;

  return GoRouter(
    initialLocation: '/home',
    refreshListenable: GoRouterRefreshStream(authStream),
    redirect: (context, state) {
      final authService = ref.read(authServiceProvider);
      final isAuth = authService.currentUser != null;
      final isLoggingIn = state.matchedLocation == '/login' || state.matchedLocation == '/signup';

      if (!isAuth && !isLoggingIn) return '/login';
      if (isAuth && isLoggingIn) return '/home';
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/game',
        builder: (context, state) => const GameBoardScreen(),
      ),
      GoRoute(
        path: '/ai_solve',
        builder: (context, state) => const AiSolveResultScreen(),
      ),
      GoRoute(
        path: '/solution',
        builder: (context, state) {
          final result = state.extra as SolverResult;
          return SolutionPathScreen(result: result);
        },
      ),
      GoRoute(
        path: '/leaderboard',
        builder: (context, state) => const LeaderboardScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/help',
        builder: (context, state) => const HelpScreen(),
      ),
    ],
  );
});
