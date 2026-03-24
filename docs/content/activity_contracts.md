# activity_contracts.md

## Objetivo

Este documento define el **contrato oficial de actividades** para Flutter Quest.

Su propósito es evitar deriva de esquema entre rutas, lecciones y tipos de ejercicios.  
A partir de este documento:

- cada `type` tiene **una única estructura oficial**
- los parsers deben validar contra esta estructura
- los JSON de contenido deben respetar este contrato
- cualquier nuevo tipo de actividad debe agregarse aquí antes de usarse

---

## Principios generales

### 1. Un `type`, una estructura
Cada tipo de actividad debe tener **un solo formato permitido**.  
No se deben aceptar múltiples variantes para el mismo `type`.

Ejemplo correcto:
- `matchConcept` siempre usa `pairs`

Ejemplo incorrecto:
- unas veces `pairs`
- otras veces `matchLeft`, `matchRight` y `correctMatches`

---

### 2. Campos comunes
Toda actividad debe incluir como mínimo:

- `id`
- `type`

Y según el tipo, deberá incluir sus campos obligatorios específicos.

---

### 3. Explicaciones obligatorias
Toda actividad evaluable debe incluir:

- `correctExplanation`
- `incorrectExplanation`

Esto garantiza feedback pedagógico consistente.

---

### 4. Recompensa explícita
Toda actividad evaluable debe incluir:

- `xpReward`

Los pasos `intro` no necesitan `xpReward`.

---

### 5. Orden aleatorio por defecto
Los elementos interactivos que consisten en opciones, bloques, pares o listas comparables deben mostrarse **en desorden por defecto**, salvo que el tipo exija explícitamente un orden fijo.

Esto aplica especialmente a:

- `multipleChoice`
- `matchConcept`
- `orderCodeBlocks`
- `findTheWrongLine` si tiene opciones auxiliares
- `predictOutput`

La idea es evitar que el usuario memorice posición en lugar de aprender el concepto.

---

### 6. Campo `shuffle`
Para controlar esto de forma explícita, los tipos que lo permitan deben soportar:

- `shuffle: true` → desordenar al renderizar
- `shuffle: false` → respetar orden exacto del JSON

**Regla general:**  
Si un tipo soporta desorden y el campo `shuffle` no existe, debe asumirse:

```json
"shuffle": true
```

**Excepciones comunes:**
- `intro` → no aplica
- `guidedWriting` → no aplica
- `completeSnippet` → no aplica
- `fillInTheCode` → no aplica
- `fixTheBug` → normalmente no aplica
- `orderCodeBlocks` → los bloques visibles deben desordenarse, pero `correctOrder` siempre conserva el orden correcto
- `findTheWrongLine` → las líneas del código deben respetar el snippet original; no se deben desordenar

---

## Estructura raíz de una ruta

```json
{
  "routeId": "dart_route",
  "title": "Dart",
  "description": "Fundamentos del lenguaje Dart.",
  "icon": "route_dart",
  "themeColor": "#005E9E",
  "version": 1,
  "estimatedMinutes": 180,
  "examNodeId": "dart_final_exam",
  "nodes": []
}
```

### Campos de ruta

- `routeId`: identificador único de la ruta
- `title`: nombre visible de la ruta
- `description`: descripción general
- `icon`: icono representativo de la ruta
- `themeColor`: color principal asociado
- `version`: versión del contenido
- `estimatedMinutes`: tiempo estimado de la ruta
- `examNodeId`: id del nodo final de examen
- `nodes`: lista de nodos/lecciones

---

## Estructura de un nodo

```json
{
  "id": "dart_intro",
  "title": "Introducción a Dart",
  "shortDescription": "Qué es Dart y cómo luce un programa simple.",
  "icon": "rocket_launch",
  "nodeType": "lesson",
  "xpReward": 30,
  "steps": []
}
```

### Campos de nodo

- `id`: identificador único del nodo
- `title`: nombre visible
- `shortDescription`: resumen breve
- `icon`: icono del nodo en el mapa
- `nodeType`: `lesson` o `exam`
- `xpReward`: XP total estimada del nodo
- `steps`: lista de pasos/actividades

---

# Tipos oficiales de actividad

---

## 1. `intro`

### Propósito
Explicar un concepto antes de evaluar o practicar.

### Estructura oficial

```json
{
  "id": "intro_1",
  "type": "intro",
  "title": "Bienvenido a Dart",
  "body": "Dart es un lenguaje moderno...",
  "example": "void main() { print('Hola'); }"
}
```

