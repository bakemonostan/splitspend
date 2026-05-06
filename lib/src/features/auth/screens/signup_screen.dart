import 'package:flutter/material.dart';
import 'package:split_spend/src/core/ui/app_toast.dart';
import 'package:split_spend/src/features/auth/validation/auth_field_validators.dart';
import 'package:split_spend/src/features/auth/widgets/auth_brand_header.dart';
import 'package:split_spend/src/features/auth/widgets/auth_footer_link.dart';
import 'package:split_spend/src/features/auth/widgets/auth_headline.dart';
import 'package:split_spend/src/features/auth/widgets/auth_input_decoration.dart';
import 'package:split_spend/src/features/auth/widgets/auth_primary_button.dart';
import 'package:split_spend/src/features/auth/widgets/auth_social_login_row.dart';
import 'package:split_spend/src/theme/theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _agreedToTerms = false;
  bool _submitting = false;

  void _onFieldOrTermsChanged() {
    setState(() {});
  }

  bool get _canSubmit {
    if (!_agreedToTerms) return false;
    if (AuthFieldValidators.fullName(_nameController.text) != null) {
      return false;
    }
    if (AuthFieldValidators.email(_emailController.text) != null) {
      return false;
    }
    if (AuthFieldValidators.signupPassword(_passwordController.text) != null) {
      return false;
    }
    return true;
  }

  Future<void> _submit() async {
    final valid = _formKey.currentState?.validate() ?? false;
    if (!valid || !_agreedToTerms || _submitting) return;
    setState(() => _submitting = true);
    try {
      final res = await Supabase.instance.client.auth.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        data: {'full_name': _nameController.text.trim()},
      );
      if (!mounted) return;
      if (res.user == null) {
        await AppToast.error('Could not create account. Please try again.');
        return;
      }
      // If email confirmation is off, Supabase returns a session and AuthGate
      // would jump to Home. We want sign-in first, so clear any session.
      await Supabase.instance.client.auth.signOut();
      if (!mounted) return;
      await AppToast.success(
        'Account created. Sign in with your email and password.',
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
  void initState() {
    super.initState();
    _nameController.addListener(_onFieldOrTermsChanged);
    _emailController.addListener(_onFieldOrTermsChanged);
    _passwordController.addListener(_onFieldOrTermsChanged);
  }

  @override
  void dispose() {
    _nameController.removeListener(_onFieldOrTermsChanged);
    _emailController.removeListener(_onFieldOrTermsChanged);
    _passwordController.removeListener(_onFieldOrTermsChanged);
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPalette.primary50,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const AuthBrandHeader(),
                  const SizedBox(height: 24),
                  const AuthHeadline(
                    title: 'Create account',
                    subtitle: 'Start your journey to anxiety-free finance',
                  ),
                  const SizedBox(height: 28),
                  Form(
                    key: _formKey,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Full Name',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppPalette.neutral700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _nameController,
                          textInputAction: TextInputAction.next,
                          textCapitalization: TextCapitalization.words,
                          validator: AuthFieldValidators.fullName,
                          decoration: buildAuthInputDecoration(
                            hintText: 'John Doe',
                            prefixIcon: const Icon(
                              Icons.person_outline,
                              color: AppPalette.neutral500,
                              size: 22,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Email',
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
                          textInputAction: TextInputAction.next,
                          validator: AuthFieldValidators.email,
                          decoration: buildAuthInputDecoration(
                            hintText: 'name@example.com',
                            prefixIcon: const Icon(
                              Icons.mail_outline,
                              color: AppPalette.neutral500,
                              size: 22,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Password',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppPalette.neutral700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          obscuringCharacter: '•',
                          textInputAction: TextInputAction.done,
                          validator: AuthFieldValidators.signupPassword,
                          decoration: buildAuthInputDecoration(
                            hintText: 'At least 8 characters',
                            prefixIcon: const Icon(
                              Icons.lock_outline_rounded,
                              color: AppPalette.neutral500,
                              size: 22,
                            ),
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: AppPalette.neutral500,
                                size: 22,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: 24,
                              width: 24,
                              child: Checkbox(
                                value: _agreedToTerms,
                                onChanged: (v) {
                                  setState(() {
                                    _agreedToTerms = v ?? false;
                                  });
                                },
                                fillColor: WidgetStateProperty.resolveWith((
                                  states,
                                ) {
                                  if (states.contains(WidgetState.selected)) {
                                    return AppPalette.primary500;
                                  }
                                  return null;
                                }),
                                side: const BorderSide(
                                  color: AppPalette.neutral300,
                                ),
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                                visualDensity: VisualDensity.compact,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 2),
                                child: Wrap(
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    Text(
                                      'I agree to the ',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: AppPalette.neutral500,
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {},
                                      child: Text(
                                        'Terms',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: AppPalette.primary500,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      ' and ',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: AppPalette.neutral500,
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {},
                                      child: Text(
                                        'Privacy Policy',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: AppPalette.primary500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  AuthPrimaryButton(
                    label: _submitting ? 'Creating account…' : 'Create Account',
                    onPressed: (_canSubmit && !_submitting)
                        ? () => _submit()
                        : null,
                  ),
                  const SizedBox(height: 28),
                  AuthSocialLoginRow(
                    onGoogle: () {},
                    onApple: () {},
                  ),
                  const SizedBox(height: 28),
                  AuthFooterLink(
                    leadingText: 'Already have an account? ',
                    linkText: 'Sign in',
                    onLinkTap: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
