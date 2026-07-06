import 'package:artid/core/costants/app_spacing.dart';
import 'package:artid/data/services/share_links_api_service.dart';
import 'package:artid/domain/models/student_profile.dart';
import 'package:artid/presentation/layout/layout.dart';
import 'package:artid/presentation/screens/content/content_detail_screen.dart';
import 'package:artid/presentation/widgets/content_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SharedProfileScreen extends ConsumerWidget {
  const SharedProfileScreen({super.key, required this.token});

  final String token;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncView = ref.watch(sharedViewProvider(token));

    return asyncView.when(
      loading: () => const AppLayout(
        title: 'Caricamento…',
        showBackButton: true,
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) {
        final isDioError = e.toString().contains('404') || e.toString().contains('410');
        return AppLayout(
          title: isDioError ? 'Link non valido' : 'Errore',
          showBackButton: true,
          body: Center(
            child: Text(isDioError
                ? 'Questo link non esiste, è stato rimosso o è scaduto.'
                : 'Errore durante il caricamento della condivisione.'),
          ),
        );
      },
      data: (view) => _SharedView(view: view),
    );
  }
}

class _SharedView extends StatelessWidget {
  const _SharedView({required this.view});

  final SharedViewData view;

  @override
  Widget build(BuildContext context) {
    final profile = view.profile;
    final contents = view.items;

    return AppLayout(
      title: view.label,
      subtitle: 'Condivisione ArtID',
      showBackButton: true,
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          if (profile != null) ...[
            _SharedProfileHeader(profile: profile),
            const SizedBox(height: AppSpacing.lg),
          ],
          if (contents.isEmpty)
            const Center(child: Text('Nessun contenuto in questa condivisione'))
          else ...[
            Text(
              'CONTENUTI CONDIVISI',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w700, letterSpacing: 1.1),
            ),
            const SizedBox(height: AppSpacing.sm),
            for (final item in contents)
              Card(
                margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: ListTile(
                  leading: ContentTypeIcon(type: item.type, size: 36),
                  title: Text(item.title),
                  subtitle: Text('${item.type.label} · ${item.year}'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => ContentDetailScreen(contentId: item.id),
                      ),
                    );
                  },
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _SharedProfileHeader extends StatelessWidget {
  const _SharedProfileHeader({required this.profile});

  final StudentProfile profile;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: colors.surfaceContainerLow,
        border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(profile.fullName, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(profile.institution, style: Theme.of(context).textTheme.bodyMedium),
          Text('${profile.course} · ${profile.studyYear}° anno', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant)),
          if (profile.bio.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            Text(profile.bio, style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.5)),
          ],
        ],
      ),
    );
  }
}
