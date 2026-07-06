import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  // Usa i font di sistema come fallback sicuro;
  // sostituisci con GoogleFonts se hai il pacchetto.
  static const _displayFamily = 'Georgia';
  static const _bodyFamily = null; // sistema

  static TextTheme buildTextTheme({required bool dark}) {
    final onBackground = dark ? AppColors.darkOnBackground : AppColors.lightOnBackground;
    final onSurface = dark ? AppColors.darkOnSurface : AppColors.lightOnSurface;
    final subtle = dark ? AppColors.darkOnSurfaceVariant : AppColors.lightOnSurfaceVariant;

    return TextTheme(
      // ── Display ───────────────────────────────
      displayLarge: TextStyle(fontFamily: _displayFamily, fontSize: 57, fontWeight: FontWeight.w700, letterSpacing: -0.5, height: 1.12, color: onBackground),
      displayMedium: TextStyle(fontFamily: _displayFamily, fontSize: 45, fontWeight: FontWeight.w700, letterSpacing: -0.25, height: 1.16, color: onBackground),
      displaySmall: TextStyle(fontFamily: _displayFamily, fontSize: 36, fontWeight: FontWeight.w600, letterSpacing: 0, height: 1.22, color: onBackground),

      // ── Headline ──────────────────────────────
      headlineLarge: TextStyle(fontFamily: _displayFamily, fontSize: 32, fontWeight: FontWeight.w600, letterSpacing: -0.25, height: 1.25, color: onBackground),
      headlineMedium: TextStyle(fontFamily: _displayFamily, fontSize: 28, fontWeight: FontWeight.w600, height: 1.29, color: onBackground),
      headlineSmall: TextStyle(fontFamily: _displayFamily, fontSize: 24, fontWeight: FontWeight.w500, height: 1.33, color: onBackground),

      // ── Title ─────────────────────────────────
      titleLarge: TextStyle(fontFamily: _bodyFamily, fontSize: 22, fontWeight: FontWeight.w600, letterSpacing: 0, height: 1.27, color: onSurface),
      titleMedium: TextStyle(fontFamily: _bodyFamily, fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: 0.15, height: 1.5, color: onSurface),
      titleSmall: TextStyle(fontFamily: _bodyFamily, fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.1, height: 1.43, color: onSurface),

      // ── Label ─────────────────────────────────
      labelLarge: TextStyle(fontFamily: _bodyFamily, fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.1, height: 1.43, color: onSurface),
      labelMedium: TextStyle(fontFamily: _bodyFamily, fontSize: 12, fontWeight: FontWeight.w500, letterSpacing: 0.5, height: 1.33, color: subtle),
      labelSmall: TextStyle(fontFamily: _bodyFamily, fontSize: 11, fontWeight: FontWeight.w500, letterSpacing: 0.5, height: 1.45, color: subtle),

      // ── Body ──────────────────────────────────
      bodyLarge: TextStyle(fontFamily: _bodyFamily, fontSize: 16, fontWeight: FontWeight.w400, letterSpacing: 0.15, height: 1.5, color: onSurface),
      bodyMedium: TextStyle(fontFamily: _bodyFamily, fontSize: 14, fontWeight: FontWeight.w400, letterSpacing: 0.25, height: 1.43, color: onSurface),
      bodySmall: TextStyle(fontFamily: _bodyFamily, fontSize: 12, fontWeight: FontWeight.w400, letterSpacing: 0.4, height: 1.33, color: subtle),
    );
  }
}
