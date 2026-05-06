import 'package:flutter/material.dart';
import 'package:split_spend/src/theme/theme.dart';

/// Smiley + small “+” badge (used in “Start something new?” cards).
class SmileyAddMark extends StatelessWidget {
  const SmileyAddMark({
    super.key,
    this.smileColor = AppPalette.primary500,
    this.plusColor = AppPalette.primary600,
  });

  final Color smileColor;
  final Color plusColor;

  static const double _circle = 46;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _circle,
      height: _circle,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppPalette.neutral900.withValues(alpha: 0.07),
            offset: const Offset(0, 6),
            blurRadius: 12,
          ),
        ],
        border: Border.all(color: AppPalette.primary300, width: 1.5),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Icon(
            Icons.sentiment_satisfied_alt_rounded,
            size: 30,
            color: smileColor,
          ),
          Positioned(
            right: 6,
            top: 6,
            child: DecoratedBox(
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.add_rounded, size: 12, color: plusColor),
            ),
          ),
        ],
      ),
    );
  }
}
