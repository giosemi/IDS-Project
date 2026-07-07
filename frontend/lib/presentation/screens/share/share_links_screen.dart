import 'package:artid/core/costants/app_spacing.dart';
import 'package:artid/domain/models/share_link.dart';
import 'package:artid/presentation/layout/layout.dart';
import 'package:artid/presentation/screens/share/create_share_link_screen.dart';
import 'package:artid/presentation/screens/share/shared_profile_screen.dart';
import 'package:artid/presentation/widgets/app_snack_bar.dart';
import 'package:artid/providers/share/share_links_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ShareLinksScreen extends ConsumerWidget {
  const ShareLinksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final links = ref.watch(shareLinksProvider);

    return AppLayout(
      title: 'Condivisioni',
      subtitle: 'Link per soggetti esterni',
      showBackButton: true,
      body: Stack(
        children: [
          links.isEmpty
              ? const _EmptyLinks()
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.sm, AppSpacing.md, 100),
                  itemCount: links.length,
                  separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.sm),
                  itemBuilder: (context, index) => _ShareLinkCard(link: links[index]),
                ),
          Positioned(
            right: AppSpacing.md,
            bottom: AppSpacing.md,
            child: FloatingActionButton.extended(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const CreateShareLinkScreen()));
              },
              icon: const Icon(Icons.add_link_rounded),
              label: const Text('Nuovo link'),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyLinks extends StatelessWidget {
  const _EmptyLinks();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.link_off_rounded, size: 56, color: Theme.of(context).colorScheme.onSurfaceVariant),
            const SizedBox(height: AppSpacing.md),
            Text('Nessun link condiviso', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Crea un link per condividere contenuti selezionati con commissioni o docenti esterni.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShareLinkCard extends ConsumerWidget {
  const _ShareLinkCard({required this.link});

  final ShareLink link;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(link.label, style: text.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                ),
                if (link.isExpired)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: colors.errorContainer, borderRadius: BorderRadius.circular(12)),
                    child: Text('Scaduto', style: text.labelSmall?.copyWith(color: colors.onErrorContainer)),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text('${link.contentIds.length} contenuti · ${link.viewCount} visualizzazioni', style: text.bodySmall?.copyWith(color: colors.onSurfaceVariant)),
            if (link.lastViewedAt != null) ...[const SizedBox(height: 4), Text('Ultima apertura: ${_formatDate(link.lastViewedAt!)}', style: text.bodySmall?.copyWith(color: colors.onSurfaceVariant))],
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                TextButton.icon(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: link.shareUrl));
                    AppSnackBar.success(context, 'Link copiato negli appunti');
                  },
                  icon: const Icon(Icons.copy_rounded, size: 18),
                  label: const Text('Copia'),
                ),
                TextButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => SharedProfileScreen(token: link.token)));
                  },
                  icon: const Icon(Icons.visibility_outlined, size: 18),
                  label: const Text('Anteprima'),
                ),
                const Spacer(),
                TextButton.icon(
                  style: TextButton.styleFrom(foregroundColor: colors.error),
                  onPressed: () => ref.read(shareLinksProvider.notifier).remove(link.id),
                  icon: const Icon(Icons.delete_outline_rounded, size: 18),
                  label: const Text('Elimina'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
