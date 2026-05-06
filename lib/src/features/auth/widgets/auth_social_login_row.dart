import 'package:flutter/material.dart';
import 'package:split_spend/src/features/auth/widgets/auth_input_decoration.dart';
import 'package:split_spend/src/theme/theme.dart';

/// Divider "Or continue with" + Google / Apple outlined buttons.
class AuthSocialLoginRow extends StatelessWidget {
  const AuthSocialLoginRow({
    super.key,
    this.onGoogle,
    this.onApple,
  });

  final VoidCallback? onGoogle;
  final VoidCallback? onApple;

  @override
  Widget build(BuildContext context) {
    final outlineStyle = OutlinedButton.styleFrom(
      foregroundColor: AppPalette.neutral900,
      side: const BorderSide(color: AppPalette.neutral200),
      padding: const EdgeInsets.symmetric(vertical: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(kAuthFieldRadius),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Divider(
                height: 1,
                thickness: 1,
                color: AppPalette.neutral200,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Text(
                'Or continue with',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: AppPalette.neutral500,
                ),
              ),
            ),
            Expanded(
              child: Divider(
                height: 1,
                thickness: 1,
                color: AppPalette.neutral200,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: onGoogle,
                style: outlineStyle,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'G',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF4285F4),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Google',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton(
                onPressed: onApple,
                style: outlineStyle,
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.apple,
                      size: 20,
                      color: AppPalette.neutral900,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'Apple',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
