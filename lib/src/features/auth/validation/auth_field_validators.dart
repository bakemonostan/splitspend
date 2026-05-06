/// Shared field validators (Zod-style: return `null` when valid, else an error string).
abstract final class AuthFieldValidators {
  AuthFieldValidators._();

  static String? fullName(String? value) {
    final s = value?.trim() ?? '';
    if (s.isEmpty) {
      return 'Please enter your full name';
    }
    if (s.length < 2) {
      return 'Enter at least 2 characters';
    }
    return null;
  }

  static String? email(String? value) {
    final s = value?.trim() ?? '';
    if (s.isEmpty) {
      return 'Please enter your email';
    }
    final emailRegex = RegExp(r'^[\w\+\.\-]+@([\w\-]+\.)+[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(s)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  /// Sign-up: enforce minimum length.
  static String? signupPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a password';
    }
    if (value.length < 8) {
      return 'Use at least 8 characters';
    }
    return null;
  }

  /// Sign-in: only require non-empty (server checks the actual password).
  static String? signInPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    return null;
  }
}
