import 'package:flutter/material.dart';
import 'package:split_spend/src/theme/theme.dart';

/// Centered title + subtitle below the brand header.
class AuthHeadline extends StatelessWidget {
  const AuthHeadline({
    super.key,
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: AppPalette.neutral900,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w400,
            color: AppPalette.neutral500,
          ),
        ),
      ],
    );
  }
}