### Campos
- `id` obligatorio
- `type` obligatorio
- `title` obligatorio
- `body` obligatorio
- `example` opcional pero recomendado

### Reglas
- no lleva `xpReward`
- no lleva `correctExplanation`
- no lleva `incorrectExplanation`
- no se evalúa
- no se desordena

---

## 2. `multipleChoice`

### Propósito
Validar comprensión conceptual con una sola respuesta correcta.

### Estructura oficial

```json
{
  "id": "mc_1",
  "type": "multipleChoice",
  "question": "¿Qué función inicia un programa Dart?",
  "options": ["start()", "main()", "run()", "init()"],
  "correctAnswer": "main()",
  "correctExplanation": "main() es el punto de entrada.",
  "incorrectExplanation": "La respuesta correcta es main().",
  "xpReward": 10,
  "shuffle": true
}
```

### Campos
- `id` obligatorio
- `type` obligatorio
- `question` obligatorio
- `options` obligatorio
- `correctAnswer` obligatorio
- `correctExplanation` obligatorio
- `incorrectExplanation` obligatorio
- `xpReward` obligatorio
- `shuffle` opcional

### Reglas
- `correctAnswer` debe existir dentro de `options`
- las `options` deben mostrarse desordenadas por defecto
- si `shuffle` es `false`, se mantiene el orden del JSON

---

## 3. `fillInTheCode`

### Propósito
Completar una parte faltante de una línea o snippet simple.

### Estructura oficial

```json
{
  "id": "fic_1",
  "type": "fillInTheCode",
  "prompt": "Completa el tipo correcto.",
  "initialCode": "_____ age = 28;",
  "expectedAnswer": "int",
  "correctExplanation": "int representa números enteros.",
  "incorrectExplanation": "Para 28 debes usar int.",
  "hint": "Piensa en enteros.",
  "xpReward": 12
}
```

### Campos
- `id` obligatorio
- `type` obligatorio
- `prompt` obligatorio
- `initialCode` obligatorio
- `expectedAnswer` obligatorio
- `correctExplanation` obligatorio
- `incorrectExplanation` obligatorio
- `xpReward` obligatorio
- `hint` opcional

### Reglas
- `initialCode` debe contener un hueco lógico para completar
- no se desordena
- la validación debe usar comparación controlada según las reglas del app renderer

---

## 4. `completeSnippet`

### Propósito
Completar una parte clave de un snippet más guiado.

### Estructura oficial

```json
{
  "id": "cs_1",
  "type": "completeSnippet",
  "prompt": "Completa la función de entrada.",
  "initialCode": "void _____() {\n  print('Hola');\n}",
  "expectedAnswer": "main",
  "correctExplanation": "main es la entrada del programa.",
  "incorrectExplanation": "La función correcta es main.",
  "hint": "Es el punto de entrada.",
  "xpReward": 15
}
```

### Campos
- `id` obligatorio
- `type` obligatorio
- `prompt` obligatorio
- `initialCode` obligatorio
- `expectedAnswer` obligatorio
- `correctExplanation` obligatorio
- `incorrectExplanation` obligatorio
- `hint` opcional
- `xpReward` obligatorio

### Reglas
- no se desordena
- debe sentirse como completar una parte esencial del snippet

---

## 5. `fixTheBug`

### Propósito
Corregir una línea o snippet con error.

### Estructura oficial

```json
{
  "id": "ftb_1",
  "type": "fixTheBug",
  "prompt": "Corrige la línea para comparar igualdad.",
  "initialCode": "if (level = 5) {\n  print('Nivel exacto');\n}",
  "expectedAnswer": "if (level == 5) {\n  print('Nivel exacto');\n}",
  "correctExplanation": "Debes comparar con ==.",
  "incorrectExplanation": "El error está en usar = en vez de ==.",
  "hint": "Uno asigna, el otro compara.",
  "xpReward": 15
}
```

### Campos
- `id` obligatorio
- `type` obligatorio
- `prompt` obligatorio
- `initialCode` obligatorio
- `expectedAnswer` obligatorio
- `correctExplanation` obligatorio
- `incorrectExplanation` obligatorio
- `hint` opcional
- `xpReward` obligatorio

### Reglas
- no se desordena
- debe mostrar el snippet original exactamente en el orden correcto
- el usuario debe editar o corregir el código

---

## 6. `orderCodeBlocks`

### Propósito
Ordenar líneas o bloques en el orden correcto.

### Estructura oficial

