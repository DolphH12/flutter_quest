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
  String get homeTab => 'Inicio';

  @override
  String get profileTab => 'Perfil';

  @override
  String get routesAvailable => 'Rutas disponibles';

  @override
  String get homeSubtitle => 'Elige una ruta y sigue avanzando';

  @override
  String get monthlyRouteBannerTitle => 'Cada mes llega una ruta nueva';

  @override
  String get monthlyRouteBannerBody =>
      'Liberamos una ruta a la vez para que cada camino salga pulido, jugable y digno de tu racha.';

  @override
  String get loadRoutesError =>
      'No pudimos cargar el contenido de las rutas. Inténtalo de nuevo.';

  @override
  String get loadPartialRoutesError => 'No pudimos cargar algunas rutas';

  @override
  String get loadPartialRoutesErrorWithColon =>
      'No pudimos cargar algunas rutas:';

  @override
  String get routeLoadWarningTitle => 'Algunas rutas no cargaron';

  @override
  String get routeContentErrorBadge => 'Error de contenido';

  @override
  String get routeContentErrorMessage =>
      'Esta ruta está temporalmente en mantenimiento. Puedes reintentar o marcarla como pendiente para continuar.';

  @override
  String get routePendingBadge => 'Pendiente';

  @override
  String get markPendingButton => 'Marcar pendiente';

  @override
  String get pendingRouteNotice =>
      'Ruta marcada como pendiente. Ya puedes continuar.';

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
  String get routeOpenErrorMessage =>
      'No pudimos abrir esta ruta ahora. Inténtalo de nuevo.';

  @override
  String completeRouteToUnlock(String routeTitle) {
    return 'Completa $routeTitle para desbloquear';
  }

  @override
  String get completeRequiredRouteToUnlock =>
      'Completa la ruta requerida para desbloquear';

  @override
  String completeRouteIdToUnlock(String routeId) {
    return 'Completa $routeId para desbloquear esta ruta.';
  }

  @override
  String get backToHome => 'Volver al Home';

  @override
  String get continueLearning => 'Seguir aprendiendo';

  @override
  String get routeCompleted => 'Ruta completada';

  @override
  String get upcomingRouteBadge => 'Próximamente';

  @override
  String get upcomingRouteLockedBody =>
      'Termina la ruta publicada actual y mantente atento. Cuando se libere la siguiente, esta será la que verás aquí.';

  @override
  String get upcomingRouteReadyBody =>
      'Ya estás listo para el siguiente camino. Aparecerá aquí en cuanto se publique la próxima liberación mensual.';

  @override
  String get upcomingRouteDetailMessage =>
      'Esta ruta pertenece a la siguiente ventana de publicación. Liberamos una ruta a la vez y solo verás la siguiente cuando completes la ruta publicada actual.';

  @override
  String get upcomingRouteFallbackDescription =>
      'Ya viene un nuevo camino. Lo estamos afinando antes de abrir la siguiente ventana de publicación.';

  @override
  String get currentPathFallback => 'Aún no has comenzado';

  @override
  String get welcomeTitle => '¡Bienvenido a Flutter Quest!';

  @override
  String get welcomeSubtitle =>
      'Tu viaje para dominar Dart y Flutter arranca aquí. Vamos paso a paso, sin drama y con mucho power.';

  @override
  String get nameInputLabel => 'DANOS TU NOMBRE';

  @override
  String get nameInputHint => 'Tu nombre aquí...';

  @override
  String get onboardingWelcomeTitle => 'Bienvenido a Flutter Quest';

  @override
  String get onboardingWelcomeBody =>
      'Aprende Dart y Flutter con misiones cortas, feedback claro y progreso real.';

  @override
  String get onboardingRoutesTitle => 'Rutas';

  @override
  String get onboardingRoutesBody =>
      'Cada ruta es un camino guiado. Empieza por Dart y luego desbloquea Flutter Foundations.';

  @override
  String get onboardingRoutesBodyGeneral =>
      'Explora rutas temáticas y sube de nivel paso a paso. Hoy fundamentos, mañana builds legendarios.';

  @override
  String get onboardingNodesTitle => 'Nodos';

  @override
  String get onboardingNodesBody =>
      'Cada nodo es una mini misión. Ganas una, desbloqueas la siguiente y mantienes el combo activo.';

  @override
  String get onboardingNodeCompletedLabel => 'Completado';

  @override
  String get onboardingNodeNextLabel => 'Siguiente';

  @override
  String get onboardingRewardsTitle => 'Recompensas';

  @override
  String get onboardingRewardsBody =>
      'Cada lección completada te da XP, insignias y progreso real. Tu perfil se pone cada vez más pro.';

  @override
  String get onboardingStreakTitle => 'Racha';

  @override
  String get onboardingStreakBody =>
      'Tu racha crece cada día que estudias. Si te saltas uno, vuelve a cero... pero siempre puedes volver más fuerte.';

  @override
  String get onboardingAllSetTitle => 'Todo listo';

  @override
  String get onboardingAllSetBody =>
      'Todo listo. Entra, completa nodos y haz que Dart y Flutter jueguen a tu favor.';

  @override
  String get onboardingBackButton => 'Atrás';

  @override
  String get onboardingLanguageTitle => 'Elige idioma';

  @override
  String get languageAuto => 'Auto';

  @override
  String get languageSpanish => 'Español';

  @override
  String get languageEnglish => 'English';

  @override
  String get onboardingRemindersTitle => 'Recordatorios diarios';

  @override
  String get onboardingRemindersBody =>
      'Activa recordatorios para proteger tu racha y mantener tu ritmo de aprendizaje.';

  @override
  String get onboardingEnableReminders => 'Activar recordatorios';

  @override
  String get onboardingSkipButton => 'Saltar';

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
  String get feedbackFallbackTitle => 'Retroalimentación';

  @override
  String get retryFeedback => 'Revisa tu respuesta e inténtalo de nuevo.';

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
  String get unlockedBadges => 'Insignias desbloqueadas';

  @override
  String get currentNode => 'Nodo actual';

  @override
  String get finalExamPassed => 'Examen final aprobado';

  @override
  String get finalExamUnlocked => 'Examen final desbloqueado';

  @override
  String get finalExamLocked => 'Examen final bloqueado';

  @override
  String get badgesTitle => 'Insignias';

  @override
  String get badgesEmpty =>
      'Aún no hay insignias desbloqueadas. Completa nodos para ganar logros.';

  @override
  String get recentActivityTitle => 'Actividad reciente';

  @override
  String get noRecentActivity => 'Todavía no tienes actividad registrada.';

  @override
  String get passedStatus => 'Aprobado';

  @override
  String get retryStatus => 'Reintentar';

  @override
  String get devToolsTitle => 'Reiniciar tu progreso';

  @override
  String get devToolsSubtitle =>
      'Borra tu avance local para volver a empezar desde cero.';

  @override
  String get resetProgressButton => 'Reiniciar progreso';

  @override
  String get habitReminderTitle => 'Recordatorios diarios';

  @override
  String get habitReminderSubtitle =>
      'Recibe un recordatorio diario para volver a Flutter Quest.';

  @override
  String get notificationPermissionDenied =>
      'No pudimos activar los recordatorios sin permiso de notificaciones.';

  @override
  String reminderTimeLabel(int hour, int minute) {
    return 'Hora: $hour:$minute';
  }

  @override
  String get resetDialogTitle => 'Reiniciar progreso';

  @override
  String get resetDialogBody =>
      'Se borrarán todos los datos locales: progreso, XP, racha, badges y nombre. Esta acción no se puede deshacer.';

  @override
  String get cancelButton => 'Cancelar';

  @override
  String get deleteAllButton => 'Borrar todo';

  @override
  String get initializationErrorTitle => 'No pudimos iniciar la app';

  @override
  String get retryButton => 'Reintentar';

  @override
  String get nodeLockedBack => 'Nodo bloqueado · Volver';

  @override
  String get backToRoute => 'Volver a la ruta';

  @override
  String get badgeUnlockedTitle => 'Nueva insignia desbloqueada';

  @override
  String get languageMenuTooltip => 'Idioma';

  @override
  String get backupSectionTitle => 'Respaldo del progreso';

  @override
  String get backupSectionSubtitle =>
      'Exporta o importa tu progreso local para recuperar tu avance.';

  @override
  String get backupExportButton => 'Exportar';

  @override
  String get backupImportButton => 'Importar';

  @override
  String get backupExportSuccess => 'Progreso exportado correctamente';

  @override
  String backupExportError(String error) {
    return 'No pudimos exportar el progreso: $error';
  }

  @override
  String get backupImportTitle => 'Importar progreso';

  @override
  String get backupUnknownUser => 'N/A';

  @override
  String backupImportPreview(
    String user,
    int xp,
    int routes,
    String backupDate,
  ) {
    return 'Usuario: $user\\nXP: $xp\\nRutas completadas: $routes\\nBackup: $backupDate\\n\\nEsta acción sobrescribirá tus datos locales.';
  }

  @override
  String get backupImportSuccess => 'Progreso importado correctamente';

  @override
  String backupImportError(String error) {
    return 'No pudimos importar el respaldo: $error';
  }

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
