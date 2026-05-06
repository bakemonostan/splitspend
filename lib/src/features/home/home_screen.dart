import 'package:flutter/material.dart';
import 'package:split_spend/src/theme/theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    final email = user?.email ?? 'Signed in';

    return Scaffold(
      backgroundColor: AppPalette.primary50,
      appBar: AppBar(
        backgroundColor: AppPalette.primary50,
        foregroundColor: AppPalette.neutral900,
        elevation: 0,
        title: const Text('SplitSpend'),
        actions: [
          TextButton(
            onPressed: () => Supabase.instance.client.auth.signOut(),
            child: Text(
              'Sign out',
              style: TextStyle(
                color: AppPalette.primary500,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            email,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              color: AppPalette.neutral700,
            ),
          ),
        ),
      ),
    );
  }
}
