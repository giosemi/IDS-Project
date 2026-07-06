import 'package:artid/core/costants/app_spacing.dart';
import 'package:artid/domain/models/student_profile.dart';
import 'package:artid/presentation/screens/share/share_links_screen.dart';
import 'package:artid/providers/portfolio/portfolio_provider.dart';
import 'package:artid/providers/profile/profile_provider.dart';
import 'package:artid/providers/share/share_links_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider);
    final contents = ref.watch(portfolioProvider);
    final links = ref.watch(shareLinksProvider);

    if (profile == null) {
      return const Center(child: Text('Profilo non disponibile'));
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.sm, AppSpacing.md, AppSpacing.xl),
      children: [
        _IdentityCard(profile: profile),
        const SizedBox(height: AppSpacing.lg),
        _StatsRow(contentsCount: contents.length, linksCount: links.length),
        const SizedBox(height: AppSpacing.lg),
        if (profile.bio.isNotEmpty) ...[_SectionTitle('Bio'), const SizedBox(height: AppSpacing.sm), _InfoCard(child: Text(profile.bio, style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.5))), const SizedBox(height: AppSpacing.lg)],
        _SectionTitle('Azioni'),
        const SizedBox(height: AppSpacing.sm),
        _ActionTile(
          icon: Icons.link_rounded,
          title: 'Gestisci condivisioni',
          subtitle: 'Crea link per audizioni e candidature',
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const ShareLinksScreen()));
          },
        ),
      ],
    );
  }
}

class _IdentityCard extends StatelessWidget {
  const _IdentityCard({required this.profile});

  final StudentProfile profile;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(colors: [colors.primary.withValues(alpha: 0.18), colors.secondary.withValues(alpha: 0.10)]),
        border: Border.all(color: colors.primary.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 32,
                backgroundColor: colors.primary,
                child: Text(
                  profile.fullName.isNotEmpty ? profile.fullName[0].toUpperCase() : '?',
                  style: text.headlineSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(profile.fullName, style: text.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                    Text(profile.email, style: text.bodySmall?.copyWith(color: colors.onSurfaceVariant)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(profile.institution, style: text.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text('${profile.course} · ${profile.studyYear}° anno', style: text.bodyMedium?.copyWith(color: colors.onSurfaceVariant)),
        ],
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.contentsCount, required this.linksCount});

  final int contentsCount;
  final int linksCount;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(label: 'Contenuti', value: contentsCount.toString(), icon: Icons.folder_outlined),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _StatCard(label: 'Link attivi', value: linksCount.toString(), icon: Icons.link_outlined),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value, required this.icon});

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Icon(icon, color: colors.primary),
          const SizedBox(width: AppSpacing.sm),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              Text(label, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title.toUpperCase(),
      style: Theme.of(context).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w700, letterSpacing: 1.1, color: Theme.of(context).colorScheme.onSurfaceVariant),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: child,
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({required this.icon, required this.title, required this.subtitle, required this.onTap});

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: ListTile(
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(color: colors.primary.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: colors.primary),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
        trailing: Icon(Icons.chevron_right_rounded, color: colors.onSurfaceVariant),
        onTap: onTap,
      ),
    );
  }
}
