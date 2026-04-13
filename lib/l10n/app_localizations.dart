import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Flutter Quest'**
  String get appTitle;

  /// No description provided for @homeTab.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get homeTab;

  /// No description provided for @profileTab.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTab;

  /// No description provided for @routesAvailable.
  ///
  /// In en, this message translates to:
  /// **'Available routes'**
  String get routesAvailable;

  /// No description provided for @homeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Pick a route and keep moving forward'**
  String get homeSubtitle;

  /// No description provided for @loadRoutesError.
  ///
  /// In en, this message translates to:
  /// **'Could not load route content.'**
  String get loadRoutesError;

  /// No description provided for @loadPartialRoutesError.
  ///
  /// In en, this message translates to:
  /// **'Some routes could not be loaded'**
  String get loadPartialRoutesError;

  /// No description provided for @routeLoadWarningTitle.
  ///
  /// In en, this message translates to:
  /// **'Some routes failed to load'**
  String get routeLoadWarningTitle;

  /// No description provided for @completionLabel.
  ///
  /// In en, this message translates to:
  /// **'Completion'**
  String get completionLabel;

  /// No description provided for @progressLabel.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get progressLabel;

  /// No description provided for @examPassed.
  ///
  /// In en, this message translates to:
  /// **'Exam passed'**
  String get examPassed;

  /// No description provided for @examUnlocked.
  ///
  /// In en, this message translates to:
  /// **'Exam unlocked'**
  String get examUnlocked;

  /// No description provided for @examLocked.
  ///
  /// In en, this message translates to:
  /// **'Exam locked'**
  String get examLocked;

  /// No description provided for @lockedRouteTitle.
  ///
  /// In en, this message translates to:
  /// **'Locked route'**
  String get lockedRouteTitle;

  /// No description provided for @backToHome.
  ///
  /// In en, this message translates to:
  /// **'Back to Home'**
  String get backToHome;

  /// No description provided for @continueLearning.
  ///
  /// In en, this message translates to:
  /// **'Continue learning'**
  String get continueLearning;

  /// No description provided for @routeCompleted.
  ///
  /// In en, this message translates to:
  /// **'Route completed'**
  String get routeCompleted;

  /// No description provided for @currentPathFallback.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t started yet'**
  String get currentPathFallback;

  /// No description provided for @welcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Flutter Quest!'**
  String get welcomeTitle;

  /// No description provided for @welcomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your journey to master Dart and Flutter starts here.'**
  String get welcomeSubtitle;

  /// No description provided for @nameInputLabel.
  ///
  /// In en, this message translates to:
  /// **'YOUR NAME'**
  String get nameInputLabel;

  /// No description provided for @nameInputHint.
  ///
  /// In en, this message translates to:
  /// **'Your name here...'**
  String get nameInputHint;

  /// No description provided for @nameRequiredError.
  ///
  /// In en, this message translates to:
  /// **'Enter a name to continue.'**
  String get nameRequiredError;

  /// No description provided for @startButton.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get startButton;

  /// No description provided for @saveInProgress.
  ///
  /// In en, this message translates to:
  /// **'Saving...'**
  String get saveInProgress;

  /// No description provided for @verifyButton.
  ///
  /// In en, this message translates to:
  /// **'Check'**
  String get verifyButton;

  /// No description provided for @nextActivityButton.
  ///
  /// In en, this message translates to:
  /// **'Next activity'**
  String get nextActivityButton;

  /// No description provided for @continueButton.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// No description provided for @finishButton.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get finishButton;

  /// No description provided for @lessonFallbackTitle.
  ///
  /// In en, this message translates to:
  /// **'Lesson'**
  String get lessonFallbackTitle;

  /// No description provided for @feedbackFallbackTitle.
  ///
  /// In en, this message translates to:
  /// **'Feedback'**
  String get feedbackFallbackTitle;

  /// No description provided for @retryFeedback.
  ///
  /// In en, this message translates to:
  /// **'Review your answer and try again.'**
  String get retryFeedback;

  /// No description provided for @excellentWork.
  ///
  /// In en, this message translates to:
  /// **'Excellent work!'**
  String get excellentWork;

  /// No description provided for @keepTrying.
  ///
  /// In en, this message translates to:
  /// **'Keep going'**
  String get keepTrying;

  /// No description provided for @lessonSuccessSubtitle.
  ///
  /// In en, this message translates to:
  /// **'You completed the lesson successfully.'**
  String get lessonSuccessSubtitle;

  /// No description provided for @lessonFailSubtitle.
  ///
  /// In en, this message translates to:
  /// **'You did not reach the required score this time.'**
  String get lessonFailSubtitle;

  /// No description provided for @experiencePoints.
  ///
  /// In en, this message translates to:
  /// **'EXPERIENCE\nPOINTS'**
  String get experiencePoints;

  /// No description provided for @accuracyLabel.
  ///
  /// In en, this message translates to:
  /// **'ACCURACY'**
  String get accuracyLabel;

  /// No description provided for @resultQuoteSuccess.
  ///
  /// In en, this message translates to:
  /// **'\"Your learning streak is impressive. Keep it up!\"'**
  String get resultQuoteSuccess;

  /// No description provided for @resultQuoteFail.
  ///
  /// In en, this message translates to:
  /// **'\"Every attempt gets you closer to mastery. Adjust and come back stronger.\"'**
  String get resultQuoteFail;

  /// No description provided for @repeatButton.
  ///
  /// In en, this message translates to:
  /// **'Repeat'**
  String get repeatButton;

  /// No description provided for @profileKicker.
  ///
  /// In en, this message translates to:
  /// **'PLAYER PROFILE'**
  String get profileKicker;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @profileSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your real learning progress, streak and achievements.'**
  String get profileSubtitle;

  /// No description provided for @profileSubtitleDesktop.
  ///
  /// In en, this message translates to:
  /// **'Your real learning progress and achievements.'**
  String get profileSubtitleDesktop;

  /// No description provided for @levelAdventurer.
  ///
  /// In en, this message translates to:
  /// **'Level {level} · Dart Adventurer'**
  String levelAdventurer(int level);

  /// No description provided for @streakLabel.
  ///
  /// In en, this message translates to:
  /// **'Streak'**
  String get streakLabel;

  /// No description provided for @bestLabel.
  ///
  /// In en, this message translates to:
  /// **'Best'**
  String get bestLabel;

  /// No description provided for @completedLessons.
  ///
  /// In en, this message translates to:
  /// **'Completed Lessons'**
  String get completedLessons;

  /// No description provided for @completedRoutes.
  ///
  /// In en, this message translates to:
  /// **'Completed Routes'**
  String get completedRoutes;

  /// No description provided for @unlockedBadges.
  ///
  /// In en, this message translates to:
  /// **'Unlocked Badges'**
  String get unlockedBadges;

  /// No description provided for @currentNode.
  ///
  /// In en, this message translates to:
  /// **'Current Node'**
  String get currentNode;

  /// No description provided for @finalExamPassed.
  ///
  /// In en, this message translates to:
  /// **'Final exam passed'**
  String get finalExamPassed;

  /// No description provided for @finalExamUnlocked.
  ///
  /// In en, this message translates to:
  /// **'Final exam unlocked'**
  String get finalExamUnlocked;

  /// No description provided for @finalExamLocked.
  ///
  /// In en, this message translates to:
  /// **'Final exam locked'**
  String get finalExamLocked;

  /// No description provided for @badgesTitle.
  ///
  /// In en, this message translates to:
  /// **'Badges'**
  String get badgesTitle;

  /// No description provided for @badgesEmpty.
  ///
  /// In en, this message translates to:
  /// **'No badges unlocked yet. Complete nodes to earn achievements.'**
  String get badgesEmpty;

  /// No description provided for @recentActivityTitle.
  ///
  /// In en, this message translates to:
  /// **'Recent Activity'**
  String get recentActivityTitle;

  /// No description provided for @noRecentActivity.
  ///
  /// In en, this message translates to:
  /// **'You still have no recorded activity.'**
  String get noRecentActivity;

  /// No description provided for @passedStatus.
  ///
  /// In en, this message translates to:
  /// **'Passed'**
  String get passedStatus;

  /// No description provided for @retryStatus.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retryStatus;

  /// No description provided for @devToolsTitle.
  ///
  /// In en, this message translates to:
  /// **'Developer Tools'**
  String get devToolsTitle;

  /// No description provided for @devToolsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Temporary button for local testing.'**
  String get devToolsSubtitle;

  /// No description provided for @resetProgressButton.
  ///
  /// In en, this message translates to:
  /// **'Reset progress'**
  String get resetProgressButton;

  /// No description provided for @habitReminderTitle.
  ///
  /// In en, this message translates to:
  /// **'Daily reminders'**
  String get habitReminderTitle;

  /// No description provided for @habitReminderSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Get a habit ping at 10:00 AM if you have not studied today.'**
  String get habitReminderSubtitle;

  /// No description provided for @notificationPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Notification permission is required to enable reminders.'**
  String get notificationPermissionDenied;

  /// No description provided for @resetDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset progress'**
  String get resetDialogTitle;

  /// No description provided for @resetDialogBody.
  ///
  /// In en, this message translates to:
  /// **'All local data will be deleted: progress, XP, streak, badges and name. This action cannot be undone.'**
  String get resetDialogBody;

  /// No description provided for @cancelButton.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelButton;

  /// No description provided for @deleteAllButton.
  ///
  /// In en, this message translates to:
  /// **'Delete all'**
  String get deleteAllButton;

  /// No description provided for @nodeLockedBack.
  ///
  /// In en, this message translates to:
  /// **'Locked node · Back'**
  String get nodeLockedBack;

  /// No description provided for @backToRoute.
  ///
  /// In en, this message translates to:
  /// **'Back to route'**
  String get backToRoute;

  /// No description provided for @badgeUnlockedTitle.
  ///
  /// In en, this message translates to:
  /// **'New badge unlocked'**
  String get badgeUnlockedTitle;

  /// No description provided for @streakLostToast.
  ///
  /// In en, this message translates to:
  /// **'You lost your streak 😢'**
  String get streakLostToast;

  /// No description provided for @quizSelectOptionError.
  ///
  /// In en, this message translates to:
  /// **'Select an option before checking.'**
  String get quizSelectOptionError;

  /// No description provided for @quizSelectWrongLineError.
  ///
  /// In en, this message translates to:
  /// **'Select the line you think is wrong.'**
  String get quizSelectWrongLineError;

  /// No description provided for @quizSelectOutputError.
  ///
  /// In en, this message translates to:
  /// **'Choose the output you expect from the code.'**
  String get quizSelectOutputError;

  /// No description provided for @quizFixInputError.
  ///
  /// In en, this message translates to:
  /// **'Write a solution before checking.'**
  String get quizFixInputError;

  /// No description provided for @correctTitle.
  ///
  /// In en, this message translates to:
  /// **'Well played'**
  String get correctTitle;

  /// No description provided for @incorrectTitle.
  ///
  /// In en, this message translates to:
  /// **'Almost there'**
  String get incorrectTitle;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
