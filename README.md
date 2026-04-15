<table border="0">
  <tr>
    <td>
      <img src="assets/images/LOGO_FC.png" width="400"> 
    </td>
    <td>
      <h1>Flutter Quest</h1>
      <p>Flutter Quest is a gamified educational app to learn Dart and Flutter through routes, nodes, and interactive lessons.</p>
      <p>Flutter Quest es una app educativa gamificada para aprender Dart y Flutter mediante rutas, nodos y lecciones interactivas.</p>
    </td>
  </tr>
</table>

## Project Vision / Visión

**EN**
- Build a premium learning experience focused on practical progression.
- Teach by short theory + practice + feedback.
- Keep progress meaningful through XP, badges, streak, and route completion.

**ES**
- Construir una experiencia de aprendizaje premium con progresión práctica.
- Enseñar con teoría corta + práctica + feedback.
- Hacer que el progreso importe con XP, insignias, racha y cierre de rutas.

## Architecture / Arquitectura

### Technical Stack
- Flutter (mobile + web)
- Riverpod (single source of truth for app state)
- GoRouter (declarative navigation)
- Local JSON content (routes, nodes, activities)
- SharedPreferences (local progress persistence)
- flutter_local_notifications (habit reminders)

### State Boundaries
- **Content State**: routes and lessons loaded from JSON assets.
- **Progress State**: XP, completed nodes/routes, streak, badges, user preferences.
- **Lesson Session State**: temporary lesson runtime state (current step, answers, validation).

### Content Contract
- All activity schemas are defined in:
  - [`activity_contracts.md`](docs/content/activity_contracts.md)
- New route JSON must comply with this contract.

## How To Run / Cómo correr

### Prerequisites
- Flutter SDK (stable)
- Dart SDK (bundled with Flutter)

### Commands
```bash
flutter pub get
flutter run
```

Optional checks:
```bash
flutter analyze
```

## Add a New Route / Cómo agregar una nueva ruta

1. Create the JSON file in `assets/content/`.
2. Follow the schema from:
   - [`activity_contracts.md`](docs/content/activity_contracts.md)
   - [`estructura_json_nueva_ruta.md`](docs/estructura_json_nueva_ruta.md)
3. Register the route manifest in:
   - [`app_state_providers.dart`](`lib/features/learning/state/app_state_providers.dart`)
   - `routeManifestsProvider`
5. If needed, define unlock dependency (`requiredCompletedRouteId`).
6. Run the app and verify route rendering and lesson flow.

## Open Source Model / Modelo Open Source

This project uses:
- `AGPL-3.0-only` as public open-source license [`LICENSE`](LICENSE.md).
- Commercial licensing options [`LICENSE-COMMERCIAL.md`](LICENSE-COMMERCIAL.md).

Any commercial usage outside AGPL obligations requires a commercial license.
Any deployment or reuse must preserve creation credit to **Dolph Hincapie**.

## Contributing / Contribuir

Please read:
- [`CONTRIBUTING.md`](CONTRIBUTING.md)
- [`CODE_OF_CONDUCT.md`](CODE_OF_CONDUCT.md)
- [`SECURITY.md`](SECURITY.md)

Main branch receives PRs directly (`main` workflow).

## Security / Seguridad

Report vulnerabilities responsibly to:
- [`dolph.hincapie26@gmail.com`](dolph.hincapie26@gmail.com)

## Maintainer

- **Dolph Hincapie**
