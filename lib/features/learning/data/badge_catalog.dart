import 'package:flutter/material.dart';

class BadgeDefinition {
  const BadgeDefinition({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
  });

  final String id;
  final String title;
  final String description;
  final IconData icon;
}

abstract final class BadgeCatalog {
  static const firstNodeCompleted = BadgeDefinition(
    id: 'first_node_completed',
    title: 'First Step',
    description: 'Completaste tu primer nodo.',
    icon: Icons.flag_rounded,
  );

  static const threeLessonsCompleted = BadgeDefinition(
    id: 'three_lessons_completed',
    title: 'Momentum x3',
    description: 'Completaste tres lecciones.',
    icon: Icons.whatshot_rounded,
  );

  static const firstExamPassed = BadgeDefinition(
    id: 'first_exam_passed',
    title: 'Exam Crusher',
    description: 'Aprobaste tu primer examen final.',
    icon: Icons.military_tech_rounded,
  );

  static const dartRouteCompleted = BadgeDefinition(
    id: 'dart_route_completed',
    title: 'Dart Explorer',
    description: 'Terminaste la ruta completa de Dart.',
    icon: Icons.rocket_launch_rounded,
  );

  static const bugHunter = BadgeDefinition(
    id: 'bug_hunter',
    title: 'Bug Hunter',
    description: 'Completaste la lección de manejo de errores.',
    icon: Icons.bug_report_rounded,
  );

  static const nullSafetySurvivor = BadgeDefinition(
    id: 'null_safety_survivor',
    title: 'Null Safety Survivor',
    description: 'Superaste la lección de Null Safety.',
    icon: Icons.verified_user_rounded,
  );

  static const all = <BadgeDefinition>[
    firstNodeCompleted,
    threeLessonsCompleted,
    firstExamPassed,
    dartRouteCompleted,
    bugHunter,
    nullSafetySurvivor,
  ];

  static BadgeDefinition? byId(String id) {
    for (final item in all) {
      if (item.id == id) return item;
    }
    return null;
  }
}
