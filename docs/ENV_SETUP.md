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

## 3. VS Code / Cursor debugger (F5)

This repo includes **`split_spend/.vscode/launch.json`**: it passes `SUPABASE_URL` and `SUPABASE_ANON_KEY` via **`toolArgs`** so **Run and Debug** works like `flutter run` with `--dart-define`.

1. Open **`split_spend/.vscode/launch.json`**.
2. Replace the two placeholder values with your real project URL and anon (or publishable) key.
3. Pick the right **launch configuration** (dropdown next to the Play button):
   - **`split_spend`** — use when your workspace folder **is** `split_spend`.
   - **`split_spend (monorepo folder open)`** — use when the workspace root is the parent repo (e.g. `net-ninja-flutter`) and `split_spend` is a subfolder.
4. Press **F5** or **Start Debugging**.

**Git:** Prefer keeping **placeholders** in `launch.json` and filling real keys only on your machine—or add `launch.json` to `.gitignore` locally if you commit real keys by mistake.

If `toolArgs` is ignored by your Dart extension version, use **Terminal** and the `flutter run` command from section 2 instead.

## 4. CI / release builds

Pass the same `--dart-define` values in your pipeline’s secret store (GitHub Actions secrets, etc.). Do not echo keys in logs.

## 5. What not to do

- Do not put keys in `pubspec.yaml`, Dart source, or committed `.env` files.
- Do not use **secret** / **service_role** keys in the mobile app (they bypass RLS).

## 6. If keys were exposed

Rotate keys in Supabase Dashboard → API, and update your local/command-line defines.
