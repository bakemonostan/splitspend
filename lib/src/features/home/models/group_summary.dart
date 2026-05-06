import 'package:flutter/material.dart';
import 'package:split_spend/src/theme/theme.dart';

/// Row model for a group card (home / groups list).
class GroupSummary {
  const GroupSummary({
    required this.name,
    required this.memberCount,
    required this.statusLabel,
    required this.amountLabel,
    required this.amountColor,
    required this.icon,
    required this.iconColor,
    required this.iconTileBackground,
  });

  final String name;
  final int memberCount;
  final String statusLabel;
  final String amountLabel;
  final Color amountColor;
  final IconData icon;
  final Color iconColor;
  final Color iconTileBackground;

  /// Maps a `groups` row (from `group_members` → `groups` embed).
  /// Prefer passing [memberCount] from a separate aggregate query; embed counts are brittle in PostgREST.
  factory GroupSummary.fromGroupRow(
    Map<String, dynamic> g, {
    int? memberCount,
  }) {
    final category = g['category'] as String? ?? 'other';
    var n = memberCount ?? _parseEmbedCount(g['group_members']);
    final v = _visualsForCategory(category);
    return GroupSummary(
      name: g['name'] as String? ?? 'Group',
      memberCount: n,
      statusLabel: 'Settled',
      amountLabel: r'$0.00',
      amountColor: const Color(0xFF16A34A),
      icon: v.icon,
      iconColor: v.iconColor,
      iconTileBackground: v.tileBg,
    );
  }

  static int _parseEmbedCount(dynamic countData) {
    if (countData is List && countData.isNotEmpty) {
      final first = countData.first;
      if (first is Map && first['count'] != null) {
        final c = first['count'];
        if (c is int) {
          return c;
        }
        if (c is num) {
          return c.toInt();
        }
      }
    }
    return 1;
  }

  static _CategoryVisuals _visualsForCategory(String category) {
    switch (category) {
      case 'trip':
        return const _CategoryVisuals(
          icon: Icons.flight_rounded,
          iconColor: Color(0xFF2563EB),
          tileBg: Color(0xFFDBEAFE),
        );
      case 'home':
        return const _CategoryVisuals(
          icon: Icons.home_rounded,
          iconColor: AppPalette.primary600,
          tileBg: AppPalette.primary100,
        );
      case 'event':
        return const _CategoryVisuals(
          icon: Icons.celebration_rounded,
          iconColor: AppPalette.tertiary600,
          tileBg: AppPalette.tertiary100,
        );
      default:
        return const _CategoryVisuals(
          icon: Icons.more_horiz_rounded,
          iconColor: AppPalette.neutral600,
          tileBg: AppPalette.neutral100,
        );
    }
  }
}

class _CategoryVisuals {
  const _CategoryVisuals({
    required this.icon,
    required this.iconColor,
    required this.tileBg,
  });

  final IconData icon;
  final Color iconColor;
  final Color tileBg;
}
