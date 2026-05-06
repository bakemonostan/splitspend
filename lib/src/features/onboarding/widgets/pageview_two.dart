import 'package:flutter/material.dart';
import 'package:split_spend/src/theme/theme.dart';
import 'package:split_spend/src/features/onboarding/widgets/onboarding_footer.dart';

class PageViewTwo extends StatelessWidget {
  const PageViewTwo({super.key});

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
              child: const Image(
                image: AssetImage('assets/img/onboarding/page_two.png'),
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: Column(
                children: [
                  const Text(
                    'Split with ease',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 48),
                    child: Text(
                      'Assign expenses to specific people or split them equally among the group.',
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
              child: const Text('Get Started'),
            ),
            const OnboardingFooter(),
          ],
        ),
      ),
    );
  }
}
