import 'package:artid/core/costants/app_colors.dart';
import 'package:artid/core/costants/app_shapes.dart';
import 'package:artid/core/costants/app_spacing.dart';
import 'package:flutter/material.dart';

enum AppSnackBarType { info, success, error }

class AppSnackBar {
  AppSnackBar._();

  static void show(
    BuildContext context,
    String message, {
    AppSnackBarType type = AppSnackBarType.info,
    String? actionLabel,
    VoidCallback? onAction,
    Duration duration = const Duration(seconds: 3),
    double? bottomMargin,
  }) {
    final messenger = ScaffoldMessenger.of(context);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final text = theme.textTheme;

    final (icon, accent) = switch (type) {
      AppSnackBarType.success => (Icons.check_circle_rounded, AppColors.success),
      AppSnackBarType.error => (Icons.error_outline_rounded, AppColors.error),
      AppSnackBarType.info => (Icons.info_outline_rounded, colors.primary),
    };

    final bottom = bottomMargin ?? AppSpacing.md + MediaQuery.of(context).padding.bottom;

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          duration: duration,
          margin: EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.md, bottom),
          backgroundColor: colors.inverseSurface,
          elevation: 6,
          shape: AppShapes.medium,
          content: Row(
            children: [
              Icon(icon, color: accent, size: 22),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  message,
                  style: text.bodyMedium?.copyWith(color: colors.onInverseSurface),
                ),
              ),
            ],
          ),
          action: actionLabel != null
              ? SnackBarAction(
                  label: actionLabel,
                  textColor: colors.inversePrimary,
                  onPressed: onAction ?? messenger.hideCurrentSnackBar,
                )
              : null,
        ),
      );
  }

  static void info(BuildContext context, String message) {
    show(context, message, type: AppSnackBarType.info);
  }

  static void success(BuildContext context, String message) {
    show(context, message, type: AppSnackBarType.success);
  }

  static void error(BuildContext context, String message) {
    show(context, message, type: AppSnackBarType.error);
  }
}
