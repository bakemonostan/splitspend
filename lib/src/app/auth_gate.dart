import 'package:flutter/material.dart';
import 'package:split_spend/src/core/ui/skeleton.dart';
import 'package:split_spend/src/app/main_shell.dart';
import 'package:split_spend/src/features/auth/screens/signin_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            Supabase.instance.client.auth.currentSession == null) {
          return const Scaffold(
            body: SafeArea(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Skeleton(
                  child: Column(
                    children: [
                      SizedBox(height: 28),
                      SkeletonBox(height: 36, width: 140, radius: 12),
                      SizedBox(height: 36),
                      SkeletonBox(height: 56, radius: 12),
                      SizedBox(height: 14),
                      SkeletonBox(height: 56, radius: 12),
                      SizedBox(height: 14),
                      SkeletonBox(height: 56, radius: 12),
                    ],
                  ),
                ),
              ),
            ),
          );
        }
        final session = snapshot.data?.session ??
            Supabase.instance.client.auth.currentSession;
        if (session != null) {
          return const MainShell();
        }
        return const SigninScreen();
      },
    );
  }
}
