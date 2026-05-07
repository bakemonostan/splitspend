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
    this.id,
    this.inviteCode,
    this.isOwner = false,
    this.category = 'other',
    this.coverImageUrl,
  });

  /// Supabase `groups.id`; null for demo / placeholder rows.
  final String? id;

  /// Invite code when loaded from API.
  final String? inviteCode;

  /// Whether the current user is the group owner (`group_members.role`).
  final bool isOwner;

  /// DB category key: `trip` | `home` | `event` | `other`.
  final String category;

  /// Optional cover image URL from `groups.cover_image_url`.
  final String? coverImageUrl;

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
    required String memberRole,
    int? memberCount,
  }) {
    final category = g['category'] as String? ?? 'other';
    var n = memberCount ?? _parseEmbedCount(g['group_members']);
    final v = _visualsForCategory(category);
    return GroupSummary(
      id: g['id']?.toString(),
      inviteCode: g['invite_code'] as String?,
      isOwner: memberRole == 'owner',
      category: category,
      coverImageUrl: g['cover_image_url'] as String?,
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

  /// UI label for [category] (settings / identity card).
  static String categoryLabel(String category) {
    switch (category) {
      case 'trip':
        return 'Travel & Vacation';
      case 'home':
        return 'Rent & Utilities';
      case 'event':
        return 'Parties & Weddings';
      default:
        return 'General expenses';
    }
  }

  String get categoryDisplayLabel => categoryLabel(category);

  GroupSummary copyWith({
    String? name,
    int? memberCount,
    String? id,
    String? inviteCode,
    bool? isOwner,
    String? category,
    String? coverImageUrl,
  }) {
    return GroupSummary(
      name: name ?? this.name,
      memberCount: memberCount ?? this.memberCount,
      statusLabel: statusLabel,
      amountLabel: amountLabel,
      amountColor: amountColor,
      icon: icon,
      iconColor: iconColor,
      iconTileBackground: iconTileBackground,
      id: id ?? this.id,
      inviteCode: inviteCode ?? this.inviteCode,
      isOwner: isOwner ?? this.isOwner,
      category: category ?? this.category,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
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
