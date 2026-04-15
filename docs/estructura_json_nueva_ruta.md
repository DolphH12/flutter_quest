# Estructura JSON Para Una Nueva Ruta (Flutter Quest)

Este documento resume la estructura oficial que consume la app actualmente para crear una nueva ruta de aprendizaje.

Referencia base del contrato:
- `docs/content/activity_contracts.md`

Referencia de parser/validación real:
- `lib/features/learning/models/learning_models.dart`
- `lib/features/learning/data/route_content_validator.dart`
- `lib/features/learning/data/route_asset_source.dart`

---

## 1) Estructura raíz de una ruta

```json
{
  "routeId": "my_new_route",
  "title": { "es": "Mi Ruta", "en": "My Route" },
  "description": {
    "es": "Descripción de la ruta.",
    "en": "Route description."
  },
  "icon": "route_dart",
  "themeColor": "#005E9E",
  "version": 1,
  "estimatedMinutes": 120,
  "examNodeId": "my_final_exam",
  "nodes": []
}
```

### Campos
- `routeId`: id único de ruta.
- `title`: nombre visible (localizable recomendado).
- `description`: descripción (localizable recomendado).
- `icon`: string de icono.
- `themeColor`: hex de color principal.
- `version`: versión del contenido.
- `estimatedMinutes`: tiempo estimado.
- `examNodeId`: id del nodo final de examen.
- `nodes`: lista de nodos.

---

## 2) Estructura de nodo

```json
{
  "id": "node_1_intro",
  "title": { "es": "Introducción", "en": "Introduction" },
  "shortDescription": {
    "es": "Resumen breve.",
    "en": "Short summary."
  },
  "icon": "rocket_launch",
  "nodeType": "lesson",
  "xpReward": 30,
  "xOffset": 0.0,
  "steps": []
}
```

### Campos
- `id`: id único del nodo.
- `title`: título visible.
- `shortDescription`: resumen corto.
- `icon`: icono del nodo.
- `nodeType`: `lesson` o `exam`.
- `xpReward`: XP de referencia del nodo.
- `xOffset`: opcional para composición del mapa.
- `steps`: lista de pasos/actividades.

> El nodo con `id == examNodeId` debe existir y tener `nodeType: "exam"`.

---

## 3) Tipos de actividad soportados

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

---

## 4) Estructura exacta por tipo

## `intro`

```json
{
  "id": "intro_1",
  "type": "intro",
  "title": { "es": "Bienvenido", "en": "Welcome" },
  "body": { "es": "Texto breve...", "en": "Short text..." },
  "example": { "es": "void main() {}", "en": "void main() {}" }
}
```

Reglas:
- no lleva `xpReward`
- no se valida como pregunta
- no shuffle

## `multipleChoice`

```json
{
  "id": "mc_1",
  "type": "multipleChoice",
  "question": { "es": "Pregunta", "en": "Question" },
  "options": {
    "es": ["A", "B", "C"],
    "en": ["A", "B", "C"]
  },
  "correctAnswer": { "es": "B", "en": "B" },
  "correctExplanation": { "es": "Correcto porque...", "en": "Correct because..." },
  "incorrectExplanation": { "es": "No, la correcta es...", "en": "No, correct is..." },
  "xpReward": 10,
  "shuffle": true
}
```

Reglas:
- `correctAnswer` debe existir en `options`
- `shuffle` por defecto true

## `fillInTheCode`

```json
{
  "id": "fic_1",
  "type": "fillInTheCode",
  "prompt": { "es": "Completa...", "en": "Complete..." },
  "initialCode": { "es": "_____ age = 20;", "en": "_____ age = 20;" },
  "expectedAnswer": { "es": "int", "en": "int" },
  "correctExplanation": { "es": "Bien.", "en": "Good." },
  "incorrectExplanation": { "es": "Debía ser int.", "en": "It should be int." },
  "hint": { "es": "Es entero", "en": "Think integer" },
  "xpReward": 12
}
```

## `completeSnippet`

