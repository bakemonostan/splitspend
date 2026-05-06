import 'package:flutter/material.dart';
import 'package:split_spend/src/theme/theme.dart';

/// Large "Home" title and subtitle for the home tab.
class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Home',
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
            color: AppPalette.neutral900,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Keep track of shared expenses with friends and family.',
          style: TextStyle(
            fontSize: 15,
            height: 1.35,
            color: AppPalette.neutral500,
          ),
        ),
      ],
    );
  }
}
