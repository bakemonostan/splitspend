import 'package:flutter/material.dart';

/// Demo / UI model for a group row on the home list.
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
}
