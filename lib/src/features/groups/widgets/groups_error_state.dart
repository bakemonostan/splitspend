import 'package:flutter/material.dart';
import 'package:split_spend/src/theme/theme.dart';

class GroupsErrorState extends StatelessWidget {
  const GroupsErrorState({super.key, required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Could not load groups',
          style: TextStyle(color: AppPalette.neutral700),
        ),
        const SizedBox(height: 8),
        TextButton(onPressed: onRetry, child: const Text('Retry')),
      ],
    );
  }
}
