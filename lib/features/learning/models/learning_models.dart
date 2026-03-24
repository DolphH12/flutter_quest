import 'dart:convert';

enum NodeStatus { completed, active, locked }

enum LessonStepType {
  intro,
  multipleChoice,
  fillInTheCode,
  fixTheBug,
  completeSnippet,
  orderCodeBlocks,
  findTheWrongLine,
  matchConcept,
  predictOutput,
  guidedWriting,
  unknown,
}

String _asString(dynamic value, {String fallback = ''}) {
  if (value == null) return fallback;
  if (value is String) return value;
  return value.toString();
}

int _asInt(dynamic value, {int fallback = 0}) {
  if (value == null) return fallback;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? fallback;
  return fallback;
}

List<String>? _asStringList(dynamic value) {
  if (value is! List) return null;
  return value.map((item) => _asString(item)).toList();
}

List<int>? _asIntList(dynamic value) {
  if (value is! List) return null;
  return value.map((item) => _asInt(item)).toList();
}

Set<String> _asStringSet(dynamic value) {
  if (value is! List) return <String>{};
  return value.map((item) => _asString(item)).toSet();
}

Map<String, double> _asDoubleMap(dynamic value) {
  if (value is! Map) return <String, double>{};
  final map = <String, double>{};
  for (final entry in value.entries) {
    map[_asString(entry.key)] = (entry.value as num?)?.toDouble() ?? 0;
  }
  return map;
}

Map<String, String> _asStringMap(dynamic value) {
  if (value is! Map) return <String, String>{};
  final map = <String, String>{};
  for (final entry in value.entries) {
    map[_asString(entry.key)] = _asString(entry.value);
  }
  return map;
}

class DartRouteContent {
  const DartRouteContent({
    required this.routeId,
    required this.title,
    required this.description,
    required this.icon,
    required this.themeColorHex,
    required this.version,
    required this.estimatedMinutes,
    required this.examNodeId,
    required this.nodes,
  });

  final String routeId;
  final String title;
  final String description;
  final String icon;
  final String themeColorHex;
  final int version;
  final int estimatedMinutes;
  final String examNodeId;
  final List<LearningNodeContent> nodes;

  factory DartRouteContent.fromJson(Map<String, dynamic> json) {
    return DartRouteContent(
      routeId: _asString(json['routeId']),
      title: _asString(json['title']),
      description: _asString(json['description']),
      icon: _asString(json['icon']),
      themeColorHex: _asString(json['themeColor']),
      version: _asInt(json['version'], fallback: 1),
      estimatedMinutes: _asInt(json['estimatedMinutes']),
      examNodeId: _asString(json['examNodeId']),
      nodes: (json['nodes'] as List<dynamic>? ?? const [])
          .map(
            (item) =>
                LearningNodeContent.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'routeId': routeId,
      'title': title,
      'description': description,
      'icon': icon,
      'themeColor': themeColorHex,
      'version': version,
      'estimatedMinutes': estimatedMinutes,
      'examNodeId': examNodeId,
      'nodes': nodes.map((node) => node.toJson()).toList(),
    };
  }
}

class LearningNodeContent {
  const LearningNodeContent({
    required this.id,
    required this.title,
    required this.shortDescription,
    required this.icon,
    required this.nodeType,
    required this.xpReward,
    required this.steps,
    required this.xOffset,
  });

  final String id;
  final String title;
  final String shortDescription;
  final String icon;
  final String nodeType;
  final int xpReward;
  final List<LessonStep> steps;
  final double xOffset;

  bool get isExam => nodeType == 'exam';

