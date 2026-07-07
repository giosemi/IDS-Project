import 'package:artid/presentation/screens/otp/widgets/otp_card.dart';
import 'package:flutter/material.dart';

class OtpScreen extends StatelessWidget {
  const OtpScreen({
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
            child: OtpCard(email: email, devOtp: devOtp),
          ),
        ),
      ),
    );
  }
}
