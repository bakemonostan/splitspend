import 'package:flutter/material.dart';
import 'package:split_spend/src/theme/theme.dart';

/// Logo + app name used at the top of auth screens.
class AuthBrandHeader extends StatelessWidget {
  const AuthBrandHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Image.asset(
            'assets/img/general/logo_filled.png',
            width: 80,
            height: 80,
          ),
          const SizedBox(height: 12),
          Text(
            'SplitSpend',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppPalette.primary500,
            ),
          ),
        ],
      ),
    );
  }
}
