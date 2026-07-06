import 'package:artid/core/costants/app_spacing.dart';
import 'package:artid/domain/models/content_item.dart';
import 'package:artid/domain/models/portfolio_section.dart';
import 'package:artid/presentation/layout/layout.dart';
import 'package:artid/presentation/widgets/content_widgets.dart';
import 'package:artid/providers/portfolio/portfolio_provider.dart';
import 'package:artid/providers/portfolio/portfolio_sections_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OrganizePortfolioScreen extends ConsumerWidget {
  const OrganizePortfolioScreen({super.key});

  Future<void> _addSection(BuildContext context, WidgetRef ref) async {
    final title = await showDialog<String>(context: context, builder: (context) => const _AddSectionDialog());

    if (title == null || title.isEmpty) return;
    ref.read(portfolioSectionsProvider.notifier).addSection(title);
  }

  Future<void> _confirmDeleteSection(BuildContext context, WidgetRef ref, PortfolioSection section) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Elimina sezione'),
        content: Text('Eliminare "${section.title}"? Le opere resteranno nel portfolio.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Annulla')),
          FilledButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Elimina')),
        ],
      ),
    );

    if (confirmed == true) {
      ref.read(portfolioSectionsProvider.notifier).removeSection(section.id);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final grouped = ref.watch(groupedPortfolioProvider);
    final layout = ref.watch(portfolioSectionsProvider);
    final colors = Theme.of(context).colorScheme;

    return AppLayout(
      title: 'Organizza portfolio',
      subtitle: 'Sezioni e ordine opere',
      showBackButton: true,
      body: grouped.allItems.isEmpty
          ? const Center(child: Text('Aggiungi opere al portfolio per organizzarle'))
          : ListView(
              padding: const EdgeInsets.all(AppSpacing.md),
              children: [
                if (layout.sections.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                    child: Text('Crea sezioni per raggruppare le opere. Trascina per riordinare.', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: colors.onSurfaceVariant)),
                  ),
                if (layout.sections.isEmpty)
                  _UnassignedBlock(items: grouped.unassigned, sections: layout.sections)
                else
                  ReorderableListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: layout.sections.length,
                    onReorder: (oldIndex, newIndex) {
                      ref.read(portfolioSectionsProvider.notifier).reorderSections(oldIndex, newIndex);
                    },
                    itemBuilder: (context, index) {
                      final section = layout.sections[index];
                      final view = grouped.sections.firstWhere(
                        (entry) => entry.section.id == section.id,
                        orElse: () => PortfolioSectionView(section: section, items: const []),
                      );

                      return _SectionEditorCard(
                        key: ValueKey(section.id),
                        section: section,
                        items: view.items,
                        allSections: layout.sections,
                        onRename: (title) {
                          ref.read(portfolioSectionsProvider.notifier).renameSection(section.id, title);
                        },
                        onDelete: () => _confirmDeleteSection(context, ref, section),
                        onReorderItem: (oldIndex, newIndex) {
                          ref.read(portfolioSectionsProvider.notifier).reorderInSection(section.id, oldIndex, newIndex);
                        },
                        onRemoveItem: (contentId) {
                          ref.read(portfolioSectionsProvider.notifier).removeFromSections(contentId);
                        },
                      );
                    },
                  ),
                if (layout.sections.isNotEmpty && grouped.unassigned.isNotEmpty) ...[const SizedBox(height: AppSpacing.lg), _SectionTitle('Non assegnate'), const SizedBox(height: AppSpacing.sm), _UnassignedBlock(items: grouped.unassigned, sections: layout.sections)],
                const SizedBox(height: AppSpacing.lg),
                OutlinedButton.icon(onPressed: () => _addSection(context, ref), icon: const Icon(Icons.create_new_folder_outlined), label: const Text('Nuova sezione')),
              ],
            ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title.toUpperCase(),
      style: Theme.of(context).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w700, letterSpacing: 1.1, color: Theme.of(context).colorScheme.onSurfaceVariant),
    );
  }
}

class _UnassignedBlock extends ConsumerWidget {
  const _UnassignedBlock({required this.items, required this.sections});

