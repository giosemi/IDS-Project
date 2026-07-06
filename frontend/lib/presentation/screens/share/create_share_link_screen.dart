import 'package:artid/core/costants/app_spacing.dart';
import 'package:artid/domain/models/content_item.dart';
import 'package:artid/presentation/layout/layout.dart';
import 'package:artid/presentation/screens/share/shared_profile_screen.dart';
import 'package:artid/presentation/widgets/content_widgets.dart';
import 'package:artid/presentation/widgets/app_snack_bar.dart';
import 'package:artid/providers/portfolio/portfolio_provider.dart';
import 'package:artid/providers/share/share_links_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CreateShareLinkScreen extends ConsumerStatefulWidget {
  const CreateShareLinkScreen({super.key});

  @override
  ConsumerState<CreateShareLinkScreen> createState() => _CreateShareLinkScreenState();
}

class _CreateShareLinkScreenState extends ConsumerState<CreateShareLinkScreen> {
  final _labelController = TextEditingController();
  final _selectedIds = <String>{};
  var _includeProfile = true;
  var _hasExpiry = false;
  var _isCreating = false;

  @override
  void dispose() {
    _labelController.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    if (_labelController.text.trim().isEmpty) {
      AppSnackBar.error(context, 'Inserisci un\'etichetta per il link');
      return;
    }
    if (_selectedIds.isEmpty && !_includeProfile) {
      AppSnackBar.error(context, 'Seleziona almeno un contenuto o il profilo');
      return;
    }
    if (_isCreating) return;
    setState(() => _isCreating = true);

    final link = await ref.read(shareLinksProvider.notifier).create(
          label: _labelController.text.trim(),
          contentIds: _selectedIds.toList(),
          includeProfile: _includeProfile,
          expiresAt: _hasExpiry ? DateTime.now().add(const Duration(days: 30)) : null,
        );

    if (!mounted) return;
    setState(() => _isCreating = false);

    if (link == null) {
      AppSnackBar.error(context, 'Errore nella creazione del link');
      return;
    }

    Navigator.of(context).pop();
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => SharedProfileScreen(token: link.token)));
  }

  @override
  Widget build(BuildContext context) {
    final contents = ref.watch(portfolioProvider);

    return AppLayout(
      title: 'Nuovo link',
      subtitle: 'Scegli cosa condividere',
      showBackButton: true,
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          TextField(
            controller: _labelController,
            decoration: const InputDecoration(labelText: 'Etichetta', hintText: 'Es. Audizione Conservatorio di Milano'),
          ),
          const SizedBox(height: AppSpacing.lg),
          SwitchListTile(contentPadding: EdgeInsets.zero, title: const Text('Includi profilo'), subtitle: const Text('Nome, bio, percorso accademico'), value: _includeProfile, onChanged: (v) => setState(() => _includeProfile = v)),
          SwitchListTile(contentPadding: EdgeInsets.zero, title: const Text('Scadenza 30 giorni'), value: _hasExpiry, onChanged: (v) => setState(() => _hasExpiry = v)),
          const SizedBox(height: AppSpacing.lg),
          Text('CONTENUTI', style: Theme.of(context).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w700, letterSpacing: 1.1)),
          const SizedBox(height: AppSpacing.sm),
          if (contents.isEmpty)
            Text('Nessun contenuto nel portfolio', style: Theme.of(context).textTheme.bodyMedium)
          else
            ...contents.map(
              (item) => _ContentCheckbox(
                item: item,
                selected: _selectedIds.contains(item.id),
                onChanged: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedIds.add(item.id);
                    } else {
                      _selectedIds.remove(item.id);
                    }
                  });
                },
              ),
            ),
          const SizedBox(height: AppSpacing.xl),
          FilledButton.icon(
            onPressed: _isCreating ? null : _create,
            icon: _isCreating
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.link_rounded),
            label: const Text('Genera link'),
          ),
        ],
      ),
    );
  }
}

class _ContentCheckbox extends StatelessWidget {
  const _ContentCheckbox({required this.item, required this.selected, required this.onChanged});

  final ContentItem item;
  final bool selected;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: CheckboxListTile(
        value: selected,
        onChanged: (v) => onChanged(v ?? false),
        secondary: ContentTypeIcon(type: item.type, size: 36),
        title: Text(item.title),
        subtitle: Row(
          children: [
            Text(item.type.label),
            const SizedBox(width: AppSpacing.sm),
          ],
        ),
      ),
    );
  }
}
