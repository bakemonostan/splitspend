import 'package:flutter/material.dart';
import 'package:split_spend/src/core/utils/number_formatters.dart';
import 'package:split_spend/src/features/expenses/models/expense_item.dart';
import 'package:split_spend/src/theme/theme.dart';

class HomeExpenseRowCard extends StatelessWidget {
  const HomeExpenseRowCard({
    super.key,
    required this.expense,
    this.onTap,
  });

  final ExpenseItem expense;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final date = '${expense.spentAt.day.toString().padLeft(2, '0')}/'
        '${expense.spentAt.month.toString().padLeft(2, '0')}/'
        '${expense.spentAt.year}';

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppPalette.neutral900.withValues(alpha: 0.06),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    color: AppPalette.primary50,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.receipt_long_rounded,
                    color: AppPalette.primary600,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        expense.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: AppPalette.neutral900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${expense.groupName} • ${expense.category} • $date',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppPalette.neutral500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  NumberFormatters.formatCurrency(expense.amount),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppPalette.primary600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
