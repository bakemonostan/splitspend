# Where to put Supabase keys (safely)

Your app reads config at **compile time** via `--dart-define` (see `lib/src/core/config/supabase_env.dart`). **Do not** commit real keys into the repo.

## 1. Required values

| Variable | Example shape | Notes |
|----------|----------------|--------|
| `SUPABASE_URL` | `https://<project-ref>.supabase.co` | From Project Settings → General (Project ID / URL). |
| `SUPABASE_ANON_KEY` | Long `eyJ...` JWT **or** new `sb_publishable_...` | Use whatever Supabase labels **anon / public / publishable** for **client** apps. **Never** use the **secret** / `service_role` key in Flutter. |

## 2. Run from terminal (safe)

```bash
cd split_spend

flutter run \
  --dart-define=SUPABASE_URL=https://YOUR_PROJECT_REF.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=your_public_anon_or_publishable_key
```

Replace placeholders locally; do not paste keys into tracked files.

## 3. VS Code / Cursor (local only)

- Create **`.vscode/launch.json`** (optional) with `"toolArgs"` or `args` containing `--dart-define=...`, **or**
- Use a **task** / script that wraps `flutter run` with defines.

Keep `launch.json` **out of git** if it contains secrets, **or** use placeholder defines and each developer copies locally.

## 4. CI / release builds

Pass the same `--dart-define` values in your pipeline’s secret store (GitHub Actions secrets, etc.). Do not echo keys in logs.

## 5. What not to do

- Do not put keys in `pubspec.yaml`, Dart source, or committed `.env` files.
- Do not use **secret** / **service_role** keys in the mobile app (they bypass RLS).

## 6. If keys were exposed

Rotate keys in Supabase Dashboard → API, and update your local/command-line defines.
