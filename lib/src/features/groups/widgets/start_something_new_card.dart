import 'package:flutter/material.dart';
import 'package:split_spend/src/features/home/widgets/dashed_rounded_rect_painter.dart';
import 'package:split_spend/src/features/home/widgets/smiley_add_mark.dart';
import 'package:split_spend/src/theme/theme.dart';

class StartSomethingNewCard extends StatelessWidget {
  const StartSomethingNewCard({
    super.key,
    this.onCreateGroup,
    this.onJoinWithCode,
  });

  final VoidCallback? onCreateGroup;
  final VoidCallback? onJoinWithCode;

  static const double _radius = 12;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppPalette.primary50,
      borderRadius: BorderRadius.circular(_radius),
      clipBehavior: Clip.antiAlias,
      child: CustomPaint(
        painter: DashedRoundedRectPainter(
          color: AppPalette.primary400,
          strokeWidth: 1.5,
          radius: _radius,
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SmileyAddMark(),
              const SizedBox(height: 14),
              Text(
                'Start something new?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppPalette.primary600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Create a group to easily split bills with friends on your next outing.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  height: 1.4,
                  color: AppPalette.neutral600,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: FilledButton(
                      onPressed: onCreateGroup,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppPalette.primary500,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Create group'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onJoinWithCode,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppPalette.primary600,
                        side: BorderSide(color: AppPalette.primary400),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Join with code'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
