import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:split_spend/src/core/ui/app_toast.dart';
import 'package:split_spend/src/features/home/models/group_summary.dart';
import 'package:split_spend/src/theme/theme.dart';

class GroupIdentityCard extends StatelessWidget {
  const GroupIdentityCard({
    super.key,
    required this.summary,
    required this.isOwner,
    this.onEditPressed,
  });

  final GroupSummary summary;
  final bool isOwner;
  final VoidCallback? onEditPressed;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppPalette.neutral900.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _GroupAvatar(summary: summary),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'GROUP IDENTITY',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1,
                          color: AppPalette.neutral400,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        summary.name,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: AppPalette.neutral900,
                          letterSpacing: -0.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (isOwner && onEditPressed != null) ...[
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: onEditPressed,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppPalette.neutral800,
                  side: BorderSide(color: AppPalette.neutral200),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Edit Group',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
            const SizedBox(height: 18),
            _MetaRow(
              icon: Icons.category_outlined,
              label: 'Category',
              value: summary.categoryDisplayLabel,
            ),
            const SizedBox(height: 12),
            _InviteRow(
              code: summary.inviteCode ?? '—',
              onCopy: summary.inviteCode == null || summary.inviteCode!.isEmpty
                  ? null
                  : () async {
                      await Clipboard.setData(
                        ClipboardData(text: summary.inviteCode!),
                      );
                      await AppToast.success('Invite code copied');
                    },
            ),
          ],
        ),
      ),
    );
  }
}

class _GroupAvatar extends StatelessWidget {
  const _GroupAvatar({required this.summary});

  final GroupSummary summary;

  @override
  Widget build(BuildContext context) {
    final url = summary.coverImageUrl;
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 64,
        height: 64,
        color: summary.iconTileBackground,
        child: url != null && url.isNotEmpty
            ? Image.network(
                url,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Icon(
                  summary.icon,
                  color: summary.iconColor,
                  size: 30,
                ),
              )
            : Icon(
                summary.icon,
                color: summary.iconColor,
                size: 30,
              ),
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppPalette.neutral500),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppPalette.neutral500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppPalette.neutral900,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _InviteRow extends StatelessWidget {
  const _InviteRow({required this.code, this.onCopy});

  final String code;
  final VoidCallback? onCopy;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(Icons.link_rounded, size: 20, color: AppPalette.neutral500),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Invite Code',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppPalette.neutral500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                code,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                  color: AppPalette.primary600,
                ),
              ),
            ],
          ),
        ),
        if (onCopy != null)
          IconButton(
            onPressed: onCopy,
            icon: const Icon(Icons.copy_rounded, color: AppPalette.primary500),
            tooltip: 'Copy',
          ),
      ],
    );
  }
}
