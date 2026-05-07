import 'package:flutter/material.dart';
import 'package:split_spend/src/features/activity/models/activity_item.dart';
import 'package:split_spend/src/theme/theme.dart';

class ActivityEventTile extends StatelessWidget {
  const ActivityEventTile({
    super.key,
    required this.item,
    required this.currentUserId,
  });

  final ActivityItem item;
  final String currentUserId;

  @override
  Widget build(BuildContext context) {
    final title = _titleFor(item.eventType);
    final actorLabel = item.actorUserId == null
        ? 'System'
        : (item.actorUserId == currentUserId
              ? 'You'
              : (item.actorDisplayName ?? 'Member'));
    final relative = _timeAgo(item.createdAt);
    final icon = _iconFor(item.eventType);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppPalette.neutral100),
      ),
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppPalette.primary50,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppPalette.primary600, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: AppPalette.neutral900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '$actorLabel • ${item.groupName ?? 'Group'}',
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
          const SizedBox(width: 8),
          Text(
            relative,
            style: TextStyle(
              fontSize: 12,
              color: AppPalette.neutral500,
            ),
          ),
        ],
      ),
    );
  }

  static String _titleFor(String eventType) {
    switch (eventType) {
      case 'expense_created':
        return 'Expense created';
      case 'expense_edited':
        return 'Expense edited';
      case 'group_created':
        return 'Group created';
      case 'group_updated':
        return 'Group updated';
      case 'member_added':
        return 'Member added';
      case 'member_removed':
        return 'Member removed';
      case 'member_left':
        return 'Member left';
      default:
        return 'Activity';
    }
  }

  static IconData _iconFor(String eventType) {
    switch (eventType) {
      case 'expense_created':
      case 'expense_edited':
        return Icons.receipt_long_rounded;
      case 'member_added':
      case 'member_removed':
      case 'member_left':
        return Icons.group_outlined;
      case 'group_created':
      case 'group_updated':
        return Icons.groups_rounded;
      default:
        return Icons.bolt_rounded;
    }
  }

  static String _timeAgo(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);
    if (diff.inMinutes < 1) return 'now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    if (diff.inDays < 7) return '${diff.inDays}d';
    return '${time.day.toString().padLeft(2, '0')}/'
        '${time.month.toString().padLeft(2, '0')}';
  }
}
