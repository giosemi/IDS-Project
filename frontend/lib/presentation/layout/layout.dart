import 'package:artid/presentation/layout/widgets/appbar/appbar.dart';
import 'package:artid/presentation/layout/widgets/navbar/animated_floating_nav_bar.dart';
import 'package:flutter/material.dart';

class AppLayout extends StatelessWidget {
  const AppLayout({super.key, required this.title, required this.body, this.subtitle, this.showBackButton = false, this.onBackPressed, this.actions, this.showNavBar = false, this.navItems = const [], this.navSelectedIndex = 0, this.onNavItemSelected});

  final String title;
  final String? subtitle;
  final Widget body;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final List<Widget>? actions;
  final bool showNavBar;
  final List<BottomNavItem> navItems;
  final int navSelectedIndex;
  final ValueChanged<int>? onNavItemSelected;

  static double bottomInset(BuildContext context, {required bool hasNavBar}) {
    if (!hasNavBar) return 0;
    return 95 + MediaQuery.of(context).padding.bottom;
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = bottomInset(context, hasNavBar: showNavBar);

    return Scaffold(
      extendBody: showNavBar,
      appBar: ArtAppBar(title: title, subtitle: subtitle, showBackButton: showBackButton, onBackPressed: onBackPressed, actions: actions),
      body: Padding(
        padding: EdgeInsets.only(bottom: bottomPadding),
        child: body,
      ),
      bottomNavigationBar: showNavBar ? AnimatedFloatingNavBar(items: navItems, selectedIndex: navSelectedIndex, onItemSelected: onNavItemSelected) : null,
    );
  }
}
