import 'package:artid/core/costants/app_spacing.dart';
import 'package:artid/domain/models/content_item.dart';
import 'package:artid/presentation/layout/layout.dart';
import 'package:artid/presentation/screens/share/shared_profile_screen.dart';
import 'package:artid/presentation/widgets/app_snack_bar.dart';
import 'package:artid/presentation/widgets/content_widgets.dart';
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
  final _descriptionController = TextEditingController();
  final _selectedIds = <String>{};
  var _includeProfile = true;
  var _allowDownload = false;
  var _hasExpiry = false;
  DateTime? _expiryDate;
  var _isCreating = false;

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }

  DateTime _endOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59);
  }

  Future<void> _pickExpiryDate() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final picked = await showDatePicker(
      context: context,
      initialDate: _expiryDate ?? today.add(const Duration(days: 30)),
      firstDate: today,
      lastDate: today.add(const Duration(days: 365 * 5)),
      helpText: 'Seleziona data di scadenza',
      cancelText: 'Annulla',
      confirmText: 'Conferma',
    );

    if (!mounted || picked == null) return;

    setState(() {
      _expiryDate = picked;
      _hasExpiry = true;
    });
  }

  Future<void> _setHasExpiry(bool value) async {
    if (!value) {
      setState(() {
        _hasExpiry = false;
        _expiryDate = null;
      });
      return;
    }

    await _pickExpiryDate();
    if (!mounted) return;
    if (_expiryDate == null) {
      setState(() => _hasExpiry = false);
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    if (_descriptionController.text.trim().isEmpty) {
      AppSnackBar.error(context, 'Inserisci una descrizione per il link');
      return;
    }
    if (_selectedIds.isEmpty && !_includeProfile) {
      AppSnackBar.error(context, 'Seleziona almeno un\'opera o includi il profilo');
      return;
    }
    if (_hasExpiry && _expiryDate == null) {
      AppSnackBar.error(context, 'Seleziona una data di scadenza');
      return;
    }
    if (_isCreating) return;
    setState(() => _isCreating = true);

    try {
      final link = await ref.read(shareLinksProvider.notifier).create(label: _descriptionController.text.trim(), contentIds: _selectedIds.toList(), includeProfile: _includeProfile, allowDownload: _allowDownload, expiresAt: _hasExpiry && _expiryDate != null ? _endOfDay(_expiryDate!) : null);

      if (!mounted) return;
      setState(() => _isCreating = false);

      Navigator.of(context).pop();
      Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => SharedProfileScreen(token: link.token)));
    } on ShareLinkException catch (e) {
      if (!mounted) return;
      setState(() => _isCreating = false);
      AppSnackBar.error(context, e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final contents = ref.watch(portfolioProvider);

    return AppLayout(
      title: 'Nuovo link',
      subtitle: 'Configura la condivisione esterna',
      showBackButton: true,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, AppSpacing.xl),
        children: [
          Text('Descrizione link', style: text.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: _descriptionController,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(hintText: 'Es. Audizione Conservatorio di Milano', prefixIcon: Icon(Icons.description_outlined)),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('Privacy', style: text.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: AppSpacing.sm),
          _OptionsCard(
            children: [
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                secondary: Icon(Icons.schedule_rounded, color: colors.primary),
                title: const Text('Scadenza'),
                subtitle: Text(_hasExpiry && _expiryDate != null ? 'Scade il ${_formatDate(_expiryDate!)}' : 'Imposta una data di scadenza per il link'),
                value: _hasExpiry,
                onChanged: _setHasExpiry,
              ),
              if (_hasExpiry) ...[
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: OutlinedButton.icon(onPressed: _pickExpiryDate, icon: const Icon(Icons.calendar_month_rounded, size: 20), label: Text(_expiryDate != null ? 'Modifica data: ${_formatDate(_expiryDate!)}' : 'Seleziona data')),
                ),
              ],
              Divider(height: 1, color: colors.outlineVariant.withValues(alpha: 0.5)),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                secondary: Icon(Icons.person_outline_rounded, color: colors.primary),
                title: const Text('Includi profilo'),
                subtitle: const Text('Nome, bio e percorso accademico'),
                value: _includeProfile,
                onChanged: (value) => setState(() => _includeProfile = value),
              ),
              Divider(height: 1, color: colors.outlineVariant.withValues(alpha: 0.5)),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                secondary: Icon(Icons.download_rounded, color: colors.primary),
                title: const Text('Permetti download'),
                subtitle: const Text('Consenti il download dei file condivisi'),
                value: _allowDownload,
                onChanged: (value) => setState(() => _allowDownload = value),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: Text('Opere disponibili', style: text.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
              ),
              if (contents.isNotEmpty)
                TextButton(
                  onPressed: () {
                    setState(() {
                      if (_selectedIds.length == contents.length) {
                        _selectedIds.clear();
                      } else {
                        _selectedIds.addAll(contents.map((item) => item.id));
                      }
                    });
                  },
                  child: Text(_selectedIds.length == contents.length ? 'Deseleziona tutte' : 'Seleziona tutte'),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          if (contents.isEmpty)
            _OptionsCard(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  child: Row(
                    children: [
                      Icon(Icons.collections_outlined, color: colors.onSurfaceVariant),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Text('Nessuna opera nel portfolio. Aggiungi contenuti prima di condividere.', style: text.bodyMedium?.copyWith(color: colors.onSurfaceVariant)),
                      ),
                    ],
                  ),
                ),
              ],
            )
          else
            ...contents.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: _ContentCheckbox(
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
            ),
          const SizedBox(height: AppSpacing.lg),
          FilledButton.icon(
            onPressed: _isCreating ? null : _create,
            style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
            icon: _isCreating ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.link_rounded),
            label: const Text('Genera link'),
          ),
        ],
      ),
    );
  }
}

class _OptionsCard extends StatelessWidget {
  const _OptionsCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Material(
      color: colors.surfaceContainerHighest.withValues(alpha: 0.45),
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        child: Column(children: children),
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
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Material(
      color: selected ? colors.primaryContainer.withValues(alpha: 0.35) : colors.surface,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => onChanged(!selected),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: selected ? colors.primary.withValues(alpha: 0.45) : colors.outlineVariant.withValues(alpha: 0.6)),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
            child: Row(
              children: [
                Checkbox(value: selected, onChanged: (value) => onChanged(value ?? false)),
                ContentTypeIcon(type: item.type, size: 36),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.title, style: text.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                      Text(item.type.label, style: text.bodySmall?.copyWith(color: colors.onSurfaceVariant)),
                    ],
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
