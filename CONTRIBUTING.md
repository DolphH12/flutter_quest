# Contributing to Flutter Quest

Gracias por contribuir a Flutter Quest.
Thanks for contributing to Flutter Quest.

## 1) Before You Start

1. Read:
- `README.md`
- `docs/content/activity_contracts.md`
- `docs/estructura_json_nueva_ruta.md`

2. Make sure your change has a clear scope:
- bug fix,
- UX improvement,
- content update,
- architecture/refactor.

## 2) Development Setup

```bash
flutter pub get
flutter analyze
flutter run
```

## 3) Branch & PR Flow

Repository flow:
- open PRs directly against `main`.

Recommended branch naming:
- `feat/<short-description>`
- `fix/<short-description>`
- `docs/<short-description>`
- `refactor/<short-description>`

## 4) Coding Guidelines

- Keep Riverpod boundaries clean (no duplicated state sources).
- Avoid business logic inside widgets.
- Respect JSON activity contract.
- Keep UI consistent with current design system.
- Prefer small, focused PRs.

## 5) Content (JSON Routes) Rules

- Use only allowed activity types.
- Keep one structure per activity `type`.
- Use localized fields where applicable (`es` / `en`).
- Validate route semantics:
  - unique node ids,
  - unique activity ids,
  - valid `examNodeId`.

## 6) Commit Style

Suggested conventional style:
- `feat: ...`
- `fix: ...`
- `docs: ...`
- `refactor: ...`

## 7) Pull Request Checklist

Before opening PR:
- [ ] `flutter analyze` passes.
- [ ] No unrelated file changes.
- [ ] UI changes include screenshot/GIF.
- [ ] JSON changes comply with contract docs.
- [ ] README/docs updated if behavior changed.

## 8) Review Expectations

PRs may be asked to:
- reduce scope,
- improve naming and architecture boundaries,
- improve UX copy and states,
- split into smaller PRs.

## 9) License & Attribution

By contributing, you agree your contribution is distributed under:
- AGPL-3.0-only (`LICENSE`), and
- the project's dual-licensing model (`LICENSE-COMMERCIAL.md`).

All usage/distribution must preserve creator credit:
- **Created by Dolph Hincapie**
