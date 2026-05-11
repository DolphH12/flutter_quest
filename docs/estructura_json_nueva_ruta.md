# Estructura JSON de Nueva Ruta (v2)

Este archivo describe la estructura recomendada para crear rutas nuevas en Flutter Quest con validación pedagógica más robusta.

Contrato oficial:
- `docs/content/activity_contracts.md`

Implementación real:
- `lib/features/learning/models/learning_models.dart`
- `lib/features/learning/data/route_content_validator.dart`
- `lib/features/learning/state/lesson_session_provider.dart`

Publicación editorial:
- `lib/features/learning/state/app_state_providers.dart`
- `routeManifestsProvider`
- `routeReleasePlanProvider`

Importante:
- Registrar una ruta en `assets/content/` no la vuelve pública automáticamente.
- Flutter Quest publica contenido por ventanas editoriales:
  - rutas ya liberadas,
  - una sola ruta visible como `próximamente`,
  - rutas restantes ocultas hasta futuras publicaciones.

---

## 1) Ruta

```json
{
  "routeId": "my_new_route",
  "title": { "es": "Mi Ruta", "en": "My Route" },
  "description": { "es": "Descripción", "en": "Description" },
  "icon": "route_dart",
  "themeColor": "#005E9E",
  "version": 2,
  "estimatedMinutes": 120,
  "examNodeId": "my_final_exam",
  "nodes": []
}
```

---

## 2) Nodo

```json
{
  "id": "node_intro",
  "title": { "es": "Introducción", "en": "Introduction" },
  "shortDescription": { "es": "Resumen breve", "en": "Short summary" },
  "icon": "rocket_launch",
  "nodeType": "lesson",
  "xpReward": 40,
  "xOffset": 0,
  "steps": []
}
```

---

## 3) Metadatos nuevos para actividades evaluables (v2)

Usa estos campos para evitar ambigüedad:

```json
{
  "validationMode": "multiAnswer",
  "acceptedAnswers": [
    "for (var i = 0; i < 4; i++)",
    "for (var i = 0; i <= 3; i++)"
  ],
  "requiredTokens": ["for", "print", "i++"],
  "forbiddenTokens": ["while"],
  "acceptanceCriteria": [
    "Itera de 0 a 3",
    "Imprime en cada iteración"
  ],
  "customKeywords": ["UserRepository", "loadProducts", "setState"],
  "namingPolicy": "flexible",
  "suggestedName": "UserRepository",
  "errorTolerance": {
    "allowMissingSemicolon": true,
    "allowWhitespaceVariance": true,
    "allowQuoteStyleVariance": true
  },
  "prerequisites": ["dart_loops"]
}
```

### `validationMode`
- `exact`
- `multiAnswer`
- `containsTokens`
- `regex`

### `namingPolicy`
- `fixed`: nombre obligatorio exacto
- `flexible`: nombre sugerido pero no obligatorio

---

## 4) Ejemplo recomendado de `guidedWriting` claro

```json
{
  "id": "gw_products_1",
  "type": "guidedWriting",
  "instructions": {
    "es": "Completa el método para cargar productos y manejar loading.",
    "en": "Complete the method to load products and handle loading state."
  },
  "starterCode": {
    "es": "Future<void> loadProducts() async {\n  setState(() {\n    isLoading = true;\n  });\n\n  // TODO\n\n  setState(() {\n    isLoading = false;\n  });\n}",
    "en": "Future<void> loadProducts() async {\n  setState(() {\n    isLoading = true;\n  });\n\n  // TODO\n\n  setState(() {\n    isLoading = false;\n  });\n}"
  },
  "expectedFragments": {
    "es": ["await", "setState", "isLoading = false"],
    "en": ["await", "setState", "isLoading = false"]
  },
  "validationMode": "containsTokens",
  "requiredTokens": {
    "es": ["await", "setState", "isLoading = false"],
    "en": ["await", "setState", "isLoading = false"]
  },
  "acceptanceCriteria": {
    "es": [
      "Debe activar loading antes de la llamada async",
      "Debe esperar la carga con await",
      "Debe desactivar loading al finalizar"
    ],
    "en": [
      "Turn loading on before async call",
      "Use await for the loading call",
      "Turn loading off when finished"
    ]
  },
  "customKeywords": {
    "es": ["loadProducts", "setState", "isLoading", "repository"],
    "en": ["loadProducts", "setState", "isLoading", "repository"]
  },
  "correctExplanation": {
    "es": "Excelente: cubres loading y llamada async correctamente.",
    "en": "Great: loading flow and async call are correctly handled."
  },
  "incorrectExplanation": {
    "es": "Faltan partes clave del flujo de loading o de la llamada async.",
    "en": "Key loading or async flow parts are missing."
  },
  "xpReward": 20
}
```

---

## 5) Reglas editoriales mínimas

1. No introducir conceptos antes de su nodo.
2. Si un nombre es obligatorio, indicarlo explícitamente en `acceptanceCriteria` y `namingPolicy`.
3. Si hay más de una solución válida, usar `multiAnswer` o token-based validation.
4. Evitar ejercicios de “adivinanza” en examenes finales.
