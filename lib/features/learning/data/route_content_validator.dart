import '../models/learning_models.dart';
import 'dart:core';

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
    final orderedNodeIds = <String>[];
    for (final node in route.nodes) {
      orderedNodeIds.add(node.id);
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
        _validateStep(step: step, nodeId: node.id);
      }
      if (duplicatedStepIds.isNotEmpty) {
        throw FormatException(
          'node ${node.id} has duplicate activity ids: ${duplicatedStepIds.join(', ')}',
        );
      }
    }

    final nodeIndex = <String, int>{
      for (int i = 0; i < orderedNodeIds.length; i++) orderedNodeIds[i]: i,
    };
    for (final node in route.nodes) {
      for (final step in node.steps) {
        final prerequisites = step.prerequisites ?? const <String>[];
        for (final requiredNodeId in prerequisites) {
          final requiredIndex = nodeIndex[requiredNodeId];
          if (requiredIndex == null) {
            throw FormatException(
              'step ${step.id} references unknown prerequisite node $requiredNodeId',
            );
          }
          if (requiredIndex >= (nodeIndex[node.id] ?? 0)) {
            throw FormatException(
              'step ${step.id} has prerequisite $requiredNodeId that is not before node ${node.id}',
            );
          }
        }
      }
    }
  }

  static void _validateStep({
    required LessonStep step,
    required String nodeId,
  }) {
    if (step.requiresValidation && step.xpReward <= 0) {
      throw FormatException('step ${step.id} in node $nodeId must have xpReward > 0');
    }

    if (step.validationMode == ValidationMode.multiAnswer &&
        (step.acceptedAnswers == null || step.acceptedAnswers!.isEmpty)) {
      throw FormatException(
        'step ${step.id} uses validationMode multiAnswer but has no acceptedAnswers',
      );
    }
    if (step.validationMode == ValidationMode.containsTokens &&
        (step.requiredTokens == null || step.requiredTokens!.isEmpty)) {
      throw FormatException(
        'step ${step.id} uses validationMode containsTokens but has no requiredTokens',
      );
    }
    if (step.validationMode == ValidationMode.regex &&
        (step.acceptedAnswers == null || step.acceptedAnswers!.isEmpty)) {
      throw FormatException(
        'step ${step.id} uses validationMode regex but has no acceptedAnswers patterns',
      );
    }
    if (step.validationMode == ValidationMode.regex) {
      for (final pattern in step.acceptedAnswers ?? const <String>[]) {
        try {
          RegExp(pattern);
        } catch (_) {
          throw FormatException(
            'step ${step.id} contains invalid regex pattern: $pattern',
          );
        }
      }
    }

    if ((step.namingPolicy ?? '').trim() == 'fixed') {
      final hasExpectation =
          (step.expectedAnswer ?? '').trim().isNotEmpty ||
          (step.acceptedAnswers ?? const <String>[]).isNotEmpty ||
          (step.requiredTokens ?? const <String>[]).isNotEmpty;
      if (!hasExpectation) {
        throw FormatException(
          'step ${step.id} has namingPolicy fixed but no explicit expected naming fields',
        );
      }
    }
  }
}
