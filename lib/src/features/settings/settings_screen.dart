import 'package:flutter/material.dart';
import 'package:split_spend/src/theme/theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.white,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Account and app preferences.',
                style: TextStyle(
                  fontSize: 15,
                  color: AppPalette.neutral500,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.logout, color: AppPalette.neutral700),
                title: const Text('Sign out'),
                onTap: () => Supabase.instance.client.auth.signOut(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
