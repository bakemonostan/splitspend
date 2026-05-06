import 'package:flutter/material.dart';
import 'package:split_spend/src/theme/theme.dart';
import 'package:split_spend/src/features/onboarding/widgets/onboarding_footer.dart';

class PageViewOne extends StatelessWidget {
  const PageViewOne({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 88, 24, 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image(
                image: AssetImage('assets/img/onboarding/page_one.png'),
                fit: BoxFit.contain,
              ),
            ),
            SizedBox(height: 24),
            // center the text
            Center(
              child: Column(
                children: [
                  Text(
                    'Track your spending',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
                  ),
                  SizedBox(height: 8),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 48),
                    child: Text(
                      'Log shared expenses with your housemates, friends, or teams.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: AppPalette.neutral500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppPalette.primary500,
                foregroundColor: AppPalette.primary10,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {},
              child: Text('Get Started'),
            ),
            const OnboardingFooter(),
          ],
        ),
      ),
    );
  }
}
