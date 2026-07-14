import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sportin_clone/l10n/app_localizations.dart';

import '../features/admin/presentation/admin_users_screen.dart';
import '../features/auth/application/auth_providers.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/auth/presentation/reset_password_screen.dart';
import '../features/auth/presentation/signup_screen.dart';
import '../features/auth/presentation/splash_screen.dart';
import '../features/booking/presentation/my_bookings_screen.dart';
import '../features/booking/presentation/trainer_sessions_screen.dart';
import '../features/chat/presentation/chat_screen.dart';
import '../features/chat/presentation/group_chat_screen.dart';
import '../features/chat/presentation/one_on_one_chat_screen.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/measurements/presentation/client_measurements_screen.dart';
import '../features/measurements/presentation/measurements_screen.dart';
import '../features/measurements/presentation/my_clients_screen.dart';
import '../features/profile/presentation/profile_screen.dart';
import '../features/scheduling/presentation/availability_editor_screen.dart';
import '../features/scheduling/presentation/studio_closed_days_screen.dart';
import '../features/packages/presentation/my_package_screen.dart';
import '../features/packages/presentation/package_types_screen.dart';
import '../features/scheduling/domain/booking.dart';
import '../features/scheduling/presentation/trainer_slots_screen.dart';
import '../features/group_classes/presentation/group_classes_screen.dart';
import '../features/group_classes/presentation/trainer_group_classes_screen.dart';
import '../features/trainers/presentation/trainer_directory_screen.dart';
import '../features/trainers/presentation/trainer_edit_screen.dart';
import '../features/trainers/presentation/trainer_profile_screen.dart';

const _authRoutes = {'/login', '/signup', '/reset'};

/// Kinetik slide-fade page transition for pushed (non-tab) screens.
/// Mirrors the `kineticRoute` logic from kinetic_effects.dart.
CustomTransitionPage<void> _kineticPage(LocalKey key, Widget child) {
  return CustomTransitionPage<void>(
    key: key,
    child: child,
    transitionDuration: const Duration(milliseconds: 420),
    reverseTransitionDuration: const Duration(milliseconds: 300),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.08, 0),
            end: Offset.zero,
          ).animate(curved),
          child: child,
        ),
      );
    },
  );
}

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
              builder: (context, state) => const TrainerDirectoryScreen(),
              routes: [
                GoRoute(
                  path: 'group-classes',
                  pageBuilder: (context, state) => _kineticPage(
                    state.pageKey,
                    const GroupClassesScreen(),
                  ),
                ),
                GoRoute(
                  path: 'trainer/:uid',
                  pageBuilder: (context, state) => _kineticPage(
                    state.pageKey,
                    TrainerProfileScreen(uid: state.pathParameters['uid']!),
                  ),
                  routes: [
                    GoRoute(
                      path: 'slots',
                      pageBuilder: (context, state) => _kineticPage(
                        state.pageKey,
                        TrainerSlotsScreen(
                          trainerUid: state.pathParameters['uid']!,
                          rescheduling: state.extra as Booking?,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
                path: '/measurements',
                builder: (context, state) => const MeasurementsScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/chat',
              builder: (context, state) => const ChatScreen(),
              routes: [
                GoRoute(
                  path: 'thread/:trainerUid/:clientUid',
                  pageBuilder: (context, state) => _kineticPage(
                    state.pageKey,
                    OneOnOneChatScreen(
                      trainerUid: state.pathParameters['trainerUid']!,
                      clientUid: state.pathParameters['clientUid']!,
                    ),
                  ),
                ),
                GoRoute(
                  path: 'group/:classId',
                  pageBuilder: (context, state) => _kineticPage(
                    state.pageKey,
                    GroupChatScreen(
                      classId: state.pathParameters['classId']!,
                    ),
                  ),
                ),
              ],
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/profile',
              builder: (context, state) => const ProfileScreen(),
              routes: [
                GoRoute(
                  path: 'admin-users',
                  pageBuilder: (context, state) => _kineticPage(
                    state.pageKey,
                    const AdminUsersScreen(),
                  ),
                ),
                GoRoute(
                  path: 'trainer-edit',
                  pageBuilder: (context, state) => _kineticPage(
                    state.pageKey,
                    const TrainerEditScreen(),
                  ),
                ),
                GoRoute(
                  path: 'availability',
                  pageBuilder: (context, state) => _kineticPage(
                    state.pageKey,
                    const AvailabilityEditorScreen(),
                  ),
                ),
                GoRoute(
                  path: 'studio',
                  pageBuilder: (context, state) => _kineticPage(
                    state.pageKey,
                    const StudioClosedDaysScreen(),
                  ),
                ),
                GoRoute(
                  path: 'bookings',
                  pageBuilder: (context, state) => _kineticPage(
                    state.pageKey,
                    const MyBookingsScreen(),
                  ),
                ),
                GoRoute(
                  path: 'sessions',
                  pageBuilder: (context, state) => _kineticPage(
                    state.pageKey,
                    const TrainerSessionsScreen(),
                  ),
                ),
                GoRoute(
                  path: 'package',
                  pageBuilder: (context, state) => _kineticPage(
                    state.pageKey,
                    const MyPackageScreen(),
                  ),
                ),
                GoRoute(
                  path: 'package-types',
                  pageBuilder: (context, state) => _kineticPage(
                    state.pageKey,
                    const PackageTypesScreen(),
                  ),
                ),
                GoRoute(
                  path: 'group-classes',
                  pageBuilder: (context, state) => _kineticPage(
                    state.pageKey,
                    const TrainerGroupClassesScreen(),
                  ),
                ),
                GoRoute(
                  path: 'clients',
                  pageBuilder: (context, state) => _kineticPage(
                    state.pageKey,
                    const MyClientsScreen(),
                  ),
                  routes: [
                    GoRoute(
                      path: ':clientUid',
                      pageBuilder: (context, state) => _kineticPage(
                        state.pageKey,
                        ClientMeasurementsScreen(
                          clientUid: state.pathParameters['clientUid']!,
                          clientDisplayName: state.extra as String?,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
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
