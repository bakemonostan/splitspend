import 'package:flutter/material.dart';
import 'package:split_spend/src/features/home/widgets/dashed_rounded_rect_painter.dart';
import 'package:split_spend/src/features/home/widgets/smiley_add_mark.dart';
import 'package:split_spend/src/theme/theme.dart';

/// Light teal card with dashed border and centered copy (new group CTA).
class CreateGroupPlaceholder extends StatelessWidget {
  const CreateGroupPlaceholder({super.key, this.onTap});

  final VoidCallback? onTap;

  static const double _radius = 12;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppPalette.primary50,
      borderRadius: BorderRadius.circular(_radius),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(_radius),
        child: CustomPaint(
          painter: DashedRoundedRectPainter(
            color: AppPalette.primary400,
            strokeWidth: 1.5,
            radius: _radius,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