```json
{
  "id": "ocb_1",
  "type": "orderCodeBlocks",
  "prompt": "Ordena el snippet correctamente.",
  "blocks": [
    "children: [",
    "Column(",
    "Text('Hola'),",
    "Text('Flutter'),",
    "],",
    ")"
  ],
  "correctOrder": [
    "Column(",
    "children: [",
    "Text('Hola'),",
    "Text('Flutter'),",
    "],",
    ")"
  ],
  "correctExplanation": "Primero el contenedor y luego sus hijos.",
  "incorrectExplanation": "Revisa el orden natural del widget y sus children.",
  "xpReward": 20,
  "shuffle": true
}
```

### Campos
- `id` obligatorio
- `type` obligatorio
- `prompt` obligatorio
- `blocks` obligatorio
- `correctOrder` obligatorio
- `correctExplanation` obligatorio
- `incorrectExplanation` obligatorio
- `xpReward` obligatorio
- `shuffle` opcional

### Reglas
- `blocks` representa el conjunto visible al usuario
- `correctOrder` define el orden exacto correcto
- visualmente los bloques deben mostrarse desordenados por defecto
- si `shuffle` no existe, asumir `true`

---

## 7. `findTheWrongLine`

### Propósito
Identificar cuál línea de un snippet es incorrecta.

### Estructura oficial

```json
{
  "id": "fwl_1",
  "type": "findTheWrongLine",
  "prompt": "Identifica la línea incorrecta.",
  "codeLines": [
    "return Scaffold(",
    "  title: const Text('Inicio'),",
    "  body: const Center(child: Text('Hola')),",
    ");"
  ],
  "wrongLineIndex": 1,
  "correctExplanation": "Scaffold no tiene la propiedad title.",
  "incorrectExplanation": "La línea incorrecta es la que intenta usar title directamente en Scaffold.",
  "xpReward": 15
}
```

### Campos
- `id` obligatorio
- `type` obligatorio
- `prompt` obligatorio
- `codeLines` obligatorio
- `wrongLineIndex` obligatorio
- `correctExplanation` obligatorio
- `incorrectExplanation` obligatorio
- `xpReward` obligatorio

### Reglas
- `codeLines` debe conservar el orden real del snippet
- **nunca** se deben desordenar las líneas
- `wrongLineIndex` es índice base 0

---

## 8. `matchConcept`

### Propósito
Relacionar conceptos con definiciones, ejemplos o responsabilidades.

### Estructura oficial

```json
{
  "id": "mcpt_1",
  "type": "matchConcept",
  "prompt": "Relaciona cada concepto con su definición correcta.",
  "pairs": [
    { "left": "Future", "right": "Valor que llegará de forma asíncrona" },
    { "left": "nullable", "right": "Tipo que puede aceptar null" },
    { "left": "loop for", "right": "Permite repetir instrucciones varias veces" }
  ],
  "correctExplanation": "Excelente conexión de conceptos.",
  "incorrectExplanation": "Revisa cada relación con más calma.",
  "xpReward": 20,
  "shuffle": true
}
```

### Campos
- `id` obligatorio
- `type` obligatorio
- `prompt` obligatorio
- `pairs` obligatorio
- `correctExplanation` obligatorio
- `incorrectExplanation` obligatorio
- `xpReward` obligatorio
- `shuffle` opcional

### Reglas
- `pairs` es la **única** forma válida para este tipo
- cada item debe tener:
  - `left`
  - `right`
- no usar:
  - `matchLeft`
  - `matchRight`
  - `correctMatches`
- al renderizar:
  - la columna izquierda puede mantenerse estable
  - la columna derecha debe desordenarse por defecto
- si `shuffle` no existe, asumir `true`

### Forma prohibida
Esto **no** debe volver a usarse:

```json
{
  "type": "matchConcept",
  "matchLeft": ["Future"],
  "matchRight": ["Valor que llegará de forma asíncrona"],
  "correctMatches": {
    "Future": "Valor que llegará de forma asíncrona"
  }
}
```

---

## 9. `predictOutput`

### Propósito
Predecir la salida de un snippet.

### Estructura oficial

```json
{
  "id": "po_1",
  "type": "predictOutput",
  "question": "¿Cuál sería la salida?",
  "codeSnippet": "print(2 + 3);",
  "options": ["23", "5", "2 + 3", "Error"],
  "correctAnswer": "5",
  "correctExplanation": "2 + 3 se evalúa antes de imprimirse.",
  "incorrectExplanation": "La salida correcta del snippet es 5.",
  "xpReward": 15,
  "shuffle": true
}
```

