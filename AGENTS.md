# AGENTS

## Stack

- Flutter (Android only), Dart package `ahorra_app`.
- State and dependency injection: Riverpod (`flutter_riverpod`).
- Local database: Drift (SQLite), pinned to 2.34 because `drift_dev >=2.35` needs a newer `meta` than Flutter allows.
- Backend: `ahorra-api` (separate repo, FastAPI). This repo has no Docker.

## Commands

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter analyze
flutter test
flutter run
```

## Project rules

- The app is offline-first: the UI reads only from Drift, never directly from the API.
- Writes go to Drift first, then to the `core/sync` queue that sends them to the API.
- Features never import each other; shared code goes in `core/`.
- `domain/` is pure Dart: no Flutter, Drift, or HTTP imports.
- Every money amount stores its currency and the exchange rate in effect when it was recorded; history is never recalculated.
- Never use `double` for money.
- Single user: login only, no sign-up screen.
- Generated files (`*.g.dart`) are never edited by hand.
- UI copy, code, and comments are in English; `docs/` is in Spanish.

## Documentation

`docs/` is the source of truth. Before implementing, read `docs/README.md`,
`docs/00-vision.md`, `docs/01-architecture.md`, and the affected
`docs/areas/*.md`. After finishing, follow the `project-docs` skill.

Tasks and ADRs live in FunWork (project Ahorra, id 2, area frontend), not in
this repo. Create the task in FunWork and set it to `Doing` before starting
work; set it to `Done` with the commit when finished.

## Skills

General conventions come from installed skills (`clean-code`,
`testing-strategy`, `error-handling`, `ui-design`,
`android-design-guidelines`). Flutter, Riverpod, and Drift APIs come from
their official documentation.
