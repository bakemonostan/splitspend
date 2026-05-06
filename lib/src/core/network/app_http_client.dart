import 'package:dio/dio.dart';
import 'package:split_spend/src/core/config/supabase_env.dart';
import 'package:split_spend/src/core/network/api_error.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Dio instance for **custom** HTTP (Edge Functions or external REST).  
/// Supabase DB/Auth via `Supabase.instance.client` does not need this.
class AppHttpClient {
  AppHttpClient._();

  static Dio? _instance;

  static String _resolvedBaseUrl() {
    if (SupabaseEnv.apiBaseUrl.isNotEmpty) {
      return SupabaseEnv.apiBaseUrl;
    }
    final u = SupabaseEnv.url;
    if (u.isEmpty) return '';
    return '${u.replaceAll(RegExp(r'/$'), '')}/functions/v1';
  }

  static Dio get instance {
    _instance ??= _create();
    return _instance!;
  }

  static Dio _create() {
    final dio = Dio(
      BaseOptions(
        baseUrl: _resolvedBaseUrl(),
        connectTimeout: const Duration(minutes: 5),
        receiveTimeout: const Duration(minutes: 5),
        headers: const {'Content-Type': 'application/json'},
        validateStatus: (s) => s != null && s < 500,
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token =
              Supabase.instance.client.auth.currentSession?.accessToken;
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onResponse: (response, handler) {
          final code = response.statusCode;
          if (code == 401) {
            Supabase.instance.client.auth.signOut();
          }
          return handler.next(response);
        },
        onError: (e, handler) async {
          if (e.response?.statusCode == 401) {
            await Supabase.instance.client.auth.signOut();
          }
          return handler.next(e);
        },
      ),
    );

    return dio;
  }

  static ApiError toApiError(DioException e) => ApiError.fromDio(e);
}
