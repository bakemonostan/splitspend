import 'package:flutter/material.dart';
import 'package:split_spend/src/theme/theme.dart';
import 'package:split_spend/src/widgets/profile_toolbar_avatar.dart';

class SettingsAppBar extends StatelessWidget implements PreferredSizeWidget {
  const SettingsAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 10,
      scrolledUnderElevation: 0,
      titleSpacing: 0,
      title: Row(
        children: [
          const SizedBox(width: 8),
          Icon(
            Icons.account_balance_wallet_outlined,
            color: AppPalette.primary500,
            size: 24,
          ),
          const SizedBox(width: 2),
          Text(
            'SplitSpend',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppPalette.primary500,
            ),
          ),
          const Spacer(),
          const ProfileToolbarAvatar(radius: 18),
          const SizedBox(width: 8),
        ],
      ),
    );
  }
}
