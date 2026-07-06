import 'package:artid/domain/models/content_type.dart';
import 'package:artid/domain/models/content_visibility.dart';
import 'package:flutter/material.dart';

class ContentTypeIcon extends StatelessWidget {
  const ContentTypeIcon({
    super.key,
    required this.type,
    this.size = 40,
  });

  final ContentType type;
  final double size;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: colors.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(type.icon, color: colors.onPrimaryContainer),
    );
  }
}

class VisibilityChip extends StatelessWidget {
  const VisibilityChip({super.key, required this.visibility});

  final ContentVisibility visibility;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final (bg, fg) = switch (visibility) {
      ContentVisibility.public => (colors.primary.withValues(alpha: 0.12), colors.primary),
      ContentVisibility.restricted => (colors.tertiary.withValues(alpha: 0.15), colors.tertiary),
      ContentVisibility.private => (colors.onSurfaceVariant.withValues(alpha: 0.12), colors.onSurfaceVariant),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        visibility.label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: fg,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}
