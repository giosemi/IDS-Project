import 'package:artid/presentation/screens/reset_password/reset_password_screen.dart';
import 'package:artid/presentation/widgets/app_snack_bar.dart';
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
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final text = theme.textTheme;
    final isLoading = ref.watch(authProvider.select((state) => state.isLoading));

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 420),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  height: 88,
                  width: 88,
                  decoration: BoxDecoration(color: colors.primaryContainer, shape: BoxShape.circle),
                  child: Icon(Icons.lock_reset_rounded, size: 42, color: colors.onPrimaryContainer),
                ),
                const SizedBox(height: 24),
                Text(
                  'Password dimenticata?',
                  style: text.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Inserisci la tua email: ti invieremo un codice per reimpostare la password.',
                  style: text.bodyLarge?.copyWith(color: colors.onSurfaceVariant),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 36),
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
                const SizedBox(height: 32),
                FilledButton(
                  onPressed: isLoading ? null : _submit,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: isLoading ? SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: colors.onPrimary)) : const Text('Invia codice'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