  final List<ContentItem> items;
  final List<PortfolioSection> sections;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (items.isEmpty) {
      return Text('Tutte le opere sono assegnate a una sezione.', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant));
    }

    return Column(
      children: [
        for (final item in items)
          _ContentAssignTile(
            item: item,
            sections: sections,
            onAssign: sections.isEmpty
                ? null
                : (sectionId) {
                    ref.read(portfolioSectionsProvider.notifier).assignToSection(item.id, sectionId);
                  },
          ),
      ],
    );
  }
}

class _SectionEditorCard extends StatefulWidget {
  const _SectionEditorCard({super.key, required this.section, required this.items, required this.allSections, required this.onRename, required this.onDelete, required this.onReorderItem, required this.onRemoveItem});

  final PortfolioSection section;
  final List<ContentItem> items;
  final List<PortfolioSection> allSections;
  final ValueChanged<String> onRename;
  final VoidCallback onDelete;
  final void Function(int oldIndex, int newIndex) onReorderItem;
  final ValueChanged<String> onRemoveItem;

  @override
  State<_SectionEditorCard> createState() => _SectionEditorCardState();
}

class _SectionEditorCardState extends State<_SectionEditorCard> {
  late final TextEditingController _titleController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.section.title);
  }

  @override
  void didUpdateWidget(_SectionEditorCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.section.title != widget.section.title && _titleController.text != widget.section.title) {
      _titleController.text = widget.section.title;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Card(
      key: widget.key,
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(Icons.drag_handle_rounded, color: colors.onSurfaceVariant),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(labelText: 'Nome sezione', isDense: true),
                    onSubmitted: widget.onRename,
                    onTapOutside: (_) => widget.onRename(_titleController.text),
                  ),
                ),
                IconButton(
                  tooltip: 'Elimina sezione',
                  onPressed: widget.onDelete,
                  icon: Icon(Icons.delete_outline_rounded, color: colors.error),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            if (widget.items.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                child: Text('Nessuna opera in questa sezione', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant)),
              )
            else
              ReorderableListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: widget.items.length,
                onReorder: widget.onReorderItem,
                itemBuilder: (context, index) {
                  final item = widget.items[index];
                  return _SectionContentTile(key: ValueKey('${widget.section.id}-${item.id}'), item: item, onRemove: () => widget.onRemoveItem(item.id));
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _SectionContentTile extends StatelessWidget {
  const _SectionContentTile({super.key, required this.item, required this.onRemove});

  final ContentItem item;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      key: key,
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.drag_indicator_rounded),
      title: Text(item.title, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(item.type.label),
      trailing: IconButton(tooltip: 'Rimuovi dalla sezione', icon: const Icon(Icons.remove_circle_outline_rounded), onPressed: onRemove),
    );
  }
}

class _ContentAssignTile extends StatelessWidget {
  const _ContentAssignTile({required this.item, required this.sections, this.onAssign});

  final ContentItem item;
  final List<PortfolioSection> sections;
  final ValueChanged<String>? onAssign;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: ListTile(
        leading: ContentTypeIcon(type: item.type, size: 36),
        title: Text(item.title, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text(item.type.label),
        trailing: sections.isEmpty
            ? null
            : PopupMenuButton<String>(
                tooltip: 'Assegna a sezione',
                icon: const Icon(Icons.drive_file_move_outlined),
                onSelected: onAssign,
                itemBuilder: (context) => [for (final section in sections) PopupMenuItem(value: section.id, child: Text(section.title))],
              ),
      ),
    );
  }
}

class _AddSectionDialog extends StatefulWidget {
  const _AddSectionDialog();

  @override
  State<_AddSectionDialog> createState() => _AddSectionDialogState();
}

class _AddSectionDialogState extends State<_AddSectionDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() => Navigator.of(context).pop(_controller.text.trim());

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nuova sezione'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        decoration: const InputDecoration(labelText: 'Nome sezione', hintText: 'Es. Pittura, Audizioni'),
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Annulla')),
        FilledButton(onPressed: _submit, child: const Text('Crea')),
      ],
    );
  }
}
