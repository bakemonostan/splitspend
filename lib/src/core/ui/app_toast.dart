import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:split_spend/src/theme/theme.dart';

/// Native-style toasts via [fluttertoast] (Android Toast / iOS toast view).
/// For in-scaffold banners, use [ScaffoldMessenger] / [SnackBar] instead.
abstract final class AppToast {
  static Future<void> success(String message) {
    return _show(message, background: AppPalette.primary600);
  }

  /// Non-error notices (e.g. “check your email”).
  static Future<void> info(String message) {
    return _show(message, background: AppPalette.primary700);
  }

  static Future<void> error(String message) {
    return _show(message, background: AppPalette.neutral800);
  }

  static Future<void> _show(String message, {required Color background}) {
    return Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 2,
      backgroundColor: background,
      textColor: Colors.white,
      fontSize: 14,
    );
  }
}
