import 'package:flutter/material.dart';
import 'package:split_spend/src/app/app_root.dart';
import 'package:split_spend/src/app/missing_supabase_config_screen.dart';
import 'package:split_spend/src/core/config/supabase_env.dart';
import 'package:split_spend/src/theme/theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseEnv.load();

  if (SupabaseEnv.isConfigured) {
    await Supabase.initialize(
      url: SupabaseEnv.url,
      anonKey: SupabaseEnv.anonKey,
    );
  }

  runApp(const SplitSpendApp());
}

class SplitSpendApp extends StatelessWidget {
  const SplitSpendApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SplitSpend',
      theme: primaryTheme,
      home: SupabaseEnv.isConfigured
          ? const AppRoot()
          : const MissingSupabaseConfigScreen(),
    );
  }
}
