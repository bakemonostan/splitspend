import 'package:flutter/material.dart';
import 'package:split_spend/src/theme/theme.dart';
import 'package:split_spend/src/features/onboarding/widgets/onboarding_footer.dart';

class PageViewThree extends StatelessWidget {
  const PageViewThree({super.key, required this.onPrimary});

  final VoidCallback onPrimary;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: const Image(
                image: AssetImage('assets/img/onboarding/page_three.png'),
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: Column(
                children: [
                  const Text(
                    'Scan and save',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 48),
                    child: Text(
                      'Never lose a paper trail. Snap a photo of your receipt and attach it instantly to any expense.',
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
              onPressed: onPrimary,
              child: const Text('Get Started'),
            ),
            const OnboardingFooter(),
          ],
        ),
      ),
    );
  }
}
