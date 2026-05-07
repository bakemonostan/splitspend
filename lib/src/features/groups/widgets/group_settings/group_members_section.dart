import 'package:flutter/material.dart';
import 'package:split_spend/src/features/groups/models/group_member_display.dart';
import 'package:split_spend/src/features/groups/widgets/group_settings/group_member_tile.dart';
import 'package:split_spend/src/theme/theme.dart';

class GroupMembersSection extends StatelessWidget {
  const GroupMembersSection({
    super.key,
    required this.members,
    required this.currentUserId,
    required this.viewerIsOwner,
    this.onRemoveMember,
    this.loading = false,
  });

  final List<GroupMemberDisplay> members;
  final String currentUserId;
  final bool viewerIsOwner;
  final void Function(GroupMemberDisplay member)? onRemoveMember;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Text(
              'Group Members',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: AppPalette.neutral900,
              ),
            ),
            const Spacer(),
            if (!loading)
              Text(
                '${members.length} Members',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppPalette.primary600,
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        if (loading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(child: CircularProgressIndicator()),
          )
        else
          Column(
            children: [
              for (final m in members)
                GroupMemberTile(
                  member: m,
                  currentUserId: currentUserId,
                  viewerIsOwner: viewerIsOwner,
                  onRemove:
                      viewerIsOwner &&
                          !m.isOwner &&
                          m.userId != currentUserId &&
                          onRemoveMember != null
                      ? () => onRemoveMember!(m)
                      : null,
                ),
            ],
          ),
      ],
    );
  }
}
