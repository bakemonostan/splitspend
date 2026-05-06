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
      backgroundColor: Colors.white,
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
      bottomNavigationBar: NavigationBar(
        height: 64,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        indicatorColor: AppPalette.primary100,
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.article_outlined),
            selectedIcon: Icon(Icons.article_rounded),
            label: 'Activity',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings_rounded),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
