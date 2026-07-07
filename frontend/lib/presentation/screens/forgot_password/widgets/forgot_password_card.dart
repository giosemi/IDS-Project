import 'package:artid/core/costants/app_spacing.dart';
import 'package:artid/presentation/screens/reset_password/reset_password_screen.dart';
import 'package:artid/presentation/widgets/app_snack_bar.dart';
import 'package:artid/presentation/widgets/auth_form_card.dart';
import 'package:artid/providers/auth/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ForgotPasswordCard extends ConsumerStatefulWidget {
  const ForgotPasswordCard({super.key});

  @override
  ConsumerState<ForgotPasswordCard> createState() => _ForgotPasswordCardState();
}

class _ForgotPasswordCardState extends ConsumerState<ForgotPasswordCard> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim();
    final response = await ref.read(authProvider.notifier).requestPasswordReset(email: email);

    if (!mounted) return;

    if (response != null) {
      await Navigator.of(context).push<void>(
        MaterialPageRoute<void>(
          builder: (_) => ResetPasswordScreen(email: email, devOtp: response.devOtp),
        ),
      );
    } else {
      final error = ref.read(authProvider).errorMessage;
      if (error != null) {
        AppSnackBar.error(context, error);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final isLoading = ref.watch(authProvider.select((state) => state.isLoading));

    return AuthFormCard(
      icon: Icons.lock_reset_rounded,
      title: 'Password dimenticata?',
      subtitle: 'Inserisci la tua email: ti invieremo un codice per reimpostare la password.',
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _submit(),
              decoration: const InputDecoration(labelText: 'Indirizzo email', hintText: 'nome@email.com', prefixIcon: Icon(Icons.email_outlined)),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Inserisci la tua email';
                }
                if (!value.contains('@')) {
                  return 'Email non valida';
                }
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.lg),
            AuthPrimaryButton(label: 'Recupera credenziali', icon: Icons.send_rounded, onPressed: isLoading ? null : _submit, isLoading: isLoading),
            const SizedBox(height: AppSpacing.lg),
            const AuthOrDivider(),
            const SizedBox(height: AppSpacing.lg),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Ti sei ricordato la password?', style: text.bodyMedium),
                TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Accedi')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
