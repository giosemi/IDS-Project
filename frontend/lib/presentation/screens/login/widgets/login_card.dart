import 'package:artid/core/costants/app_spacing.dart';
import 'package:artid/presentation/screens/forgot_password/forgot_password_screen.dart';
import 'package:artid/presentation/screens/otp/otp_screen.dart';
import 'package:artid/presentation/screens/register/register_screen.dart';
import 'package:artid/presentation/widgets/app_snack_bar.dart';
import 'package:artid/presentation/widgets/auth_form_card.dart';
import 'package:artid/providers/auth/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginCard extends ConsumerStatefulWidget {
  const LoginCard({super.key});

  @override
  ConsumerState<LoginCard> createState() => _LoginCardState();
}

class _LoginCardState extends ConsumerState<LoginCard> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _loginWithSpid() async {
    AppSnackBar.info(context, 'Funzionalità presto disponibile');
  }

  Future<void> _enterAsExternal() async {
    if (!ref.read(authProvider).isGuest) {
      ref.read(authProvider.notifier).enterAsGuest();
    }

    if (!mounted) return;

    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim();
    final response = await ref.read(authProvider.notifier).requestLoginOtp(email: email, password: _passwordController.text);

    if (!mounted) return;

    if (response != null) {
      await Navigator.of(context).push<void>(
        MaterialPageRoute<void>(
          builder: (_) => OtpScreen(email: email, devOtp: response.devOtp),
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
      title: 'Bentornato',
      subtitle: 'Accedi al tuo account ArtID',
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(labelText: 'Email', hintText: 'nome@email.com', prefixIcon: Icon(Icons.email_outlined)),
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
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _submit(),
              decoration: InputDecoration(
                labelText: 'Password',
                hintText: '••••••••',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(icon: Icon(_obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined), onPressed: () => setState(() => _obscurePassword = !_obscurePassword)),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Inserisci la password';
                }
                if (value.length < 6) {
                  return 'Minimo 6 caratteri';
                }
                return null;
              },
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const ForgotPasswordScreen()));
                },
                child: const Text('Password dimenticata?'),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            AuthPrimaryButton(label: 'Accedi', icon: Icons.login_rounded, onPressed: isLoading ? null : _submit, isLoading: isLoading),
            const SizedBox(height: AppSpacing.sm),
            _SpidLoginButton(onPressed: isLoading ? null : _loginWithSpid),
            const SizedBox(height: AppSpacing.lg),
            const AuthOrDivider(),
            const SizedBox(height: AppSpacing.lg),
            _ExternalAccessTile(onPressed: isLoading ? null : _enterAsExternal),
            const SizedBox(height: AppSpacing.lg),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Non hai un account?', style: text.bodyMedium),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const RegisterScreen()));
                  },
                  child: const Text('Registrati'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SpidLoginButton extends StatelessWidget {
  const _SpidLoginButton({required this.onPressed});

  static const _spidBlue = Color(0xFF0066CC);

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _spidBlue,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        child: Container(
          height: 52,
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6)),
                child: const Text(
                  'SPID',
                  style: TextStyle(color: _spidBlue, fontWeight: FontWeight.w800, fontSize: 13, letterSpacing: 0.5),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              const Text(
                'Accedi con SPID/eIDAS',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExternalAccessTile extends StatelessWidget {
  const _ExternalAccessTile({required this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Material(
      color: colors.surfaceContainerHighest.withValues(alpha: 0.55),
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(color: colors.primaryContainer.withValues(alpha: 0.65), borderRadius: BorderRadius.circular(12)),
                child: Icon(Icons.travel_explore_rounded, color: colors.primary, size: 24),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Accedi come soggetto esterno', style: text.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 2),
                    Text('Esplora portfolio condivisi senza registrarti', style: text.bodySmall?.copyWith(color: colors.onSurfaceVariant)),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_rounded, color: colors.onSurfaceVariant, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
