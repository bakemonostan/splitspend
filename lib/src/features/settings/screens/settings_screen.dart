import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:split_spend/src/app/app_flow_controller.dart';
import 'package:split_spend/src/core/config/app_version.dart';
import 'package:split_spend/src/core/storage/avatar_storage_service.dart';
import 'package:split_spend/src/core/ui/skeleton.dart';
import 'package:split_spend/src/core/ui/app_toast.dart';
import 'package:split_spend/src/features/settings/widgets/settings_group_card.dart';
import 'package:split_spend/src/features/settings/widgets/settings_logout_tile.dart';
import 'package:split_spend/src/features/settings/widgets/settings_navigation_tile.dart';
import 'package:split_spend/src/features/settings/widgets/settings_profile_header.dart';
import 'package:split_spend/src/features/settings/widgets/settings_section_header.dart';
import 'package:split_spend/src/theme/theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final ImagePicker _picker = ImagePicker();
  bool _uploading = false;

  Future<void> _pickAndUploadAvatar() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      await AppToast.error('Sign in to change your profile photo.');
      return;
    }

    final x = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      imageQuality: 85,
    );
    if (x == null || !mounted) return;

    setState(() => _uploading = true);
    try {
      await AvatarStorageService.uploadProfilePhoto(x);
      if (mounted) await AppToast.success('Profile photo updated.');
    } catch (e) {
      if (!mounted) return;
      final msg = e.toString();
      final friendly = msg.contains('DatabaseInvalidObjectDefinition') ||
              msg.contains('infinite recursion')
          ? 'Could not reach storage. Try again — if it persists, check Supabase status.'
          : 'Could not update photo.';
      await AppToast.error(friendly);
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  Future<void> _logout() async {
    await Supabase.instance.client.auth.signOut();
    AppFlowController.instance.returnToOnboarding();
    if (mounted) await AppToast.info('Signed out. See you on the tour.');
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.background,
      child: StreamBuilder<AuthState>(
        stream: Supabase.instance.client.auth.onAuthStateChange,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              Supabase.instance.client.auth.currentUser == null) {
            return const _SettingsSkeleton();
          }
          final user = Supabase.instance.client.auth.currentUser;
          final name = user == null
              ? '—'
              : AvatarStorageService.resolvedDisplayName(user);
          final email = AvatarStorageService.emailFromUser(user) ?? '—';
          final avatarUrl = AvatarStorageService.avatarUrlFromUser(user);
          final currency =
              AvatarStorageService.currencyLabelFromUser(user);
          final notificationsOn =
              AvatarStorageService.notificationsEnabledFromUser(user);
          final passwordHint =
              AvatarStorageService.passwordSectionSubtitleFromUser(user);

          return CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    SettingsProfileHeader(
                      name: name,
                      email: email,
                      avatarUrl: avatarUrl,
                      uploading: _uploading,
                      onEditPhoto: _pickAndUploadAvatar,
                    ),
                    const SettingsSectionHeader(title: 'Profile'),
                    _groupCard(
                      children: [
                        SettingsNavigationTile(
                          icon: Icons.person_outline_rounded,
                          title: 'Full Name',
                          subtitle: name,
                          onTap: () {},
                        ),
                        _tileDivider(),
                        SettingsNavigationTile(
                          icon: Icons.mail_outline_rounded,
                          title: 'Email',
                          subtitle: email,
                          onTap: () {},
                        ),
                      ],
                    ),
                    const SettingsSectionHeader(title: 'Preferences'),
                    _groupCard(
                      children: [
                        SettingsNavigationTile(
                          icon: Icons.payments_outlined,
                          title: 'Currency',
                          subtitle: currency,
                          onTap: () {},
                        ),
                        _tileDivider(),
                        ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 2,
                          ),
                          leading: Icon(
                            Icons.notifications_outlined,
                            color: AppPalette.neutral600,
                            size: 22,
                          ),
                          title: const Text(
                            'Notifications',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                              color: AppPalette.neutral900,
                            ),
                          ),
                          subtitle: Text(
                            notificationsOn ? 'Enabled' : 'Disabled',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppPalette.neutral500,
                            ),
                          ),
                          trailing: Switch(
                            value: notificationsOn,
                            onChanged: null,
                            activeThumbColor: AppPalette.primary500,
                          ),
                        ),
                      ],
                    ),
                    const SettingsSectionHeader(title: 'Security'),
                    _groupCard(
                      children: [
                        SettingsNavigationTile(
                          icon: Icons.lock_outline_rounded,
                          title: 'Change Password',
                          subtitle: passwordHint,
                          onTap: () {},
                        ),
                      ],
                    ),
                    const SettingsSectionHeader(title: 'About'),
                    _groupCard(
                      children: [
                        SettingsNavigationTile(
                          icon: Icons.help_outline_rounded,
                          title: 'Help Center',
                          trailing: Icon(
                            Icons.open_in_new_rounded,
                            size: 20,
                            color: AppPalette.neutral400,
                          ),
                          onTap: () {},
                        ),
                        _tileDivider(),
                        SettingsNavigationTile(
                          icon: Icons.shield_outlined,
                          title: 'Privacy Policy',
                          onTap: () {},
                        ),
                        _tileDivider(),
                        SettingsLogoutTile(onLogout: _logout),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      AppVersion.label,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppPalette.neutral400,
                      ),
                    ),
                    const SizedBox(height: 88),
                  ]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  static Widget _tileDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      indent: 56,
      color: AppPalette.neutral100,
    );
  }

  static Widget _groupCard({required List<Widget> children}) {
    return SettingsGroupCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: children,
      ),
    );
  }
}

class _SettingsSkeleton extends StatelessWidget {
  const _SettingsSkeleton();

  @override
  Widget build(BuildContext context) {
    return Skeleton(
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SkeletonBox(height: 112, radius: 16),
                const SizedBox(height: 20),
                const SkeletonBox(height: 18, width: 88),
                const SizedBox(height: 10),
                const SkeletonBox(height: 122, radius: 16),
                const SizedBox(height: 16),
                const SkeletonBox(height: 18, width: 100),
                const SizedBox(height: 10),
                const SkeletonBox(height: 178, radius: 16),
                const SizedBox(height: 16),
                const SkeletonBox(height: 18, width: 70),
                const SizedBox(height: 10),
                const SkeletonBox(height: 70, radius: 16),
                const SizedBox(height: 16),
                const SkeletonBox(height: 18, width: 52),
                const SizedBox(height: 10),
                const SkeletonBox(height: 170, radius: 16),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
