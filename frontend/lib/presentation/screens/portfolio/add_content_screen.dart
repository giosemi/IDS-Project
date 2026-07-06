import 'package:artid/core/costants/app_spacing.dart';
import 'package:artid/core/utils/content_file_formats.dart';
import 'package:artid/domain/models/content_item.dart';
import 'package:artid/domain/models/content_type.dart';
import 'package:artid/presentation/layout/layout.dart';
import 'package:artid/presentation/widgets/app_snack_bar.dart';
import 'package:artid/presentation/widgets/content_widgets.dart';
import 'package:artid/providers/auth/auth_provider.dart';
import 'package:artid/providers/portfolio/user_contents_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AddContentScreen extends ConsumerStatefulWidget {
  const AddContentScreen({super.key, this.content});

  final ContentItem? content;

  bool get isEditing => content != null;

  @override
  ConsumerState<AddContentScreen> createState() => _AddContentScreenState();
}

class _AddContentScreenState extends ConsumerState<AddContentScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _subtitleController;
  late final TextEditingController _yearController;
  late final TextEditingController _techniqueController;
  late final TextEditingController _dimensionsController;
  late final TextEditingController _durationController;
  late final TextEditingController _descriptionController;

  ContentType? _type;
  ContentType? _pdfType;
  PlatformFile? _selectedFile;
  bool _removedExistingFile = false;
  bool _isSaving = false;
  bool _isPickingFile = false;

  @override
  void initState() {
    super.initState();
    final content = widget.content;
    _titleController = TextEditingController(text: content?.title ?? '');
    _subtitleController = TextEditingController(text: content?.subtitle ?? '');
    _yearController = TextEditingController(text: content?.year.toString() ?? '');
    _techniqueController = TextEditingController(text: content?.technique ?? '');
    _dimensionsController = TextEditingController(text: content?.dimensions ?? '');
    _durationController = TextEditingController(text: content?.duration ?? '');
    _descriptionController = TextEditingController(text: content?.description ?? '');
    _type = content?.type;
    if (content?.fileName != null && ContentFileFormats.isPdf(content!.fileName!)) {
      _pdfType = content.type == ContentType.cv ? ContentType.cv : ContentType.score;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _subtitleController.dispose();
    _yearController.dispose();
    _techniqueController.dispose();
    _dimensionsController.dispose();
    _durationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  bool get _hasFile => _selectedFile != null || (!_removedExistingFile && widget.content?.fileName != null);

  String? get _displayFileName => _removedExistingFile ? _selectedFile?.name : (_selectedFile?.name ?? widget.content?.fileName);

  bool get _showsDurationFields => _type == ContentType.audio || _type == ContentType.video;

  void _applyFile(PlatformFile file) {
    if (!ContentFileFormats.isAllowed(file.name)) {
      AppSnackBar.error(context, 'Formato file non consentito');
      return;
    }

    setState(() {
      _selectedFile = file;
      _removedExistingFile = false;
      if (ContentFileFormats.isPdf(file.name)) {
        _pdfType = ContentType.score;
        _type = ContentType.score;
      } else {
        _pdfType = null;
        _type = ContentFileFormats.resolveType(file.name);
      }

      if (_titleController.text.trim().isEmpty) {
        final dot = file.name.lastIndexOf('.');
        _titleController.text = dot > 0 ? file.name.substring(0, dot) : file.name;
      }
    });
  }

  Future<void> _pickFile() async {
    setState(() => _isPickingFile = true);

    try {
      final result = await FilePicker.pickFiles(type: FileType.custom, allowedExtensions: ContentFileFormats.allowedExtensions, withData: false);

      if (!mounted) return;
      setState(() => _isPickingFile = false);

      if (result == null || result.files.isEmpty) return;
      _applyFile(result.files.first);
    } on MissingPluginException {
      if (!mounted) return;
      setState(() => _isPickingFile = false);
      AppSnackBar.error(context, 'Selettore file non disponibile: chiudi l\'app e riavviala completamente');
    } catch (_) {
      if (!mounted) return;
      setState(() => _isPickingFile = false);
      AppSnackBar.error(context, 'Impossibile aprire il selettore file');
    }
  }

  void _clearFile() {
    setState(() {
      _selectedFile = null;
      _removedExistingFile = true;
      _pdfType = null;
      _type = null;
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_hasFile) {
      AppSnackBar.error(context, 'Seleziona un file da caricare');
      return;
    }

    if (ContentFileFormats.isPdf(_displayFileName!) && _pdfType == null) {
      AppSnackBar.error(context, 'Indica se il PDF è uno spartito o un curriculum');
      return;
    }

    final resolvedType = _selectedFile != null ? ContentFileFormats.resolveType(_selectedFile!.name, pdfAs: _pdfType) : (_removedExistingFile ? null : widget.content?.type);

    if (resolvedType == null) {
      AppSnackBar.error(context, 'Formato file non riconosciuto');
      return;
    }

    final user = ref.read(authProvider).user;
    if (user == null) return;

    setState(() => _isSaving = true);

    final item = ContentItem(id: widget.content?.id ?? 'local-${DateTime.now().millisecondsSinceEpoch}', title: _titleController.text.trim(), subtitle: _subtitleController.text.trim().isEmpty ? null : _subtitleController.text.trim(), year: int.parse(_yearController.text.trim()), description: _descriptionController.text.trim(), ownerId: user.id, type: resolvedType, technique: _techniqueController.text.trim().isEmpty ? null : _techniqueController.text.trim(), dimensions: _dimensionsController.text.trim().isEmpty ? null : _dimensionsController.text.trim(), duration: _durationController.text.trim().isEmpty ? null : _durationController.text.trim(), fileName: _selectedFile?.name ?? (_removedExistingFile ? null : widget.content?.fileName), filePath: _selectedFile?.path ?? (_removedExistingFile ? null : widget.content?.filePath));

    if (widget.isEditing) {
      await ref.read(userContentsProvider.notifier).update(item);
    } else {
      await ref.read(userContentsProvider.notifier).add(item);
    }

    if (!mounted) return;
    setState(() => _isSaving = false);
    Navigator.of(context).pop();
    AppSnackBar.success(context, widget.isEditing ? 'Opera aggiornata' : 'Opera aggiunta al portfolio');
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return AppLayout(
      title: widget.isEditing ? 'Modifica opera' : 'Nuova opera',
      subtitle: widget.isEditing ? 'Aggiorna i dettagli' : 'Aggiungi al tuo portfolio',
      showBackButton: true,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _FilePickerSection(fileName: _displayFileName, contentType: _type, isPicking: _isPickingFile, onPick: _pickFile, onClear: _hasFile ? _clearFile : null),
              if (ContentFileFormats.isPdf(_displayFileName ?? '')) ...[
                const SizedBox(height: AppSpacing.md),
                Text('Tipo PDF', style: text.labelLarge),
                const SizedBox(height: AppSpacing.sm),
                SegmentedButton<ContentType>(
                  segments: const [
                    ButtonSegment(value: ContentType.score, label: Text('Spartito'), icon: Icon(Icons.music_note_rounded)),
                    ButtonSegment(value: ContentType.cv, label: Text('Curriculum'), icon: Icon(Icons.description_rounded)),
                  ],
                  selected: {_pdfType ?? ContentType.score},
                  onSelectionChanged: (selection) {
                    setState(() {
                      _pdfType = selection.first;
                      _type = _pdfType;
                    });
                  },
                ),
              ],
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Titolo'),
                validator: (v) => v == null || v.trim().isEmpty ? 'Obbligatorio' : null,
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _yearController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Anno di realizzazione'),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Obbligatorio';
                  if (int.tryParse(v.trim()) == null) return 'Anno non valido';
                  return null;
                },
              ),
              if (_showsDurationFields) ...[
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: _durationController,
                  decoration: const InputDecoration(labelText: 'Durata'),
                ),
              ],
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: const InputDecoration(labelText: 'Descrizione', alignLabelWithHint: true),
                validator: (v) => v == null || v.trim().isEmpty ? 'Obbligatorio' : null,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text('Formati consentiti: ${ContentFileFormats.formatsHint}', style: text.bodySmall?.copyWith(color: colors.onSurfaceVariant)),
              const SizedBox(height: AppSpacing.xl),
              FilledButton.icon(onPressed: _isSaving ? null : _submit, icon: const Icon(Icons.check_rounded), label: Text(_isSaving ? 'Salvataggio…' : (widget.isEditing ? 'Salva modifiche' : 'Salva'))),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilePickerSection extends StatelessWidget {
  const _FilePickerSection({required this.fileName, required this.contentType, required this.isPicking, required this.onPick, this.onClear});

  final String? fileName;
  final ContentType? contentType;
  final bool isPicking;
  final VoidCallback onPick;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final hasFile = fileName != null;

    return Material(
      color: hasFile ? colors.primaryContainer.withValues(alpha: 0.35) : colors.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: isPicking ? null : onPick,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              if (hasFile) ...[
                Row(
                  children: [
                    if (contentType != null) ContentTypeIcon(type: contentType!, size: 44),
                    if (contentType != null) const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(fileName!, style: text.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                          if (contentType != null) Text(contentType!.label, style: text.bodySmall?.copyWith(color: colors.onSurfaceVariant)),
                        ],
                      ),
                    ),
                    if (onClear != null) IconButton(tooltip: 'Rimuovi file', onPressed: onClear, icon: const Icon(Icons.close_rounded)),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                OutlinedButton.icon(
                  onPressed: isPicking ? null : onPick,
                  icon: isPicking ? SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: colors.primary)) : const Icon(Icons.swap_horiz_rounded),
                  label: Text(isPicking ? 'Apertura…' : 'Sostituisci file'),
                ),
              ] else ...[
                Icon(Icons.upload_file_rounded, size: 48, color: colors.primary),
                const SizedBox(height: AppSpacing.sm),
                Text('Seleziona un file', style: text.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Tocca per scegliere dal dispositivo',
                  style: text.bodyMedium?.copyWith(color: colors.onSurfaceVariant),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.md),
                FilledButton.tonalIcon(
                  onPressed: isPicking ? null : onPick,
                  icon: isPicking ? SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: colors.primary)) : const Icon(Icons.folder_open_rounded),
                  label: Text(isPicking ? 'Apertura…' : 'Sfoglia file'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
