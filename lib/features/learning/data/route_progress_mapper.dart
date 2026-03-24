import '../models/learning_models.dart';

class NodeUiState {
  const NodeUiState({
    required this.node,
    required this.status,
    required this.isExamUnlocked,
    required this.isExamPassed,
  });

  final LearningNodeContent node;
  final NodeStatus status;
  final bool isExamUnlocked;
  final bool isExamPassed;
}

abstract final class RouteProgressMapper {
  static List<NodeUiState> toNodeUiStates({
    required DartRouteContent route,
    required LearningProgressState progress,
  }) {
    final completed = progress.completedNodeIds;
    final activeNodeId =
        progress.activeNodeId ??
        nextActiveNodeId(route: route, completedNodeIds: completed);

    return route.nodes.asMap().entries.map((entry) {
      final index = entry.key;
      final node = entry.value;
      final isCompleted = progress.completedNodeIds.contains(node.id);
      if (isCompleted) {
        return NodeUiState(
          node: node,
          status: NodeStatus.completed,
          isExamUnlocked: true,
          isExamPassed: node.isExam,
        );
      }
      final unlocked = isNodeUnlocked(
        route: route,
        completedNodeIds: completed,
        nodeIndex: index,
      );
      if (node.id == activeNodeId && unlocked) {
        return NodeUiState(
          node: node,
          status: NodeStatus.active,
          isExamUnlocked: unlocked && node.isExam,
          isExamPassed: false,
        );
      }
      return NodeUiState(
        node: node,
        status: NodeStatus.locked,
        isExamUnlocked: unlocked && node.isExam,
        isExamPassed: false,
      );
    }).toList();
  }

  static double routeCompletion({
    required DartRouteContent route,
    required Set<String> completedNodeIds,
  }) {
    if (route.nodes.isEmpty) return 0;
    final completedCount = route.nodes
        .where((node) => completedNodeIds.contains(node.id))
        .length;
    return completedCount / route.nodes.length;
  }

  static bool isNodeUnlocked({
    required DartRouteContent route,
    required Set<String> completedNodeIds,
    required int nodeIndex,
  }) {
    if (nodeIndex <= 0) return true;
    final node = route.nodes[nodeIndex];
    if (node.isExam) {
      final previousNodes = route.nodes.take(nodeIndex);
      return previousNodes.every((item) => completedNodeIds.contains(item.id));
    }
    final previous = route.nodes[nodeIndex - 1];
    return completedNodeIds.contains(previous.id);
  }

  static String? nextActiveNodeId({
    required DartRouteContent route,
    required Set<String> completedNodeIds,
  }) {
    for (var index = 0; index < route.nodes.length; index++) {
      final node = route.nodes[index];
      if (completedNodeIds.contains(node.id)) continue;
      final unlocked = isNodeUnlocked(
        route: route,
        completedNodeIds: completedNodeIds,
        nodeIndex: index,
      );
      if (unlocked) return node.id;
    }
    return null;
  }
}
