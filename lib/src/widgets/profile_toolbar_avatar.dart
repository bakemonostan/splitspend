import 'package:flutter/material.dart';
import 'package:split_spend/src/core/storage/avatar_storage_service.dart';
import 'package:split_spend/src/theme/theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Circular avatar from `user_metadata.avatar_url`; rebuilds on auth/user updates.
class ProfileToolbarAvatar extends StatelessWidget {
  const ProfileToolbarAvatar({
    super.key,
    this.radius = 18,
    this.onPressed,
  });

  final double radius;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, _) {
        final user = Supabase.instance.client.auth.currentUser;
        final avatarUrl = AvatarStorageService.avatarUrlFromUser(user);
        final hasUrl = avatarUrl != null && avatarUrl.isNotEmpty;

        final avatar = CircleAvatar(
          radius: radius,
          backgroundColor: AppPalette.primary100,
          backgroundImage: hasUrl ? NetworkImage(avatarUrl) : null,
          child: hasUrl
              ? null
              : Icon(
                  Icons.person_rounded,
                  color: AppPalette.primary600,
                  size: radius * 1.15,
                ),
        );

        if (onPressed != null) {
          return IconButton(
            onPressed: onPressed,
            padding: EdgeInsets.zero,
            icon: avatar,
          );
        }
        return avatar;
      },
    );
  }
}
