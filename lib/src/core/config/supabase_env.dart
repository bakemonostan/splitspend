import 'dart:convert';

import 'package:flutter/services.dart';

/// Supabase config from `--dart-define` with local asset fallback.
abstract final class SupabaseEnv {
  static String _url = const String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: '',
  );

  static String _anonKey = const String.fromEnvironment(
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

  static String get url => _url;

  static String get anonKey => _anonKey;

  static bool get isConfigured => _url.isNotEmpty && _anonKey.isNotEmpty;

  /// Loads local config when dart-defines are missing.
  static Future<void> load() async {
    if (isConfigured) {
      return;
    }
    try {
      final raw = await rootBundle.loadString('assets/config/supabase.local.json');
      final json = jsonDecode(raw);
      if (json is! Map<String, dynamic>) {
        return;
      }
      _url = (json['SUPABASE_URL'] as String? ?? '').trim();
      _anonKey = (json['SUPABASE_ANON_KEY'] as String? ?? '').trim();
    } catch (_) {
      // Keep empty values when file is missing/invalid.
    }
  }
}
