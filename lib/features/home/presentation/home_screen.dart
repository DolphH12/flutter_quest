import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/fq_colors.dart';
import '../../../core/theme/fq_gradients.dart';
import '../../../core/theme/fq_tokens.dart';
import '../../../core/widgets/fq_chips.dart';
import '../../../core/widgets/fq_page_container.dart';
import '../../../core/widgets/fq_progress_bar.dart';
import '../../../core/widgets/fq_surface_card.dart';
import '../../learning/data/route_progress_mapper.dart';
import '../../learning/models/learning_models.dart';
import '../../learning/state/app_state_providers.dart';
import '../../lesson_flow/presentation/lesson_flow_screen.dart';
import 'route_completion_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key, this.onRouteViewChanged});

  final ValueChanged<bool>? onRouteViewChanged;

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _inRouteDetail = false;
  LessonContent? _activeLesson;
  RouteCompletionResultData? _routeCompletionData;
  String? _focusedNodeId;
  String? _selectedRouteId;

  @override
  void initState() {
    super.initState();
    widget.onRouteViewChanged?.call(false);
  }

  @override
  Widget build(BuildContext context) {
    final routesAsync = ref.watch(allRoutesProvider);
    final progressAsync = ref.watch(appProgressNotifierProvider);
    final unlockRequirements = ref.watch(routeUnlockRequirementsProvider);
    final routeLoadErrors = ref.watch(routeLoadErrorsProvider);

    if (routesAsync.isLoading || progressAsync.isLoading) {
      return const FQPageContainer(
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (routesAsync.hasError || progressAsync.hasError) {
      return FQPageContainer(
        child: Center(
          child: Text(
            'No se pudo cargar el contenido de las rutas.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    final routes = routesAsync.value;
    final progress = progressAsync.value;
    if (routes == null || routes.isEmpty || progress == null) {
      return FQPageContainer(
        child: Center(
          child: Text(
            routeLoadErrors.isEmpty
                ? 'No se pudo cargar el contenido de rutas.'
                : _buildLoadErrorMessage(routeLoadErrors),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (_routeCompletionData != null) {
      return RouteCompletionScreen(
        data: _routeCompletionData!,
        onGoHome: () {
          setState(() {
            _routeCompletionData = null;
            _activeLesson = null;
            _inRouteDetail = false;
          });
          widget.onRouteViewChanged?.call(false);
        },
        onContinueLearning: () {
          setState(() {
            _routeCompletionData = null;
            _activeLesson = null;
          });
        },
      );
    }

    if (_activeLesson != null) {
      return FQPageContainer(
        child: LessonFlowScreen(
          lesson: _activeLesson!,
          onBack: () {
            setState(() {
              _activeLesson = null;
              _routeCompletionData = null;
              _inRouteDetail = true;
            });
            widget.onRouteViewChanged?.call(true);
          },
          onRouteCompleted: (data) {
            setState(() {
              _activeLesson = null;
              _routeCompletionData = data;
            });
          },
        ),
      );
    }

    if (!_inRouteDetail) {
      return _RouteOverview(
        routes: routes,
        progress: progress,
        unlockRequirements: unlockRequirements,
        routeLoadErrors: routeLoadErrors,
        onOpenRoute: (route) => _openRouteDetail(route.routeId),
      );
    }

    final selectedRoute = _findSelectedRoute(routes);
    if (selectedRoute == null ||
        !_isRouteUnlocked(selectedRoute, progress, unlockRequirements)) {
      return _RouteOverview(
        routes: routes,
        progress: progress,
        unlockRequirements: unlockRequirements,
        routeLoadErrors: routeLoadErrors,
        onOpenRoute: (route) => _openRouteDetail(route.routeId),
      );
    }

    final nodeStates = RouteProgressMapper.toNodeUiStates(
      route: selectedRoute,
      progress: progress,
    );
    final focused =
        _focusedNodeId ??
        nodeStates
            .firstWhere(
              (item) => item.status == NodeStatus.active,
              orElse: () => nodeStates.first,
            )
            .node
            .id;

    return _RouteDetail(
      route: selectedRoute,
      progress: progress,
      nodeStates: nodeStates,
      focusedNodeId: focused,
      onBack: _closeRouteDetail,
      onNodeTap: (uiNode) => _openNodeLesson(selectedRoute, uiNode),
    );
  }

  DartRouteContent? _findSelectedRoute(List<DartRouteContent> routes) {
    if (_selectedRouteId != null) {
      for (final route in routes) {
        if (route.routeId == _selectedRouteId) return route;
      }
    }
    for (final route in routes) {
      if (route.routeId == 'dart_route') return route;
    }
    return routes.first;
  }

  bool _isRouteUnlocked(
    DartRouteContent route,
    LearningProgressState progress,
    Map<String, String?> unlockRequirements,
  ) {
    final requirement = unlockRequirements[route.routeId];
    if (requirement == null) return true;
    return progress.completedRouteIds.contains(requirement);
  }

  void _openRouteDetail(String routeId) {
    setState(() {
      _selectedRouteId = routeId;
      _inRouteDetail = true;
    });
    widget.onRouteViewChanged?.call(true);
  }

  void _closeRouteDetail() {
    setState(() {
      _inRouteDetail = false;
      _activeLesson = null;
      _routeCompletionData = null;
      _focusedNodeId = null;
    });
    widget.onRouteViewChanged?.call(false);
  }

  void _openNodeLesson(DartRouteContent route, NodeUiState uiNode) {
    if (uiNode.status == NodeStatus.locked) return;
    _focusedNodeId = uiNode.node.id;

    final lesson = LessonContent(
      id: '${route.routeId}:${uiNode.node.id}',
      routeId: route.routeId,
      nodeId: uiNode.node.id,
      nodeTitle: uiNode.node.title,
      introTitle: uiNode.node.title,
      introBody: uiNode.node.shortDescription,
      introExample: null,
      activities: uiNode.node.steps,
      isExam: uiNode.node.isExam,
    );

    setState(() {
      _activeLesson = lesson;
    });
  }

  String _buildLoadErrorMessage(Map<String, String> errors) {
    final lines = <String>['No se pudieron cargar algunas rutas:'];
    errors.forEach((routeId, message) {
      lines.add('- $routeId: $message');
    });
    return lines.join('\n');
  }
}

class _RouteOverview extends StatelessWidget {
  const _RouteOverview({
    required this.routes,
    required this.progress,
    required this.unlockRequirements,
    required this.routeLoadErrors,
    required this.onOpenRoute,
  });

  final List<DartRouteContent> routes;
  final LearningProgressState progress;
  final Map<String, String?> unlockRequirements;
  final Map<String, String> routeLoadErrors;
  final ValueChanged<DartRouteContent> onOpenRoute;

  @override
  Widget build(BuildContext context) {
    return FQPageContainer(
      child: ListView(
        children: [
          _OverviewHeader(progress: progress),
          const SizedBox(height: 14),
          Text(
            'Rutas disponibles',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(color: FQColors.deepNavy),
          ),
          const SizedBox(height: 10),
          if (routeLoadErrors.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _RouteLoadWarning(errors: routeLoadErrors),
            ),
          for (final route in routes)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _RouteCardTile(
                route: route,
                progress: progress,
                isUnlocked: _isUnlocked(route),
                lockReason: _lockReason(route, routes),
                onTap: () => onOpenRoute(route),
              ),
            ),
        ],
      ),
    );
  }

  bool _isUnlocked(DartRouteContent route) {
    final requirement = unlockRequirements[route.routeId];
    if (requirement == null) return true;
    return progress.completedRouteIds.contains(requirement);
  }

  String? _lockReason(DartRouteContent route, List<DartRouteContent> routes) {
    final requirement = unlockRequirements[route.routeId];
    if (requirement == null) return null;
    if (progress.completedRouteIds.contains(requirement)) return null;
    for (final item in routes) {
      if (item.routeId == requirement) {
        return 'Completa ${item.title} para desbloquear';
      }
    }
    return 'Completa la ruta requerida para desbloquear';
  }
}

class _RouteLoadWarning extends StatelessWidget {
  const _RouteLoadWarning({required this.errors});

  final Map<String, String> errors;

  @override
  Widget build(BuildContext context) {
    return FQSurfaceCard(
      radius: FQRadius.large,
      color: const Color(0xFFFFF4E0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Algunas rutas no cargaron',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: const Color(0xFF755700),
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          for (final entry in errors.entries)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                '${entry.key}: ${entry.value}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: const Color(0xFF755700),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _RouteCardTile extends StatelessWidget {
  const _RouteCardTile({
    required this.route,
    required this.progress,
    required this.isUnlocked,
    required this.lockReason,
    required this.onTap,
  });

  final DartRouteContent route;
  final LearningProgressState progress;
  final bool isUnlocked;
  final String? lockReason;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final progressValue = progress.routeProgress(route.routeId);
    final cardBody = FQSurfaceCard(
      radius: FQRadius.large,
      gradient: isUnlocked ? FQGradients.subtlePanel : null,
      color: isUnlocked ? null : FQColors.surfaceHigh.withValues(alpha: 0.56),
      border: Border.all(
        color: _routeBorderColor(
          progress: progress,
          routeId: route.routeId,
          isUnlocked: isUnlocked,
        ),
        width: _routeBorderWidth(
          progress: progress,
          routeId: route.routeId,
          isUnlocked: isUnlocked,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              borderRadius: FQRadius.medium,
              gradient: isUnlocked
                  ? FQGradients.heroBlue
                  : const LinearGradient(
                      colors: [Color(0xFFC8D2EB), Color(0xFFB8C5E6)],
                    ),
            ),
            child: Icon(
              _iconFromName(route.icon),
              color: isUnlocked ? Colors.white : FQColors.outlineVariant,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        route.title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: isUnlocked
                              ? FQColors.deepNavy
                              : FQColors.onSurface.withValues(alpha: 0.66),
                        ),
                      ),
                    ),
                    if (!isUnlocked)
                      const Icon(
                        Icons.lock_rounded,
                        size: 18,
                        color: FQColors.outlineVariant,
                      ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  route.description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: FQColors.onSurface.withValues(alpha: 0.72),
                  ),
                ),
                if (lockReason != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    lockReason!,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: FQColors.tertiaryDark,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
                if (progressValue > 0) ...[
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Text(
                        'Progress',
                        style: Theme.of(context).textTheme.labelMedium
                            ?.copyWith(
                              color: FQColors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const Spacer(),
                      Text(
                        '${(progressValue * 100).toInt()}%',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: FQColors.primary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  FQProgressBar(value: progressValue),
                ],
              ],
            ),
          ),
        ],
      ),
    );

    if (!isUnlocked) return cardBody;
    return InkWell(borderRadius: FQRadius.large, onTap: onTap, child: cardBody);
  }
}

class _OverviewHeader extends StatelessWidget {
  const _OverviewHeader({required this.progress});

  final LearningProgressState progress;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Flutter Quest',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
            fontSize: 36,
            color: FQColors.primary,
            height: 1.0,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Elige una ruta y sigue avanzando',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: FQColors.onSurface.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            FQStatChip(
              icon: Icons.auto_awesome_rounded,
              label: 'XP',
              value: '${progress.totalXp}',
              accent: FQColors.primary,
            ),
            const SizedBox(width: 8),
            FQStatChip(
              icon: Icons.local_fire_department_rounded,
              label: 'Streak',
              value: '${progress.currentStreak}',
              accent: FQColors.tertiaryDark,
            ),
          ],
        ),
      ],
    );
  }
}

Color _routeBorderColor({
  required LearningProgressState progress,
  required String routeId,
  required bool isUnlocked,
}) {
  if (!isUnlocked) return Colors.transparent;
  if (progress.completedRouteIds.contains(routeId)) {
    return const Color(0xFF34A853);
  }
  if (progress.routeProgress(routeId) > 0) {
    return FQColors.tertiary;
  }
  return Colors.transparent;
}

double _routeBorderWidth({
  required LearningProgressState progress,
  required String routeId,
  required bool isUnlocked,
}) {
  if (!isUnlocked) return 0;
  if (progress.completedRouteIds.contains(routeId)) return 2.2;
  if (progress.routeProgress(routeId) > 0) return 2.2;
  return 0;
}

class _RouteDetail extends StatelessWidget {
  const _RouteDetail({
    required this.route,
    required this.progress,
    required this.nodeStates,
    required this.focusedNodeId,
    required this.onBack,
    required this.onNodeTap,
  });

  final DartRouteContent route;
  final LearningProgressState progress;
  final List<NodeUiState> nodeStates;
  final String focusedNodeId;
  final VoidCallback onBack;
  final ValueChanged<NodeUiState> onNodeTap;

  @override
  Widget build(BuildContext context) {
    return FQPageContainer(
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: onBack,
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
              ),
              Expanded(
                child: Text(
                  route.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontSize: 36,
                    color: FQColors.deepNavy,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              FQPill(
                label: progress.completedNodeIds.contains(route.examNodeId)
                    ? 'Exam passed'
                    : (progress.unlockedExamIds.contains(route.examNodeId)
                          ? 'Exam unlocked'
                          : 'Exam locked'),
                icon: Icons.military_tech_rounded,
                color: progress.completedNodeIds.contains(route.examNodeId)
                    ? const Color(0xFFDFF7E8)
                    : (progress.unlockedExamIds.contains(route.examNodeId)
                          ? FQColors.tertiary.withValues(alpha: 0.32)
                          : FQColors.surfaceHigh.withValues(alpha: 0.84)),
                textColor: progress.completedNodeIds.contains(route.examNodeId)
                    ? const Color(0xFF1D8D4A)
                    : (progress.unlockedExamIds.contains(route.examNodeId)
                          ? FQColors.tertiaryDark
                          : FQColors.onSurface),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _CurrentPathCard(progress: progress.routeProgress(route.routeId)),
          const SizedBox(height: 12),
          Expanded(
            child: _PathBoard(
              nodeStates: nodeStates,
              examNodeId: route.examNodeId,
              focusedNodeId: focusedNodeId,
              onNodeTap: onNodeTap,
            ),
          ),
        ],
      ),
    );
  }
}

class _CurrentPathCard extends StatelessWidget {
  const _CurrentPathCard({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    return FQSurfaceCard(
      radius: FQRadius.large,
      gradient: FQGradients.subtlePanel,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'COMPLETION',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: FQColors.primary,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                ),
              ),
              const Spacer(),
              Text(
                '${(progress * 100).toInt()}%',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: FQColors.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          FQProgressBar(value: progress),
        ],
      ),
    );
  }
}

