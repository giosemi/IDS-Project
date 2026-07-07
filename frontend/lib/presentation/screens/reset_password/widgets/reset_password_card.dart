import 'package:artid/presentation/widgets/app_snack_bar.dart';
import 'package:artid/presentation/widgets/otp_input_field.dart';
import 'package:artid/providers/auth/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ResetPasswordCard extends ConsumerStatefulWidget {
  const ResetPasswordCard({required this.email, this.devOtp, super.key});

  final String email;
  final String? devOtp;

  @override
  ConsumerState<ResetPasswordCard> createState() => _ResetPasswordCardState();
}

class _ResetPasswordCardState extends ConsumerState<ResetPasswordCard> {
  static const _otpLength = 5;

  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String _otpCode = '';
  String? _devOtp;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    _devOtp = widget.devOtp;
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_otpCode.length != _otpLength) {
      AppSnackBar.error(context, 'Inserisci il codice a $_otpLength cifre');
      return;
    }
    if (_passwordController.text.length < 6) {
      AppSnackBar.error(context, 'La password deve avere almeno 6 caratteri');
      return;
    }
    if (_passwordController.text != _confirmPasswordController.text) {
      AppSnackBar.error(context, 'Le password non coincidono');
      return;
    }

    final success = await ref.read(authProvider.notifier).resetPassword(email: widget.email, code: _otpCode, newPassword: _passwordController.text);

    if (!mounted) return;

    if (success) {
      AppSnackBar.success(context, 'Password aggiornata. Ora puoi accedere.');
      Navigator.of(context).popUntil((route) => route.isFirst);
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                height: 88,
                width: 88,
                decoration: BoxDecoration(color: colors.primaryContainer, shape: BoxShape.circle),
                child: Icon(Icons.vpn_key_outlined, size: 42, color: colors.onPrimaryContainer),
              ),
              const SizedBox(height: 24),
              Text(
                'Imposta nuova password',
                style: text.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Inserisci il codice inviato a ${widget.email} e scegli una nuova password.',
                style: text.bodyLarge?.copyWith(color: colors.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
              if (_devOtp != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: colors.primaryContainer.withValues(alpha: 0.35), borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    children: [
                      Icon(Icons.developer_mode, size: 20, color: colors.primary),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text('Codice di sviluppo: $_devOtp', style: text.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 24),
              OtpInputField(length: _otpLength, onChanged: (code) => setState(() => _otpCode = code)),
              const SizedBox(height: 24),
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: 'Nuova password',
                  hintText: '••••••••',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(icon: Icon(_obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined), onPressed: () => setState(() => _obscurePassword = !_obscurePassword)),
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: _obscureConfirmPassword,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _submit(),
                decoration: InputDecoration(
                  labelText: 'Conferma password',
                  hintText: '••••••••',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(icon: Icon(_obscureConfirmPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined), onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword)),
                ),
              ),
              const SizedBox(height: 32),
              FilledButton(
                onPressed: isLoading ? null : _submit,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: isLoading ? SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: colors.onPrimary)) : const Text('Salva password'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
