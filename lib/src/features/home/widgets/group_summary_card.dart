import 'package:flutter/material.dart';
import 'package:split_spend/src/features/home/models/group_summary.dart';
import 'package:split_spend/src/features/home/widgets/group_card_icon_tile.dart';
import 'package:split_spend/src/theme/theme.dart';

class GroupSummaryCard extends StatelessWidget {
  const GroupSummaryCard({super.key, required this.summary, this.onTap});

  final GroupSummary summary;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppPalette.neutral900.withValues(alpha: 0.07),
            offset: const Offset(0, 4),
            blurRadius: 14,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            child: Row(
              children: [
                GroupCardIconTile(
                  icon: summary.icon,
                  iconColor: summary.iconColor,
                  backgroundColor: summary.iconTileBackground,
                ),
                const SizedBox(width: 14),
                Expanded(child: _GroupTitleAndMembers(summary: summary)),
                _GroupBalanceColumn(summary: summary),
                const SizedBox(width: 2),
                Icon(
                  Icons.chevron_right,
                  color: AppPalette.neutral400,
                  size: 22,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GroupTitleAndMembers extends StatelessWidget {
  const _GroupTitleAndMembers({required this.summary});

  final GroupSummary summary;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          summary.name,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppPalette.neutral900,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(
              Icons.people_outline,
              size: 16,
              color: AppPalette.neutral500,
            ),
            const SizedBox(width: 4),
            Text(
              '${summary.memberCount} members',
              style: TextStyle(
                fontSize: 13,
                color: AppPalette.neutral500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _GroupBalanceColumn extends StatelessWidget {
  const _GroupBalanceColumn({required this.summary});

  final GroupSummary summary;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          summary.statusLabel,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppPalette.neutral500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          summary.amountLabel,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: summary.amountColor,
          ),
        ),
      ],
    );
  }
}
