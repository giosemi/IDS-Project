import 'package:artid/core/costants/app_spacing.dart';
import 'package:artid/presentation/widgets/app_snack_bar.dart';
import 'package:artid/presentation/widgets/auth_form_card.dart';
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
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final isLoading = ref.watch(authProvider.select((state) => state.isLoading));

    return AuthFormCard(
      icon: Icons.vpn_key_rounded,
      title: 'Imposta nuova password',
      subtitle: 'Inserisci il codice inviato a ${widget.email} e scegli una nuova password.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_devOtp != null) ...[
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
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
            const SizedBox(height: AppSpacing.lg),
          ],
          OtpInputField(length: _otpLength, onChanged: (code) => setState(() => _otpCode = code)),
          const SizedBox(height: AppSpacing.lg),
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
          const SizedBox(height: AppSpacing.md),
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
          const SizedBox(height: AppSpacing.lg),
          AuthPrimaryButton(label: 'Conferma', icon: Icons.check_rounded, onPressed: isLoading ? null : _submit, isLoading: isLoading),
        ],
      ),
    );
  }
}
