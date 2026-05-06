import 'package:flutter/material.dart';
import 'package:split_spend/src/core/ui/app_toast.dart';
import 'package:split_spend/src/features/auth/screens/forgotpassword_screen.dart';
import 'package:split_spend/src/features/auth/screens/signup_screen.dart';
import 'package:split_spend/src/features/auth/validation/auth_field_validators.dart';
import 'package:split_spend/src/features/auth/widgets/auth_brand_header.dart';
import 'package:split_spend/src/features/auth/widgets/auth_footer_link.dart';
import 'package:split_spend/src/features/auth/widgets/auth_headline.dart';
import 'package:split_spend/src/features/auth/widgets/auth_input_decoration.dart';
import 'package:split_spend/src/features/auth/widgets/auth_primary_button.dart';
import 'package:split_spend/src/features/auth/widgets/auth_social_login_row.dart';
import 'package:split_spend/src/theme/theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SigninScreen extends StatefulWidget {
  const SigninScreen({super.key});

  @override
  State<SigninScreen> createState() => _SigninScreenState();
}

class _SigninScreenState extends State<SigninScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _submitting = false;

  void _onFieldsChanged() {
    setState(() {});
  }

  bool get _canSubmit {
    if (AuthFieldValidators.email(_emailController.text) != null) return false;
    if (AuthFieldValidators.signInPassword(_passwordController.text) != null) {
      return false;
    }
    return true;
  }

  Future<void> _signIn() async {
    final ok = _formKey.currentState?.validate() ?? false;
    if (!ok || _submitting) return;
    setState(() => _submitting = true);
    try {
      await Supabase.instance.client.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      // No BuildContext needed; show even if AuthGate swaps to Home immediately.
      await AppToast.success('Signed in successfully.');
    } on AuthException catch (e) {
      await AppToast.error(e.message);
    } catch (e) {
      await AppToast.error(e.toString());
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_onFieldsChanged);
    _passwordController.addListener(_onFieldsChanged);
  }

  @override
  void dispose() {
    _emailController.removeListener(_onFieldsChanged);
    _passwordController.removeListener(_onFieldsChanged);
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
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const AuthBrandHeader(),
                    const SizedBox(height: 24),
                    const AuthHeadline(
                      title: 'Welcome back',
                      subtitle: 'Please enter your details to sign in',
                    ),
                    const SizedBox(height: 28),
                    Form(
                      key: _formKey,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Email address',
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
                              hintText: 'name@company.com',
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                'Password',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: AppPalette.neutral700,
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const ForgotPasswordScreen(),
                                    ),
                                  );
                                },
                                style: TextButton.styleFrom(
                                  foregroundColor: AppPalette.primary500,
                                  elevation: 0,
                                  padding: EdgeInsets.zero,
                                ),
                                child: Text(
                                  'Forgot password?',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    color: AppPalette.primary500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            obscuringCharacter: '•',
                            textInputAction: TextInputAction.done,
                            validator: AuthFieldValidators.signInPassword,
                            onFieldSubmitted: (_) {
                              if (_canSubmit) _signIn();
                            },
                            decoration: buildAuthInputDecoration(
                              hintText: 'Enter your password',
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
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                    AuthPrimaryButton(
                      label: _submitting ? 'Signing in…' : 'Sign In',
                      onPressed:
                          (_canSubmit && !_submitting) ? () => _signIn() : null,
                    ),
                    const SizedBox(height: 28),
                    AuthSocialLoginRow(
                      onGoogle: () {},
                      onApple: () {},
                    ),
                    const SizedBox(height: 28),
                    AuthFooterLink(
                      leadingText: "Don't have an account? ",
                      linkText: 'Sign up',
                      onLinkTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (context) => const SignupScreen(),
                          ),
                        );
                      },
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
