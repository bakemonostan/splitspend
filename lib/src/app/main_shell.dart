import 'package:flutter/material.dart';
import 'package:split_spend/src/features/expenses/screens/create_expense_screen.dart';
import 'package:split_spend/src/features/activity/activity_screen.dart';
import 'package:split_spend/src/features/groups/screens/create_group_screen.dart';
import 'package:split_spend/src/features/groups/screens/groups_screen.dart';
import 'package:split_spend/src/features/home/screens/home_screen.dart';
import 'package:split_spend/src/features/home/widgets/home_app_bar.dart';
import 'package:split_spend/src/features/settings/screens/settings_screen.dart';
import 'package:split_spend/src/features/settings/widgets/settings_app_bar.dart';
import 'package:split_spend/src/theme/theme.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  /// Bumped after a group is created from the FAB so [GroupsScreen] reloads.
  final ValueNotifier<int> _groupsRefreshSignal = ValueNotifier<int>(0);

  static const _activityTitle = 'Activity';

  @override
  void dispose() {
    _groupsRefreshSignal.dispose();
    super.dispose();
  }

  Future<void> _openCreateGroup() async {
    final created = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const CreateGroupScreen()),
    );
    if (created == true && mounted) {
      _groupsRefreshSignal.value++;
    }
  }

  Future<void> _openCreateExpense() async {
    final created = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const CreateExpenseScreen()),
    );
    if (created == true && mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9F9),
      appBar: _index == 0 || _index == 1
          ? const HomeAppBar()
          : _index == 3
          ? const SettingsAppBar()
          : AppBar(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              title: const Text(
                _activityTitle,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppPalette.neutral900,
                ),
              ),
            ),
      body: IndexedStack(
        index: _index,
        children: [
          HomeScreen(groupsRefreshSignal: _groupsRefreshSignal),
          GroupsScreen(refreshSignal: _groupsRefreshSignal),
          const ActivityScreen(),
          const SettingsScreen(),
        ],
      ),
      floatingActionButton: _index == 0 || _index == 1
          ? FloatingActionButton(
              onPressed: _index == 0 ? _openCreateExpense : _openCreateGroup,
              backgroundColor: AppPalette.primary500,
              foregroundColor: Colors.white,
              shape: const CircleBorder(),
              child: Icon(
                _index == 0
                    ? Icons.add_rounded
                    : Icons.person_add_alt_1_rounded,
              ),
            )
          : null,
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: AppPalette.neutral200, width: 1),
          ),
          boxShadow: [
            BoxShadow(
              color: AppPalette.neutral900.withValues(alpha: 0.05),
              offset: const Offset(0, -2),
              blurRadius: 8,
            ),
          ],
        ),
        child: NavigationBar(
          height: 64,
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          shadowColor: Colors.transparent,
          elevation: 0,
          indicatorColor: AppPalette.primary100,
          selectedIndex: _index,
          onDestinationSelected: (i) => setState(() => _index = i),
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined, color: AppPalette.neutral200),
              selectedIcon: Icon(
                Icons.home_rounded,
                color: AppPalette.primary400,
              ),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.groups_outlined, color: AppPalette.neutral500),
              selectedIcon: Icon(
                Icons.groups_rounded,
                color: AppPalette.primary500,
              ),
              label: 'Groups',
            ),
            NavigationDestination(
              icon: Icon(Icons.article_outlined, color: AppPalette.neutral500),
              selectedIcon: Icon(
                Icons.article_rounded,
                color: AppPalette.primary500,
              ),
              label: 'Activity',
            ),
            NavigationDestination(
              icon: Icon(Icons.settings_outlined, color: AppPalette.neutral500),
              selectedIcon: Icon(
                Icons.settings_rounded,
                color: AppPalette.primary500,
              ),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}
