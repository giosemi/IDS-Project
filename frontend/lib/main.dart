import 'package:artid/core/navigation/app_navigator.dart';
import 'package:artid/core/session/session_activity_scope.dart';
import 'package:artid/core/theme/app_theme.dart';
import 'package:artid/presentation/screens/login/login_screen.dart';
import 'package:artid/presentation/shell/main_shell.dart';
import 'package:artid/providers/auth/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'ArtID',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      navigatorKey: rootNavigatorKey,
      builder: (context, child) {
        final hasAppAccess = ref.watch(authProvider.select((state) => state.hasAppAccess));
        if (!hasAppAccess || child == null) {
          return child ?? const SizedBox.shrink();
        }
        return SessionActivityScope(
          navigatorKey: rootNavigatorKey,
          child: child,
        );
      },
      home: const AuthGate(),
    );
  }
}

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasAppAccess = ref.watch(authProvider.select((state) => state.hasAppAccess));

    return hasAppAccess ? const MainShell() : const LoginScreen();
  }
}
