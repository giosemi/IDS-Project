import 'package:artid/presentation/widgets/app_logo.dart';
import 'package:artid/presentation/screens/login/widgets/login_card.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

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
                const AppLogo(height: 80),
                const SizedBox(height: 32),
                const LoginCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