### Campos
- `id` obligatorio
- `type` obligatorio
- `question` obligatorio
- `codeSnippet` obligatorio
- `options` obligatorio
- `correctAnswer` obligatorio
- `correctExplanation` obligatorio
- `incorrectExplanation` obligatorio
- `xpReward` obligatorio
- `shuffle` opcional

### Reglas
- `correctAnswer` debe existir dentro de `options`
- las opciones deben mostrarse desordenadas por defecto

---

## 10. `guidedWriting`

### Propósito
Ejercicio de escritura guiada con reglas simples de validación.

### Estructura oficial

```json
{
  "id": "gw_1",
  "type": "guidedWriting",
  "instructions": "Escribe el fragmento necesario para agregar padding uniforme de 16.",
  "starterCode": "Padding(\n  _____\n  child: Text('Hola'),\n)",
  "expectedFragments": ["padding:", "EdgeInsets.all(16)"],
  "correctExplanation": "Padding recibe la propiedad padding con EdgeInsets.all(16).",
  "incorrectExplanation": "Tu respuesta debe incluir padding y EdgeInsets.all(16).",
  "hint": "La propiedad se llama igual que el widget.",
  "xpReward": 20
}
```

### Campos
- `id` obligatorio
- `type` obligatorio
- `instructions` obligatorio
- `starterCode` obligatorio
- `expectedFragments` obligatorio
- `correctExplanation` obligatorio
- `incorrectExplanation` obligatorio
- `hint` opcional
- `xpReward` obligatorio

### Reglas
- no se desordena
- `expectedFragments` define piezas mínimas esperadas en la respuesta
- ideal para ejercicios donde varias soluciones cercanas son válidas mientras contengan partes clave

---

# Convenciones generales de presentación

## Texto pedagógico
- `title`, `body`, `prompt`, `question`, `instructions` deben venir redactados de forma clara y breve
- tono consistente con Flutter Quest:
  - claro
  - cercano
  - didáctico
  - con humor ligero
  - sin sacrificar claridad

---

## Campos de explicación

### `correctExplanation`
Debe:
- reafirmar el concepto correcto
- explicar por qué está bien
- reforzar aprendizaje

### `incorrectExplanation`
Debe:
- explicar por qué falló
- orientar al concepto correcto
- evitar respuestas secas o ambiguas

---

## `xpReward`
- siempre numérico
- siempre entero
- no string
- obligatorio en actividades evaluables

---

## `icon`
Los nodos deben incluir `icon` como string que luego se mapea a `IconData`.

Ejemplos válidos:
- `rocket_launch`
- `data_object`
- `loop`
- `functions`
- `verified_user`
- `bug_report`
- `workspace_premium`

Si el icono falla:
- el renderer debe usar fallback elegante

---

## `nodeType`
Valores permitidos:
- `lesson`
- `exam`

No usar valores alternativos sin documentarlos primero aquí.

---

# Reglas de validación del parser

Si un JSON no cumple el contrato del `type`, el parser debe fallar con error claro.

Ejemplos:
- `multipleChoice requires options and correctAnswer`
- `matchConcept requires pairs`
- `orderCodeBlocks requires blocks and correctOrder`
- `guidedWriting requires starterCode and expectedFragments`

No se deben aceptar variantes implícitas o ambiguas.

---

# Resumen de desorden aleatorio por tipo

| Type | ¿Se desordena? | Regla |
|---|---:|---|
| `intro` | No | Orden fijo |
| `multipleChoice` | Sí | `shuffle = true` por defecto |
| `fillInTheCode` | No | Orden fijo |
| `completeSnippet` | No | Orden fijo |
| `fixTheBug` | No | Orden fijo |
| `orderCodeBlocks` | Sí | Bloques visibles se mezclan; `correctOrder` no |
| `findTheWrongLine` | No | Las líneas deben respetar el snippet |
| `matchConcept` | Sí | La columna derecha se desordena por defecto |
| `predictOutput` | Sí | Opciones desordenadas por defecto |
| `guidedWriting` | No | Orden fijo |

---

# Recomendación operativa para futuras rutas

Antes de crear o modificar JSON de una ruta:

1. revisar este documento
2. confirmar el `type`
3. copiar la estructura oficial correspondiente
4. completar los campos obligatorios
5. evitar inventar nombres nuevos de campos
6. validar el archivo antes de integrarlo

---

# Estado actual de estandarización

A partir de ahora, este documento define el contrato oficial de actividades de Flutter Quest.

Cualquier JSON nuevo debe construirse con base en estas estructuras.
Si un nuevo tipo de actividad aparece, primero debe documentarse aquí.
