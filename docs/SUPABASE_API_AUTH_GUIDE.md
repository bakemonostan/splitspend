# SplitSpend — Supabase, API layer, and auth routing (Flutter)

Step-by-step guide to implement: Supabase auth, session-aware navigation (home vs sign-in), and a Dio-style HTTP layer (headers + error handling similar to axios interceptors).

**Prereqs:** Flutter SDK matches `pubspec.yaml`, a Supabase project (URL + anon key).

---

## Implemented in this repo

| Piece | Location |
|-------|----------|
| `SUPABASE_URL` / `SUPABASE_ANON_KEY` / optional `API_BASE_URL`, `SUPABASE_REDIRECT_URL` | `lib/src/core/config/supabase_env.dart` |
| `main.dart` → `Supabase.initialize`, `AuthGate` | `lib/main.dart` |
| Session routing: signed in → `HomeScreen`, else → `SigninScreen` | `lib/src/app/auth_gate.dart` |
| Dio + Bearer + 401 → `signOut()` | `lib/src/core/network/app_http_client.dart` |
| Typed API errors | `lib/src/core/network/api_error.dart` |
| Sign in / sign up / reset password | `lib/src/features/auth/screens/*.dart` |
| Missing keys screen | `lib/src/app/missing_supabase_config_screen.dart` |

**Run (replace with your project values):**

```bash
flutter run \
  --dart-define=SUPABASE_URL=https://YOUR_REF.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=your_anon_key
```

Optional:

```bash
--dart-define=API_BASE_URL=https://custom.api      # overrides default …/functions/v1
--dart-define=SUPABASE_REDIRECT_URL=myapp://recovery  # password reset deep link
```

---

## Part A — Add dependencies

1. Already added: **`supabase_flutter`**, **`dio`**. Optional later: **`flutter_secure_storage`**.

2. Run:

   ```bash
   flutter pub get
   ```

---

## Part B — Supabase project & configuration

1. In [Supabase Dashboard](https://supabase.com/dashboard) → your project → **Project Settings → API** — copy **Project URL** and **anon public** key.

2. **Do not commit secrets** to git. Common patterns:
   - **`--dart-define=SUPABASE_URL=...`** and **`--dart-define=SUPABASE_ANON_KEY=...`** when running or building, or
   - A `.env` file (gitignored) + a small loader package — only if you standardize that in the repo.

3. If you use **password recovery / magic links / OAuth**, configure **Auth → URL configuration** and redirect URLs in Supabase.

---

## Part C — Initialize Supabase before `runApp`

1. In `lib/main.dart`, ensure:

   ```dart
   WidgetsFlutterBinding.ensureInitialized();
   await Supabase.initialize(
     url: yourSupabaseUrl,
     anonKey: yourSupabaseAnonKey,
   );
   runApp(const MyApp());
   ```

2. Make `main()` `async` so `await Supabase.initialize` completes. This restores the user session from storage on cold start.

---

## Part D — Wire auth to your existing screens

Your screens live under `lib/src/features/auth/screens/`. Replace the `// TODO` placeholders with real calls:

| Screen | Typical Supabase call |
|--------|------------------------|
| Sign in | `Supabase.instance.client.auth.signInWithPassword(email: …, password: …)` |
| Sign up | `Supabase.instance.client.auth.signUp(email: …, password: …)` |
| Sign out | `Supabase.instance.client.auth.signOut()` |
| Forgot password | `resetPasswordForEmail(...)` — align with Supabase email templates and redirect URL |

Catch **`AuthException`** (or generic errors), map to user-visible messages (SnackBar / inline).

---

## Part E — “Protected routes” / correct first screen

**Goal:** If logged in → show **home**. If not → show **sign-in** (or onboarding, if you prefer that flow).

### Option 1 — Root widget listens to auth (simple)

1. **`Supabase.instance.client.auth.currentSession`** — non-null means a session exists (check `currentUser` too if you need profile).

2. Listen with **`auth.onAuthStateChange`** and call `setState` (or update a `ValueNotifier` / `ChangeNotifier`) when `AuthChangeEvent.signedIn` / `signedOut` / `tokenRefreshed` fires.

3. At the **root** of the app (above or inside `MaterialApp`), swap `home:` / child:
   - Session present → your **home** or **shell** widget
   - No session → **SigninScreen** / **PageViewBuilder** (onboarding), etc.

4. On first frame, show a **short loading** placeholder until the first auth resolution (avoids flashing the wrong screen).

### Option 2 — `go_router` + `redirect` (scales like SPA “protected routes”)

1. Add **`go_router`** to `pubspec.yaml`.

2. Define routes, e.g. `/`, `/login`, `/onboarding`.

3. Use a **`GoRouterRefreshStream`** (or similar) wired to `supabase.auth.onAuthStateChange` so the router rebuilds when auth changes.

4. In **`redirect`**:
   - No user + path is protected → send to `/login`
   - User on `/login` → send to `/` (home)

---

## Part F — Dio client (axios interceptors analogue)

**Use for:** your **own REST API** (`BASE_URL`), not for raw Supabase PostgREST if you already use `SupabaseClient` (that client attaches the session for Supabase endpoints).

1. **Single `Dio` instance** with `baseUrl`, timeouts, default `Content-Type: application/json`.

2. **Request interceptor**
   - Read: `Supabase.instance.client.auth.currentSession?.accessToken`
   - If set: `options.headers['Authorization'] = 'Bearer $token'`

3. **Error interceptor** (`onError`)
   - Parse `DioException.response?.statusCode` and body
   - **401:** `signOut()`, clear local user state, navigate to login (via `go_router` or a global `navigatorKey`)
   - Map other codes to a small **`ApiError`** type (message + optional validation map), similar to your TS layer

4. Export thin helpers: `get`, `post`, etc., so feature code never duplicates headers.

---

## Part G — Optional: secure storage

Supabase Flutter persists its own session. Add **`flutter_secure_storage`** only if you store **other** tokens or secrets. Otherwise skip to keep the stack minimal.

---

## Part H — Suggested folders under `lib/src/`

| Path | Purpose |
|------|--------|
| `core/config/` | Read URL/key from `--dart-define` or env |
| `core/network/` | `dio_client.dart`, interceptors, `api_error.dart` |
| `core/auth/` | Session listener / `AuthGate` / router refresh |
| `features/auth/screens/` | Existing UI — call Supabase from here or from a thin `AuthRepository` |

---

## Part I — Verification checklist

1. **Cold start** with valid saved session → opens **home** without typing password again.

2. **Sign out** → lands on **sign-in** (or your unauthenticated root).

3. **Wrong password** → error shown; remains on sign-in.

4. **Dio request** with logged-in user → request includes **`Authorization: Bearer …`** (verify in logs or a proxy during dev).

5. **API returns 401** → interceptor triggers sign-out / redirect / message per your policy.

---

## Docs in this repo

- **`docs/README.md`** — index of project docs
- **`docs/PRD.md`** — product scope (mentions Supabase for backend)
- **`docs/DESIGN_SYSTEM.md`** — UI tokens

---

## References

- [Supabase — Dart/Flutter client](https://supabase.com/docs/reference/dart/introduction)
- [Dio — Interceptors](https://pub.dev/packages/dio)
- [go_router — Redirection](https://pub.dev/documentation/go_router/latest/topics/Redirection-topic.html)
