import 'package:flutter/material.dart';
import 'package:split_spend/src/features/groups/models/group_member_display.dart';
import 'package:split_spend/src/theme/theme.dart';

class GroupMemberTile extends StatelessWidget {
  const GroupMemberTile({
    super.key,
    required this.member,
    required this.currentUserId,
    required this.viewerIsOwner,
    this.onRemove,
  });

  final GroupMemberDisplay member;
  final String currentUserId;
  final bool viewerIsOwner;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final title =
        member.displayName?.trim().isNotEmpty == true
            ? member.displayName!.trim()
            : 'Member ${member.shortIdTail}';

    final subtitle =
        member.displayName?.trim().isNotEmpty == true
            ? 'SplitSpend member'
            : 'User …${member.shortIdTail}';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _Avatar(url: member.avatarUrl, label: title),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppPalette.neutral900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppPalette.neutral500,
                  ),
                ),
              ],
            ),
          ),
          if (member.isOwner)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppPalette.primary50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'OWNER',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.6,
                  color: AppPalette.primary600,
                ),
              ),
            )
          else if (viewerIsOwner &&
              onRemove != null &&
              member.userId != currentUserId)
            IconButton(
              onPressed: onRemove,
              icon: Icon(
                Icons.person_remove_alt_1_rounded,
                color: Colors.red.shade400,
                size: 22,
              ),
              tooltip: 'Remove member',
            ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({this.url, required this.label});

  final String? url;
  final String label;

  @override
  Widget build(BuildContext context) {
    final initial = label.isNotEmpty ? label.substring(0, 1).toUpperCase() : '?';

    return CircleAvatar(
      radius: 22,
      backgroundColor: AppPalette.primary100,
      backgroundImage:
          url != null && url!.isNotEmpty ? NetworkImage(url!) : null,
      child: url == null || url!.isEmpty
          ? Text(
              initial,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: AppPalette.primary700,
              ),
            )
          : null,
    );
  }
}
