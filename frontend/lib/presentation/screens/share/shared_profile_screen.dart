import 'package:artid/core/costants/app_spacing.dart';
import 'package:artid/data/services/share_links_api_service.dart';
import 'package:artid/data/services/shared_content_download_service.dart';
import 'package:artid/domain/models/content_item.dart';
import 'package:artid/domain/models/student_profile.dart';
import 'package:artid/presentation/layout/layout.dart';
import 'package:artid/presentation/screens/content/content_detail_screen.dart';
import 'package:artid/presentation/widgets/app_snack_bar.dart';
import 'package:artid/presentation/widgets/content_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final _sharedContentDownloadServiceProvider = Provider(
  (ref) => const SharedContentDownloadService(),
);

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

class _SharedView extends ConsumerWidget {
  const _SharedView({required this.view});

  final SharedViewData view;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = view.profile;
    final contents = view.items;
    final text = Theme.of(context).textTheme;

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
              'Opere condivise',
              style: text.titleSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: AppSpacing.sm),
            for (final item in contents)
              _SharedContentTile(
                item: item,
                shareToken: view.token,
                allowDownload: view.allowDownload,
              ),
          ],
        ],
      ),
    );
  }
}

class _SharedContentTile extends ConsumerStatefulWidget {
  const _SharedContentTile({
    required this.item,
    required this.shareToken,
    required this.allowDownload,
  });

  final ContentItem item;
  final String shareToken;
  final bool allowDownload;

  bool get _canDownload =>
      allowDownload &&
      item.fileName != null &&
      item.fileName!.isNotEmpty &&
      item.hasMedia;

  @override
  ConsumerState<_SharedContentTile> createState() => _SharedContentTileState();
}

class _SharedContentTileState extends ConsumerState<_SharedContentTile> {
  var _isDownloading = false;

  Future<void> _download() async {
    if (_isDownloading) return;
    setState(() => _isDownloading = true);

    try {
      final path = await ref.read(_sharedContentDownloadServiceProvider).download(
            shareToken: widget.shareToken,
            item: widget.item,
          );
      if (!mounted) return;
      AppSnackBar.success(context, 'Scaricato: ${widget.item.fileName}\n$path');
    } on SharedContentDownloadException catch (e) {
      if (!mounted) return;
      AppSnackBar.error(context, e.message);
    } catch (_) {
      if (!mounted) return;
      AppSnackBar.error(context, 'Impossibile scaricare il file');
    } finally {
      if (mounted) setState(() => _isDownloading = false);
    }
  }

  void _openDetail() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ContentDetailScreen(
          content: widget.item,
          shareToken: widget.shareToken,
          allowDownload: widget.allowDownload,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: _openDetail,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ContentTypeIcon(type: widget.item.type, size: 40),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.item.title,
                          style: text.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${widget.item.type.label} · ${widget.item.year}',
                          style: text.bodySmall?.copyWith(color: colors.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded, color: colors.onSurfaceVariant),
                ],
              ),
            ),
          ),
          if (widget._canDownload)
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.sm, 0, AppSpacing.sm, AppSpacing.sm),
              child: Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: _isDownloading ? null : _download,
                  icon: _isDownloading
                      ? SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: colors.primary),
                        )
                      : const Icon(Icons.download_rounded, size: 18),
                  label: const Text('Scarica'),
                ),
              ),
            ),
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
          Text(
            '${profile.course} · ${profile.studyYear}° anno',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
          ),
          if (profile.bio.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            Text(profile.bio, style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.5)),
          ],
        ],
      ),
    );
  }
}
