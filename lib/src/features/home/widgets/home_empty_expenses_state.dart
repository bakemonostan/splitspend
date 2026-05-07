import 'package:flutter/material.dart';
import 'package:split_spend/src/theme/theme.dart';

class HomeEmptyExpensesState extends StatelessWidget {
  const HomeEmptyExpensesState({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 22, 18, 22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppPalette.neutral100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 40,
            color: AppPalette.neutral400,
          ),
          const SizedBox(height: 12),
          const Text(
            'No expenses yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppPalette.neutral900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Your created expenses will appear here.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppPalette.neutral500, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
