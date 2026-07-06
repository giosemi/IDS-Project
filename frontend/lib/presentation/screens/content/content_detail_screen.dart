import 'package:artid/core/costants/app_spacing.dart';
import 'package:artid/presentation/layout/layout.dart';
import 'package:artid/presentation/screens/portfolio/add_content_screen.dart';
import 'package:artid/presentation/widgets/app_snack_bar.dart';
import 'package:artid/providers/portfolio/portfolio_provider.dart';
import 'package:artid/providers/portfolio/user_contents_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ContentDetailScreen extends ConsumerWidget {
  const ContentDetailScreen({super.key, required this.contentId});

  final String contentId;

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Elimina opera'),
        content: const Text('Sei sicuro di voler eliminare questa opera dal portfolio?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Annulla')),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error, foregroundColor: Theme.of(context).colorScheme.onError),
            child: const Text('Elimina'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    await ref.read(userContentsProvider.notifier).remove(contentId);
    if (!context.mounted) return;
    Navigator.of(context).pop();
    AppSnackBar.success(context, 'Opera eliminata');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final item = ref.watch(contentByIdProvider(contentId));
    final canManage = ref.watch(canManageContentProvider(contentId));
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    if (item == null) {
      return const AppLayout(
        title: 'Opera',
        showBackButton: true,
        body: Center(child: Text('Opera non trovata')),
      );
    }

    return AppLayout(
      title: item.title,
      subtitle: item.subtitle ?? item.type.label,
      showBackButton: true,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AspectRatio(
              aspectRatio: 4 / 3,
              child: Container(
                decoration: BoxDecoration(color: colors.primaryContainer, borderRadius: BorderRadius.circular(16)),
                child: Icon(item.type.icon, size: 80, color: colors.onPrimaryContainer),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(item.title, style: text.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
            if (item.subtitle != null) ...[const SizedBox(height: AppSpacing.sm), Text(item.subtitle!, style: text.titleMedium?.copyWith(color: colors.primary))],
            const SizedBox(height: AppSpacing.lg),
            _DetailRow(label: 'Anno', value: item.year.toString()),
            if (item.duration != null) _DetailRow(label: 'Durata', value: item.duration!),
            const SizedBox(height: AppSpacing.lg),
            Text('Descrizione', style: text.titleSmall),
            const SizedBox(height: AppSpacing.sm),
            Text(item.description, style: text.bodyLarge?.copyWith(color: colors.onSurfaceVariant, height: 1.5)),
            if (canManage) ...[
              const SizedBox(height: AppSpacing.xl),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => AddContentScreen(content: item)));
                      },
                      icon: const Icon(Icons.edit_outlined),
                      label: const Text('Modifica'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => _confirmDelete(context, ref),
                      icon: const Icon(Icons.delete_outline_rounded),
                      label: const Text('Elimina'),
                      style: FilledButton.styleFrom(backgroundColor: colors.error, foregroundColor: colors.onError),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(label, style: text.labelLarge?.copyWith(fontWeight: FontWeight.w600)),
          ),
          Expanded(child: Text(value, style: text.bodyLarge)),
        ],
      ),
    );
  }
}
