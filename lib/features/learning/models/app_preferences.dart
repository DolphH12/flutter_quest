class AppPreferences {
  const AppPreferences({required this.hasCompletedOnboarding});

  final bool hasCompletedOnboarding;

  static const defaults = AppPreferences(hasCompletedOnboarding: false);

  AppPreferences copyWith({bool? hasCompletedOnboarding}) {
    return AppPreferences(
      hasCompletedOnboarding:
          hasCompletedOnboarding ?? this.hasCompletedOnboarding,
    );
  }
}
