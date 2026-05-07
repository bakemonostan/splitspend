import 'package:flutter/material.dart';
import 'package:split_spend/src/core/ui/app_toast.dart';
import 'package:split_spend/src/features/groups/screens/create_group_screen.dart';
import 'package:split_spend/src/features/groups/screens/join_group_screen.dart';
import 'package:split_spend/src/features/groups/widgets/start_something_new_card.dart';
import 'package:split_spend/src/features/home/models/group_summary.dart';
import 'package:split_spend/src/features/home/widgets/group_summary_card.dart';
import 'package:split_spend/src/features/home/widgets/home_header.dart';
import 'package:split_spend/src/theme/theme.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, this.groupsRefreshSignal});

  /// When create/join succeeds from Home, bump so the Groups tab reloads.
  final ValueNotifier<int>? groupsRefreshSignal;

  static final List<GroupSummary> _demoGroups = [
    GroupSummary(
      name: 'Flatmates 2024',
      memberCount: 4,
      statusLabel: 'You owe',
      amountLabel: r'$42.50',
      amountColor: const Color(0xFFDC2626),
      icon: Icons.apartment_rounded,
      iconColor: AppPalette.primary600,
      iconTileBackground: AppPalette.primary100,
      category: 'home',
    ),
    GroupSummary(
      name: 'Tokyo Trip',
      memberCount: 6,
      statusLabel: 'Settled',
      amountLabel: r'$0.00',
      amountColor: const Color(0xFF16A34A),
      icon: Icons.flight_rounded,
      iconColor: const Color(0xFF2563EB),
      iconTileBackground: const Color(0xFFDBEAFE),
      category: 'trip',
    ),
    GroupSummary(
      name: 'Dinner Club',
      memberCount: 8,
      statusLabel: 'Owes you',
      amountLabel: r'$115.20',
      amountColor: const Color(0xFF16A34A),
      icon: Icons.restaurant_rounded,
      iconColor: AppPalette.tertiary600,
      iconTileBackground: AppPalette.tertiary100,
      category: 'event',
    ),
  ];

  Future<void> _openCreate(BuildContext context) async {
    final ok = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const CreateGroupScreen()),
    );
    if (ok == true) {
      groupsRefreshSignal?.value++;
    }
  }

  Future<void> _openJoin(BuildContext context) async {
    final ok = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const JoinGroupScreen()),
    );
    if (ok == true) {
      groupsRefreshSignal?.value++;
      await AppToast.success('Joined group');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.background,
      child: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const HomeHeader(),
                  const SizedBox(height: 24),
                  ..._demoGroups.map(
                    (g) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: GroupSummaryCard(summary: g, onTap: () {}),
                    ),
                  ),
                  const SizedBox(height: 8),
                  StartSomethingNewCard(
                    onCreateGroup: () => _openCreate(context),
                    onJoinWithCode: () => _openJoin(context),
                  ),
                  const SizedBox(height: 100),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
