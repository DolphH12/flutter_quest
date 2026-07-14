# Contributing to Flutter Quest

Gracias por contribuir a Flutter Quest.
Thanks for contributing to Flutter Quest.

## 1) Before You Start

1. Read:
- `README.md`
- `docs/content/activity_contracts.md`
- `docs/estructura_json_nueva_ruta.md`
- if touching daily challenges, also review `lib/features/daily_challenge/`

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

Optional local env for daily challenges:

```bash
cp .env.example .env
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
- If changing challenge behavior, keep route progression and challenge progression clearly separated.

## 5) Content (JSON Routes) Rules

- Use only allowed activity types.
- Keep one structure per activity `type`.
- Use localized fields where applicable (`es` / `en`).
- Validate route semantics:
  - unique node ids,
  - unique activity ids,
  - valid `examNodeId`.

## 6) Route Release Policy

- A route existing in `assets/content/` does **not** mean it is publicly visible in the app.
- Public exposure is staged:
  - live route(s),
  - one visible `Coming soon` teaser,
  - remaining routes hidden until future releases.
- Route order in `routeManifestsProvider` matters.
- Public release cadence is controlled in:
  - `lib/features/learning/state/app_state_providers.dart`
  - `routeReleasePlanProvider`
- When contributing a new route:
  - add the JSON,
  - register the manifest,
  - keep it hidden unless the maintainer explicitly decides to publish it.

## 6.1) Daily Challenge Rules

- Daily challenges are loaded from Supabase, not from route JSON.
- The active day is resolved from the user's **local device date**.
- The main daily challenge grants XP.
- The recent backlog shows the last 7 previous days.
- Previous unresolved challenges can be played for practice only.
- Previous backlog challenges must not grant XP.
- Correctly completed backlog challenges must remain visibly completed and non-replayable.
- Failed backlog challenges must remain visible as `No logrado` / `Not achieved`.
- Recent challenges should open from already loaded data first; network fetch is fallback only.
- Retry/error states must avoid infinite loaders.
- If you change challenge payload assumptions, update the README and architecture docs in the same PR.

## 7) Commit Style

Suggested conventional style:
- `feat: ...`
- `fix: ...`
- `docs: ...`
- `refactor: ...`

## 8) Pull Request Checklist

Before opening PR:
- [ ] `flutter analyze` passes.
- [ ] No unrelated file changes.
- [ ] UI changes include screenshot/GIF.
- [ ] JSON changes comply with contract docs.
- [ ] Route visibility/release policy was preserved.
- [ ] README/docs updated if behavior changed.

## 9) Review Expectations

PRs may be asked to:
- reduce scope,
- improve naming and architecture boundaries,
- improve UX copy and states,
- split into smaller PRs.

## 10) License & Attribution

By contributing, you agree your contribution is distributed under:
- AGPL-3.0-only (`LICENSE`), and
- the project's dual-licensing model (`LICENSE-COMMERCIAL.md`).

All usage/distribution must preserve creator credit:
- **Created by Dolph Hincapie**
