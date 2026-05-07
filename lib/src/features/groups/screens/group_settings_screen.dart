import 'package:flutter/material.dart';
import 'package:split_spend/src/core/ui/app_toast.dart';
import 'package:split_spend/src/features/groups/data/groups_repository.dart';
import 'package:split_spend/src/features/groups/models/group_member_display.dart';
import 'package:split_spend/src/features/groups/widgets/group_settings/dashed_add_member_button.dart';
import 'package:split_spend/src/features/groups/widgets/group_settings/group_danger_zone_card.dart';
import 'package:split_spend/src/features/groups/widgets/group_settings/group_identity_card.dart';
import 'package:split_spend/src/features/groups/widgets/group_settings/group_members_section.dart';
import 'package:split_spend/src/features/home/models/group_summary.dart';
import 'package:split_spend/src/theme/theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Group details / settings — owners manage members; others are read-only except leave.
class GroupSettingsScreen extends StatefulWidget {
  const GroupSettingsScreen({super.key, required this.summary});

  final GroupSummary summary;

  @override
  State<GroupSettingsScreen> createState() => _GroupSettingsScreenState();
}

class _GroupSettingsScreenState extends State<GroupSettingsScreen> {
  late GroupSummary _summary;
  late final GroupsRepository _repo;
  List<GroupMemberDisplay>? _members;
  Object? _loadError;

  @override
  void initState() {
    super.initState();
    _summary = widget.summary;
    _repo = GroupsRepository(Supabase.instance.client);
    _loadMembers();
  }

  String? get _groupId => _summary.id;

  String get _currentUserId =>
      Supabase.instance.client.auth.currentUser?.id ?? '';

  Future<void> _loadMembers() async {
    final gid = _groupId;
    if (gid == null) {
      return;
    }
    setState(() {
      _members = null;
      _loadError = null;
    });
    try {
      final list = await _repo.fetchGroupMembers(gid);
      if (mounted) {
        setState(() => _members = list);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loadError = e);
      }
    }
  }

  Future<void> _editName() async {
    final nameOrNull = await showDialog<String>(
      context: context,
      builder: (ctx) => _EditGroupNameDialog(initialName: _summary.name),
    );
    if (nameOrNull == null || !mounted) {
      return;
    }
    final name = nameOrNull.trim();
    if (name.length < 2) {
      await AppToast.error('Name too short');
      return;
    }
    final gid = _groupId;
    if (gid == null) {
      return;
    }
    try {
      await _repo.updateGroupName(groupId: gid, name: name);
      if (mounted) {
        setState(() => _summary = _summary.copyWith(name: name));
        await AppToast.success('Group updated');
      }
    } catch (_) {
      if (mounted) {
        await AppToast.error('Could not update group');
      }
    }
  }

  Future<void> _confirmRemove(GroupMemberDisplay member) async {
    final yes = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove member?'),
        content: Text(
          '${member.displayName ?? 'This member'} will lose access to this group.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (yes != true || !mounted) {
      return;
    }
    final gid = _groupId;
    if (gid == null) {
      return;
    }
    try {
      await _repo.removeMember(groupId: gid, targetUserId: member.userId);
      if (mounted) {
        await AppToast.success('Member removed');
        await _loadMembers();
        setState(() {
          _summary = _summary.copyWith(
            memberCount: (_summary.memberCount - 1).clamp(1, 999999),
          );
        });
      }
    } catch (_) {
      if (mounted) {
        await AppToast.error('Could not remove member');
      }
    }
  }

  Future<void> _leave() async {
    final yes = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Leave group?'),
        content: const Text(
          'You will lose access to this group until someone invites you again.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Leave'),
          ),
        ],
      ),
    );
    if (yes != true || !mounted) {
      return;
    }
    final gid = _groupId;
    if (gid == null) {
      return;
    }
    try {
      await _repo.leaveGroup(gid);
      if (!mounted) {
        return;
      }
      await AppToast.success('Left group');
      if (!mounted) {
        return;
      }
      Navigator.of(context).pop(true);
    } catch (_) {
      if (mounted) {
        await AppToast.error('Could not leave group');
      }
    }
  }

  Future<void> _deleteGroup() async {
    final yes = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete group forever?'),
        content: const Text(
          'This removes the group and related data for everyone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (yes != true || !mounted) {
      return;
    }
    final gid = _groupId;
    if (gid == null) {
      return;
    }
    try {
      await _repo.deleteGroup(gid);
      if (!mounted) {
        return;
      }
      await AppToast.success('Group deleted');
      if (!mounted) {
        return;
      }
      Navigator.of(context).pop(true);
    } catch (_) {
      if (mounted) {
        await AppToast.error('Could not delete group');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final gid = _groupId;
    final owner = _summary.isOwner;
    final invite = _summary.inviteCode ?? '';

    if (gid == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Group'),
          backgroundColor: Colors.white,
          foregroundColor: AppPalette.neutral900,
          surfaceTintColor: Colors.transparent,
        ),
        body: const Center(
          child: Text('This group is not linked to the server.'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: AppPalette.neutral900,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.of(context).pop(false),
        ),
        title: const Text(
          'Group Settings',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_outlined, color: AppPalette.neutral600),
            onPressed: () {},
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppPalette.primary500,
        onRefresh: _loadMembers,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          children: [
            GroupIdentityCard(
              summary: _summary,
              isOwner: owner,
              onEditPressed: owner ? _editName : null,
            ),
            const SizedBox(height: 28),
            if (_loadError != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  'Could not load members',
                  style: TextStyle(color: AppPalette.neutral600),
                ),
              ),
            GroupMembersSection(
              members: _members ?? [],
              currentUserId: _currentUserId,
              viewerIsOwner: owner,
              loading: _members == null,
              onRemoveMember: owner ? _confirmRemove : null,
            ),
            if (owner) ...[
              const SizedBox(height: 20),
              DashedAddMemberButton(inviteCode: invite),
            ],
            const SizedBox(height: 28),
            GroupDangerZoneCard(
              showDeleteGroup: owner,
              onDeleteGroup: owner ? _deleteGroup : null,
              onLeaveGroup: _leave,
            ),
          ],
        ),
      ),
    );
  }
}

/// Owns [TextEditingController] so it is disposed only after the route is torn down
/// (avoids "used after disposed" during dialog dismiss animation).
class _EditGroupNameDialog extends StatefulWidget {
  const _EditGroupNameDialog({required this.initialName});

  final String initialName;

  @override
  State<_EditGroupNameDialog> createState() => _EditGroupNameDialogState();
}

class _EditGroupNameDialogState extends State<_EditGroupNameDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialName);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit group name'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        decoration: const InputDecoration(labelText: 'Group name'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, _controller.text),
          child: const Text('Save'),
        ),
      ],
    );
  }
}
