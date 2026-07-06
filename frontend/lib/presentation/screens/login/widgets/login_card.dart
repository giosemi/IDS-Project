import 'package:artid/presentation/screens/register/register_screen.dart';
import 'package:artid/presentation/widgets/app_snack_bar.dart';
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
  final TextEditingController _emailController = TextEditingController(text: 'test@test.com');
  final TextEditingController _passwordController = TextEditingController(text: 'password');

  bool _obscurePassword = true;
  bool _rememberMe = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
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

    final success = await ref.read(authProvider.notifier).login(email: _emailController.text, password: _passwordController.text);

    if (!mounted) return;

    if (success) {
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
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
                  child: Icon(Icons.palette_rounded, size: 42, color: colors.onPrimaryContainer),
                ),
                const SizedBox(height: 24),
                Text(
                  'Bentornato',
                  style: text.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Accedi al tuo account ArtID',
                  style: text.bodyLarge?.copyWith(color: colors.onSurfaceVariant),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 36),
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
                const SizedBox(height: 20),
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
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Checkbox(value: _rememberMe, onChanged: (value) => setState(() => _rememberMe = value ?? false)),
                          const Text('Ricordami'),
                        ],
                      ),
                    ),
                    TextButton(onPressed: () {}, child: const Text('Password dimenticata?')),
                  ],
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: isLoading ? null : _submit,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: isLoading ? SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: colors.onPrimary)) : const Text('Accedi'),
                  ),
                ),
                const SizedBox(height: 20),
                const Divider(endIndent: 50, indent: 50),
                const SizedBox(height: 20),
                OutlinedButton.icon(onPressed: isLoading ? null : _enterAsExternal, icon: const Icon(Icons.explore_outlined), label: const Text('Accedi come Esterno')),
                const SizedBox(height: 12),
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
        ),
      ),
    );
  }
}
