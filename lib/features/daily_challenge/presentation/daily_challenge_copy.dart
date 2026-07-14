import 'package:flutter/material.dart';

class DailyChallengeCopy {
  const DailyChallengeCopy._();

  static bool _isEs(BuildContext context) =>
      Localizations.localeOf(context).languageCode.toLowerCase() == 'es';

  static String recentChallengesTitle(BuildContext context) =>
      _isEs(context) ? 'Retos recientes' : 'Recent challenges';

  static String recentChallengesSubtitle(BuildContext context) => _isEs(context)
      ? 'Si dejaste alguno pasar, aquí tienes los últimos 7 días para practicar. Ya no dan XP, pero sí te dejan ponerte al día.'
      : 'If you missed one, here are the last 7 days to practice. They no longer grant XP, but they still help you catch up.';

  static String recentChallengesOffline(BuildContext context) => _isEs(context)
      ? 'Con internet vuelven a aparecer los retos recientes.'
      : 'Recent challenges will show up again once you are back online.';

  static String recentChallengesEmpty(BuildContext context) => _isEs(context)
      ? 'Todavía no hay retos recientes para mostrar.'
      : 'There are no recent challenges to show yet.';

  static String solveWithoutXp(BuildContext context) =>
      _isEs(context) ? 'Resolver sin XP' : 'Solve without XP';

  static String alreadyDone(BuildContext context) =>
      _isEs(context) ? 'Ya realizado' : 'Already done';

  static String practiceOnly(BuildContext context) =>
      _isEs(context) ? 'Práctica' : 'Practice';

  static String noXpLabel(BuildContext context) =>
      _isEs(context) ? 'Sin XP' : 'No XP';

  static String completedBadge(BuildContext context) =>
      _isEs(context) ? 'Completado' : 'Completed';

  static String failedBadge(BuildContext context) =>
      _isEs(context) ? 'No logrado' : 'Not achieved';

  static String completedPastChallengeTitle(BuildContext context) => _isEs(context)
      ? 'Este reto ya quedó resuelto'
      : 'This challenge is already done';

  static String completedPastChallengeBody(BuildContext context) => _isEs(context)
      ? 'Ya jugaste este reto diario. Mañana habrá otro intento fresco y este queda guardado en tu historial.'
      : 'You already played this daily challenge. A fresh one arrives tomorrow, and this one stays in your history.';

  static String backToRecentChallenges(BuildContext context) =>
      _isEs(context) ? 'Volver a retos' : 'Back to challenges';

  static String challengeDateLabel(BuildContext context) =>
      _isEs(context) ? 'Fecha' : 'Date';

  static String recentChallengeSectionKicker(BuildContext context) =>
      _isEs(context) ? 'Últimos 7 días' : 'Last 7 days';
}
