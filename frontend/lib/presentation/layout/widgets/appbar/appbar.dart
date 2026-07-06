import 'package:artid/core/costants/app_spacing.dart';
import 'package:flutter/material.dart';

class ArtAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ArtAppBar({super.key, required this.title, this.subtitle, this.showBackButton = false, this.onBackPressed, this.actions});

  final String title;
  final String? subtitle;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final List<Widget>? actions;

  static const double toolbarHeight = 110;

  @override
  Size get preferredSize => const Size.fromHeight(toolbarHeight);

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Material(
      color: colors.surface,
      elevation: 0,
      surfaceTintColor: colors.surfaceTint,
      child: Container(
        height: toolbarHeight,
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: colors.outlineVariant.withValues(alpha: 0.6))),
        ),
        padding: EdgeInsets.fromLTRB(AppSpacing.md, MediaQuery.of(context).padding.top, AppSpacing.md, AppSpacing.sm),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (showBackButton)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                child: IconButton(icon: const Icon(Icons.arrow_back_rounded), tooltip: 'Indietro', onPressed: onBackPressed ?? () => Navigator.of(context).maybePop()),
              ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: text.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: text.bodySmall?.copyWith(color: colors.onSurfaceVariant),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            if (actions != null) ...actions!,
          ],
        ),
      ),
    );
  }
}
