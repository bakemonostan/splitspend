import 'package:flutter/material.dart';

class SettingsLogoutTile extends StatelessWidget {
  const SettingsLogoutTile({super.key, required this.onLogout});

  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      leading: Icon(Icons.logout_rounded, color: Colors.red.shade600, size: 22),
      title: Text(
        'Logout',
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 15,
          color: Colors.red.shade600,
        ),
      ),
      onTap: onLogout,
    );
  }
}
