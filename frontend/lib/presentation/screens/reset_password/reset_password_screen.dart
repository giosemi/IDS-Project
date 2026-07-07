import 'package:artid/presentation/screens/reset_password/widgets/reset_password_card.dart';
import 'package:artid/presentation/widgets/app_logo.dart';
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
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const AppLogo(height: 72),
                const SizedBox(height: 28),
                ResetPasswordCard(email: email, devOtp: devOtp),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
