# Flutter Quest: Arquitectura y decisiones de construcción

## 1. Qué es Flutter Quest hoy

Flutter Quest es una app educativa gamificada para aprender Dart y Flutter con:

- rutas de aprendizaje cargadas desde JSON local
- mapa de nodos por ruta
- flujo de lección con actividades evaluables
- examen final por ruta
- progreso local persistido
- perfil conectado a datos reales
- notificaciones visuales de badges
- navegación robusta con `go_router`
- gestión de estado central con `Riverpod`

El objetivo arquitectónico actual es claro: **producto estable, escalable y consistente**, priorizando una sola fuente de verdad para progreso y una separación fuerte entre contenido, estado de usuario y sesión temporal de lección.

---

## 2. Stack técnico y por qué se eligió

- **Flutter + Material 3 personalizado**
  - Se usa Material como base técnica por estabilidad multiplataforma.
  - Se personaliza visualmente para evitar look estándar y mantener identidad Flutter Quest.

- **Riverpod (`flutter_riverpod`)**
  - Permite estado reactivo y desacoplado de widgets.
  - Evita inconsistencias entre pantallas (problema que existía antes del refactor).
  - Facilita separar estado global (progreso) de estado temporal (sesión de lección).

- **GoRouter**
  - Da control explícito del grafo de rutas.
  - Evita errores de navegación por `push/pop` mezclados.
  - Permite deep links internos claros por `routeId`/`nodeId`.

- **SharedPreferences**
  - Persistencia local simple y suficiente para la etapa actual.
  - Guarda progreso, streak, XP, badges y metadatos de usuario.

- **JSON local en assets**
  - Contenido editable sin recompilar lógica.
  - Permite escalar a más rutas reutilizando el mismo motor.

---

## 3. Estructura de carpetas

```text
lib/
  app/
  core/
    responsive/
    theme/
    widgets/
  features/
    home/
    learning/
      data/
      models/
      state/
    lesson_flow/
    profile/
```

### Por qué esta estructura

- `app/`: composición global (router, shell, app root, overlays globales)
- `core/`: diseño, tokens, componentes reutilizables y responsive base
- `features/`: dominio por vertical de producto
- `learning/` concentra dominio pedagógico/transversal (contenido, progreso, estado)

Esto evita mezclar UI con reglas de progreso y mantiene responsabilidades claras.

---

## 4. Arquitectura por capas

## 4.1 Capa de contenido (Route Content)

Responsabilidad: cargar y validar rutas desde JSON.

Archivos clave:

- `lib/features/learning/data/route_asset_source.dart`
- `lib/features/learning/data/route_content_repository.dart`
- `lib/features/learning/data/route_content_validator.dart`
- `lib/features/learning/models/learning_models.dart`
- `docs/content/activity_contracts.md`

Decisiones:

- El parser es estricto por tipo de actividad.
- Se eliminó tolerancia a formatos ambiguos legacy.
- Se valida contrato para fallar temprano con errores claros (ids duplicados, exam inválido, campos faltantes, etc.).

Motivo: contenido educativo debe ser confiable; errores silenciosos dañan la experiencia pedagógica.

## 4.2 Capa de progreso (User Progress)

Responsabilidad: fuente única de verdad del avance del usuario.

Archivos clave:

- `lib/features/learning/data/local_progress_store.dart`
- `lib/features/learning/data/progress_repository.dart`
- `lib/features/learning/state/app_state_providers.dart`
- `LearningProgressState` en `learning_models.dart`

Decisiones:

- Estado global centralizado en `AppProgressNotifier`.
- Persistencia encapsulada en repositorio/store, no en widgets.
- Progreso por ruta + métricas globales (XP, streak, badges).

Motivo: Home, Route Detail y Profile deben mostrar siempre la misma data.

## 4.3 Capa de sesión de lección (Lesson Session)

Responsabilidad: estado temporal de una sesión activa.

Archivo clave:

- `lib/features/learning/state/lesson_session_provider.dart`

Controla:

- actividad actual
- respuestas parciales
- orden de opciones/bloques (shuffle)
- validación local
- feedback actual
- score de la sesión

Motivo: separar “lo que pasa durante la lección” del progreso persistido global.

---

## 5. Navegación actual

Archivo clave: `lib/app/app_router.dart`

Se usa `StatefulShellRoute.indexedStack` con 2 ramas principales:

- `/home`
- `/profile`

Flujo principal:

- Home: `/home`
- Detalle de ruta: `/home/route/:routeId`
- Lección de nodo: `/home/route/:routeId/lesson/:nodeId`
- Resultado final de ruta: `/home/route/:routeId/completed`

Motivo de este diseño:

- mantener tabs estables por rama
- navegación declarativa y trazable
- evitar regresiones al volver desde lección/resultado

---

## 6. Shell, responsive y composición de navegación

Archivo clave: `lib/app/quest_shell.dart`

- Mobile: bottom navigation custom (Home/Profile)
- Web/Desktop: rail lateral custom (estilo NavigationRail)
- Welcome inicial full-screen si no hay nombre

`FQBreakpoints` define mobile/tablet/desktop.

Motivo:

