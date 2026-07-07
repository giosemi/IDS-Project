import 'package:artid/presentation/widgets/app_snack_bar.dart';
import 'package:artid/presentation/widgets/otp_input_field.dart';
import 'package:artid/providers/auth/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OtpCard extends ConsumerStatefulWidget {
  const OtpCard({required this.email, this.devOtp, super.key});

  final String email;
  final String? devOtp;

  @override
  ConsumerState<OtpCard> createState() => _OtpCardState();
}

class _OtpCardState extends ConsumerState<OtpCard> {
  static const _otpLength = 5;

  String _otpCode = '';
  String? _devOtp;

  @override
  void initState() {
    super.initState();
    _devOtp = widget.devOtp;
  }

  Future<void> _submit([String? code]) async {
    final otp = code ?? _otpCode;
    if (otp.length != _otpLength) {
      AppSnackBar.error(context, 'Inserisci il codice a $_otpLength cifre');
      return;
    }

    final success = await ref.read(authProvider.notifier).verifyOtp(email: widget.email, otp: otp);

    if (!mounted) return;

    if (success) {
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
    final canSubmit = _otpCode.length == _otpLength && !isLoading;

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
                child: Icon(Icons.mark_email_read_outlined, size: 42, color: colors.onPrimaryContainer),
              ),
              const SizedBox(height: 24),
              Text(
                'Verifica accesso',
                style: text.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Inserisci il codice inviato via e-mail a ${widget.email}',
                style: text.bodyLarge?.copyWith(color: colors.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
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
              OtpInputField(length: _otpLength, onChanged: (code) => setState(() => _otpCode = code), onCompleted: _submit),
              const SizedBox(height: 32),
              FilledButton(
                onPressed: canSubmit ? _submit : null,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: isLoading ? SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: colors.onPrimary)) : const Text('Conferma'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