```json
{
  "id": "cs_1",
  "type": "completeSnippet",
  "prompt": { "es": "Completa...", "en": "Complete..." },
  "initialCode": { "es": "void _____() {}", "en": "void _____() {}" },
  "expectedAnswer": { "es": "main", "en": "main" },
  "correctExplanation": { "es": "main es entrada.", "en": "main is entrypoint." },
  "incorrectExplanation": { "es": "Debe ser main.", "en": "It must be main." },
  "hint": { "es": "Punto de entrada", "en": "Entry point" },
  "xpReward": 15
}
```

## `fixTheBug`

```json
{
  "id": "bug_1",
  "type": "fixTheBug",
  "prompt": { "es": "Corrige el bug", "en": "Fix the bug" },
  "initialCode": { "es": "if (a = b) {}", "en": "if (a = b) {}" },
  "expectedAnswer": { "es": "if (a == b) {}", "en": "if (a == b) {}" },
  "correctExplanation": { "es": "== compara.", "en": "== compares." },
  "incorrectExplanation": { "es": "Usa ==.", "en": "Use ==." },
  "hint": { "es": "Comparación", "en": "Comparison" },
  "xpReward": 14
}
```

## `orderCodeBlocks`

```json
{
  "id": "ocb_1",
  "type": "orderCodeBlocks",
  "prompt": { "es": "Ordena el código", "en": "Order the code" },
  "blocks": {
    "es": ["void main() {", "print('Hi');", "}"],
    "en": ["void main() {", "print('Hi');", "}"]
  },
  "correctOrder": {
    "es": ["void main() {", "print('Hi');", "}"],
    "en": ["void main() {", "print('Hi');", "}"]
  },
  "correctExplanation": { "es": "Orden correcto.", "en": "Correct order." },
  "incorrectExplanation": { "es": "Revisa secuencia.", "en": "Check sequence." },
  "xpReward": 16,
  "shuffle": true
}
```

Reglas:
- `blocks` y `correctOrder` deben tener mismo tamaño
- mismos elementos en ambos arrays
- `shuffle` por defecto true

## `findTheWrongLine`

```json
{
  "id": "fwl_1",
  "type": "findTheWrongLine",
  "prompt": { "es": "¿Qué línea está mal?", "en": "Which line is wrong?" },
  "codeLines": {
    "es": ["void main() {", "int x = '2';", "}"],
    "en": ["void main() {", "int x = '2';", "}"]
  },
  "wrongLineIndex": 1,
  "correctExplanation": { "es": "Tipo incorrecto.", "en": "Wrong type." },
  "incorrectExplanation": { "es": "No era esa línea.", "en": "Not that line." },
  "xpReward": 12
}
```

Reglas:
- `wrongLineIndex` dentro del rango de `codeLines`
- no shuffle de líneas

## `matchConcept` (solo `pairs`)

```json
{
  "id": "match_1",
  "type": "matchConcept",
  "prompt": { "es": "Relaciona", "en": "Match" },
  "pairs": [
    {
      "left": { "es": "int", "en": "int" },
      "right": { "es": "Entero", "en": "Integer" }
    },
    {
      "left": { "es": "String", "en": "String" },
      "right": { "es": "Texto", "en": "Text" }
    }
  ],
  "correctExplanation": { "es": "Buen match.", "en": "Good match." },
  "incorrectExplanation": { "es": "Revisa pares.", "en": "Review pairs." },
  "xpReward": 14,
  "shuffle": true
}
```

Reglas:
- `pairs` obligatorio
- no usar estructuras legacy (`matchLeft`, `matchRight`, `correctMatches`)

## `predictOutput`

```json
{
  "id": "po_1",
  "type": "predictOutput",
  "question": { "es": "¿Qué imprime?", "en": "What prints?" },
  "codeSnippet": { "es": "print(2 + 3);", "en": "print(2 + 3);" },
  "options": {
    "es": ["23", "5", "2+3"],
    "en": ["23", "5", "2+3"]
  },
  "correctAnswer": { "es": "5", "en": "5" },
  "correctExplanation": { "es": "Suma numérica.", "en": "Numeric sum." },
  "incorrectExplanation": { "es": "No concatena.", "en": "No concatenation." },
  "xpReward": 11,
  "shuffle": true
}
```

