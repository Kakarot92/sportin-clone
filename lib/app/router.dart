import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sportin_clone/l10n/app_localizations.dart';

import '../features/auth/application/auth_providers.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/auth/presentation/reset_password_screen.dart';
import '../features/auth/presentation/signup_screen.dart';
import '../features/auth/presentation/splash_screen.dart';
import '../features/chat/presentation/chat_screen.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/measurements/presentation/measurements_screen.dart';
import '../features/profile/presentation/profile_screen.dart';
import '../features/schedule/presentation/schedule_screen.dart';

const _authRoutes = {'/login', '/signup', '/reset'};

final routerProvider = Provider<GoRouter>((ref) {
  // Bump this whenever auth state changes so go_router re-evaluates redirects.
  final refresh = ValueNotifier<int>(0);
  ref.listen(authStateChangesProvider, (_, _) => refresh.value++);

  final router = GoRouter(
    initialLocation: '/home',
    refreshListenable: refresh,
    redirect: (context, state) {
      final authAsync = ref.read(authStateChangesProvider);
      final loc = state.matchedLocation;

      // Still resolving the initial auth state: show the splash.
      if (authAsync.isLoading && !authAsync.hasValue) {
        return loc == '/splash' ? null : '/splash';
      }

      final loggedIn = authAsync.asData?.value != null;
      if (!loggedIn) {
        return _authRoutes.contains(loc) ? null : '/login';
      }
      // Logged in: keep them out of the auth/splash routes.
      if (loc == '/splash' || _authRoutes.contains(loc)) return '/home';
      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (context, state) => const SplashScreen()),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/signup', builder: (context, state) => const SignupScreen()),
      GoRoute(
          path: '/reset',
          builder: (context, state) => const ResetPasswordScreen()),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
                path: '/schedule',
                builder: (context, state) => const ScheduleScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
                path: '/measurements',
                builder: (context, state) => const MeasurementsScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/chat', builder: (context, state) => const ChatScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfileScreen()),
          ]),
        ],
      ),
    ],
  );

  ref.onDispose(refresh.dispose);
  ref.onDispose(router.dispose);
  return router;
});

/// Root scaffold hosting the bottom navigation across the five top-level tabs.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home),
            label: l10n.navHome,
          ),
          NavigationDestination(
            icon: const Icon(Icons.calendar_month_outlined),
            selectedIcon: const Icon(Icons.calendar_month),
            label: l10n.navSchedule,
          ),
          NavigationDestination(
            icon: const Icon(Icons.monitor_weight_outlined),
            selectedIcon: const Icon(Icons.monitor_weight),
            label: l10n.navMeasurements,
          ),
          NavigationDestination(
            icon: const Icon(Icons.chat_bubble_outline),
            selectedIcon: const Icon(Icons.chat_bubble),
            label: l10n.navChat,
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_outline),
            selectedIcon: const Icon(Icons.person),
            label: l10n.navProfile,
          ),
        ],
      ),
    );
  }
}
