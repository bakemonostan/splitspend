import 'package:flutter/material.dart';
import 'package:split_spend/src/theme/theme.dart';

class GroupDangerZoneCard extends StatelessWidget {
  const GroupDangerZoneCard({
    super.key,
    required this.showDeleteGroup,
    required this.onLeaveGroup,
    this.onDeleteGroup,
  });

  final bool showDeleteGroup;
  final VoidCallback onLeaveGroup;
  final VoidCallback? onDeleteGroup;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1F2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFECDD3)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Danger Zone',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: Color(0xFFB91C1C),
              ),
            ),
            const SizedBox(height: 16),
            if (showDeleteGroup && onDeleteGroup != null) ...[
              const Text(
                'Delete Group',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppPalette.neutral900,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Once you delete a group, there is no going back. All expenses '
                'and balances for this group will be removed.',
                style: TextStyle(
                  fontSize: 13,
                  height: 1.4,
                  color: AppPalette.neutral600,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFDC2626),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: onDeleteGroup,
                  child: const Text(
                    'Delete Group',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(height: 22),
            ],
            const Text(
              'Leave Group',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppPalette.neutral900,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'You will lose access to this group and pending balances shown '
              'here.',
              style: TextStyle(
                fontSize: 13,
                height: 1.4,
                color: AppPalette.neutral600,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFDC2626),
                  side: const BorderSide(color: Color(0xFFDC2626)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: onLeaveGroup,
                child: const Text(
                  'Leave Group',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