class _PathBoard extends StatefulWidget {
  const _PathBoard({
    required this.nodeStates,
    required this.examNodeId,
    required this.focusedNodeId,
    required this.onNodeTap,
  });

  final List<NodeUiState> nodeStates;
  final String examNodeId;
  final String focusedNodeId;
  final ValueChanged<NodeUiState> onNodeTap;

  @override
  State<_PathBoard> createState() => _PathBoardState();
}

class _PathBoardState extends State<_PathBoard> {
  final ScrollController _scrollController = ScrollController();
  double _viewportHeight = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToFocused());
  }

  @override
  void didUpdateWidget(covariant _PathBoard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.focusedNodeId != widget.focusedNodeId ||
        oldWidget.nodeStates.length != widget.nodeStates.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToFocused());
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToFocused() {
    if (!_scrollController.hasClients) return;
    final focusedIndex = widget.nodeStates.indexWhere(
      (state) => state.node.id == widget.focusedNodeId,
    );
    if (focusedIndex < 0) return;

    const estimatedItemHeight = 178.0;
    final estimatedCenter = focusedIndex * estimatedItemHeight;
    final target = estimatedCenter - (_viewportHeight / 2) + 70;
    final clamped = target.clamp(
      _scrollController.position.minScrollExtent,
      _scrollController.position.maxScrollExtent,
    );
    _scrollController.animateTo(
      clamped,
      duration: const Duration(milliseconds: 360),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FQSurfaceCard(
      radius: FQRadius.xLarge,
      gradient: const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFF0F4FF), Color(0xFFE8EEFF)],
      ),
      padding: const EdgeInsets.fromLTRB(8, 20, 8, 22),
      child: LayoutBuilder(
        builder: (context, constraints) {
          _viewportHeight = constraints.maxHeight;
          return SingleChildScrollView(
            controller: _scrollController,
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 270),
                child: Column(
                  children: [
                    for (int i = 0; i < widget.nodeStates.length; i++)
                      _PathStep(
                        nodeState: widget.nodeStates[i],
                        visualOffset: widget.nodeStates[i].node.xOffset == 0
                            ? ((i % 4 == 0)
                                  ? -34
                                  : (i % 4 == 1)
                                  ? 30
                                  : (i % 4 == 2)
                                  ? -20
                                  : 24)
                            : widget.nodeStates[i].node.xOffset,
                        isExam:
                            widget.nodeStates[i].node.id == widget.examNodeId,
                        isExamPassed: widget.nodeStates[i].isExamPassed,
                        isFocused:
                            widget.nodeStates[i].node.id ==
                            widget.focusedNodeId,
                        hasConnector: i != widget.nodeStates.length - 1,
                        onTap: () => widget.onNodeTap(widget.nodeStates[i]),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _PathStep extends StatelessWidget {
  const _PathStep({
    required this.nodeState,
    required this.visualOffset,
    required this.isExam,
    required this.isExamPassed,
    required this.isFocused,
    required this.hasConnector,
    required this.onTap,
  });

  final NodeUiState nodeState;
  final double visualOffset;
  final bool isExam;
  final bool isExamPassed;
  final bool isFocused;
  final bool hasConnector;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final node = nodeState.node;
    final status = nodeState.status;
    final isActive = status == NodeStatus.active;
    final isLocked = status == NodeStatus.locked;
    final isEnabled = !isLocked;

    final nodeSize = isExam ? 100.0 : (isActive ? 96.0 : 82.0);
    final outerColor = switch (status) {
      NodeStatus.completed =>
        isExamPassed
            ? const Color(0xFF14503B)
            : (isExam ? const Color(0xFF8A6700) : const Color(0xFF015892)),
      NodeStatus.active =>
        isExam ? const Color(0xFF8A6700) : const Color(0xFF8A6700),
      NodeStatus.locked => const Color(0xFFCACDD4),
    };
    final innerColor = switch (status) {
      NodeStatus.completed =>
        isExamPassed
            ? const Color(0xFF2F9D74)
            : (isExam ? const Color(0xFFF6C400) : const Color(0xFF56B2FF)),
      NodeStatus.active =>
        isExam ? const Color(0xFFF6C400) : const Color(0xFFF6C400),
      NodeStatus.locked => const Color(0xFFD8DBE1),
    };

    return Transform.translate(
      offset: Offset(visualOffset, 0),
      child: Column(
        children: [
          InkWell(
            onTap: isEnabled ? onTap : null,
            borderRadius: BorderRadius.circular(999),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              width: nodeSize,
              height: nodeSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: outerColor,
                boxShadow: [
                  ...FQShadows.soft,
                  if (isActive)
                    BoxShadow(
                      color: FQColors.tertiary.withValues(alpha: 0.55),
                      blurRadius: 28,
                      spreadRadius: 2,
                    ),
                  if (isFocused && isEnabled)
                    BoxShadow(
                      color: FQColors.primaryBright.withValues(alpha: 0.32),
                      blurRadius: 0,
                      spreadRadius: 5,
                    ),
                ],
              ),
              child: Center(
                child: Container(
                  width: nodeSize - 10,
                  height: nodeSize - 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: innerColor,
                    border: Border.all(
                      color: Colors.black.withValues(alpha: 0.12),
                      width: 1.4,
                    ),
                  ),
                  child: Icon(
                    _iconFromName(node.icon),
                    size: isExam ? 36 : (isActive ? 38 : 32),
                    color: isLocked
                        ? FQColors.outlineVariant
                        : (isActive ? const Color(0xFF312200) : Colors.white),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          _StepLabel(node: node, status: status, isExam: isExam),
          if (hasConnector) ...[
            const SizedBox(height: 9),
            Container(
              width: 8,
              height: 54,
              decoration: BoxDecoration(
                color: FQColors.primary.withValues(alpha: 0.18),
                borderRadius: FQRadius.pill,
              ),
            ),
            const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}

class _StepLabel extends StatelessWidget {
  const _StepLabel({
    required this.node,
    required this.status,
    required this.isExam,
  });

  final LearningNodeContent node;
  final NodeStatus status;
  final bool isExam;

  @override
  Widget build(BuildContext context) {
    final isCompleted = status == NodeStatus.completed;
    final isActive = status == NodeStatus.active;
    final isLocked = status == NodeStatus.locked;

    if (isLocked) {
      return Text(
        node.title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: FQColors.onSurface.withValues(alpha: 0.46),
          fontWeight: FontWeight.w600,
        ),
      );
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        color: isExam
            ? const Color(0xFF11385F)
            : (isActive ? const Color(0xFF152D63) : Colors.white),
        borderRadius: FQRadius.pill,
        boxShadow: FQShadows.soft,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        child: Text(
          isActive ? node.title.toUpperCase() : node.title,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: (isActive || isExam)
                ? Colors.white
                : (isCompleted ? FQColors.primary : FQColors.onSurface),
            fontWeight: FontWeight.w800,
            letterSpacing: isActive ? 0.4 : 0,
          ),
        ),
      ),
    );
  }
}

IconData _iconFromName(String value) {
  return switch (value) {
    'rocket_launch' => Icons.rocket_launch_rounded,
    'data_object' => Icons.data_object_rounded,
    'alt_route' => Icons.alt_route_rounded,
    'loop' => Icons.loop_rounded,
    'functions' => Icons.functions_rounded,
    'view_list' => Icons.view_list_rounded,
    'verified_user' => Icons.verified_user_rounded,
    'category' => Icons.category_rounded,
    'bolt' => Icons.bolt_rounded,
    'bug_report' => Icons.bug_report_rounded,
    'military_tech' => Icons.military_tech_rounded,
    'route_dart' => Icons.route_rounded,
    'flutter_dash' => Icons.flutter_dash_rounded,
    'folder_copy' => Icons.folder_copy_rounded,
    'play_circle' => Icons.play_circle_fill_rounded,
    'web_asset' => Icons.web_asset_rounded,
    'view_column' => Icons.view_column_rounded,
    'crop_square' => Icons.crop_square_rounded,
    'smart_button' => Icons.smart_button_rounded,
    'format_list_bulleted' => Icons.format_list_bulleted_rounded,
    'navigation' => Icons.navigation_rounded,
    'dashboard_customize' => Icons.dashboard_customize_rounded,
    'workspace_premium' => Icons.workspace_premium_rounded,
    'flutter' => Icons.flutter_dash_rounded,
    _ => Icons.circle_rounded,
  };
}
