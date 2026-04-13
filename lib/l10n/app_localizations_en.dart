// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Flutter Quest';

  @override
  String get homeTab => 'Home';

  @override
  String get profileTab => 'Profile';

  @override
  String get routesAvailable => 'Available routes';

  @override
  String get homeSubtitle => 'Pick a route and keep moving forward';

  @override
  String get loadRoutesError => 'Could not load route content.';

  @override
  String get loadPartialRoutesError => 'Some routes could not be loaded';

  @override
  String get routeLoadWarningTitle => 'Some routes failed to load';

  @override
  String get completionLabel => 'Completion';

  @override
  String get progressLabel => 'Progress';

  @override
  String get examPassed => 'Exam passed';

  @override
  String get examUnlocked => 'Exam unlocked';

  @override
  String get examLocked => 'Exam locked';

  @override
  String get lockedRouteTitle => 'Locked route';

  @override
  String get backToHome => 'Back to Home';

  @override
  String get continueLearning => 'Continue learning';

  @override
  String get routeCompleted => 'Route completed';

  @override
  String get currentPathFallback => 'You haven\'t started yet';

  @override
  String get welcomeTitle => 'Welcome to Flutter Quest!';

  @override
  String get welcomeSubtitle =>
      'Your journey to master Dart and Flutter starts here.';

  @override
  String get nameInputLabel => 'YOUR NAME';

  @override
  String get nameInputHint => 'Your name here...';

  @override
  String get nameRequiredError => 'Enter a name to continue.';

  @override
  String get startButton => 'Start';

  @override
  String get saveInProgress => 'Saving...';

  @override
  String get verifyButton => 'Check';

  @override
  String get nextActivityButton => 'Next activity';

  @override
  String get continueButton => 'Continue';

  @override
  String get finishButton => 'Finish';

  @override
  String get lessonFallbackTitle => 'Lesson';

  @override
  String get feedbackFallbackTitle => 'Feedback';

  @override
  String get retryFeedback => 'Review your answer and try again.';

  @override
  String get excellentWork => 'Excellent work!';

  @override
  String get keepTrying => 'Keep going';

  @override
  String get lessonSuccessSubtitle => 'You completed the lesson successfully.';

  @override
  String get lessonFailSubtitle =>
      'You did not reach the required score this time.';

  @override
  String get experiencePoints => 'EXPERIENCE\nPOINTS';

  @override
  String get accuracyLabel => 'ACCURACY';

  @override
  String get resultQuoteSuccess =>
      '\"Your learning streak is impressive. Keep it up!\"';

  @override
  String get resultQuoteFail =>
      '\"Every attempt gets you closer to mastery. Adjust and come back stronger.\"';

  @override
  String get repeatButton => 'Repeat';

  @override
  String get profileKicker => 'PLAYER PROFILE';

  @override
  String get profileTitle => 'Profile';

  @override
  String get profileSubtitle =>
      'Your real learning progress, streak and achievements.';

  @override
  String get profileSubtitleDesktop =>
      'Your real learning progress and achievements.';

  @override
  String levelAdventurer(int level) {
    return 'Level $level · Dart Adventurer';
  }

  @override
  String get streakLabel => 'Streak';

  @override
  String get bestLabel => 'Best';

  @override
  String get completedLessons => 'Completed Lessons';

  @override
  String get completedRoutes => 'Completed Routes';

  @override
  String get unlockedBadges => 'Unlocked Badges';

  @override
  String get currentNode => 'Current Node';

  @override
  String get finalExamPassed => 'Final exam passed';

  @override
  String get finalExamUnlocked => 'Final exam unlocked';

  @override
  String get finalExamLocked => 'Final exam locked';

  @override
  String get badgesTitle => 'Badges';

  @override
  String get badgesEmpty =>
      'No badges unlocked yet. Complete nodes to earn achievements.';

  @override
  String get recentActivityTitle => 'Recent Activity';

  @override
  String get noRecentActivity => 'You still have no recorded activity.';

  @override
  String get passedStatus => 'Passed';

  @override
  String get retryStatus => 'Retry';

  @override
  String get devToolsTitle => 'Developer Tools';

  @override
  String get devToolsSubtitle => 'Temporary button for local testing.';

  @override
  String get resetProgressButton => 'Reset progress';

  @override
  String get habitReminderTitle => 'Daily reminders';

  @override
  String get habitReminderSubtitle =>
      'Get a habit ping at 10:00 AM if you have not studied today.';

  @override
  String get notificationPermissionDenied =>
      'Notification permission is required to enable reminders.';

  @override
  String get resetDialogTitle => 'Reset progress';

  @override
  String get resetDialogBody =>
      'All local data will be deleted: progress, XP, streak, badges and name. This action cannot be undone.';

  @override
  String get cancelButton => 'Cancel';

  @override
  String get deleteAllButton => 'Delete all';

  @override
  String get nodeLockedBack => 'Locked node · Back';

  @override
  String get backToRoute => 'Back to route';

  @override
  String get badgeUnlockedTitle => 'New badge unlocked';

  @override
  String get streakLostToast => 'You lost your streak 😢';

  @override
  String get quizSelectOptionError => 'Select an option before checking.';

  @override
  String get quizSelectWrongLineError => 'Select the line you think is wrong.';

  @override
  String get quizSelectOutputError =>
      'Choose the output you expect from the code.';

  @override
  String get quizFixInputError => 'Write a solution before checking.';

  @override
  String get correctTitle => 'Well played';

  @override
  String get incorrectTitle => 'Almost there';
}
