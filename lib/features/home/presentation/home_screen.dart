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

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key, this.onRouteViewChanged});

  final ValueChanged<bool>? onRouteViewChanged;

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _inRouteDetail = false;
  LessonContent? _activeLesson;
  String? _focusedNodeId;

  @override
  void initState() {
    super.initState();
    widget.onRouteViewChanged?.call(false);
  }

  @override
  Widget build(BuildContext context) {
    final routeAsync = ref.watch(routeContentProvider);
    final progressAsync = ref.watch(appProgressNotifierProvider);

    if (routeAsync.isLoading || progressAsync.isLoading) {
      return const FQPageContainer(
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (routeAsync.hasError || progressAsync.hasError) {
      return FQPageContainer(
        child: Center(
          child: Text(
            'No se pudo cargar el contenido de Dart.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    final route = routeAsync.value;
    final progress = progressAsync.value;
    if (route == null || progress == null) {
      return const FQPageContainer(
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_activeLesson != null) {
      return FQPageContainer(
        child: LessonFlowScreen(
          lesson: _activeLesson!,
          onBack: () {
            setState(() {
              _activeLesson = null;
            });
          },
        ),
      );
    }

    if (!_inRouteDetail) {
      return _RouteOverview(
        route: route,
        progress: progress,
        onOpen: _openRouteDetail,
      );
    }

    final nodeStates = RouteProgressMapper.toNodeUiStates(
      route: route,
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
      route: route,
      progress: progress,
      nodeStates: nodeStates,
      focusedNodeId: focused,
      onBack: _closeRouteDetail,
      onNodeTap: (uiNode) => _openNodeLesson(route, uiNode),
    );
  }

  void _openRouteDetail() {
    setState(() {
      _inRouteDetail = true;
    });
    widget.onRouteViewChanged?.call(true);
  }

  void _closeRouteDetail() {
    setState(() {
      _inRouteDetail = false;
      _activeLesson = null;
      _focusedNodeId = null;
    });
    widget.onRouteViewChanged?.call(false);
  }

  void _openNodeLesson(DartRouteContent route, NodeUiState uiNode) {
    if (uiNode.status == NodeStatus.locked) return;
    _focusedNodeId = uiNode.node.id;

    final introSteps = uiNode.node.steps
        .where((step) => step.type == LessonStepType.intro)
        .toList();
    final activitySteps = uiNode.node.steps
        .where((step) => step.type != LessonStepType.intro)
        .toList();
    final introBody = introSteps
        .map((step) => step.body ?? '')
        .where((text) => text.isNotEmpty)
        .join('\n\n');
    final introExamples = introSteps
        .map((step) => step.example)
        .whereType<String>()
        .toList();
    final introExample = introExamples.isEmpty ? null : introExamples.first;

    final lesson = LessonContent(
      id: '${route.routeId}:${uiNode.node.id}',
      routeId: route.routeId,
      nodeId: uiNode.node.id,
      nodeTitle: uiNode.node.title,
      introTitle: introSteps.isNotEmpty && introSteps.first.title != null
          ? introSteps.first.title!
          : uiNode.node.title,
      introBody: introBody.isEmpty ? uiNode.node.shortDescription : introBody,
      introExample: introExample,
      activities: activitySteps,
      isExam: uiNode.node.isExam,
    );

    setState(() {
      _activeLesson = lesson;
    });
  }
}

class _RouteOverview extends StatelessWidget {
  const _RouteOverview({
    required this.route,
    required this.progress,
    required this.onOpen,
  });

  final DartRouteContent route;
  final LearningProgressState progress;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return FQPageContainer(
      child: ListView(
        children: [
          _OverviewHeader(progress: progress),
          const SizedBox(height: 14),
          Text(
            'Ruta disponible',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(color: FQColors.deepNavy),
          ),
          const SizedBox(height: 10),
          InkWell(
            borderRadius: FQRadius.large,
            onTap: onOpen,
            child: FQSurfaceCard(
              radius: FQRadius.large,
              gradient: FQGradients.subtlePanel,
              border: Border.all(
                color: _routeBorderColor(
                  progress: progress,
                  routeId: route.routeId,
                ),
                width: _routeBorderWidth(
                  progress: progress,
                  routeId: route.routeId,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      borderRadius: FQRadius.medium,
                      gradient: FQGradients.heroBlue,
                    ),
                    child: const Icon(Icons.route_rounded, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          route.title,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          route.description,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: FQColors.onSurface.withValues(
                                  alpha: 0.72,
                                ),
                              ),
                        ),
                        if (progress.routeProgress(route.routeId) > 0) ...[
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
                                '${(progress.routeProgress(route.routeId) * 100).toInt()}%',
                                style: Theme.of(context).textTheme.labelLarge
                                    ?.copyWith(
                                      color: FQColors.primary,
                                      fontWeight: FontWeight.w800,
                                    ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          FQProgressBar(
                            value: progress.routeProgress(route.routeId),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
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
          'Ruta Dart activa',
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
}) {
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
}) {
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
          _CurrentPathCard(progress: progress.routeCompletion),
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

class _PathBoard extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return FQSurfaceCard(
      radius: FQRadius.xLarge,
      gradient: const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFF0F4FF), Color(0xFFE8EEFF)],
      ),
      padding: const EdgeInsets.fromLTRB(8, 20, 8, 22),
      child: SingleChildScrollView(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 270),
            child: Column(
              children: [
                for (int i = 0; i < nodeStates.length; i++)
                  _PathStep(
                    nodeState: nodeStates[i],
                    visualOffset: nodeStates[i].node.xOffset == 0
                        ? ((i % 4 == 0)
                              ? -34
                              : (i % 4 == 1)
                              ? 30
                              : (i % 4 == 2)
                              ? -20
                              : 24)
                        : nodeStates[i].node.xOffset,
                    isExam: nodeStates[i].node.id == examNodeId,
                    isExamPassed: nodeStates[i].isExamPassed,
                    isFocused: nodeStates[i].node.id == focusedNodeId,
                    hasConnector: i != nodeStates.length - 1,
                    onTap: () => onNodeTap(nodeStates[i]),
                  ),
              ],
            ),
          ),
        ),
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
    _ => Icons.circle_rounded,
  };
}
