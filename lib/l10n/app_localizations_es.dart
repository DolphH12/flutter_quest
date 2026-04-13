// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Flutter Quest';

  @override
  String get homeTab => 'Home';

  @override
  String get profileTab => 'Profile';

  @override
  String get routesAvailable => 'Rutas disponibles';

  @override
  String get homeSubtitle => 'Elige una ruta y sigue avanzando';

  @override
  String get loadRoutesError => 'No se pudo cargar el contenido de las rutas.';

  @override
  String get loadPartialRoutesError => 'No se pudieron cargar algunas rutas';

  @override
  String get routeLoadWarningTitle => 'Algunas rutas no cargaron';

  @override
  String get completionLabel => 'Completado';

  @override
  String get progressLabel => 'Progreso';

  @override
  String get examPassed => 'Examen aprobado';

  @override
  String get examUnlocked => 'Examen desbloqueado';

  @override
  String get examLocked => 'Examen bloqueado';

  @override
  String get lockedRouteTitle => 'Ruta bloqueada';

  @override
  String get backToHome => 'Volver al Home';

  @override
  String get continueLearning => 'Seguir aprendiendo';

  @override
  String get routeCompleted => 'Ruta completada';

  @override
  String get currentPathFallback => 'Aún no has comenzado';

  @override
  String get welcomeTitle => '¡Bienvenido a Flutter Quest!';

  @override
  String get welcomeSubtitle =>
      'Tu viaje para dominar Dart y Flutter comienza aquí.';

  @override
  String get nameInputLabel => 'DANOS TU NOMBRE';

  @override
  String get nameInputHint => 'Tu nombre aquí...';

  @override
  String get nameRequiredError => 'Escribe un nombre para continuar.';

  @override
  String get startButton => 'Empezar';

  @override
  String get saveInProgress => 'Guardando...';

  @override
  String get verifyButton => 'Verificar';

  @override
  String get nextActivityButton => 'Siguiente actividad';

  @override
  String get continueButton => 'Continuar';

  @override
  String get finishButton => 'Finalizar';

  @override
  String get lessonFallbackTitle => 'Lección';

  @override
  String get feedbackFallbackTitle => 'Feedback';

  @override
  String get retryFeedback => 'Revisa tu respuesta e intenta de nuevo.';

  @override
  String get excellentWork => '¡Excelente trabajo!';

  @override
  String get keepTrying => 'Sigue intentando';

  @override
  String get lessonSuccessSubtitle => 'Has completado la lección con éxito.';

  @override
  String get lessonFailSubtitle =>
      'No alcanzaste el puntaje requerido esta vez.';

  @override
  String get experiencePoints => 'PUNTOS DE\nEXPERIENCIA';

  @override
  String get accuracyLabel => 'PRECISIÓN';

  @override
  String get resultQuoteSuccess =>
      '\"Tu racha de aprendizaje es impresionante. ¡Sigue así!\"';

  @override
  String get resultQuoteFail =>
      '\"Cada intento te acerca al dominio. Ajusta y vuelve más fuerte.\"';

  @override
  String get repeatButton => 'Repetir';

  @override
  String get profileKicker => 'PERFIL DEL JUGADOR';

  @override
  String get profileTitle => 'Perfil';

  @override
  String get profileSubtitle =>
      'Tu progreso real de aprendizaje, racha y logros.';

  @override
  String get profileSubtitleDesktop =>
      'Tu progreso real y tus logros de aprendizaje.';

  @override
  String levelAdventurer(int level) {
    return 'Nivel $level · Aventurero Dart';
  }

  @override
  String get streakLabel => 'Racha';

  @override
  String get bestLabel => 'Mejor';

  @override
  String get completedLessons => 'Lecciones completadas';

  @override
  String get completedRoutes => 'Rutas completadas';

  @override
  String get unlockedBadges => 'Badges desbloqueados';

  @override
  String get currentNode => 'Nodo actual';

  @override
  String get finalExamPassed => 'Examen final aprobado';

  @override
  String get finalExamUnlocked => 'Examen final desbloqueado';

  @override
  String get finalExamLocked => 'Examen final bloqueado';

  @override
  String get badgesTitle => 'Badges';

  @override
  String get badgesEmpty =>
      'Aún no hay badges desbloqueados. Completa nodos para ganar logros.';

  @override
  String get recentActivityTitle => 'Actividad reciente';

  @override
  String get noRecentActivity => 'Todavía no tienes actividad registrada.';

  @override
  String get passedStatus => 'Aprobado';

  @override
  String get retryStatus => 'Reintentar';

  @override
  String get devToolsTitle => 'Herramientas de desarrollo';

  @override
  String get devToolsSubtitle => 'Botón temporal para pruebas locales.';

  @override
  String get resetProgressButton => 'Resetear progreso';

  @override
  String get habitReminderTitle => 'Recordatorios diarios';

  @override
  String get habitReminderSubtitle =>
      'Recibe un recordatorio a las 10:00 AM si hoy no has estudiado.';

  @override
  String get notificationPermissionDenied =>
      'Se requiere permiso de notificaciones para activar los recordatorios.';

  @override
  String get resetDialogTitle => 'Resetear progreso';

  @override
  String get resetDialogBody =>
      'Se borrarán todos los datos locales: progreso, XP, racha, badges y nombre. Esta acción no se puede deshacer.';

  @override
  String get cancelButton => 'Cancelar';

  @override
  String get deleteAllButton => 'Borrar todo';

  @override
  String get nodeLockedBack => 'Nodo bloqueado · Volver';

  @override
  String get backToRoute => 'Volver a la ruta';

  @override
  String get badgeUnlockedTitle => 'Nueva insignia desbloqueada';

  @override
  String get streakLostToast => 'Perdiste la racha 😢';

  @override
  String get quizSelectOptionError => 'Selecciona una opción para verificar.';

  @override
  String get quizSelectWrongLineError =>
      'Selecciona la línea que consideras incorrecta.';

  @override
  String get quizSelectOutputError => 'Elige la salida que esperas del código.';

  @override
  String get quizFixInputError => 'Escribe una respuesta antes de verificar.';

  @override
  String get correctTitle => 'Bien jugado';

  @override
  String get incorrectTitle => 'Casi, sigue intentando';
}
