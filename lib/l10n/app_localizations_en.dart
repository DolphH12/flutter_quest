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
  String get monthlyRouteBannerTitle => 'A new route lands every month';

  @override
  String get monthlyRouteBannerBody =>
      'We release one route at a time so each path ships polished, playable, and worth your streak.';

  @override
  String get loadRoutesError =>
      'We couldn\'t load route content. Please try again.';

  @override
  String get loadPartialRoutesError => 'We couldn\'t load some routes';

  @override
  String get loadPartialRoutesErrorWithColon =>
      'We couldn\'t load some routes:';

  @override
  String get routeLoadWarningTitle => 'Some routes failed to load';

  @override
  String get routeContentErrorBadge => 'Content error';

  @override
  String get routeContentErrorMessage =>
      'This route is temporarily under maintenance. You can retry or mark it as pending to continue.';

  @override
  String get routePendingBadge => 'Pending';

  @override
  String get markPendingButton => 'Mark as pending';

  @override
  String get pendingRouteNotice =>
      'Route marked as pending. You can continue now.';

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
  String get routeOpenErrorMessage =>
      'We couldn\'t open this route right now. Please try again.';

  @override
  String completeRouteToUnlock(String routeTitle) {
    return 'Complete $routeTitle to unlock it';
  }

  @override
  String get completeRequiredRouteToUnlock =>
      'Complete the required route to unlock this one';

  @override
  String completeRouteIdToUnlock(String routeId) {
    return 'Complete $routeId to unlock this route.';
  }

  @override
  String get backToHome => 'Back to Home';

  @override
  String get continueLearning => 'Continue learning';

  @override
  String get routeCompleted => 'Route completed';

  @override
  String get upcomingRouteBadge => 'Coming soon';

  @override
  String get upcomingRouteLockedBody =>
      'Finish your current published route and stay tuned. When the next route is released, this is the one you will see here.';

  @override
  String get upcomingRouteReadyBody =>
      'You are ready for the next path. It will appear here as soon as the next monthly release goes live.';

  @override
  String get upcomingRouteDetailMessage =>
      'This route is part of the upcoming release window. We publish one route at a time, and you will only see the next one after finishing the current published path.';

  @override
  String get upcomingRouteFallbackDescription =>
      'A new path is already on deck. We are polishing it before opening the next release window.';

  @override
  String get currentPathFallback => 'You haven\'t started yet';

  @override
  String get welcomeTitle => 'Welcome to Flutter Quest!';

  @override
  String get welcomeSubtitle =>
      'Your Dart and Flutter journey starts now. One step at a time, no stress, all momentum.';

  @override
  String get nameInputLabel => 'YOUR NAME';

  @override
  String get nameInputHint => 'Your name here...';

  @override
  String get onboardingWelcomeTitle => 'Welcome to Flutter Quest';

  @override
  String get onboardingWelcomeBody =>
      'Learn Dart and Flutter with short missions, clear feedback, and real progress.';

  @override
  String get onboardingRoutesTitle => 'Routes';

  @override
  String get onboardingRoutesBody =>
      'Each route is a guided learning path. Start with Dart, then unlock Flutter Foundations.';

  @override
  String get onboardingRoutesBodyGeneral =>
      'Explore themed routes and level up step by step. Foundations first, wizard moves next.';

  @override
  String get onboardingNodesTitle => 'Nodes';

  @override
  String get onboardingNodesBody =>
      'Each node is a mini mission. Clear one, unlock the next, and keep your streak alive.';

  @override
  String get onboardingNodeCompletedLabel => 'Completed';

  @override
  String get onboardingNodeNextLabel => 'Next';

  @override
  String get onboardingRewardsTitle => 'Rewards';

  @override
  String get onboardingRewardsBody =>
      'Every finished lesson gives XP, badges, and real progress. Your profile starts looking elite.';

  @override
  String get onboardingStreakTitle => 'Streak';

  @override
  String get onboardingStreakBody =>
      'Study daily to grow your streak. Skip a day and it resets, but your comeback can be legendary.';

  @override
  String get onboardingAllSetTitle => 'All set';

  @override
  String get onboardingAllSetBody =>
      'You\'re all set. Jump in, clear nodes, and make Dart and Flutter work for you.';

  @override
  String get onboardingBackButton => 'Back';

  @override
  String get onboardingLanguageTitle => 'Choose language';

  @override
  String get languageAuto => 'Auto';

  @override
  String get languageSpanish => 'Español';

  @override
  String get languageEnglish => 'English';

  @override
  String get onboardingRemindersTitle => 'Daily reminders';

  @override
  String get onboardingRemindersBody =>
      'Turn on reminders to protect your streak and keep your learning rhythm.';

  @override
  String get onboardingEnableReminders => 'Enable reminders';

  @override
  String get onboardingSkipButton => 'Skip';

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
  String get devToolsTitle => 'Reset your progress';

  @override
  String get devToolsSubtitle =>
      'Clear your local progress and start from scratch.';

  @override
  String get resetProgressButton => 'Reset progress';

  @override
  String get habitReminderTitle => 'Daily reminders';

  @override
  String get habitReminderSubtitle =>
      'Get a daily reminder to jump back into Flutter Quest.';

  @override
  String get notificationPermissionDenied =>
      'We couldn\'t enable reminders without notification permission.';

  @override
  String reminderTimeLabel(int hour, int minute) {
    return 'Time: $hour:$minute';
  }

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
  String get initializationErrorTitle => 'We couldn\'t start the app';

  @override
  String get retryButton => 'Retry';

  @override
  String get nodeLockedBack => 'Locked node · Back';

  @override
  String get backToRoute => 'Back to route';

  @override
  String get badgeUnlockedTitle => 'New badge unlocked';

  @override
  String get languageMenuTooltip => 'Language';

  @override
  String get backupSectionTitle => 'Progress backup';

  @override
  String get backupSectionSubtitle =>
      'Export or import your local progress to keep your learning safe.';

  @override
  String get backupExportButton => 'Export';

  @override
  String get backupImportButton => 'Import';

  @override
  String get backupExportSuccess => 'Progress exported successfully';

  @override
  String backupExportError(String error) {
    return 'We couldn\'t export your progress: $error';
  }

  @override
  String get backupImportTitle => 'Import progress';

  @override
  String get backupUnknownUser => 'N/A';

  @override
  String backupImportPreview(
    String user,
    int xp,
    int routes,
    String backupDate,
  ) {
    return 'User: $user\\nXP: $xp\\nCompleted routes: $routes\\nBackup: $backupDate\\n\\nThis action will overwrite your local data.';
  }

  @override
  String get backupImportSuccess => 'Progress imported successfully';

  @override
  String backupImportError(String error) {
    return 'We couldn\'t import the backup: $error';
  }

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
