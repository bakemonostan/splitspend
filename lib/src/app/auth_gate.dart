import 'package:flutter/material.dart';
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
