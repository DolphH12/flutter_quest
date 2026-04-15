import '../models/learning_models.dart';

abstract final class RouteContentValidator {
  static void validate(DartRouteContent route) {
    if (route.nodes.isEmpty) {
      throw const FormatException('route requires at least one node');
    }

    final routeNodeIds = <String>{};
    final duplicatedNodeIds = <String>{};
    for (final node in route.nodes) {
      if (!routeNodeIds.add(node.id)) {
        duplicatedNodeIds.add(node.id);
      }
    }
    if (duplicatedNodeIds.isNotEmpty) {
      throw FormatException(
        'duplicate node ids: ${duplicatedNodeIds.join(', ')}',
      );
    }

    final examNodes = route.nodes.where((item) => item.id == route.examNodeId);
    if (examNodes.isEmpty) {
      throw FormatException(
        'examNodeId ${route.examNodeId} does not exist in nodes',
      );
    }
    final examNode = examNodes.first;
    if (examNode.nodeType != 'exam') {
      throw FormatException(
        'examNodeId ${route.examNodeId} must reference a nodeType "exam"',
      );
    }

    final globalStepIds = <String>{};
    for (final node in route.nodes) {
      if (node.nodeType != 'lesson' && node.nodeType != 'exam') {
        throw FormatException(
          'node ${node.id} has invalid nodeType ${node.nodeType}',
        );
      }
      if (node.steps.isEmpty) {
        throw FormatException('node ${node.id} has no steps');
      }
      final duplicatedStepIds = <String>{};
      final localStepIds = <String>{};
      for (final step in node.steps) {
        if (step.type == ActivityType.unknown) {
          throw FormatException(
            'node ${node.id} has unknown activity type in ${step.id}',
          );
        }
        if (!localStepIds.add(step.id)) {
          duplicatedStepIds.add(step.id);
        }
        if (!globalStepIds.add(step.id)) {
          throw FormatException(
            'duplicate activity id across route: ${step.id}',
          );
        }
      }
      if (duplicatedStepIds.isNotEmpty) {
        throw FormatException(
          'node ${node.id} has duplicate activity ids: ${duplicatedStepIds.join(', ')}',
        );
      }
    }
  }
}
