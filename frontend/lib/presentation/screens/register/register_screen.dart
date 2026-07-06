import 'package:flutter/material.dart' hide SwitchTheme;
import 'package:artid/core/theme/widgets/switch_theme.dart';
import 'package:artid/presentation/screens/register/widgets/register_card.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const SafeArea(
            child: Center(
              child: SingleChildScrollView(padding: EdgeInsets.all(24), child: RegisterCard()),
            ),
          ),
          Positioned(top: MediaQuery.of(context).padding.top + 8, right: 16, child: const SwitchTheme()),
        ],
      ),
    );
  }
}
