import 'package:flutter/material.dart';
import 'package:split_spend/src/core/utils/number_formatters.dart';
import 'package:split_spend/src/features/expenses/models/expense_split_member.dart';
import 'package:split_spend/src/theme/theme.dart';

class ExpenseSplitBreakdownCard extends StatelessWidget {
  const ExpenseSplitBreakdownCard({
    super.key,
    required this.members,
  });

  final List<ExpenseSplitMember> members;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppPalette.neutral200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(14, 12, 14, 10),
            child: Text(
              'Split Breakdown',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 20,
                color: AppPalette.neutral900,
              ),
            ),
          ),
          for (var i = 0; i < members.length; i++) ...[
            if (i != 0)
              Divider(
                height: 1,
                color: AppPalette.neutral100,
              ),
            _SplitRow(member: members[i]),
          ],
        ],
      ),
    );
  }
}

class _SplitRow extends StatelessWidget {
  const _SplitRow({required this.member});

  final ExpenseSplitMember member;

  @override
  Widget build(BuildContext context) {
    final statusColor = member.statusColorHex != null
        ? Color(member.statusColorHex!)
        : AppPalette.neutral500;
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: AppPalette.neutral100,
            backgroundImage: member.avatarUrl != null && member.avatarUrl!.isNotEmpty
                ? NetworkImage(member.avatarUrl!)
                : null,
            child: member.avatarUrl == null || member.avatarUrl!.isEmpty
                ? const Icon(
                    Icons.person,
                    size: 18,
                    color: AppPalette.neutral500,
                  )
                : null,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member.displayName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: AppPalette.neutral900,
                  ),
                ),
                Text(
                  member.subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppPalette.neutral500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                NumberFormatters.formatCurrency(member.amount),
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: AppPalette.neutral900,
                ),
              ),
              Text(
                member.statusLabel,
                style: TextStyle(
                  fontSize: 12,
                  color: statusColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
