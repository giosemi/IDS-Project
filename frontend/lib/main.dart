import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:artid/core/theme/app_theme.dart';
import 'package:artid/presentation/screens/login/login_screen.dart';
import 'package:artid/presentation/shell/main_shell.dart';
import 'package:artid/providers/auth/auth_provider.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ArtID',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
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
