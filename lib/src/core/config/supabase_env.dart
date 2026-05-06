/// Compile-time config from `--dart-define` (see run command in `docs/SUPABASE_API_AUTH_GUIDE.md`).
abstract final class SupabaseEnv {
  static const String url = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: '',
  );

  static const String anonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: '',
  );

  /// Optional: deep link / universal link for password recovery (Supabase Auth → URL config).
  static const String redirectUrl = String.fromEnvironment(
    'SUPABASE_REDIRECT_URL',
    defaultValue: '',
  );

  /// Optional base for custom REST / Edge Functions. Defaults to …/functions/v1 when empty.
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '',
  );

  static bool get isConfigured => url.isNotEmpty && anonKey.isNotEmpty;
}
