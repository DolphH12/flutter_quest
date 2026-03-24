abstract final class FQMockData {
  static const String userName = 'Alex Rivera';
  static const int xp = 1240;
  static const int streakDays = 17;
  static const int level = 8;
  static const double currentTrackProgress = 0.64;

  static const List<Map<String, dynamic>> homeUnits = [
    {
      'title': 'Dart Foundations',
      'subtitle': 'Types, null safety and flow',
      'progress': 0.82,
      'tag': 'Core',
    },
    {
      'title': 'Flutter UI System',
      'subtitle': 'Layout, theming and widgets',
      'progress': 0.48,
      'tag': 'UI',
    },
    {
      'title': 'State Essentials',
      'subtitle': 'Reactive mental model',
      'progress': 0.16,
      'tag': 'State',
    },
  ];

  static const List<Map<String, dynamic>> lessons = [
    {
      'title': 'Variables and Type Inference',
      'kind': 'Microlesson',
      'minutes': 7,
      'progress': 1.0,
    },
    {
      'title': 'Control Flow in Dart',
      'kind': 'Quiz',
      'minutes': 9,
      'progress': 0.7,
    },
    {
      'title': 'Collections and Iterables',
      'kind': 'Microlesson',
      'minutes': 8,
      'progress': 0.35,
    },
    {
      'title': 'Functions and Closures',
      'kind': 'Quiz',
      'minutes': 11,
      'progress': 0.0,
    },
  ];

  static const List<Map<String, dynamic>> challenges = [
    {'title': 'Refactor Widget Tree', 'difficulty': 'Medium', 'reward': 90},
    {'title': 'Fix Async Race Condition', 'difficulty': 'Hard', 'reward': 140},
    {'title': 'Build Reusable Card API', 'difficulty': 'Easy', 'reward': 70},
  ];

  static const List<String> badges = [
    '7-Day Focus',
    'Quiz Sniper',
    'UI Explorer',
    'Bug Hunter',
    'Consistency Hero',
  ];

  static const List<Map<String, String>> achievements = [
    {'title': 'Completed Dart Foundations', 'date': '2 days ago'},
    {'title': 'Unlocked Quiz Sniper Badge', 'date': '5 days ago'},
    {'title': 'Best Streak: 17 days', 'date': '1 week ago'},
  ];
}
