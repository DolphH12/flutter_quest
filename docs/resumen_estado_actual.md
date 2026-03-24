# Flutter Quest - Resumen de avance

## Estado general
Flutter Quest ya pasó de una base visual estática a una experiencia inicial de aprendizaje funcional con contenido mock.

Hoy el proyecto incluye:
- Identidad visual base premium (paleta azul, gradientes, profundidad tonal, componentes reutilizables).
- Flujo principal centrado en rutas y nodos.
- Lecciones funcionales mock con validación local.

---

## ETAPA 1 (completada)
En la ETAPA 1 se construyó la base de producto:

- Estructura de proyecto por capas (`app`, `core`, `features`).
- Tema global personalizado (`FlutterQuestTheme`).
- Sistema responsive inicial.
- Navegación principal base.
- Pantallas visuales placeholder.

Además, se hicieron iteraciones de diseño para reforzar:
- jerarquía visual,
- identidad de componentes,
- look menos dashboard y más gamificado,
- foco del Home en ruta de aprendizaje.

---

## Cambio de dirección aplicado
Se aplicó la simplificación de experiencia solicitada:

- La navegación principal ahora es solo:
  - Home
  - Profile
- Lessons y Challenges se removieron temporalmente del nav principal.
- El aprendizaje ocurre desde:
  - Home -> Ruta -> Nodo -> Lección

---

## ETAPA 2 (completada)
Se implementó el flujo base de aprendizaje:

1. `Home` con listado de rutas mock.
2. `RouteDetail` con nodos por ruta (estados: completed, active, locked).
3. `LessonFlowScreen` al tocar nodos disponibles.

### Lección funcional mock
Cada lección incluye:
- Header con progreso y XP potencial.
- Microteoría breve.
- 2 ejercicios funcionales:
  - Multiple choice
  - Fill in the blank
- Validación local mock.
- Feedback visual correcto/incorrecto.
- CTA de avance (`Verificar`, `Continuar`, `Finalizar`).
- Estado final de resultado.

---

## Arquitectura actual (aprendizaje)
Se agregó una base preparada para crecer:

- `features/learning/models/learning_models.dart`
  - `LearningRoute`
  - `LearningNode`
  - `LessonContent`
  - `ExerciseItem`
  - `ExerciseType`

- `features/learning/data/mock_learning_content.dart`
  - rutas mock
  - nodos mock
  - lecciones mock (`Dart Basics`, `Variables`, `Control Flow`)

- `features/lesson_flow/presentation/lesson_flow_screen.dart`
  - orquestación del flujo de lección
  - render por tipo de ejercicio
  - validación local

---

## Flujo de uso actual
1. Entrar a Home.
2. Elegir una ruta disponible.
3. Tocar un nodo activo/completado.
4. Resolver ejercicios de la lección.
5. Ver resultado final y volver a la ruta.

---

## Qué NO está implementado aún
Sigue pendiente (intencionalmente):
- JSON real de contenido.
- Persistencia local real.
- Desbloqueo/progreso real.
- Backend.
- Ejecución real de código Dart.
- Más tipos de ejercicio avanzados.

---

## Próximo paso recomendado (ETAPA 3)
- Conectar contenido desde JSON (sin backend aún).
- Persistir progreso local mínimo.
- Definir reglas de desbloqueo básicas.
- Agregar al menos un nuevo tipo de ejercicio (ej: corregir error).
