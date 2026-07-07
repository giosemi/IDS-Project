import 'package:artid/presentation/screens/reset_password/widgets/reset_password_card.dart';
import 'package:flutter/material.dart';

class ResetPasswordScreen extends StatelessWidget {
  const ResetPasswordScreen({
    required this.email,
    this.devOtp,
    super.key,
  });

  final String email;
  final String? devOtp;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nuova password')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ResetPasswordCard(email: email, devOtp: devOtp),
          ),
        ),
      ),
    );
  }
}
