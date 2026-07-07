import 'dart:typed_data';

import 'package:artid/core/utils/content_file_formats.dart';
import 'package:artid/data/api/api_constants.dart';
import 'package:artid/data/api/api_client.dart';
import 'package:artid/data/api/content_media_urls.dart';
import 'package:artid/domain/models/content_item.dart';
import 'package:artid/domain/models/content_type.dart';
import 'package:artid/providers/auth/auth_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:video_player/video_player.dart';

class ContentMediaViewer extends ConsumerStatefulWidget {
  const ContentMediaViewer({
    required this.item,
    this.shareToken,
    super.key,
  });

  final ContentItem item;
  final String? shareToken;

  @override
  ConsumerState<ContentMediaViewer> createState() => _ContentMediaViewerState();
}

class _ContentMediaViewerState extends ConsumerState<ContentMediaViewer> {
  VideoPlayerController? _videoController;
  AudioPlayer? _audioPlayer;
  Uint8List? _imageBytes;
  bool _mediaLoading = true;
  String? _mediaError;

  @override
  void initState() {
    super.initState();
    _initMedia();
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _audioPlayer?.dispose();
    super.dispose();
  }

  Map<String, String> _headers() {
    if (widget.shareToken != null) return const {};
    final token = ref.read(authProvider).token;
    if (token == null) return const {};
    return {'Authorization': 'Bearer $token'};
  }

  String? get _fileName => widget.item.fileName;

  String? get _missingFileMessage {
    if (_fileName == null || _fileName!.isEmpty) {
      return 'Nessun file associato';
    }
    if (!widget.item.hasMedia) {
      return 'Il file non è stato caricato sul server.\nModifica l\'opera e seleziona di nuovo il file.';
    }
    return null;
  }

  Future<Uint8List> _fetchMediaBytes() async {
    if (widget.shareToken != null) {
      final url = contentMediaUrl(contentId: widget.item.id, shareToken: widget.shareToken);
      final response = await Dio().get<List<int>>(
        url,
        options: Options(responseType: ResponseType.bytes),
      );
      return Uint8List.fromList(response.data!);
    }

    final response = await ref.read(dioProvider).get<List<int>>(
          '/api/content/${widget.item.id}/media',
          options: Options(responseType: ResponseType.bytes),
        );
    return Uint8List.fromList(response.data!);
  }

  Future<void> _initMedia() async {
    final missingMessage = _missingFileMessage;
    if (missingMessage != null) {
      setState(() {
        _mediaLoading = false;
        _mediaError = missingMessage;
      });
      return;
    }

    final fileName = _fileName!;
    final url = contentMediaUrl(contentId: widget.item.id, shareToken: widget.shareToken);
    final headers = _headers();

    try {
      if (ContentFileFormats.isImage(fileName)) {
        final bytes = await _fetchMediaBytes();
        if (!mounted) return;
        setState(() {
          _imageBytes = bytes;
          _mediaLoading = false;
        });
        return;
      }

      if (ContentFileFormats.video.contains(ContentFileFormats.extensionOf(fileName))) {
        final controller = VideoPlayerController.networkUrl(
          Uri.parse(url),
          httpHeaders: headers,
        );
        await controller.initialize();
        if (!mounted) {
          controller.dispose();
          return;
        }
        setState(() {
          _videoController = controller;
          _mediaLoading = false;
        });
        return;
      }

      if (ContentFileFormats.audio.contains(ContentFileFormats.extensionOf(fileName))) {
        final player = AudioPlayer();
        await player.setAudioSource(
          AudioSource.uri(Uri.parse(url), headers: headers),
        );
        if (!mounted) {
          await player.dispose();
          return;
        }
        setState(() {
          _audioPlayer = player;
          _mediaLoading = false;
        });
        return;
      }

      setState(() => _mediaLoading = false);
    } on DioException catch (e) {
      if (!mounted) return;
      final status = e.response?.statusCode;
      setState(() {
        _mediaLoading = false;
        _mediaError = status == 404
            ? 'File non trovato sul server.\nModifica l\'opera e ricarica il file.'
            : 'Impossibile caricare il file. Verifica la connessione al server ($kBaseUrl).';
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _mediaLoading = false;
        _mediaError = 'Impossibile caricare il file.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final fileName = _fileName;

    if (_mediaLoading) {
      return AspectRatio(
        aspectRatio: 4 / 3,
        child: Container(
          decoration: BoxDecoration(color: colors.surfaceContainerHighest, borderRadius: BorderRadius.circular(16)),
          child: const Center(child: CircularProgressIndicator()),
        ),
      );
    }

    if (_mediaError != null) {
      return _PlaceholderBox(
        icon: Icons.broken_image_outlined,
        message: _mediaError!,
        type: widget.item.type,
      );
    }

    if (fileName == null || fileName.isEmpty) {
      return _PlaceholderBox(
        icon: widget.item.type.icon,
        message: 'Nessun file associato',
        type: widget.item.type,
      );
    }

    if (_imageBytes != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: AspectRatio(
          aspectRatio: 4 / 3,
          child: Image.memory(
            _imageBytes!,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => _PlaceholderBox(
              icon: Icons.hide_image_outlined,
              message: 'Impossibile visualizzare l\'immagine',
              type: widget.item.type,
            ),
          ),
        ),
      );
    }

    if (_videoController != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: AspectRatio(
          aspectRatio: _videoController!.value.aspectRatio == 0 ? 16 / 9 : _videoController!.value.aspectRatio,
          child: Stack(
            alignment: Alignment.center,
            children: [
              VideoPlayer(_videoController!),
              if (!_videoController!.value.isPlaying)
                IconButton.filled(
                  iconSize: 56,
                  onPressed: () => setState(() {
                    _videoController!.play();
                  }),
                  icon: const Icon(Icons.play_arrow_rounded),
                ),
            ],
          ),
        ),
      );
    }

    if (_audioPlayer != null) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: colors.primaryContainer.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(16),
        ),
        child: StreamBuilder<PlayerState>(
          stream: _audioPlayer!.playerStateStream,
          builder: (context, snapshot) {
            final playing = snapshot.data?.playing ?? false;
            return Row(
              children: [
                Icon(Icons.audiotrack_rounded, size: 40, color: colors.primary),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(fileName, style: text.titleSmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                      Text('Audio', style: text.bodySmall?.copyWith(color: colors.onSurfaceVariant)),
                    ],
                  ),
                ),
                IconButton.filled(
                  onPressed: () {
                    if (playing) {
                      _audioPlayer!.pause();
                    } else {
                      _audioPlayer!.play();
                    }
                  },
                  icon: Icon(playing ? Icons.pause_rounded : Icons.play_arrow_rounded),
                ),
              ],
            );
          },
        ),
      );
    }

    return _PlaceholderBox(
      icon: widget.item.type.icon,
      message: 'Anteprima non disponibile per questo formato.\n$fileName',
      type: widget.item.type,
    );
  }
}

class _PlaceholderBox extends StatelessWidget {
  const _PlaceholderBox({
    required this.icon,
    required this.message,
    required this.type,
  });

  final IconData icon;
  final String message;
  final ContentType type;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return AspectRatio(
      aspectRatio: 4 / 3,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: colors.primaryContainer.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 56, color: colors.onPrimaryContainer),
            const SizedBox(height: 12),
            Text(
              message,
              style: text.bodyMedium?.copyWith(color: colors.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
