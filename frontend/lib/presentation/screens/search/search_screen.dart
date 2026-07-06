import 'package:artid/core/costants/app_motion.dart';
import 'package:artid/core/costants/app_spacing.dart';
import 'package:artid/core/utils/share_link_parser.dart';
import 'package:artid/presentation/screens/share/shared_profile_screen.dart';
import 'package:artid/presentation/widgets/app_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _ExternalLinkSearchBody();
  }
}

class _ExternalLinkSearchBody extends StatefulWidget {
  const _ExternalLinkSearchBody();

  @override
  State<_ExternalLinkSearchBody> createState() => _ExternalLinkSearchBodyState();
}

class _ExternalLinkSearchBodyState extends State<_ExternalLinkSearchBody> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() => setState(() {});

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _openLink() {
    final token = parseShareToken(_controller.text);
    if (token == null) {
      AppSnackBar.error(context, 'Link non valido. Incolla un link ArtID completo.');
      return;
    }

    _focusNode.unfocus();
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => SharedProfileScreen(token: token)));
  }

  Future<void> _pasteFromClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final text = data?.text;
    if (text == null || text.trim().isEmpty) return;

    setState(() => _controller.text = text.trim());
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final focused = _focusNode.hasFocus;

    return GestureDetector(
      onTap: () => _focusNode.unfocus(),
      behavior: HitTestBehavior.opaque,
      child: AnimatedAlign(
        duration: AppMotion.normal,
        curve: AppMotion.emphasized,
        alignment: focused ? const Alignment(0, -0.35) : Alignment.center,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedContainer(
                  duration: AppMotion.normal,
                  curve: AppMotion.emphasized,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: focused ? [BoxShadow(color: colors.primary.withValues(alpha: 0.18), blurRadius: 24, offset: const Offset(0, 8))] : [],
                  ),
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    textInputAction: TextInputAction.go,
                    onSubmitted: (_) => _openLink(),
                    onTap: () => setState(() {}),
                    decoration: InputDecoration(
                      hintText: 'Incolla il link condiviso…',
                      prefixIcon: const Icon(Icons.link_rounded),
                      suffixIcon: _controller.text.isEmpty ? IconButton(icon: const Icon(Icons.content_paste_rounded), tooltip: 'Incolla', onPressed: _pasteFromClipboard) : IconButton(icon: const Icon(Icons.cancel_rounded), tooltip: 'Cancella', onPressed: () => setState(() => _controller.clear())),
                      contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.lg),
                    ),
                  ),
                ),
                AnimatedSize(
                  duration: AppMotion.normal,
                  curve: AppMotion.emphasized,
                  alignment: Alignment.topCenter,
                  child: focused
                      ? Padding(
                          padding: const EdgeInsets.only(top: AppSpacing.lg),
                          child: SizedBox(
                            width: double.infinity,
                            child: FilledButton.icon(onPressed: _openLink, icon: const Icon(Icons.open_in_new_rounded), label: const Text('Apri condivisione')),
                          ),
                        )
                      : Padding(
                          padding: const EdgeInsets.only(top: AppSpacing.lg),
                          child: Text(
                            'Incolla il link che hai ricevuto da uno studente per visualizzare i contenuti condivisi.',
                            style: text.bodyMedium?.copyWith(color: colors.onSurfaceVariant, height: 1.4),
                            textAlign: TextAlign.center,
                          ),
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
