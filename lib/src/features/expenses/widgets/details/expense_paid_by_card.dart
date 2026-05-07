import 'package:flutter/material.dart';
import 'package:split_spend/src/theme/theme.dart';

class ExpensePaidByCard extends StatelessWidget {
  const ExpensePaidByCard({
    super.key,
    required this.label,
    required this.payerName,
    required this.spentAt,
  });

  final String label;
  final String payerName;
  final DateTime spentAt;

  @override
  Widget build(BuildContext context) {
    final date = '${spentAt.day.toString().padLeft(2, '0')}/'
        '${spentAt.month.toString().padLeft(2, '0')}/'
        '${spentAt.year}';

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: AppPalette.primary500,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.92),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              CircleAvatar(
                radius: 13,
                backgroundColor: Colors.white.withValues(alpha: 0.88),
                child: const Icon(
                  Icons.person,
                  size: 14,
                  color: AppPalette.primary700,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                payerName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Date',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.92),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            date,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
