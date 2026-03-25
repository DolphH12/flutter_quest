import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/home/presentation/home_overview_screen.dart';
import '../features/home/presentation/route_completion_screen.dart';
import '../features/home/presentation/route_detail_screen.dart';
import '../features/home/presentation/lesson_route_screen.dart';
import '../features/lesson_flow/presentation/lesson_flow_screen.dart';
import '../features/profile/presentation/profile_screen.dart';
import 'quest_shell.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

final appRouterProvider = Provider<GoRouter>((ref) {
  final homeBranchKey = GlobalKey<NavigatorState>(debugLabel: 'homeBranch');
  final profileBranchKey = GlobalKey<NavigatorState>(
    debugLabel: 'profileBranch',
  );

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/home',
    routes: [
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
            navigatorKey: profileBranchKey,
            routes: [
              GoRoute(
                path: '/profile',
                name: 'profile',
                pageBuilder: (context, state) => _noTransitionPage(
                  state: state,
                  child: ProfileScreen(onAfterReset: () => context.go('/home')),
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
