import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 1. Il Notifier che gestisce lo stato del tema (ThemeMode)
class ThemeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    // Di default segue il tema del sistema operativo
    return ThemeMode.system;
  }

  // Metodo per invertire il tema corrente
  void toggleTheme(BuildContext context) {
    final currentBrightness = Theme.of(context).brightness;

    if (currentBrightness == Brightness.dark) {
      state = ThemeMode.light;
    } else {
      state = ThemeMode.dark;
    }
  }

  // Metodo per impostare un tema specifico
  void setThemeMode(ThemeMode mode) {
    state = mode;
  }
}

// 2. Il Provider globale per accedere allo stato del tema da qualsiasi widget
final themeProvider = NotifierProvider<ThemeNotifier, ThemeMode>(() {
  return ThemeNotifier();
});