## `guidedWriting`

```json
{
  "id": "gw_1",
  "type": "guidedWriting",
  "instructions": { "es": "Escribe una función...", "en": "Write a function..." },
  "starterCode": { "es": "String greet() {\n  \n}", "en": "String greet() {\n  \n}" },
  "expectedFragments": {
    "es": ["return", "Hola"],
    "en": ["return", "Hello"]
  },
  "correctExplanation": { "es": "Incluiste lo esperado.", "en": "Expected fragments included." },
  "incorrectExplanation": { "es": "Faltan fragmentos.", "en": "Missing fragments." },
  "hint": { "es": "Incluye return", "en": "Include return" },
  "xpReward": 18
}
```

---

## 5) Reglas de shuffle

- `multipleChoice`: shuffle default `true`
- `matchConcept`: shuffle default `true`
- `orderCodeBlocks`: shuffle default `true` (solo visual, `correctOrder` no cambia)
- `predictOutput`: shuffle default `true`
- `findTheWrongLine`: **no shuffle**
- `intro`, `fillInTheCode`, `completeSnippet`, `fixTheBug`, `guidedWriting`: no shuffle

---

## 6) Validaciones que rompen carga

- IDs de nodos duplicados.
- IDs de steps duplicados (globales en una ruta).
- `examNodeId` inexistente.
- `examNodeId` apuntando a nodo que no es `exam`.
- nodo sin `steps`.
- `multipleChoice`/`predictOutput`: `correctAnswer` fuera de `options`.
- `findTheWrongLine`: `wrongLineIndex` fuera de rango.
- `orderCodeBlocks`: inconsistencia entre `blocks` y `correctOrder`.
- `matchConcept`: `pairs` ausente o vacío.

---

## 7) Localización en JSON

La app soporta campos localizados como:

```json
"campo": { "es": "texto", "en": "text" }
```

Y también valores simples:

```json
"campo": "texto"
```

Para contenido nuevo se recomienda usar `es/en` en todos los textos de UI.

---

## 8) Plantilla mínima de nueva ruta

```json
{
  "routeId": "new_route",
  "title": { "es": "Nueva Ruta", "en": "New Route" },
  "description": { "es": "Descripción", "en": "Description" },
  "icon": "route_dart",
  "themeColor": "#005E9E",
  "version": 1,
  "estimatedMinutes": 90,
  "examNodeId": "new_route_exam",
  "nodes": [
    {
      "id": "new_route_intro",
      "title": { "es": "Inicio", "en": "Start" },
      "shortDescription": { "es": "Primer paso", "en": "First step" },
      "icon": "rocket_launch",
      "nodeType": "lesson",
      "xpReward": 30,
      "steps": [
        {
          "id": "intro_1",
          "type": "intro",
          "title": { "es": "Bienvenido", "en": "Welcome" },
          "body": { "es": "Comencemos", "en": "Let's start" }
        },
        {
          "id": "mc_1",
          "type": "multipleChoice",
          "question": { "es": "¿2+2?", "en": "2+2?" },
          "options": { "es": ["3", "4"], "en": ["3", "4"] },
          "correctAnswer": { "es": "4", "en": "4" },
          "correctExplanation": { "es": "Exacto", "en": "Correct" },
          "incorrectExplanation": { "es": "Era 4", "en": "It was 4" },
          "xpReward": 10
        }
      ]
    },
    {
      "id": "new_route_exam",
      "title": { "es": "Examen Final", "en": "Final Exam" },
      "shortDescription": { "es": "Validación final", "en": "Final validation" },
      "icon": "military_tech",
      "nodeType": "exam",
      "xpReward": 50,
      "steps": [
        {
          "id": "exam_mc_1",
          "type": "multipleChoice",
          "question": { "es": "Pregunta final", "en": "Final question" },
          "options": { "es": ["A", "B"], "en": ["A", "B"] },
          "correctAnswer": { "es": "A", "en": "A" },
          "correctExplanation": { "es": "Bien", "en": "Good" },
          "incorrectExplanation": { "es": "No", "en": "No" },
          "xpReward": 20
        }
      ]
    }
  ]
}
```
