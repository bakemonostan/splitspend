import 'package:flutter/material.dart';

/// Rounded square with a light fill and a colored icon (design: soft tile, not solid).
class GroupCardIconTile extends StatelessWidget {
  const GroupCardIconTile({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
  });

  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: iconColor, size: 22),
    );
  }
}
