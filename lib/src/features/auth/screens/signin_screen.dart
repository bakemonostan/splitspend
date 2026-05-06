import 'package:flutter/material.dart';
import 'package:split_spend/src/widgets/logo_icon.dart';

class SigninScreen extends StatefulWidget {
  const SigninScreen({super.key});

  @override
  State<SigninScreen> createState() => _SigninScreenState();
}

class _SigninScreenState extends State<SigninScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign in')),
      body: const Center(child: Text('Sign in')),
      bottomNavigationBar: const LogoFull(),
    );
  }
}
