import 'package:artid/data/services/institution_api_service.dart';
import 'package:artid/presentation/widgets/app_snack_bar.dart';
import 'package:artid/providers/auth/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RegisterCard extends ConsumerStatefulWidget {
  const RegisterCard({super.key});

  @override
  ConsumerState<RegisterCard> createState() => _RegisterCardState();
}

class _RegisterCardState extends ConsumerState<RegisterCard> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String? _selectedInstitution;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final response = await ref.read(authProvider.notifier).register(
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
          institution: _selectedInstitution!,
        );

    if (!mounted) return;

    if (response != null) {
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          final colors = Theme.of(dialogContext).colorScheme;
          return AlertDialog(
            icon: Icon(Icons.check_circle_rounded, color: colors.primary, size: 48),
            title: const Text('Registrazione completata'),
            content: Text(
              'Il tuo account ArtID è stato creato con successo.\nBenvenuto, ${response.name}!',
              textAlign: TextAlign.center,
            ),
            actionsAlignment: MainAxisAlignment.center,
            actions: [
              FilledButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('Continua'),
              ),
            ],
          );
        },
      );

      if (!mounted) return;

      ref.read(authProvider.notifier).completeRegistration(response);
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
    final institutionsAsync = ref.watch(afamInstitutionsProvider);

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
                  child: Icon(Icons.person_add_rounded, size: 42, color: colors.onPrimaryContainer),
                ),
                const SizedBox(height: 24),
                Text(
                  'Crea account',
                  style: text.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Registrati su ArtID',
                  style: text.bodyLarge?.copyWith(color: colors.onSurfaceVariant),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 36),
                institutionsAsync.when(
                  loading: () => const InputDecorator(
                    decoration: InputDecoration(labelText: 'Istituto AFAM di appartenenza', prefixIcon: Icon(Icons.school_outlined)),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                    ),
                  ),
                  error: (_, _) => Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text('Impossibile caricare gli istituti AFAM', style: text.bodyMedium?.copyWith(color: colors.error)),
                      const SizedBox(height: 8),
                      OutlinedButton.icon(onPressed: () => ref.invalidate(afamInstitutionsProvider), icon: const Icon(Icons.refresh), label: const Text('Riprova')),
                    ],
                  ),
                  data: (institutions) => DropdownButtonFormField<String>(
                    initialValue: _selectedInstitution,
                    isExpanded: true,
                    decoration: const InputDecoration(labelText: 'Istituto AFAM di appartenenza', prefixIcon: Icon(Icons.school_outlined)),
                    hint: const Text('Seleziona il tuo istituto'),
                    items: institutions.map((institution) => DropdownMenuItem<String>(value: institution.name, child: Text(institution.label))).toList(),
                    onChanged: isLoading ? null : (value) => setState(() => _selectedInstitution = value),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Seleziona il tuo istituto AFAM';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _firstNameController,
                  textInputAction: TextInputAction.next,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(labelText: 'Nome', hintText: 'Il tuo nome', prefixIcon: Icon(Icons.person_outline)),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Inserisci il tuo nome';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _lastNameController,
                  textInputAction: TextInputAction.next,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(labelText: 'Cognome', hintText: 'Il tuo cognome', prefixIcon: Icon(Icons.person_outline)),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Inserisci il tuo cognome';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
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
                const SizedBox(height: 20),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.next,
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
                  validator: (value) {
                    if (value != _passwordController.text) {
                      return 'Le password non coincidono';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),
                FilledButton(
                  onPressed: isLoading ? null : _submit,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: isLoading ? SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: colors.onPrimary)) : const Text('Registrati'),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Hai già un account?', style: text.bodyMedium),
                    TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Accedi')),
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
