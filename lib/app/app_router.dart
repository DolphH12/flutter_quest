import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/home/presentation/home_overview_screen.dart';
import '../features/home/presentation/route_completion_screen.dart';
import '../features/home/presentation/route_detail_screen.dart';
import '../features/home/presentation/lesson_route_screen.dart';
import '../features/daily_challenge/models/daily_challenge_models.dart';
import '../features/daily_challenge/presentation/daily_challenge_attempt_screen.dart';
import '../features/daily_challenge/presentation/daily_challenge_screen.dart';
import '../features/onboarding/presentation/onboarding_screen.dart';
import '../features/profile/presentation/profile_screen.dart';
import '../features/lesson_flow/presentation/lesson_flow_screen.dart'
    show RouteCompletionResultData;
import 'quest_shell.dart';
import 'startup_screen.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

final appRouterProvider = Provider<GoRouter>((ref) {
  final homeBranchKey = GlobalKey<NavigatorState>(debugLabel: 'homeBranch');
  final challengesBranchKey = GlobalKey<NavigatorState>(
    debugLabel: 'challengesBranch',
  );
  final profileBranchKey = GlobalKey<NavigatorState>(
    debugLabel: 'profileBranch',
  );

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/startup',
    routes: [
      GoRoute(
        path: '/startup',
        name: 'startup',
        pageBuilder: (context, state) =>
            _noTransitionPage(state: state, child: const StartupScreen()),
      ),
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        pageBuilder: (context, state) =>
            _noTransitionPage(state: state, child: const OnboardingScreen()),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return QuestShell(
            navigationShell: navigationShell,
            location: state.uri.toString(),
          );
        },
        branches: [
          StatefulShellBranch(
            navigatorKey: homeBranchKey,
            routes: [
              GoRoute(
                path: '/home',
                name: 'home',
                pageBuilder: (context, state) => _noTransitionPage(
                  state: state,
                  child: const HomeOverviewScreen(),
                ),
                routes: [
                  GoRoute(
                    path: 'route/:routeId',
                    name: 'route-detail',
                    pageBuilder: (context, state) {
                      final routeId = state.pathParameters['routeId']!;
                      final focusNodeId = state.uri.queryParameters['focus'];
                      return _noTransitionPage(
                        state: state,
                        child: RouteDetailScreen(
                          routeId: routeId,
                          focusNodeId: focusNodeId,
                        ),
                      );
                    },
                    routes: [
                      GoRoute(
                        path: 'lesson/:nodeId',
                        name: 'lesson',
                        pageBuilder: (context, state) {
                          return _noTransitionPage(
                            state: state,
                            child: LessonRouteScreen(
                              routeId: state.pathParameters['routeId']!,
                              nodeId: state.pathParameters['nodeId']!,
                            ),
                          );
                        },
                      ),
                      GoRoute(
                        path: 'completed',
                        name: 'route-completed',
                        pageBuilder: (context, state) {
                          final routeId = state.pathParameters['routeId']!;
                          final data = state.extra is RouteCompletionResultData
                              ? state.extra as RouteCompletionResultData
                              : null;
                          return _noTransitionPage(
                            state: state,
                            child: RouteCompletionScreen(
                              data:
                                  data ??
                                  RouteCompletionResultData(
                                    routeId: routeId,
                                    routeTitle: 'Ruta completada',
                                    xpEarned: 0,
                                    correctCount: 0,
                                    totalAnswers: 0,
                                    unlockedBadgeIds: const [],
                                  ),
                              onGoHome: () => context.go('/home'),
                              onContinueLearning: () =>
                                  context.go('/home/route/$routeId'),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: challengesBranchKey,
            routes: [
              GoRoute(
                path: '/challenges',
                name: 'challenges',
                pageBuilder: (context, state) => _noTransitionPage(
                  state: state,
                  child: const DailyChallengeScreen(),
                ),
                routes: [
                  GoRoute(
                    path: 'play',
                    name: 'daily-challenge-play',
                    pageBuilder: (context, state) {
                      final publishDateKey = state.uri.queryParameters['date'];
                      final initialChallenge =
                          state.extra is DailyChallengeQuestion
                          ? state.extra as DailyChallengeQuestion
                          : null;
                      return _noTransitionPage(
                        state: state,
                        child: DailyChallengeAttemptScreen(
                          publishDateKey: publishDateKey,
                          initialChallenge: initialChallenge,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: profileBranchKey,
            routes: [
              GoRoute(
                path: '/profile',
                name: 'profile',
                pageBuilder: (context, state) => _noTransitionPage(
                  state: state,
                  child: ProfileScreen(
                    onAfterReset: () => context.go('/onboarding'),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});

Page<void> _noTransitionPage({
  required GoRouterState state,
  required Widget child,
}) {
  return NoTransitionPage<void>(key: state.pageKey, child: child);
}
