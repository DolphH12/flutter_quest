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

List<String> _requiredStringList(
  Map<String, dynamic> json,
  String key,
  String error,
) {
  final value = json[key];
  if (value is! List) {
    throw FormatException(error);
  }
  final result = <String>[];
  for (final item in value) {
    final mapped = _asString(item).trim();
    if (mapped.isEmpty) {
      throw FormatException(error);
    }
    result.add(mapped);
  }
  if (result.isEmpty) {
    throw FormatException(error);
  }
  return result;
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

String _requiredString(Map<String, dynamic> json, String key, String error) {
  final raw = json[key];
  final value = _asString(raw).trim();
  if (value.isEmpty) throw FormatException(error);
  return value;
}

int _requiredInt(Map<String, dynamic> json, String key, String error) {
  final raw = json[key];
  if (raw is! num) throw FormatException(error);
  return raw.toInt();
}

bool _optionalBool(
  Map<String, dynamic> json,
  String key, {
  required bool fallback,
}) {
  final value = json[key];
  if (value is bool) return value;
  return fallback;
}

class MatchConceptPair {
  const MatchConceptPair({required this.left, required this.right});

  final String left;
  final String right;

  factory MatchConceptPair.fromJson(dynamic raw) {
    if (raw is! Map<String, dynamic>) {
      throw const FormatException('matchConcept requires pairs');
    }
    final left = _requiredString(raw, 'left', 'matchConcept requires pairs');
    final right = _requiredString(raw, 'right', 'matchConcept requires pairs');
    return MatchConceptPair(left: left, right: right);
  }

  Map<String, dynamic> toJson() => {'left': left, 'right': right};
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
    final routeId = _requiredString(json, 'routeId', 'route requires routeId');
    final title = _requiredString(json, 'title', 'route requires title');
    final description = _requiredString(
      json,
      'description',
      'route requires description',
    );
    final icon = _requiredString(json, 'icon', 'route requires icon');
    final themeColor = _requiredString(
      json,
      'themeColor',
      'route requires themeColor',
    );
    final examNodeId = _requiredString(
      json,
      'examNodeId',
      'route requires examNodeId',
    );
    final version = _requiredInt(json, 'version', 'route requires version');
    final estimatedMinutes = _requiredInt(
      json,
      'estimatedMinutes',
      'route requires estimatedMinutes',
    );
    final rawNodes = json['nodes'];
    if (rawNodes is! List) {
      throw const FormatException('route requires nodes');
    }
    return DartRouteContent(
      routeId: routeId,
      title: title,
      description: description,
      icon: icon,
      themeColorHex: themeColor,
      version: version,
      estimatedMinutes: estimatedMinutes,
      examNodeId: examNodeId,
      nodes: rawNodes
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
    final id = _requiredString(json, 'id', 'node requires id');
    final title = _requiredString(json, 'title', 'node requires title');
    final shortDescription = _requiredString(
      json,
      'shortDescription',
      'node requires shortDescription',
    );
    final icon = _requiredString(json, 'icon', 'node requires icon');
    final nodeType = _requiredString(
      json,
      'nodeType',
      'node requires nodeType',
    );
    if (nodeType != 'lesson' && nodeType != 'exam') {
      throw const FormatException('nodeType must be lesson or exam');
    }
    final xpReward = _requiredInt(json, 'xpReward', 'node requires xpReward');
    final rawSteps = json['steps'];
    if (rawSteps is! List) {
      throw const FormatException('node requires steps');
    }
    return LearningNodeContent(
      id: id,
      title: title,
      shortDescription: shortDescription,
      icon: icon,
      nodeType: nodeType,
      xpReward: xpReward,
      steps: rawSteps
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
    required this.shuffle,
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
    this.pairs,
    this.codeSnippet,
    this.expectedFragments,
    this.instructions,
    this.starterCode,
  });

  final String id;
  final LessonStepType type;
  final bool shuffle;

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
  final List<String>? correctOrder;
  final List<String>? codeLines;
  final int? wrongLineIndex;
  final List<MatchConceptPair>? pairs;
  final String? codeSnippet;
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
    final id = _requiredString(json, 'id', 'activity requires id');
    final typeRaw = _requiredString(json, 'type', 'activity $id requires type');
    final type = _stepTypeFromString(typeRaw);
    if (type == LessonStepType.unknown) {
      throw FormatException('unknown activity type: $typeRaw');
    }
    return switch (type) {
      LessonStepType.intro => LessonStep(
        id: id,
        type: type,
        shuffle: false,
        title: _requiredString(json, 'title', 'intro requires title'),
        body: _requiredString(json, 'body', 'intro requires body'),
        example: json['example'] == null ? null : _asString(json['example']),
      ),
      LessonStepType.multipleChoice => _buildMultipleChoice(json, id, type),
      LessonStepType.fillInTheCode => _buildCodeCompletion(
        json: json,
        id: id,
        type: type,
        errorPrefix: 'fillInTheCode',
      ),
      LessonStepType.completeSnippet => _buildCodeCompletion(
        json: json,
        id: id,
        type: type,
        errorPrefix: 'completeSnippet',
      ),
      LessonStepType.fixTheBug => _buildCodeCompletion(
        json: json,
        id: id,
        type: type,
        errorPrefix: 'fixTheBug',
      ),
      LessonStepType.orderCodeBlocks => _buildOrderCodeBlocks(json, id, type),
      LessonStepType.findTheWrongLine => _buildFindWrongLine(json, id, type),
      LessonStepType.matchConcept => _buildMatchConcept(json, id, type),
      LessonStepType.predictOutput => _buildPredictOutput(json, id, type),
      LessonStepType.guidedWriting => _buildGuidedWriting(json, id, type),
      LessonStepType.unknown => throw const FormatException(
        'unknown activity type',
      ),
    };
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
      'shuffle': shuffle,
      'blocks': blocks,
      'correctOrder': correctOrder,
      'codeLines': codeLines,
      'wrongLineIndex': wrongLineIndex,
      'pairs': pairs?.map((item) => item.toJson()).toList(),
      'codeSnippet': codeSnippet,
      'expectedFragments': expectedFragments,
      'instructions': instructions,
      'starterCode': starterCode,
    };
  }

  static LessonStep _buildMultipleChoice(
    Map<String, dynamic> json,
    String id,
    LessonStepType type,
  ) {
    final options = _requiredStringList(
      json,
      'options',
      'multipleChoice requires options and correctAnswer',
    );
    final correct = _requiredString(
      json,
      'correctAnswer',
      'multipleChoice requires options and correctAnswer',
    );
    if (!options.contains(correct)) {
      throw const FormatException(
        'multipleChoice requires options and correctAnswer',
      );
    }
    return LessonStep(
      id: id,
      type: type,
      shuffle: _optionalBool(json, 'shuffle', fallback: true),
      question: _requiredString(
        json,
        'question',
        'multipleChoice requires question',
      ),
      options: options,
      correctAnswer: correct,
      correctExplanation: _requiredString(
        json,
        'correctExplanation',
        'multipleChoice requires correctExplanation',
      ),
      incorrectExplanation: _requiredString(
        json,
        'incorrectExplanation',
        'multipleChoice requires incorrectExplanation',
      ),
      xpReward: _requiredInt(
        json,
        'xpReward',
        'multipleChoice requires xpReward',
      ),
    );
  }

  static LessonStep _buildCodeCompletion({
    required Map<String, dynamic> json,
    required String id,
    required LessonStepType type,
    required String errorPrefix,
  }) {
    return LessonStep(
      id: id,
      type: type,
      shuffle: false,
      prompt: _requiredString(json, 'prompt', '$errorPrefix requires prompt'),
      initialCode: _requiredString(
        json,
        'initialCode',
        '$errorPrefix requires initialCode and expectedAnswer',
      ),
      expectedAnswer: _requiredString(
        json,
        'expectedAnswer',
        '$errorPrefix requires initialCode and expectedAnswer',
      ),
      correctExplanation: _requiredString(
        json,
        'correctExplanation',
        '$errorPrefix requires correctExplanation',
      ),
      incorrectExplanation: _requiredString(
        json,
        'incorrectExplanation',
        '$errorPrefix requires incorrectExplanation',
      ),
      hint: json['hint'] == null ? null : _asString(json['hint']),
      xpReward: _requiredInt(
        json,
        'xpReward',
        '$errorPrefix requires xpReward',
      ),
    );
  }

  static LessonStep _buildOrderCodeBlocks(
    Map<String, dynamic> json,
    String id,
    LessonStepType type,
  ) {
    final blocks = _requiredStringList(
      json,
      'blocks',
      'orderCodeBlocks requires blocks and correctOrder',
    );
    final correctOrder = _requiredStringList(
      json,
      'correctOrder',
      'orderCodeBlocks requires blocks and correctOrder',
    );
    if (blocks.length != correctOrder.length) {
      throw const FormatException(
        'orderCodeBlocks requires blocks and correctOrder',
      );
    }
    for (final block in blocks) {
      if (!correctOrder.contains(block)) {
        throw const FormatException(
          'orderCodeBlocks requires blocks and correctOrder',
        );
      }
    }
    return LessonStep(
      id: id,
      type: type,
      shuffle: _optionalBool(json, 'shuffle', fallback: true),
      prompt: _requiredString(
        json,
        'prompt',
        'orderCodeBlocks requires prompt',
      ),
      blocks: blocks,
      correctOrder: correctOrder,
      correctExplanation: _requiredString(
        json,
        'correctExplanation',
        'orderCodeBlocks requires correctExplanation',
      ),
      incorrectExplanation: _requiredString(
        json,
        'incorrectExplanation',
        'orderCodeBlocks requires incorrectExplanation',
      ),
      xpReward: _requiredInt(
        json,
        'xpReward',
        'orderCodeBlocks requires xpReward',
      ),
    );
  }

  static LessonStep _buildFindWrongLine(
    Map<String, dynamic> json,
    String id,
    LessonStepType type,
  ) {
    final codeLines = _requiredStringList(
      json,
      'codeLines',
      'findTheWrongLine requires codeLines and wrongLineIndex',
    );
    final wrongLineIndex = _requiredInt(
      json,
      'wrongLineIndex',
      'findTheWrongLine requires codeLines and wrongLineIndex',
    );
    if (wrongLineIndex < 0 || wrongLineIndex >= codeLines.length) {
      throw const FormatException(
        'findTheWrongLine requires codeLines and wrongLineIndex',
      );
    }
    return LessonStep(
      id: id,
      type: type,
      shuffle: false,
      prompt: _requiredString(
        json,
        'prompt',
        'findTheWrongLine requires prompt',
      ),
      codeLines: codeLines,
      wrongLineIndex: wrongLineIndex,
      correctExplanation: _requiredString(
        json,
        'correctExplanation',
        'findTheWrongLine requires correctExplanation',
      ),
      incorrectExplanation: _requiredString(
        json,
        'incorrectExplanation',
        'findTheWrongLine requires incorrectExplanation',
      ),
      xpReward: _requiredInt(
        json,
        'xpReward',
        'findTheWrongLine requires xpReward',
      ),
    );
  }

  static LessonStep _buildMatchConcept(
    Map<String, dynamic> json,
    String id,
    LessonStepType type,
  ) {
    final rawPairs = json['pairs'];
    if (rawPairs is! List) {
      throw const FormatException('matchConcept requires pairs');
    }
    final pairs = rawPairs
        .map((item) => MatchConceptPair.fromJson(item))
        .toList();
    if (pairs.isEmpty) {
      throw const FormatException('matchConcept requires pairs');
    }
    return LessonStep(
      id: id,
      type: type,
      shuffle: _optionalBool(json, 'shuffle', fallback: true),
      prompt: _requiredString(json, 'prompt', 'matchConcept requires prompt'),
      pairs: pairs,
      correctExplanation: _requiredString(
        json,
        'correctExplanation',
        'matchConcept requires correctExplanation',
      ),
      incorrectExplanation: _requiredString(
        json,
        'incorrectExplanation',
        'matchConcept requires incorrectExplanation',
      ),
      xpReward: _requiredInt(
        json,
        'xpReward',
        'matchConcept requires xpReward',
      ),
    );
  }

  static LessonStep _buildPredictOutput(
    Map<String, dynamic> json,
    String id,
    LessonStepType type,
  ) {
    final options = _requiredStringList(
      json,
      'options',
      'predictOutput requires options and correctAnswer',
    );
    final correct = _requiredString(
      json,
      'correctAnswer',
      'predictOutput requires options and correctAnswer',
    );
    if (!options.contains(correct)) {
      throw const FormatException(
        'predictOutput requires options and correctAnswer',
      );
    }
    return LessonStep(
      id: id,
      type: type,
      shuffle: _optionalBool(json, 'shuffle', fallback: true),
      question: _requiredString(
        json,
        'question',
        'predictOutput requires question',
      ),
      codeSnippet: _requiredString(
        json,
        'codeSnippet',
        'predictOutput requires codeSnippet',
      ),
      options: options,
      correctAnswer: correct,
      correctExplanation: _requiredString(
        json,
        'correctExplanation',
        'predictOutput requires correctExplanation',
      ),
      incorrectExplanation: _requiredString(
        json,
        'incorrectExplanation',
        'predictOutput requires incorrectExplanation',
      ),
      xpReward: _requiredInt(
        json,
        'xpReward',
        'predictOutput requires xpReward',
      ),
    );
  }

  static LessonStep _buildGuidedWriting(
    Map<String, dynamic> json,
    String id,
    LessonStepType type,
  ) {
    final expectedFragments = _requiredStringList(
      json,
      'expectedFragments',
      'guidedWriting requires starterCode and expectedFragments',
    );
    return LessonStep(
      id: id,
      type: type,
      shuffle: false,
      instructions: _requiredString(
        json,
        'instructions',
        'guidedWriting requires instructions',
      ),
      // starterCode must exist for contract consistency, but it can be empty
      // when the exercise expects writing from scratch.
      starterCode: json.containsKey('starterCode')
          ? _asString(json['starterCode'])
          : (throw const FormatException(
              'guidedWriting requires starterCode and expectedFragments',
            )),
      expectedFragments: expectedFragments,
      correctExplanation: _requiredString(
        json,
        'correctExplanation',
        'guidedWriting requires correctExplanation',
      ),
      incorrectExplanation: _requiredString(
        json,
        'incorrectExplanation',
        'guidedWriting requires incorrectExplanation',
      ),
      hint: json['hint'] == null ? null : _asString(json['hint']),
      xpReward: _requiredInt(
        json,
        'xpReward',
        'guidedWriting requires xpReward',
      ),
    );
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
    required this.pendingRouteIds,
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
  final Set<String> pendingRouteIds;
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
      pendingRouteIds: {},
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
    Set<String>? pendingRouteIds,
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
      pendingRouteIds: pendingRouteIds ?? this.pendingRouteIds,
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
      pendingRouteIds: _asStringSet(json['pendingRouteIds']),
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
      'pendingRouteIds': pendingRouteIds.toList(),
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
