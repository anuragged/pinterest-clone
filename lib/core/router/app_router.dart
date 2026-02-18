import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/dimensions.dart';
import '../../presentation/screens/main_screen.dart';
import '../../presentation/screens/home/home_screen.dart';
import '../../presentation/screens/search/search_screen.dart';
import '../../presentation/screens/create/create_screen.dart';
import '../../presentation/screens/notifications/notifications_screen.dart';
import '../../presentation/screens/profile/profile_screen.dart';
import '../../presentation/screens/profile/user_profile_detail_screen.dart';
import '../../presentation/screens/pin_detail/pin_detail_screen.dart';
import '../../presentation/screens/board_detail/board_detail_screen.dart';
import '../../presentation/screens/refine/refine_recommendations_screen.dart';
import '../../presentation/screens/onboarding/welcome_screen.dart';
import '../../presentation/screens/onboarding/signup_screen.dart';
import '../../presentation/screens/search/today_inspiration_screen.dart';
import '../../presentation/screens/notifications/chat_screen.dart';

/// Go Router configuration.
/// Feed is root route. Pin detail is a sub-route.
/// StatefulShellRoute preserves each tab's state independently.
/// Custom transitions use easeOutCubic — no default Flutter transitions.
final GoRouter appRouter = GoRouter(
  initialLocation: '/welcome',
  routes: [
    // ── Welcome / Onboarding ──
    GoRoute(
      path: '/welcome',
      pageBuilder: (context, state) => const CustomTransitionPage(
        child: WelcomeScreen(),
        transitionsBuilder: _fadeOutTransition,
      ),
    ),
    GoRoute(
      path: '/signup',
      pageBuilder: (context, state) => const CustomTransitionPage(
        child: SignUpScreen(),
        transitionsBuilder: _slideUpTransition,
      ),
    ),
    // ── Settings ──
    GoRoute(
      path: '/settings',
      pageBuilder: (context, state) => const CustomTransitionPage(
        child: ProfileScreen(),
        transitionsBuilder: _slideUpTransition,
      ),
    ),
    // ── Refine Recommendations ──
    GoRoute(
      path: '/refine-recommendations',
      pageBuilder: (context, state) => const CustomTransitionPage(
        child: RefineRecommendationsScreen(),
        transitionsBuilder: _slideUpTransition,
      ),
    ),
    // ── Shell route with bottom nav ──
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return MainScreen(navigationShell: navigationShell);
      },
      branches: [
        // Home feed
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/',
              pageBuilder: (context, state) => const NoTransitionPage(
                child: HomeScreen(),
              ),
            ),
          ],
        ),

        // Search
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/search',
              pageBuilder: (context, state) => const NoTransitionPage(
                child: SearchScreen(),
              ),
            ),
          ],
        ),

        // Create
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/create',
              pageBuilder: (context, state) => const NoTransitionPage(
                child: CreateScreen(),
              ),
            ),
          ],
        ),

        // Notifications
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/notifications',
              pageBuilder: (context, state) => const NoTransitionPage(
                child: NotificationsScreen(),
              ),
            ),
          ],
        ),

        // Profile
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/profile',
              pageBuilder: (context, state) => const NoTransitionPage(
                child: ProfileScreen(),
              ),
            ),
          ],
        ),
      ],
    ),

    // ── Pin detail (outside shell — full page) ──
    GoRoute(
      path: '/pin/:id',
      pageBuilder: (context, state) {
        final pinId = state.pathParameters['id']!;
        return CustomTransitionPage(
          key: state.pageKey,
          child: PinDetailScreen(pinId: pinId),
          transitionDuration: const Duration(
              milliseconds: PinDimensions.animDurationHero),
          reverseTransitionDuration: const Duration(
              milliseconds: PinDimensions.animDurationHero),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final curvedAnimation = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
              reverseCurve: Curves.easeInCubic,
            );
            return FadeTransition(
              opacity: curvedAnimation,
              child: child,
            );
          },
        );
      },
    ),

    // ── Board detail ──
    GoRoute(
      path: '/board/:id',
      pageBuilder: (context, state) {
        final boardId = state.pathParameters['id']!;
        return CustomTransitionPage(
          key: state.pageKey,
          child: BoardDetailScreen(boardId: boardId),
          transitionDuration: const Duration(
              milliseconds: PinDimensions.animDurationNormal),
          reverseTransitionDuration: const Duration(
              milliseconds: PinDimensions.animDurationNormal),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final curvedAnimation = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
              reverseCurve: Curves.easeInCubic,
            );
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1, 0),
                end: Offset.zero,
              ).animate(curvedAnimation),
              child: child,
            );
          },
        );
      },
    ),

    // ── Today's Inspiration Detail ──
    GoRoute(
      path: '/today-inspiration',
      pageBuilder: (context, state) => const CustomTransitionPage(
        child: TodayInspirationScreen(),
        transitionsBuilder: _slideUpTransition,
      ),
    ),
    
    // ── Chat Screen ──
    GoRoute(
      path: '/chat/:id',
      pageBuilder: (context, state) {
        final chatId = state.pathParameters['id']!;
        return CustomTransitionPage(
          child: ChatScreen(chatId: chatId),
          transitionsBuilder: _slideUpTransition,
        );
      },
    ),
    // ── User Profile Detail (Boards & Pins) ──
    GoRoute(
      path: '/profile/details',
      pageBuilder: (context, state) => const CustomTransitionPage(
        child: UserProfileDetailScreen(),
        transitionsBuilder: _slideUpTransition,
      ),
    ),
  ],
);

Widget _slideUpTransition(BuildContext context, Animation<double> animation,
    Animation<double> secondaryAnimation, Widget child) {
  return SlideTransition(
    position: Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
    child: child,
  );
}

Widget _fadeOutTransition(BuildContext context, Animation<double> animation,
    Animation<double> secondaryAnimation, Widget child) {
  return FadeTransition(opacity: animation, child: child);
}
