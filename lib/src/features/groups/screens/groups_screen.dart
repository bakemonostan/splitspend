import 'package:flutter/material.dart';
import 'package:split_spend/src/core/ui/app_toast.dart';
import 'package:split_spend/src/features/groups/data/groups_repository.dart';
import 'package:split_spend/src/features/groups/screens/create_group_screen.dart';
import 'package:split_spend/src/features/groups/screens/group_settings_screen.dart';
import 'package:split_spend/src/features/groups/screens/join_group_screen.dart';
import 'package:split_spend/src/features/groups/widgets/groups_header.dart';
import 'package:split_spend/src/features/groups/widgets/start_something_new_card.dart';
import 'package:split_spend/src/features/home/models/group_summary.dart';
import 'package:split_spend/src/features/home/widgets/group_summary_card.dart';
import 'package:split_spend/src/theme/theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class GroupsScreen extends StatefulWidget {
  const GroupsScreen({super.key, this.refreshSignal});

  /// Increment from outside (e.g. global FAB after create) to reload the list.
  final ValueNotifier<int>? refreshSignal;

  @override
  State<GroupsScreen> createState() => _GroupsScreenState();
}

class _GroupsScreenState extends State<GroupsScreen> {
  late final GroupsRepository _repo;
  List<GroupSummary>? _groups;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _repo = GroupsRepository(Supabase.instance.client);
    widget.refreshSignal?.addListener(_onExternalRefresh);
    _load();
  }

  @override
  void dispose() {
    widget.refreshSignal?.removeListener(_onExternalRefresh);
    super.dispose();
  }

  void _onExternalRefresh() => _load();

  Future<void> _load() async {
    setState(() {
      _groups = null;
      _error = null;
    });
    try {
      final list = await _repo.fetchMyGroups();
      if (mounted) {
        setState(() => _groups = list);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _error = e);
      }
    }
  }

  Future<void> _openCreate() async {
    final ok = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const CreateGroupScreen()),
    );
    if (ok == true && mounted) {
      await _load();
    }
  }

  Future<void> _openJoin() async {
    final ok = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const JoinGroupScreen()),
    );
    if (ok == true && mounted) {
      await AppToast.success('Joined group');
      await _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.background,
      child: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: _load,
          color: AppPalette.primary500,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    const GroupsHeader(),
                    const SizedBox(height: 24),
                    _buildBody(),
                    const SizedBox(height: 100),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_error != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Could not load groups',
            style: TextStyle(color: AppPalette.neutral700),
          ),
          const SizedBox(height: 8),
          TextButton(onPressed: _load, child: const Text('Retry')),
        ],
      );
    }
    if (_groups == null) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 48),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final groups = _groups!;
    if (groups.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          StartSomethingNewCard(
            onCreateGroup: _openCreate,
            onJoinWithCode: _openJoin,
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ...groups.map(
          (g) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: GroupSummaryCard(
              summary: g,
              onTap: g.id == null
                  ? null
                  : () async {
                      final changed = await Navigator.of(context).push<bool>(
                        MaterialPageRoute<bool>(
                          builder: (_) => GroupSettingsScreen(summary: g),
                        ),
                      );
                      if (changed == true && mounted) {
                        await _load();
                      }
                    },
            ),
          ),
        ),
        const SizedBox(height: 8),
        StartSomethingNewCard(
          onCreateGroup: _openCreate,
          onJoinWithCode: _openJoin,
        ),
      ],
    );
  }
}
