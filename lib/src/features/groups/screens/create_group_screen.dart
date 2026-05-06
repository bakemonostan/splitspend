import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:split_spend/src/core/ui/app_toast.dart';
import 'package:split_spend/src/features/groups/data/groups_repository.dart';
import 'package:split_spend/src/theme/theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Create group: cover (optional), name, category — invite code shown **after** success only.
class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final _nameController = TextEditingController();
  late final GroupsRepository _repo;
  String _category = 'trip';
  bool _submitting = false;
  XFile? _coverPicked;

  static const _categories = <_CategoryOption>[
    _CategoryOption(
      id: 'trip',
      label: 'Trip',
      subtitle: 'Travel & Vacations',
      icon: Icons.flight_rounded,
    ),
    _CategoryOption(
      id: 'home',
      label: 'Home',
      subtitle: 'Rent & Utilities',
      icon: Icons.home_rounded,
    ),
    _CategoryOption(
      id: 'event',
      label: 'Event',
      subtitle: 'Parties & Weddings',
      icon: Icons.celebration_rounded,
    ),
    _CategoryOption(
      id: 'other',
      label: 'Other',
      subtitle: 'General expenses',
      icon: Icons.more_horiz_rounded,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _repo = GroupsRepository(Supabase.instance.client);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickCover() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1600,
      imageQuality: 88,
    );
    if (file != null && mounted) {
      setState(() => _coverPicked = file);
    }
  }

  Future<void> _submit() async {
    if (_submitting) {
      return;
    }
    final name = _nameController.text.trim();
    if (name.length < 2) {
      await AppToast.error('Enter a group name (at least 2 characters).');
      return;
    }

    setState(() => _submitting = true);
    try {
      final row = await _repo.createGroup(name: name, category: _category);
      final id = row['id']?.toString() ?? '';
      if (id.isEmpty) {
        throw StateError('Missing group id');
      }

      if (_coverPicked != null) {
        try {
          await _repo.uploadGroupCoverIfPresent(
            groupId: id,
            image: _coverPicked!,
          );
        } catch (e, st) {
          debugPrint('uploadGroupCoverIfPresent: $e\n$st');
          if (mounted) {
            await AppToast.error(
              kDebugMode
                  ? 'Cover upload failed: $e'
                  : 'Group created, but cover upload failed',
            );
          }
        }
      }

      if (!mounted) {
        return;
      }

      final code = row['invite_code'] as String? ?? '';
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => _GroupCreatedDialog(inviteCode: code),
      );
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } on PostgrestException catch (e, st) {
      debugPrint('createGroup Postgrest: ${e.message} (code: ${e.code}) details: ${e.details}\n$st');
      if (mounted) {
        await AppToast.error(
          kDebugMode && e.message.isNotEmpty ? e.message : 'Could not create group',
        );
      }
    } catch (e, st) {
      debugPrint('createGroup error: $e\n$st');
      if (mounted) {
        await AppToast.error(
          kDebugMode ? e.toString() : 'Could not create group',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: AppPalette.neutral800),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Create Group',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppPalette.primary600,
            letterSpacing: -0.2,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _CoverPickerCard(
              picked: _coverPicked,
              onTap: _pickCover,
            ),
            const SizedBox(height: 28),
            Text(
              'Group Name',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppPalette.neutral700,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              textCapitalization: TextCapitalization.words,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              decoration: InputDecoration(
                hintText: 'e.g., Summer Trip 2024',
                hintStyle: TextStyle(
                  color: AppPalette.neutral300,
                  fontWeight: FontWeight.w500,
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppPalette.neutral200),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppPalette.neutral200),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppPalette.primary400, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 28),
            Text(
              'Choose Category',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppPalette.neutral900,
              ),
            ),
            const SizedBox(height: 14),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.45,
              children: _categories
                  .map(
                    (c) => _CategoryGridTile(
                      option: c,
                      selected: _category == c.id,
                      onTap: () => setState(() => _category = c.id),
                    ),
                  )
                  .toList(),
            ),
            SizedBox(height: 28 + bottomInset),
            _PrimaryBottomButton(
              loading: _submitting,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }
}

class _GroupCreatedDialog extends StatelessWidget {
  const _GroupCreatedDialog({required this.inviteCode});

  final String inviteCode;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        'Group created',
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
          color: AppPalette.neutral900,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Share this invite code so others can join:',
            style: TextStyle(fontSize: 14, color: AppPalette.neutral600),
          ),
          const SizedBox(height: 12),
          SelectableText(
            inviteCode.isEmpty ? '—' : inviteCode,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 20,
              letterSpacing: 1,
              color: AppPalette.neutral900,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () async {
            if (inviteCode.isNotEmpty) {
              await Clipboard.setData(ClipboardData(text: inviteCode));
              await AppToast.success('Copied invite code');
            }
          },
          child: const Text('Copy'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: AppPalette.primary500,
            foregroundColor: Colors.white,
          ),
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Done'),
        ),
      ],
    );
  }
}

class _CoverPickerCard extends StatelessWidget {
  const _CoverPickerCard({
    required this.picked,
    required this.onTap,
  });

  final XFile? picked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 28),
          child: Column(
            children: [
              SizedBox(
                width: 112,
                height: 112,
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 112,
                      height: 112,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppPalette.primary50,
                        border: Border.all(
                          color: AppPalette.primary200,
                          width: 2,
                        ),
                        image: picked != null
                            ? DecorationImage(
                                image: FileImage(File(picked!.path)),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: picked == null
                          ? Icon(
                              Icons.photo_camera_outlined,
                              size: 36,
                              color: AppPalette.primary400,
                            )
                          : null,
                    ),
                    Positioned(
                      right: 2,
                      bottom: 2,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppPalette.primary500,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: AppPalette.neutral900.withValues(alpha: 0.12),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.edit_rounded,
                          size: 14,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Tap to upload group cover',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppPalette.primary600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryOption {
  const _CategoryOption({
    required this.id,
    required this.label,
    required this.subtitle,
    required this.icon,
  });

  final String id;
  final String label;
  final String subtitle;
  final IconData icon;
}

class _CategoryGridTile extends StatelessWidget {
  const _CategoryGridTile({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  final _CategoryOption option;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final border = selected ? AppPalette.primary500 : AppPalette.neutral200;
    final bg = selected ? AppPalette.primary50 : Colors.white;

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: border, width: selected ? 2 : 1),
          ),
          padding: const EdgeInsets.fromLTRB(12, 14, 12, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                option.icon,
                size: 30,
                color: AppPalette.primary600,
              ),
              const SizedBox(height: 8),
              Text(
                option.label,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: AppPalette.neutral900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                option.subtitle,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  height: 1.25,
                  color: AppPalette.neutral500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PrimaryBottomButton extends StatelessWidget {
  const _PrimaryBottomButton({
    required this.loading,
    required this.onPressed,
  });

  final bool loading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppPalette.primary500,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: loading ? null : onPressed,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Center(
            child: loading
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text(
                    'Create Group',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 0.2,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
