import 'package:flutter/material.dart';
import 'package:split_spend/src/features/activity/activity_screen.dart';
import 'package:split_spend/src/features/home/home_screen.dart';
import 'package:split_spend/src/features/home/widgets/home_app_bar.dart';
import 'package:split_spend/src/features/settings/settings_screen.dart';
import 'package:split_spend/src/theme/theme.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  static const _titles = ['Activity', 'Settings'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9F9),
      appBar: _index == 0
          ? const HomeAppBar()
          : AppBar(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              title: Text(
                _titles[_index - 1],
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppPalette.neutral900,
                ),
              ),
            ),
      body: IndexedStack(
        index: _index,
        children: const [
          HomeScreen(),
          ActivityScreen(),
          SettingsScreen(),
        ],
      ),
      floatingActionButton: _index == 0
          ? FloatingActionButton(
              onPressed: () {},
              backgroundColor: AppPalette.primary500,
              foregroundColor: Colors.white,
              child: const Icon(Icons.person_add_alt_1_rounded),
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
              icon: Icon(Icons.home_outlined, color: AppPalette.neutral500),
              selectedIcon: Icon(Icons.home_rounded, color: AppPalette.primary500),
              label: 'Home',
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
