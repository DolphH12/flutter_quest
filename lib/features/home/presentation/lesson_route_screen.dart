import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/fq_page_container.dart';
import '../../learning/data/route_progress_mapper.dart';
import '../../learning/models/learning_models.dart';
import '../../learning/state/app_state_providers.dart';
import '../../lesson_flow/presentation/lesson_flow_screen.dart';

class LessonRouteScreen extends ConsumerWidget {
  const LessonRouteScreen({
    super.key,
    required this.routeId,
    required this.nodeId,
  });

  final String routeId;
  final String nodeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final route = ref.watch(routeByIdProvider(routeId));
    final progress = ref.watch(appProgressNotifierProvider).valueOrNull;
    if (route == null || progress == null) {
      return const FQPageContainer(
        child: Center(child: CircularProgressIndicator()),
      );
    }

    LearningNodeContent? node;
    for (final item in route.nodes) {
      if (item.id == nodeId) {
        node = item;
        break;
      }
    }
    if (node == null) {
      return FQPageContainer(
        child: Center(
          child: FilledButton(
            onPressed: () => context.go('/home/route/$routeId'),
            child: const Text('Volver a la ruta'),
          ),
        ),
      );
    }

    final nodeStates = RouteProgressMapper.toNodeUiStates(
      route: route,
      progress: progress,
    );
    NodeUiState? nodeState;
    for (final item in nodeStates) {
      if (item.node.id == nodeId) {
        nodeState = item;
        break;
      }
    }
    if (nodeState == null || nodeState.status == NodeStatus.locked) {
      return FQPageContainer(
        child: Center(
          child: FilledButton(
            onPressed: () => context.go('/home/route/$routeId'),
            child: const Text('Nodo bloqueado · Volver'),
          ),
        ),
      );
    }

    final lesson = LessonContent(
      id: '${route.routeId}:${node.id}',
      routeId: route.routeId,
      nodeId: node.id,
      nodeTitle: node.title,
      introTitle: node.title,
      introBody: node.shortDescription,
      introExample: null,
      activities: node.steps,
      isExam: node.isExam,
    );

    return FQPageContainer(
      child: LessonFlowScreen(
        lesson: lesson,
        onBack: () => context.go('/home/route/$routeId?focus=$nodeId'),
        onRouteCompleted: (data) {
          context.go('/home/route/$routeId/completed', extra: data);
        },
      ),
    );
  }
}
