import 'package:artid/presentation/layout/layout.dart';
import 'package:artid/presentation/layout/widgets/navbar/animated_floating_nav_bar.dart';
import 'package:artid/presentation/screens/portfolio/organize_portfolio_screen.dart';
import 'package:artid/presentation/screens/portfolio/portfolio_screen.dart';
import 'package:artid/presentation/screens/profile/profile_screen.dart';
import 'package:artid/presentation/screens/search/search_screen.dart';
import 'package:artid/presentation/screens/settings/settings_screen.dart';
import 'package:artid/providers/auth/auth_provider.dart';
import 'package:artid/providers/navigation/main_nav_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MainShell extends ConsumerWidget {
  const MainShell({super.key});

  static const _profilePage = (title: 'Profilo', subtitle: 'La tua identità digitale AFAM');
  static const _searchPage = (title: 'Ricerca', subtitle: 'Incolla un link condiviso');
  static const _portfolioPage = (title: 'Portfolio', subtitle: 'I tuoi contenuti artistici');
  static const _settingsPage = (title: 'Impostazioni', subtitle: 'Preferenze account');

  static final _authenticatedNavItems = [BottomNavItem(title: 'Profilo', icon: Icons.person_rounded), BottomNavItem(title: 'Portfolio', icon: Icons.art_track_rounded), BottomNavItem(title: 'Impostazioni', icon: Icons.settings_rounded)];

  static final _guestNavItems = [BottomNavItem(title: 'Ricerca', icon: Icons.search_rounded), BottomNavItem(title: 'Impostazioni', icon: Icons.settings_rounded)];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAuthenticated = ref.watch(authProvider.select((state) => state.isAuthenticated));
    final currentIndex = ref.watch(mainNavProvider);

    ref.listen(authProvider.select((state) => state.isAuthenticated), (previous, next) {
      if (previous == null) return;

      final index = ref.read(mainNavProvider);

      if (previous && !next) {
        ref.read(mainNavProvider.notifier).setIndex(index >= 1 ? 1 : 0);
      } else if (!previous && next) {
        ref.read(mainNavProvider.notifier).setIndex(0);
      }
    });

    final navItems = isAuthenticated ? _authenticatedNavItems : _guestNavItems;
    final safeIndex = currentIndex.clamp(0, navItems.length - 1);

    final page = isAuthenticated
        ? switch (safeIndex) {
            0 => _profilePage,
            1 => _portfolioPage,
            _ => _settingsPage,
          }
        : switch (safeIndex) {
            0 => _searchPage,
            _ => _settingsPage,
          };

    return AppLayout(
      title: page.title,
      subtitle: page.subtitle,
      actions: isAuthenticated && safeIndex == 1
          ? [
              TextButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(builder: (_) => const OrganizePortfolioScreen()),
                  );
                },
                icon: const Icon(Icons.edit_outlined, size: 20),
                label: const Text('Organizza sezioni'),
              ),
            ]
          : null,
      showNavBar: true,
      navItems: navItems,
      navSelectedIndex: safeIndex,
      onNavItemSelected: ref.read(mainNavProvider.notifier).setIndex,
      body: isAuthenticated ? IndexedStack(index: safeIndex, children: const [ProfileScreen(), PortfolioScreen(), SettingsScreen()]) : IndexedStack(index: safeIndex, children: const [SearchScreen(), SettingsScreen()]),
    );
  }
}
