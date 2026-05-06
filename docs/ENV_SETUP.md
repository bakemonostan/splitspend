# Where to put Supabase keys (safely)

Your app reads config at **compile time** via `--dart-define` (see `lib/src/core/config/supabase_env.dart`). **Do not** commit real keys into the repo.

## 1. Required values

| Variable | Example shape | Notes |
|----------|----------------|--------|
| `SUPABASE_URL` | `https://<project-ref>.supabase.co` | From Project Settings → General (Project ID / URL). |
| `SUPABASE_ANON_KEY` | Long `eyJ...` JWT **or** new `sb_publishable_...` | Use whatever Supabase labels **anon / public / publishable** for **client** apps. **Never** use the **secret** / `service_role` key in Flutter. |

## 2. Run from terminal (safe)

```bash
# Open **split_spend** as the workspace folder in Cursor/VS Code, then:

flutter run \
  --dart-define=SUPABASE_URL=https://YOUR_PROJECT_REF.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=your_public_anon_or_publishable_key
```

Replace placeholders locally; do not paste keys into tracked files.

## 3. VS Code / Cursor debugger (F5)

Use **`split_spend` as the workspace root** (File → Open Folder → `split_spend`). Debug config lives at **`.vscode/launch.json`** inside that folder.

The debug config passes **`--dart-define-from-file=dart_defines.local.json`**. That file is **gitignored** so keys are not committed.

1. Copy **`dart_defines.example.json`** → **`dart_defines.local.json`** in the `split_spend` folder (same directory as `pubspec.yaml`).
2. Put your real `SUPABASE_URL` and `SUPABASE_ANON_KEY` in **`dart_defines.local.json`**.
3. **Run and Debug** (sidebar) → choose **`Flutter (SplitSpend + Supabase)`** in the dropdown (not “default” or another target).
4. **F5** — do a **full stop** of the old run first. After you change defines, **hot restart is not enough**; stop the app and **run again** so Flutter recompiles.

**Why you still see “Supabase not configured”:** The defines are baked in at **compile** time. If you run with the **green play** in the editor without the right launch config, run **`flutter run` with no flags**, use **Xcode / Android Studio Run** without passing defines, or open the **parent folder** instead of `split_spend`, the built app will not include your keys.

If defines still do not apply, run from terminal (section 2) to confirm keys work, then verify the launch name and that **`dart_defines.local.json`** exists next to `pubspec.yaml`.

## 4. CI / release builds

Pass the same `--dart-define` values in your pipeline’s secret store (GitHub Actions secrets, etc.). Do not echo keys in logs.

## 5. What not to do

- Do not put keys in `pubspec.yaml`, Dart source, or committed `.env` files.
- Do not use **secret** / **service_role** keys in the mobile app (they bypass RLS).

## 6. If keys were exposed

Rotate keys in Supabase Dashboard → API, and update your local/command-line defines.
