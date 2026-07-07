import 'package:artid/core/costants/app_spacing.dart';
import 'package:artid/domain/models/student_profile.dart';
import 'package:artid/presentation/layout/layout.dart';
import 'package:artid/presentation/widgets/app_snack_bar.dart';
import 'package:artid/providers/profile/profile_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController? _nameController;
  TextEditingController? _institutionController;
  TextEditingController? _yearController;
  TextEditingController? _bioController;

  void _initControllers(StudentProfile profile) {
    _nameController ??= TextEditingController(text: profile.fullName);
    _institutionController ??= TextEditingController(text: profile.institution);
    _yearController ??= TextEditingController(text: profile.studyYear.toString());
    _bioController ??= TextEditingController(text: profile.bio);
  }

  @override
  void dispose() {
    _nameController?.dispose();
    _institutionController?.dispose();
    _yearController?.dispose();
    _bioController?.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final current = ref.read(profileProvider)!;
    final updated = current.copyWith(
      fullName: _nameController!.text.trim(),
      institution: _institutionController!.text.trim(),
      studyYear: int.parse(_yearController!.text.trim()),
      bio: _bioController!.text.trim(),
    );

    await ref.read(profileProvider.notifier).update(updated);
    if (!mounted) return;
    Navigator.of(context).pop();
    AppSnackBar.success(context, 'Profilo aggiornato');
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(profileProvider);

    if (profile == null) {
      return const AppLayout(
        title: 'Modifica profilo',
        showBackButton: true,
        body: Center(child: Text('Profilo non disponibile')),
      );
    }

    _initControllers(profile);

    return AppLayout(
      title: 'Modifica profilo',
      showBackButton: true,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(controller: _nameController, decoration: const InputDecoration(labelText: 'Nome completo'), validator: _required),
              const SizedBox(height: AppSpacing.md),
              TextFormField(controller: _institutionController, decoration: const InputDecoration(labelText: 'Istituzione AFAM'), validator: _required),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _yearController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Anno di corso'),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Obbligatorio';
                  if (int.tryParse(v.trim()) == null) return 'Numero non valido';
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(controller: _bioController, maxLines: 4, decoration: const InputDecoration(labelText: 'Bio', alignLabelWithHint: true), validator: _required),
              const SizedBox(height: AppSpacing.xl),
              FilledButton(onPressed: _save, child: const Text('Salva modifiche')),
            ],
          ),
        ),
      ),
    );
  }

  String? _required(String? v) => v == null || v.trim().isEmpty ? 'Campo obbligatorio' : null;
}
