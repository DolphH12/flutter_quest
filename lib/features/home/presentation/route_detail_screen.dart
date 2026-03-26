import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/responsive/breakpoints.dart';
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
import 'home_overview_screen.dart';

class RouteDetailScreen extends ConsumerWidget {
  const RouteDetailScreen({super.key, required this.routeId, this.focusNodeId});

  final String routeId;
  final String? focusNodeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final route = ref.watch(routeByIdProvider(routeId));
    final progress = ref.watch(appProgressNotifierProvider).valueOrNull;
    final unlockRequirements = ref.watch(routeUnlockRequirementsProvider);
    if (route == null || progress == null) {
      return const FQPageContainer(
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final requirement = unlockRequirements[route.routeId];
    if (requirement != null &&
        !progress.completedRouteIds.contains(requirement)) {
      return FQPageContainer(
        child: Center(
          child: FQSurfaceCard(
            radius: FQRadius.large,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Ruta bloqueada',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: FQColors.deepNavy,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Completa $requirement para desbloquear esta ruta.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () => context.go('/home'),
                  child: const Text('Volver al Home'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final nodeStates = RouteProgressMapper.toNodeUiStates(
      route: route,
      progress: progress,
    );
    final fallbackFocused = nodeStates
        .firstWhere(
          (item) => item.status == NodeStatus.active,
          orElse: () => nodeStates.first,
        )
        .node
        .id;

    final focused = focusNodeId ?? fallbackFocused;

    return FQPageContainer(
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => context.go('/home'),
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
              focusedNodeId: focused,
              onNodeTap: (nodeState) {
                if (nodeState.status == NodeStatus.locked) return;
                context.go('/home/route/$routeId/lesson/${nodeState.node.id}');
              },
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
  double _viewportMainAxis = 0;

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
    final isDesktop = FQBreakpoints.isDesktop(context);
    final focusedIndex = widget.nodeStates.indexWhere(
      (state) => state.node.id == widget.focusedNodeId,
    );
    if (focusedIndex < 0) return;
    final estimatedItemExtent = isDesktop ? 220.0 : 178.0;
    final estimatedCenter = focusedIndex * estimatedItemExtent;
    final target = estimatedCenter - (_viewportMainAxis / 2) + 90;
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
    final isDesktop = FQBreakpoints.isDesktop(context);
    return FQSurfaceCard(
      radius: FQRadius.xLarge,
      gradient: const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFF0F4FF), Color(0xFFE8EEFF)],
      ),
      padding: const EdgeInsets.fromLTRB(8, 50, 8, 50),
      child: LayoutBuilder(
        builder: (context, constraints) {
          _viewportMainAxis = isDesktop
              ? constraints.maxWidth
              : constraints.maxHeight;
          if (isDesktop) {
            final trackHeight = constraints.maxHeight;
            return Center(
              child: SizedBox(
                height: trackHeight / 2,
                width: constraints.maxWidth,
                child: SingleChildScrollView(
                  controller: _scrollController,
                  scrollDirection: Axis.horizontal,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minWidth: constraints.maxWidth),
                    child: Align(
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(width: 18),
                          for (int i = 0; i < widget.nodeStates.length; i++)
                            _PathStepHorizontal(
                              nodeState: widget.nodeStates[i],
                              visualOffsetY:
                                  widget.nodeStates[i].node.xOffset == 0
                                  ? ((i % 4 == 0)
                                        ? 6
                                        : (i % 4 == 1)
                                        ? 64
                                        : (i % 4 == 2)
                                        ? 12
                                        : 64)
                                  : (widget.nodeStates[i].node.xOffset * 0.2) +
                                        18,
                              isExam:
                                  widget.nodeStates[i].node.id ==
                                  widget.examNodeId,
                              isExamPassed: widget.nodeStates[i].isExamPassed,
                              isFocused:
                                  widget.nodeStates[i].node.id ==
                                  widget.focusedNodeId,
                              hasConnector: i != widget.nodeStates.length - 1,
                              onTap: () =>
                                  widget.onNodeTap(widget.nodeStates[i]),
                            ),
                          const SizedBox(width: 22),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          }
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

class _PathStepHorizontal extends StatelessWidget {
  const _PathStepHorizontal({
    required this.nodeState,
    required this.visualOffsetY,
    required this.isExam,
    required this.isExamPassed,
    required this.isFocused,
    required this.hasConnector,
    required this.onTap,
  });

  final NodeUiState nodeState;
  final double visualOffsetY;
  final bool isExam;
  final bool isExamPassed;
  final bool isFocused;
  final bool hasConnector;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: Offset(0, visualOffsetY),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 168,
            child: _PathStep(
              nodeState: nodeState,
              visualOffset: 0,
              isExam: isExam,
              isExamPassed: isExamPassed,
              isFocused: isFocused,
              hasConnector: false,
              onTap: onTap,
            ),
          ),
          if (hasConnector)
            Padding(
              padding: const EdgeInsets.only(top: 50),
              child: Container(
                width: 58,
                height: 8,
                decoration: BoxDecoration(
                  color: FQColors.primary.withValues(alpha: 0.18),
                  borderRadius: FQRadius.pill,
                ),
              ),
            ),
        ],
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
                    iconFromName(node.icon),
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
