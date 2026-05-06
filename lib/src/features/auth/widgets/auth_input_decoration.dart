import 'package:flutter/material.dart';
import 'package:split_spend/src/theme/theme.dart';

/// Corner radius for auth text fields and primary buttons.
const double kAuthFieldRadius = 6;

OutlineInputBorder _authOutline(double radius, Color color) {
  return OutlineInputBorder(
    borderRadius: BorderRadius.circular(radius),
    borderSide: BorderSide(color: color),
  );
}

/// Shared [InputDecoration] for sign-in / sign-up fields (borders + error states).
InputDecoration buildAuthInputDecoration({
  required String hintText,
  Widget? prefixIcon,
  Widget? suffixIcon,
  double radius = kAuthFieldRadius,
}) {
  return InputDecoration(
    hintText: hintText,
    hintStyle: const TextStyle(
      fontSize: 15,
      color: AppPalette.neutral400,
      fontWeight: FontWeight.w400,
    ),
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    border: _authOutline(radius, AppPalette.neutral200),
    enabledBorder: _authOutline(radius, AppPalette.neutral200),
    focusedBorder: _authOutline(radius, AppPalette.primary500),
    errorBorder: _authOutline(radius, AppPalette.tertiary400),
    focusedErrorBorder: _authOutline(radius, AppPalette.tertiary500),
    prefixIcon: prefixIcon,
    prefixIconConstraints: const BoxConstraints(minWidth: 48, minHeight: 48),
    suffixIcon: suffixIcon,
    suffixIconConstraints: const BoxConstraints(minWidth: 48, minHeight: 48),
    errorStyle: const TextStyle(fontSize: 12, height: 1.2),
  );
}
