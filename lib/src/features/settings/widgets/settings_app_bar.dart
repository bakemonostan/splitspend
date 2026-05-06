import 'package:flutter/material.dart';
import 'package:split_spend/src/core/storage/avatar_storage_service.dart';
import 'package:split_spend/src/theme/theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SettingsAppBar extends StatelessWidget implements PreferredSizeWidget {
  const SettingsAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        final user = Supabase.instance.client.auth.currentUser;
        final avatarUrl = AvatarStorageService.avatarUrlFromUser(user);

        return AppBar(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          titleSpacing: 0,
          title: Row(
            children: [
              Icon(
                Icons.account_balance_wallet_outlined,
                color: AppPalette.primary500,
                size: 26,
              ),
              const SizedBox(width: 8),
              Text(
                'SplitSpend',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppPalette.primary500,
                ),
              ),
              const Spacer(),
              CircleAvatar(
                radius: 18,
                backgroundColor: AppPalette.primary100,
                backgroundImage:
                    avatarUrl != null ? NetworkImage(avatarUrl) : null,
                child: avatarUrl == null
                    ? Icon(
                        Icons.person_rounded,
                        color: AppPalette.primary600,
                        size: 20,
                      )
                    : null,
              ),
              const SizedBox(width: 8),
            ],
          ),
        );
      },
    );
  }
}
