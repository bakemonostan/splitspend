import 'package:flutter/material.dart';
import 'package:split_spend/src/features/auth/widgets/auth_input_decoration.dart';
import 'package:split_spend/src/theme/theme.dart';

/// Full-width teal primary CTA (sign in / create account).
class AuthPrimaryButton extends StatelessWidget {
  const AuthPrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
  });

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: AppPalette.primary500,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppPalette.primary200,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(kAuthFieldRadius),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
