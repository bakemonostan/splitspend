import 'package:flutter/material.dart';
import 'package:split_spend/src/core/config/supabase_env.dart';
import 'package:split_spend/src/core/ui/app_toast.dart';
import 'package:split_spend/src/features/auth/validation/auth_field_validators.dart';
import 'package:split_spend/src/features/auth/widgets/auth_input_decoration.dart';
import 'package:split_spend/src/theme/theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  bool _submitting = false;

  Future<void> _send() async {
    if (!(_formKey.currentState?.validate() ?? false) || _submitting) return;
    setState(() => _submitting = true);
    try {
      await Supabase.instance.client.auth.resetPasswordForEmail(
        _emailController.text.trim(),
        redirectTo:
            SupabaseEnv.redirectUrl.isEmpty ? null : SupabaseEnv.redirectUrl,
      );
      if (!mounted) return;
      await AppToast.info(
        'If an account exists, check your email for a reset link.',
      );
      if (!mounted) return;
      Navigator.of(context).pop();
    } on AuthException catch (e) {
      if (mounted) await AppToast.error(e.message);
    } catch (e) {
      if (mounted) await AppToast.error(e.toString());
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(
            Icons.arrow_back,
            color: AppPalette.neutral900,
          ),
        ),
        centerTitle: true,
        title: Text(
          'SplitSpend',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppPalette.primary500,
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 16),
                    Center(
                      child: Container(
                        width: 88,
                        height: 88,
                        decoration: BoxDecoration(
                          color: AppPalette.primary100,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.lock_reset_rounded,
                          size: 40,
                          color: AppPalette.primary500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    const Text(
                      'Reset password',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: AppPalette.neutral900,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "Enter your email address and we'll send you instructions to reset your password",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        height: 1.45,
                        color: AppPalette.neutral500,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'Email Address',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppPalette.neutral700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      autocorrect: false,
                      textInputAction: TextInputAction.done,
                      validator: AuthFieldValidators.email,
                      onFieldSubmitted: (_) => _send(),
                      decoration: buildAuthInputDecoration(
                        hintText: 'e.g. alex@example.com',
                        prefixIcon: const Icon(
                          Icons.mail_outline,
                          color: AppPalette.neutral500,
                          size: 22,
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: FilledButton.icon(
                        onPressed: _submitting ? null : _send,
                        icon: _submitting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(
                                Icons.send_rounded,
                                size: 20,
                                color: Colors.white,
                              ),
                        label: Text(
                          _submitting ? 'Sending…' : 'Send Reset Link',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppPalette.primary500,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: AppPalette.primary300,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(kAuthFieldRadius),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: TextButton.icon(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: Icon(
                          Icons.arrow_back,
                          size: 18,
                          color: AppPalette.primary500,
                        ),
                        label: const Text(
                          'Back to Sign In',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppPalette.primary500,
                          ),
                        ),
                        style: TextButton.styleFrom(
                          foregroundColor: AppPalette.primary500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.shield_outlined,
                            size: 16,
                            color: AppPalette.neutral300,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Secure Password Recovery',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: AppPalette.neutral300,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
