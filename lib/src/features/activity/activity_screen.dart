import 'package:flutter/material.dart';
import 'package:split_spend/src/theme/theme.dart';

class ActivityScreen extends StatelessWidget {
  const ActivityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.white,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Recent expenses and updates will show up here.',
                style: TextStyle(
                  fontSize: 15,
                  color: AppPalette.neutral500,
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: Center(
                  child: Icon(
                    Icons.receipt_long_outlined,
                    size: 64,
                    color: AppPalette.neutral300,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
