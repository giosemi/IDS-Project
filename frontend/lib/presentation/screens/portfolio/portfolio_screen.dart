import 'package:artid/core/costants/app_spacing.dart';
import 'package:artid/domain/models/content_item.dart';
import 'package:artid/presentation/screens/content/content_detail_screen.dart';
import 'package:artid/presentation/screens/portfolio/add_content_screen.dart';
import 'package:artid/providers/portfolio/portfolio_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PortfolioScreen extends ConsumerWidget {
  const PortfolioScreen({super.key});

  void _openAddContent(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const AddContentScreen()));
  }

  void _openDetail(BuildContext context, String contentId) {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => ContentDetailScreen(contentId: contentId)));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final grouped = ref.watch(groupedPortfolioProvider);

    return Stack(
      children: [
        if (grouped.allItems.isEmpty)
          _EmptyPortfolio(onAdd: () => _openAddContent(context))
        else if (!grouped.isOrganized)
          GridView.builder(
            padding: const EdgeInsets.all(AppSpacing.md),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: AppSpacing.md, crossAxisSpacing: AppSpacing.md, childAspectRatio: 0.85),
            itemCount: grouped.allItems.length,
            itemBuilder: (context, index) {
              final item = grouped.allItems[index];
              return _ContentCard(item: item, onTap: () => _openDetail(context, item.id));
            },
          )
        else
          ListView(
            padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.sm, AppSpacing.md, AppSpacing.xl),
            children: [
              for (final section in grouped.sections) ...[
                if (section.items.isNotEmpty) ...[_SectionHeader(title: section.section.title), const SizedBox(height: AppSpacing.sm), _ContentGrid(items: section.items, onTap: (item) => _openDetail(context, item.id)), const SizedBox(height: AppSpacing.lg)],
              ],
              if (grouped.unassigned.isNotEmpty) ...[_SectionHeader(title: 'Altre opere'), const SizedBox(height: AppSpacing.sm), _ContentGrid(items: grouped.unassigned, onTap: (item) => _openDetail(context, item.id))],
            ],
          ),
        Positioned(
          right: AppSpacing.md,
          bottom: AppSpacing.md,
          child: FloatingActionButton.extended(onPressed: () => _openAddContent(context), icon: const Icon(Icons.add_rounded), label: const Text('Nuova opera')),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700));
  }
}

class _ContentGrid extends StatelessWidget {
  const _ContentGrid({required this.items, required this.onTap});

  final List<ContentItem> items;
  final ValueChanged<ContentItem> onTap;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: AppSpacing.md, crossAxisSpacing: AppSpacing.md, childAspectRatio: 0.85),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return _ContentCard(item: item, onTap: () => onTap(item));
      },
    );
  }
}

class _EmptyPortfolio extends StatelessWidget {
  const _EmptyPortfolio({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.collections_outlined, size: 56, color: colors.onSurfaceVariant),
            const SizedBox(height: AppSpacing.md),
            Text('Portfolio vuoto', style: Theme.of(context).textTheme.titleMedium, textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Aggiungi audio, video, spartiti o il tuo CV.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: colors.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ContentCard extends StatelessWidget {
  const _ContentCard({required this.item, required this.onTap});

  final ContentItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item.title, style: text.titleSmall, maxLines: 2, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 4),
              Text(item.type.label, style: text.bodySmall?.copyWith(color: colors.onSurfaceVariant)),
            ],
          ),
        ),
      ),
    );
  }
}
