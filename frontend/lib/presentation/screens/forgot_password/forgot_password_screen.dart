import 'package:artid/presentation/screens/forgot_password/widgets/forgot_password_card.dart';
import 'package:artid/presentation/widgets/app_logo.dart';
import 'package:flutter/material.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

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
                const ForgotPasswordCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
