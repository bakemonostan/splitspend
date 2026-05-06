import 'package:flutter/material.dart';

/// Shown when `SUPABASE_URL` / `SUPABASE_ANON_KEY` were not passed at compile time.
class MissingSupabaseConfigScreen extends StatelessWidget {
  const MissingSupabaseConfigScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Supabase not configured',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 16),
              const Text(
                'Run the app with your project URL and anon key:',
                style: TextStyle(height: 1.4),
              ),
              const SizedBox(height: 12),
              SelectableText(
                'flutter run \\\n'
                '  --dart-define=SUPABASE_URL=https://YOUR_REF.supabase.co \\\n'
                '  --dart-define=SUPABASE_ANON_KEY=your_anon_key',
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                  color: Colors.grey.shade800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
