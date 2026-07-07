import 'package:artid/core/costants/app_spacing.dart';
import 'package:artid/providers/auth/auth_provider.dart';
import 'package:artid/providers/navigation/main_nav_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final isAuthenticated = authState.isAuthenticated;
    final isGuest = authState.isGuest;

    return ListView(
      padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.sm, AppSpacing.md, AppSpacing.xl),
      children: [
        _ProfileHeader(isAuthenticated: isAuthenticated, isGuest: isGuest, name: user?.name, email: user?.email),
        const SizedBox(height: AppSpacing.lg),
        const _SectionLabel('Account'),
        const SizedBox(height: AppSpacing.sm),
        if (isAuthenticated || isGuest)
          _SettingsGroup(
            children: [
              _SettingsTile(
                icon: Icons.logout_rounded,
                iconColor: Theme.of(context).colorScheme.error,
                title: 'Esci',
                subtitle: isGuest ? 'Torna alla schermata di login' : 'Disconnetti il tuo account',
                showChevron: true,
                onTap: () {
                  ref.read(authProvider.notifier).logout();
                  if (isAuthenticated) {
                    ref.read(mainNavProvider.notifier).setIndex(0);
                  }
                },
              ),
            ],
          ),
      ],
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.isAuthenticated, required this.isGuest, this.name, this.email});

  final bool isAuthenticated;
  final bool isGuest;
  final String? name;
  final String? email;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    final initials = isAuthenticated && name != null && name!.isNotEmpty
        ? name![0].toUpperCase()
        : isGuest
        ? 'E'
        : '?';

    final displayName = isAuthenticated
        ? name!
        : isGuest
        ? 'Visitatore Esterno'
        : 'Ospite';

    final displayEmail = isAuthenticated
        ? email!
        : isGuest
        ? 'Esplora il catalogo senza account'
        : 'Accedi per gestire il tuo portfolio';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [colors.primary.withValues(alpha: 0.18), colors.secondary.withValues(alpha: 0.10)]),
        border: Border.all(color: colors.primary.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [colors.primary, colors.primary.withValues(alpha: 0.75)]),
              boxShadow: [BoxShadow(color: colors.primary.withValues(alpha: 0.35), blurRadius: 16, offset: const Offset(0, 6))],
            ),
            child: Center(
              child: isGuest && !isAuthenticated
                  ? const Icon(Icons.explore_rounded, color: Colors.white, size: 28)
                  : Text(
                      initials,
                      style: text.headlineSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  style: text.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  displayEmail,
                  style: text.bodyMedium?.copyWith(color: colors.onSurfaceVariant),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (isGuest && !isAuthenticated) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: colors.primary.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(20)),
                    child: Text(
                      'Accesso Esterno',
                      style: text.labelSmall?.copyWith(color: colors.primary, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: AppSpacing.xs),
      child: Text(
        label.toUpperCase(),
        style: Theme.of(context).textTheme.labelMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant, fontWeight: FontWeight.w700, letterSpacing: 1.1),
      ),
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.5)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[if (i > 0) Divider(height: 1, color: colors.outlineVariant.withValues(alpha: 0.5)), children[i]],
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({required this.icon, required this.iconColor, required this.title, required this.subtitle, this.showChevron = false, this.onTap});

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool showChevron;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.md),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(color: iconColor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, size: 22, color: iconColor),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: text.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Text(subtitle, style: text.bodySmall?.copyWith(color: colors.onSurfaceVariant)),
                  ],
                ),
              ),
              if (showChevron) Icon(Icons.chevron_right_rounded, color: colors.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}