  factory LearningNodeContent.fromJson(Map<String, dynamic> json) {
    return LearningNodeContent(
      id: _asString(json['id']),
      title: _asString(json['title']),
      shortDescription: _asString(json['shortDescription']),
      icon: _asString(json['icon'], fallback: 'circle'),
      nodeType: _asString(json['nodeType'], fallback: 'lesson'),
      xpReward: _asInt(json['xpReward']),
      steps: (json['steps'] as List<dynamic>? ?? const [])
          .map((item) => LessonStep.fromJson(item as Map<String, dynamic>))
          .toList(),
      xOffset: (json['xOffset'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'shortDescription': shortDescription,
      'icon': icon,
      'nodeType': nodeType,
      'xpReward': xpReward,
      'xOffset': xOffset,
      'steps': steps.map((step) => step.toJson()).toList(),
    };
  }
}

class LessonStep {
  const LessonStep({
    required this.id,
    required this.type,
    this.title,
    this.body,
    this.example,
    this.question,
    this.options,
    this.correctAnswer,
    this.correctExplanation,
    this.incorrectExplanation,
    this.prompt,
    this.initialCode,
    this.expectedAnswer,
    this.hint,
    this.xpReward = 0,
    this.blocks,
    this.correctOrder,
    this.codeLines,
    this.wrongLineIndex,
    this.matchLeft,
    this.matchRight,
    this.correctMatches,
    this.codeSnippet,
    this.expectedOutput,
    this.expectedFragments,
    this.instructions,
    this.starterCode,
  });

  final String id;
  final LessonStepType type;

  final String? title;
  final String? body;
  final String? example;

  final String? question;
  final List<String>? options;
  final String? correctAnswer;
  final String? correctExplanation;
  final String? incorrectExplanation;

  final String? prompt;
  final String? initialCode;
  final String? expectedAnswer;
  final String? hint;
  final List<String>? blocks;
  final List<int>? correctOrder;
  final List<String>? codeLines;
  final int? wrongLineIndex;
  final List<String>? matchLeft;
  final List<String>? matchRight;
  final Map<String, String>? correctMatches;
  final String? codeSnippet;
  final String? expectedOutput;
  final List<String>? expectedFragments;
  final String? instructions;
  final String? starterCode;

  final int xpReward;

  String? get codeTemplate => initialCode;

  bool get requiresValidation {
    return type == LessonStepType.multipleChoice ||
        type == LessonStepType.fillInTheCode ||
        type == LessonStepType.fixTheBug ||
        type == LessonStepType.completeSnippet ||
        type == LessonStepType.orderCodeBlocks ||
        type == LessonStepType.findTheWrongLine ||
        type == LessonStepType.matchConcept ||
        type == LessonStepType.predictOutput ||
        type == LessonStepType.guidedWriting;
  }

  factory LessonStep.fromJson(Map<String, dynamic> json) {
    return LessonStep(
      id: _asString(json['id']),
      type: _stepTypeFromString(_asString(json['type'])),
      title: json['title'] == null ? null : _asString(json['title']),
      body: json['body'] == null ? null : _asString(json['body']),
      example: json['example'] == null ? null : _asString(json['example']),
      question: json['question'] == null ? null : _asString(json['question']),
      options: _asStringList(json['options']),
      correctAnswer: json['correctAnswer'] == null
          ? null
          : _asString(json['correctAnswer']),
      correctExplanation: json['correctExplanation'] == null
          ? null
          : _asString(json['correctExplanation']),
      incorrectExplanation: json['incorrectExplanation'] == null
          ? null
          : _asString(json['incorrectExplanation']),
      prompt: json['prompt'] == null ? null : _asString(json['prompt']),
      initialCode: json['initialCode'] == null
          ? null
          : _asString(json['initialCode']),
      expectedAnswer: json['expectedAnswer'] == null
          ? null
          : _asString(json['expectedAnswer']),
      hint: json['hint'] == null ? null : _asString(json['hint']),
      xpReward: _asInt(json['xpReward']),
      blocks: _asStringList(json['blocks']),
      correctOrder: _asIntList(json['correctOrder']),
      codeLines: _asStringList(json['codeLines']),
      wrongLineIndex: json['wrongLineIndex'] == null
          ? null
          : _asInt(json['wrongLineIndex']),
      matchLeft: _asStringList(json['matchLeft']),
      matchRight: _asStringList(json['matchRight']),
      correctMatches: json['correctMatches'] is Map
          ? _asStringMap(json['correctMatches'])
          : null,
      codeSnippet: json['codeSnippet'] == null
          ? null
          : _asString(json['codeSnippet']),
      expectedOutput: json['expectedOutput'] == null
          ? null
          : _asString(json['expectedOutput']),
      expectedFragments: _asStringList(json['expectedFragments']),
      instructions: json['instructions'] == null
          ? null
          : _asString(json['instructions']),
      starterCode: json['starterCode'] == null
          ? null
          : _asString(json['starterCode']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'title': title,
      'body': body,
      'example': example,
      'question': question,
      'options': options,
      'correctAnswer': correctAnswer,
      'correctExplanation': correctExplanation,
      'incorrectExplanation': incorrectExplanation,
      'prompt': prompt,
      'initialCode': initialCode,
      'expectedAnswer': expectedAnswer,
      'hint': hint,
      'xpReward': xpReward,
      'blocks': blocks,
      'correctOrder': correctOrder,
      'codeLines': codeLines,
      'wrongLineIndex': wrongLineIndex,
      'matchLeft': matchLeft,
      'matchRight': matchRight,
      'correctMatches': correctMatches,
      'codeSnippet': codeSnippet,
      'expectedOutput': expectedOutput,
      'expectedFragments': expectedFragments,
      'instructions': instructions,
      'starterCode': starterCode,
    };
  }
}

LessonStepType _stepTypeFromString(String value) {
  return switch (value) {
    'intro' => LessonStepType.intro,
    'multipleChoice' => LessonStepType.multipleChoice,
    'fillInTheCode' => LessonStepType.fillInTheCode,
    'fixTheBug' => LessonStepType.fixTheBug,
    'completeSnippet' => LessonStepType.completeSnippet,
    'orderCodeBlocks' => LessonStepType.orderCodeBlocks,
    'findTheWrongLine' => LessonStepType.findTheWrongLine,
    'matchConcept' => LessonStepType.matchConcept,
    'predictOutput' => LessonStepType.predictOutput,
    'guidedWriting' => LessonStepType.guidedWriting,
    _ => LessonStepType.unknown,
  };
}

class LessonContent {
  const LessonContent({
    required this.id,
    required this.routeId,
    required this.nodeId,
    required this.nodeTitle,
    required this.introTitle,
    required this.introBody,
    required this.introExample,
    required this.activities,
    this.isExam = false,
  });

  final String id;
  final String routeId;
  final String nodeId;
  final String nodeTitle;
  final String introTitle;
  final String introBody;
  final String? introExample;
  final List<LessonStep> activities;
  final bool isExam;

  int get maxXp => activities.fold<int>(0, (sum, item) => sum + item.xpReward);
  double get passThreshold => isExam ? 0.8 : 0.7;
}

typedef LessonActivity = LessonStep;
typedef ActivityType = LessonStepType;

class LessonAttemptResult {
  const LessonAttemptResult({
    this.lessonId,
    required this.routeId,
    required this.nodeId,
    required this.correctAnswers,
    required this.totalAnswers,
    required this.xpEarned,
    required this.completedAt,
    required this.passed,
    required this.isExam,
    required this.requiredScore,
  });

  final String? lessonId;
  final String routeId;
  final String nodeId;
  final int correctAnswers;
  final int totalAnswers;
  final int xpEarned;
  final DateTime completedAt;
  final bool passed;
  final bool isExam;
  final double requiredScore;

  double get score => totalAnswers == 0 ? 0 : correctAnswers / totalAnswers;

  factory LessonAttemptResult.fromJson(Map<String, dynamic> json) {
    return LessonAttemptResult(
      lessonId: json['lessonId'] == null ? null : _asString(json['lessonId']),
      routeId: _asString(json['routeId']),
      nodeId: _asString(json['nodeId']),
      correctAnswers: _asInt(json['correctAnswers']),
      totalAnswers: _asInt(json['totalAnswers']),
      xpEarned: _asInt(json['xpEarned']),
      completedAt: DateTime.parse(_asString(json['completedAt'])),
      passed: json['passed'] as bool? ?? false,
      isExam: json['isExam'] as bool? ?? false,
      requiredScore: (json['requiredScore'] as num?)?.toDouble() ?? 0.7,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lessonId': lessonId,
      'routeId': routeId,
      'nodeId': nodeId,
      'correctAnswers': correctAnswers,
      'totalAnswers': totalAnswers,
      'xpEarned': xpEarned,
      'completedAt': completedAt.toIso8601String(),
      'passed': passed,
      'isExam': isExam,
      'requiredScore': requiredScore,
    };
  }
}

class LearningProgressState {
  const LearningProgressState({
    required this.completedNodeIds,
    required this.activeNodeId,
    required this.completedRouteIds,
    required this.unlockedExamIds,
    required this.routeProgressPercentById,
    required this.totalXp,
    required this.completedLessonsCount,
    required this.lastStudyDate,
    required this.currentStreak,
    required this.bestStreak,
    required this.unlockedBadgeIds,
    required this.badgeUnlockedAt,
    required this.userName,
    this.lastLessonResult,
  });

  final Set<String> completedNodeIds;
  final String? activeNodeId;
  final Set<String> completedRouteIds;
  final Set<String> unlockedExamIds;
  final Map<String, double> routeProgressPercentById;
  final int totalXp;
  final int completedLessonsCount;
  final String? lastStudyDate;
  final int currentStreak;
  final int bestStreak;
  final Set<String> unlockedBadgeIds;
  final Map<String, String> badgeUnlockedAt;
  final String? userName;
  final LessonAttemptResult? lastLessonResult;

  double routeProgress(String routeId) =>
      routeProgressPercentById[routeId] ?? 0;

  // Backward compatibility for current screens.
  double get routeCompletion => routeProgressPercentById['dart_route'] ?? 0;
  bool get examCompleted => completedNodeIds.contains('dart_final_exam');

  factory LearningProgressState.initial() {
    return const LearningProgressState(
      completedNodeIds: {},
      activeNodeId: null,
      completedRouteIds: {},
      unlockedExamIds: {},
      routeProgressPercentById: {'dart_route': 0},
      totalXp: 0,
      completedLessonsCount: 0,
      lastStudyDate: null,
      currentStreak: 0,
      bestStreak: 0,
      unlockedBadgeIds: {},
      badgeUnlockedAt: {},
      userName: null,
      lastLessonResult: null,
    );
  }

  LearningProgressState copyWith({
    Set<String>? completedNodeIds,
    String? activeNodeId,
    bool clearActiveNodeId = false,
    Set<String>? completedRouteIds,
    Set<String>? unlockedExamIds,
    Map<String, double>? routeProgressPercentById,
    int? totalXp,
    int? completedLessonsCount,
    String? lastStudyDate,
    bool clearLastStudyDate = false,
    int? currentStreak,
    int? bestStreak,
    Set<String>? unlockedBadgeIds,
    Map<String, String>? badgeUnlockedAt,
    String? userName,
    bool clearUserName = false,
    LessonAttemptResult? lastLessonResult,
    bool clearLastLessonResult = false,
  }) {
    return LearningProgressState(
      completedNodeIds: completedNodeIds ?? this.completedNodeIds,
      activeNodeId: clearActiveNodeId
          ? null
          : (activeNodeId ?? this.activeNodeId),
      completedRouteIds: completedRouteIds ?? this.completedRouteIds,
      unlockedExamIds: unlockedExamIds ?? this.unlockedExamIds,
      routeProgressPercentById:
          routeProgressPercentById ?? this.routeProgressPercentById,
      totalXp: totalXp ?? this.totalXp,
      completedLessonsCount:
          completedLessonsCount ?? this.completedLessonsCount,
      lastStudyDate: clearLastStudyDate
          ? null
          : (lastStudyDate ?? this.lastStudyDate),
      currentStreak: currentStreak ?? this.currentStreak,
      bestStreak: bestStreak ?? this.bestStreak,
      unlockedBadgeIds: unlockedBadgeIds ?? this.unlockedBadgeIds,
      badgeUnlockedAt: badgeUnlockedAt ?? this.badgeUnlockedAt,
      userName: clearUserName ? null : (userName ?? this.userName),
      lastLessonResult: clearLastLessonResult
          ? null
          : (lastLessonResult ?? this.lastLessonResult),
    );
  }

  factory LearningProgressState.fromJson(Map<String, dynamic> json) {
    final legacyRouteCompletion =
        (json['routeCompletion'] as num?)?.toDouble() ?? 0;
    final legacyExamCompleted = json['examCompleted'] as bool? ?? false;

    final completedNodeIds = _asStringSet(json['completedNodeIds']);
    if (legacyExamCompleted) {
      completedNodeIds.add('dart_final_exam');
    }

    final routeProgressMap = _asDoubleMap(json['routeProgressPercentById']);
    if (!routeProgressMap.containsKey('dart_route')) {
      routeProgressMap['dart_route'] = legacyRouteCompletion;
    }

    final unlockedExams = _asStringSet(json['unlockedExamIds']);
    if (legacyExamCompleted) {
      unlockedExams.add('dart_final_exam');
    }

    final completedRoutes = _asStringSet(json['completedRouteIds']);
    if (legacyExamCompleted) {
      completedRoutes.add('dart_route');
    }

    return LearningProgressState(
      completedNodeIds: completedNodeIds,
      activeNodeId: json['activeNodeId'] == null
          ? null
          : _asString(json['activeNodeId']),
      completedRouteIds: completedRoutes,
      unlockedExamIds: unlockedExams,
      routeProgressPercentById: routeProgressMap,
      totalXp: _asInt(json['totalXp']),
      completedLessonsCount: _asInt(json['completedLessonsCount']),
      lastStudyDate: json['lastStudyDate'] == null
          ? null
          : _asString(json['lastStudyDate']),
      currentStreak: _asInt(json['currentStreak']),
      bestStreak: _asInt(json['bestStreak']),
      unlockedBadgeIds: _asStringSet(json['unlockedBadgeIds']),
      badgeUnlockedAt: _asStringMap(json['badgeUnlockedAt']),
      userName: json['userName'] == null ? null : _asString(json['userName']),
      lastLessonResult: json['lastLessonResult'] == null
          ? null
          : LessonAttemptResult.fromJson(
              json['lastLessonResult'] as Map<String, dynamic>,
            ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'completedNodeIds': completedNodeIds.toList(),
      'activeNodeId': activeNodeId,
      'completedRouteIds': completedRouteIds.toList(),
      'unlockedExamIds': unlockedExamIds.toList(),
      'routeProgressPercentById': routeProgressPercentById,
      'totalXp': totalXp,
      'completedLessonsCount': completedLessonsCount,
      'lastStudyDate': lastStudyDate,
      'currentStreak': currentStreak,
      'bestStreak': bestStreak,
      'unlockedBadgeIds': unlockedBadgeIds.toList(),
      'badgeUnlockedAt': badgeUnlockedAt,
      'userName': userName,
      'lastLessonResult': lastLessonResult?.toJson(),
    };
  }

  String encode() => jsonEncode(toJson());

  static LearningProgressState decode(String raw) {
    return LearningProgressState.fromJson(
      jsonDecode(raw) as Map<String, dynamic>,
    );
  }
}
