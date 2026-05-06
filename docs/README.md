# SplitSpend Docs

This folder contains the core product and design documentation for the `split_spend` Flutter app.

## What is SplitSpend?

SplitSpend is a mobile-first expense sharing app for small groups (housemates, friends, teams).  
The current Flutter app already includes an onboarding flow with 3 pages and custom visual styling.

## Docs in this folder

- `PRD.md`  
  Product requirements for MVP scope, user flows, acceptance criteria, and high-level data model.
- `DESIGN_SYSTEM.md`  
  UI tokens, component rules, spacing, typography, and accessibility guidance.
- `SUPABASE_API_AUTH_GUIDE.md`  
  Step-by-step: Supabase init, auth, protected navigation, and Dio-style API clients.
- `ENV_SETUP.md`  
  Where to put URL/anon keys safely (`--dart-define`, no secrets in git).

## Current app snapshot (implementation)

- **Stack:** Flutter (Dart)
- **Entry point:** `lib/main.dart`
- **Onboarding widgets:**
  - `lib/src/features/onboarding/widgets/pageview_builder.dart`
  - `lib/src/features/onboarding/widgets/pageview_one.dart`
  - `lib/src/features/onboarding/widgets/pageview_two.dart`
  - `lib/src/features/onboarding/widgets/pageview_three.dart`
- **Theme tokens:** `lib/src/theme/theme.dart`
- **Onboarding assets:**
  - `assets/img/onboarding/page_one.png`
  - `assets/img/onboarding/page_two.png`
  - `assets/img/onboarding/page_three.png`

## Run locally

From project root (`split_spend`):

```bash
flutter pub get
flutter run
```

## Validate changes

Use analyze after edits:

```bash
flutter analyze
```

If you only changed onboarding widgets, you can target those files directly for faster checks.

## Notes

- Keep implementation simple and consistent with existing onboarding structure.
- Prefer reusing `AppPalette` tokens from `lib/src/theme/theme.dart`.
- When adding new image assets, register them in `pubspec.yaml` under `flutter.assets`.
