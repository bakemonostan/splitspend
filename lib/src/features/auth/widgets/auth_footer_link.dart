import 'package:flutter/material.dart';
import 'package:split_spend/src/theme/theme.dart';

/// Muted line + tappable link, e.g. "Don't have an account? Sign up".
class AuthFooterLink extends StatelessWidget {
  const AuthFooterLink({
    super.key,
    required this.leadingText,
    required this.linkText,
    required this.onLinkTap,
  });

  final String leadingText;
  final String linkText;
  final VoidCallback onLinkTap;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text.rich(
        TextSpan(
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: AppPalette.neutral500,
          ),
          children: [
            TextSpan(text: leadingText),
            WidgetSpan(
              alignment: PlaceholderAlignment.baseline,
              baseline: TextBaseline.alphabetic,
              child: GestureDetector(
                onTap: onLinkTap,
                child: Text(
                  linkText,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppPalette.primary500,
                  ),
                ),
              ),
            ),
          ],
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
