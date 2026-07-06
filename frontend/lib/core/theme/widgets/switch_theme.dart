import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:artid/core/theme/theme_provider.dart';

class SwitchTheme extends ConsumerWidget {
  const SwitchTheme({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final bool isDarkMode = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.9),
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: theme.colorScheme.shadow, blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: IconButton(
        icon: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, animation) {
            return RotationTransition(
              turns: animation,
              child: FadeTransition(opacity: animation, child: child),
            );
          },
          child: Icon(isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded, key: ValueKey(isDarkMode), color: theme.colorScheme.primary),
        ),
        onPressed: () {
          // Chiamiamo il toggle passando il contesto attuale
          ref.read(themeProvider.notifier).toggleTheme(context);
        },
        tooltip: isDarkMode ? 'Modalità chiara' : 'Modalità scura',
      ),
    );
  }
}
