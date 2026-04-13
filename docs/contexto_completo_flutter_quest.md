# Flutter Quest - Contexto Completo

## 1) Qué es la app
Flutter Quest es una app educativa gamificada para aprender programación (Dart y Flutter) con rutas de aprendizaje, nodos por lección, actividades prácticas y seguimiento local de progreso.

## 2) Stack técnico
- Flutter + Material 3 customizado (identidad visual propia).
- Riverpod como gestor principal de estado.
- GoRouter para navegación declarativa.
- SharedPreferences para persistencia local.
- JSON local en `assets/content/` como fuente de contenido.
- `flutter_local_notifications` para recordatorios de hábito locales.

## 3) Arquitectura (alto nivel)
La app separa responsabilidades en tres capas:

- Contenido (JSON): rutas, nodos, steps, actividades.
- Progreso (usuario): XP, racha, nodos completados, rutas completadas, badges.
- Sesión de lección (temporal): paso actual, respuestas, verificación, feedback.

Estructura principal:
- `lib/app/`: shell, router, app root, overlays globales.
- `lib/features/learning/`: modelos, repositorios, providers de dominio.
- `lib/features/home/`: listado de rutas y detalle de ruta/mapa.
- `lib/features/lesson_flow/`: flujo de intro + actividades + resultado.
- `lib/features/profile/`: métricas reales, badges, idioma, acciones de reset.
- `lib/features/notifications/`: preferencias y servicio de notificaciones locales.

## 4) Flujo funcional actual
1. Home lista rutas disponibles.
2. Al entrar a una ruta, se muestra su mapa de nodos.
3. Al tocar nodo disponible, abre flujo de lección.
4. La lección avanza por pasos:
   - intros (no evaluables),
   - actividades evaluables por tipo.
5. Se calcula resultado y se actualiza progreso.
6. Si corresponde, se desbloquea nodo siguiente y/o examen final.
7. Profile muestra todo desde estado persistido real.

## 5) Contenido desde JSON
Los JSON se cargan desde:
- `assets/content/dart_route.json`
- `assets/content/flutter_foundations_route.json`

El parser está alineado al contrato oficial de actividades en:
- `docs/content/activity_contracts.md`

Tipos soportados:
- `intro`
- `multipleChoice`
- `fillInTheCode`
- `completeSnippet`
- `fixTheBug`
- `orderCodeBlocks`
- `findTheWrongLine`
- `matchConcept`
- `predictOutput`
- `guidedWriting`

## 6) Progreso y persistencia
La fuente de verdad de progreso es `LearningProgressState`, persistido en SharedPreferences.

Incluye:
- `completedNodeIds`
- `activeNodeId`
- `completedRouteIds`
- `unlockedExamIds`
- `routeProgressPercentById`
- `totalXp`
- `completedLessonsCount`
- `lastStudyDate`
- `currentStreak` / `bestStreak`
- `unlockedBadgeIds`
- `userName`
- `lastLessonResult`

Reglas clave:
- avance secuencial de nodos,
- aprobación por umbral,
- desbloqueo de examen final,
- badges por hitos,
- racha reinicia si pasan más de 1 día sin estudio.

## 7) Notificaciones locales de hábito
Implementadas sin backend:
- prompt de permiso en primer arranque,
- si acepta, quedan activas por defecto,
- recordatorio diario a las 10:00 AM,
- si ya estudió hoy, se suprime el resto del día y se programa siguiente día.

Estado persistido de notificaciones:
- activado/desactivado,
- hora/minuto de recordatorio,
- bandera de primer prompt de permiso.

Control UI:
- switch en Profile para activar/desactivar.

## 8) Internacionalización
La app es bilingüe (`es` / `en`) con l10n:
- ARB en `lib/l10n/`.
- Si no hay idioma elegido por usuario, usa idioma del sistema.
- El contenido de rutas JSON usa campos localizados y se resuelve según idioma activo.

## 9) UX global
- Overlay superior para badges desbloqueados.
- Overlay superior rojo cuando se pierde la racha.
- Resultado de lección como pantalla final (no modal).
- Identidad visual consistente (azules, gradientes, superficies suaves, tono gamificado).

## 10) Estado actual y siguiente evolución natural
Estado actual:
- producto funcional end-to-end con contenido local, progreso persistido y rutas múltiples.

Siguiente evolución natural:
- selector de hora de recordatorios,
- diagnóstico in-app de notificaciones programadas,
- telemetría local de entregas (sin backend),
- más rutas y más tipos de actividad.
