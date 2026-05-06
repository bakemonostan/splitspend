import 'package:dio/dio.dart';

/// Normalized API failure for UI / logging.
class ApiError implements Exception {
  ApiError({
    required this.message,
    this.statusCode,
    this.errors,
  });

  final String message;
  final int? statusCode;
  final Map<String, dynamic>? errors;

  static ApiError fromDio(DioException e) {
    final res = e.response;
    final code = res?.statusCode;
    final data = res?.data;
    String msg = e.message ?? 'Request failed';
    Map<String, dynamic>? fieldErrors;

    if (data is Map) {
      final m = Map<String, dynamic>.from(data);
      msg = (m['message'] as String?) ??
          (m['error'] as String?) ??
          (m['msg'] as String?) ??
          msg;
      if (m['errors'] is Map) {
        fieldErrors = Map<String, dynamic>.from(m['errors']! as Map);
      }
    }

    switch (code) {
      case 401:
        msg = msg.isNotEmpty ? msg : 'Session expired. Please sign in again.';
        break;
      case 403:
        msg = msg.isNotEmpty ? msg : 'You do not have permission.';
        break;
      case 404:
        msg = msg.isNotEmpty ? msg : 'Not found.';
        break;
      default:
        break;
    }

    return ApiError(
      message: msg,
      statusCode: code,
      errors: fieldErrors,
    );
  }

  @override
  String toString() => 'ApiError($statusCode): $message';
}
