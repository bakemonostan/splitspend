import 'package:flutter/material.dart';
import 'package:split_spend/src/core/ui/app_toast.dart';
import 'package:split_spend/src/features/groups/data/groups_repository.dart';
import 'package:split_spend/src/theme/theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Join flow — matches SplitSpend modal-style layout (close + centered logo).
class JoinGroupScreen extends StatefulWidget {
  const JoinGroupScreen({super.key});

  @override
  State<JoinGroupScreen> createState() => _JoinGroupScreenState();
}

class _JoinGroupScreenState extends State<JoinGroupScreen> {
  final _codeController = TextEditingController();
  final _focusNode = FocusNode();
  late final GroupsRepository _repo;
  bool _submitting = false;

  static const _radius = 12.0;

  @override
  void initState() {
    super.initState();
    _repo = GroupsRepository(Supabase.instance.client);
  }

  @override
  void dispose() {
    _codeController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_submitting) {
      return;
    }
    final normalized = GroupsRepository.normalizeInviteCode(_codeController.text);
    if (normalized.length < 4) {
      await AppToast.error('Enter the invite code.');
      return;
    }

    setState(() => _submitting = true);
    try {
      await _repo.joinGroupByInviteCode(normalized);
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      final msg = e.toString().toLowerCase().contains('invalid')
          ? 'Invalid invite code'
          : 'Could not join group';
      await AppToast.error(msg);
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close_rounded, color: AppPalette.neutral800),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: _SplitSpendWordmark(),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),
              Center(child: _JoinHeroIcon()),
              const SizedBox(height: 28),
              Text(
                'Join a Group',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppPalette.neutral900,
                  fontSize: 22,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Collaborate on expenses with friends or family by entering '
                'their unique group invite code.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  height: 1.45,
                  color: AppPalette.neutral500,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'INVITE CODE',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                  color: AppPalette.neutral400,
                ),
              ),
              const SizedBox(height: 8),
              _InviteCodeField(
                controller: _codeController,
                focusNode: _focusNode,
                radius: _radius,
                onFieldSubmitted: (_) => _submit(),
              ),
              const SizedBox(height: 20),
              _InfoCallout(radius: _radius),
              const SizedBox(height: 36),
              _PrimaryPillButton(
                label: 'Join Group',
                loading: _submitting,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SplitSpendWordmark extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          'assets/img/general/logo_filled.png',
          width: 28,
          height: 28,
          fit: BoxFit.contain,
        ),
        const SizedBox(width: 8),
        Text(
          'SplitSpend',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: AppPalette.primary600,
            letterSpacing: -0.3,
          ),
        ),
      ],
    );
  }
}

class _JoinHeroIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 88,
      height: 88,
      decoration: BoxDecoration(
        color: AppPalette.primary50,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppPalette.primary500.withValues(alpha: 0.12),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(Icons.person_rounded, size: 44, color: AppPalette.primary500),
          Positioned(
            right: 14,
            bottom: 14,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppPalette.neutral900.withValues(alpha: 0.08),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: Icon(
                Icons.add_rounded,
                size: 16,
                color: AppPalette.primary600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InviteCodeField extends StatelessWidget {
  const _InviteCodeField({
    required this.controller,
    required this.focusNode,
    required this.radius,
    this.onFieldSubmitted,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final double radius;
  final void Function(String)? onFieldSubmitted;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: AppPalette.neutral200),
        boxShadow: [
          BoxShadow(
            color: AppPalette.neutral900.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Text(
              '#',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: AppPalette.neutral400,
              ),
            ),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              textCapitalization: TextCapitalization.characters,
              autocorrect: false,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.6,
              ),
              decoration: InputDecoration(
                hintText: 'e.g. SPLIT-1234',
                hintStyle: TextStyle(
                  color: AppPalette.neutral300,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.3,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 16,
                ),
              ),
              onSubmitted: onFieldSubmitted,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCallout extends StatelessWidget {
  const _InfoCallout({required this.radius});

  final double radius;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppPalette.neutral50,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: AppPalette.neutral100),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.info_outline_rounded,
              size: 20,
              color: AppPalette.primary500,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'You can only join private groups with a valid invitation. '
                'Please ask the group owner to share the code from their '
                'group settings.',
                style: TextStyle(
                  fontSize: 13,
                  height: 1.45,
                  color: AppPalette.neutral600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PrimaryPillButton extends StatelessWidget {
  const _PrimaryPillButton({
    required this.label,
    required this.loading,
    required this.onPressed,
  });

  final String label;
  final bool loading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppPalette.primary500,
      borderRadius: BorderRadius.circular(14),
      elevation: 0,
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
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        label,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
