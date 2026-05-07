import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:split_spend/src/core/ui/app_toast.dart';
import 'package:split_spend/src/theme/theme.dart';

/// Owner-only: shares invite code via clipboard (members cannot add via UI).
class DashedAddMemberButton extends StatelessWidget {
  const DashedAddMemberButton({
    super.key,
    required this.inviteCode,
  });

  final String inviteCode;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedRoundRectPainter(
        color: AppPalette.primary400,
        strokeWidth: 1.5,
        radius: 14,
        dashWidth: 6,
        dashGap: 4,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: inviteCode.isEmpty
              ? null
              : () async {
                  await Clipboard.setData(ClipboardData(text: inviteCode));
                  await AppToast.success('Invite code copied — share it to add members');
                },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.person_add_alt_1_rounded,
                  color: AppPalette.primary500,
                  size: 22,
                ),
                const SizedBox(width: 10),
                Text(
                  'Add New Member',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppPalette.primary600,
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

class _DashedRoundRectPainter extends CustomPainter {
  _DashedRoundRectPainter({
    required this.color,
    required this.strokeWidth,
    required this.radius,
    required this.dashWidth,
    required this.dashGap,
  });

  final Color color;
  final double strokeWidth;
  final double radius;
  final double dashWidth;
  final double dashGap;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        strokeWidth / 2,
        strokeWidth / 2,
        size.width - strokeWidth,
        size.height - strokeWidth,
      ),
      Radius.circular(radius),
    );
    final path = Path()..addRRect(rect);
    final metrics = path.computeMetrics().toList();
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    for (final m in metrics) {
      double d = 0;
      while (d < m.length) {
        final next = (d + dashWidth).clamp(0.0, m.length);
        final extract = m.extractPath(d, next.toDouble());
        canvas.drawPath(extract, paint);
        d += dashWidth + dashGap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedRoundRectPainter oldDelegate) => false;
}
