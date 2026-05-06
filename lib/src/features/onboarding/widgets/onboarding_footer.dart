import 'package:flutter/material.dart';
import 'package:split_spend/src/features/auth/screens/signin_screen.dart';
import 'package:split_spend/src/theme/theme.dart';

class OnboardingFooter extends StatelessWidget {
  const OnboardingFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Already have an account?',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: AppPalette.neutral500,
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SigninScreen()),
              );
            },
            child: Text(
              'Sign in',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: AppPalette.primary500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