- web y mobile no deben “estirar la misma UI”
- cada plataforma tiene patrón de navegación propio

---

## 7. Dominio pedagógico y tipos de actividad

El contrato oficial está en:

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

Validación:

- local/controlada por tipo
- feedback correcto/incorrecto con explicación
- umbrales de aprobación:
  - lección normal: 70%
  - examen final: 80%

Motivo: experiencia pedagógica incremental sin requerir ejecución real de Dart (todavía).

---

## 8. Flujo de aprendizaje

1. Usuario entra a una ruta.
2. Selecciona nodo disponible.
3. Se abre `LessonFlowScreen`.
4. Se recorren pasos (`intro` como pantalla propia + actividades).
5. Se verifica cada actividad y se muestra feedback.
6. Se calcula resultado final de la lección.
7. Se aplica al progreso global si corresponde.
8. Si se completa examen final, se abre resultado especial de ruta.

Archivos clave:

- `lib/features/home/presentation/lesson_route_screen.dart`
- `lib/features/lesson_flow/presentation/lesson_flow_screen.dart`
- `lib/features/lesson_flow/widgets/activity_renderers.dart`
- `lib/features/home/presentation/route_completion_screen.dart`

---

## 9. Progreso, desbloqueo y badges

Reglas implementadas:

- desbloqueo secuencial de nodos
- examen final se desbloquea al completar nodos previos
- completar examen final marca ruta completada
- actualización de XP solo en resultados aprobados
- streak con `lastStudyDate`, `currentStreak`, `bestStreak`
- badges por hitos (primer nodo, 3 lecciones, examen, ruta, etc.)

Archivos clave:

- `local_progress_store.dart`
- `route_progress_mapper.dart`
- `badge_catalog.dart`

Motivo: que el progreso tenga consecuencias reales y visibles.

---

## 10. Notificaciones globales de badges

Archivo clave: `lib/app/global_badge_overlay.dart`

Se usa un host global conectado al `rootNavigator` para mostrar snackbar superior centrado en cualquier pantalla.

Motivo:

- no depender del `Scaffold` local de cada screen
- garantizar feedback inmediato de recompensa sin romper navegación

---

## 11. Sistema visual y design system

`core/theme` y `core/widgets` centralizan identidad:

- colores semánticos (`fq_colors.dart`)
- gradientes (`fq_gradients.dart`)
- tokens de spacing/radius/shadows (`fq_tokens.dart`)
- tipografía (`fq_typography.dart`)
- tema global (`flutter_quest_theme.dart`)
- componentes base (`FQSurfaceCard`, chips, botones, progress bar, etc.)

Motivo:

- consistencia visual
- reducir “magic numbers”
- escalar UI sin duplicación

---

## 12. Carga robusta de rutas y manejo de fallos

- `routeManifestsProvider` define rutas disponibles y dependencias (unlock entre rutas).
- `RouteContentRepository` carga por manifest y cachea.
- Si una ruta falla, se captura por `routeId` y no colapsa toda la app.

Motivo: tolerancia a fallos por contenido y diagnósticos claros en desarrollo.

---

## 13. Persistencia y resiliencia local

Persistencia principal:

- `SharedPreferences` con key versionada (`learning_progress_v2`).

Fallback:

- memoria en `LocalProgressStore` ante `MissingPluginException`.

Motivo:

- evitar que la app se rompa en entornos donde el bridge del plugin no esté listo.

---

## 14. Estado derivado y consistencia entre pantallas

Providers derivados en `app_state_providers.dart`:

- `routeProgressProvider(routeId)`
- `routeUnlockedProvider(routeId)`
- `currentNodeProvider(routeId)`
- `routeCardStateProvider(routeId)`
- `profileSummaryProvider`

Motivo:

- evitar cálculos duplicados en widgets
- Home y Profile leen el mismo estado base, no copias

---

## 15. Icono y branding multiplataforma

Se configuró `flutter_launcher_icons` con:

- `assets/images/LOGO_FC.png`

Genera iconos para Android, iOS, Web, Windows y macOS.

Motivo:

- branding consistente desde el arranque en todas las plataformas.

---

## 16. Qué está preparado para próximas etapas

La arquitectura ya permite crecer hacia:

- más rutas JSON sin cambiar motor base
- nuevos tipos de actividad por renderer
- migración futura a backend/sync
- métricas y gamificación más avanzadas
- ejecución real de código más adelante (si se decide)

Sin necesidad de reescribir navegación o estado global.

---

## 17. Resumen de decisiones clave (el “por qué”)

- **Riverpod**: consistencia y testabilidad del estado.
- **GoRouter**: control fino del flujo y menos errores de navegación.
- **JSON + contrato estricto**: contenido mantenible y validable.
- **Separación contenido/progreso/sesión**: claridad de dominio.
- **Persistencia encapsulada**: widgets limpios y comportamiento estable.
- **Design system**: identidad visual coherente y reusable.
- **Responsive por composición** (no solo escalado): mejor UX en web y mobile.

En conjunto, la app se construyó así para equilibrar:

- velocidad de iteración,
- robustez técnica,
- claridad pedagógica,
- y escalabilidad real de producto.
