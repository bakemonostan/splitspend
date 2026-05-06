import 'package:flutter/material.dart';
import 'package:split_spend/src/theme/theme.dart';

class GroupSummary {
  const GroupSummary({
    required this.name,
    required this.memberCount,
    required this.statusLabel,
    required this.amountLabel,
    required this.amountColor,
    required this.icon,
    required this.iconBackground,
  });

  final String name;
  final int memberCount;
  final String statusLabel;
  final String amountLabel;
  final Color amountColor;
  final IconData icon;
  final Color iconBackground;
}

class GroupSummaryCard extends StatelessWidget {
  const GroupSummaryCard({super.key, required this.summary, this.onTap});

  final GroupSummary summary;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: summary.iconBackground,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(summary.icon, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
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
                ),
              ),
              Column(
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
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.chevron_right,
                color: AppPalette.neutral400,
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
