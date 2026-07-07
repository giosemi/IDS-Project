import 'package:artid/core/costants/app_colors.dart';
import 'package:artid/core/costants/app_shapes.dart';
import 'package:artid/core/costants/app_spacing.dart';
import 'package:flutter/material.dart';

class AuthFormCard extends StatelessWidget {
  const AuthFormCard({
    required this.title,
    required this.subtitle,
    required this.child,
    this.icon,
    super.key,
  });

  final String title;
  final String subtitle;
  final Widget child;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 440),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: colors.primary.withValues(alpha: 0.08),
              blurRadius: 32,
              offset: const Offset(0, 16),
            ),
            BoxShadow(
              color: colors.shadow.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Material(
            color: colors.surface,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  height: 5,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        colors.primary,
                        AppColors.secondary.withValues(alpha: 0.85),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(28, 28, 28, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (icon != null) ...[
                        Center(
                          child: Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: colors.primaryContainer.withValues(alpha: 0.65),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Icon(icon, color: colors.primary, size: 28),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                      ],
                      Text(
                        title,
                        style: text.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        subtitle,
                        style: text.bodyLarge?.copyWith(color: colors.onSurfaceVariant),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      child,
                    ],
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

class AuthPrimaryButton extends StatelessWidget {
  const AuthPrimaryButton({
    required this.label,
    required this.onPressed,
    required this.isLoading,
    this.icon,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(52),
        shape: AppShapes.large,
        elevation: 0,
      ),
      child: isLoading
          ? SizedBox(
              height: 22,
              width: 22,
              child: CircularProgressIndicator(strokeWidth: 2.5, color: colors.onPrimary),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 20),
                  const SizedBox(width: AppSpacing.sm),
                ],
                Text(label),
              ],
            ),
    );
  }
}

class AuthOrDivider extends StatelessWidget {
  const AuthOrDivider({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Row(
      children: [
        Expanded(child: Divider(color: colors.outlineVariant)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Text(
            'Oppure',
            style: text.labelLarge?.copyWith(
              color: colors.onSurfaceVariant,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.4,
            ),
          ),
        ),
        Expanded(child: Divider(color: colors.outlineVariant)),
      ],
    );
  }
}
