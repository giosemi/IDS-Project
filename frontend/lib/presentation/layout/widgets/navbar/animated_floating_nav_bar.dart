import 'dart:ui';
import 'package:flutter/material.dart';

class AnimatedFloatingNavBar extends StatefulWidget {
  final List<BottomNavItem> items;
  final int selectedIndex;
  final Function(int)? onItemSelected;

  const AnimatedFloatingNavBar({super.key, required this.items, required this.selectedIndex, this.onItemSelected});

  @override
  State<AnimatedFloatingNavBar> createState() => _AnimatedFloatingNavBarState();
}

class _AnimatedFloatingNavBarState extends State<AnimatedFloatingNavBar> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(milliseconds: 200), vsync: this);
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 85,
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 0),
      margin: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom + 5),
      child: Stack(
        children: [
          // Background glassmorphic container
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: isDarkMode ? [Colors.grey[900]!.withValues(alpha: 0.7), Colors.grey[800]!.withValues(alpha: 0.5)] : [Colors.white.withValues(alpha: 0.7), Colors.grey[100]!.withValues(alpha: 0.5)]),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 40),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: isDarkMode ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.05), width: 1.5),
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ),
          ),

          // Nav items
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(
              widget.items.length,
              (index) => _buildNavItem(context, widget.items[index], widget.selectedIndex == index, isDarkMode, () {
                if (widget.onItemSelected != null && widget.selectedIndex != index) {
                  widget.onItemSelected!(index);
                  _controller.forward().then((_) => _controller.reverse());
                }
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, BottomNavItem item, bool isSelected, bool isDarkMode, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: isSelected ? _scaleAnimation.value : 1.0,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.0, end: isSelected ? 1.0 : 0.0),
                          duration: const Duration(milliseconds: 300),
                          builder: (context, value, child) {
                            return Opacity(
                              opacity: value,
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                                  boxShadow: [BoxShadow(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 2))],
                                ),
                              ),
                            );
                          },
                        ),
                        Container(
                          width: 40,
                          height: 40,
                          alignment: Alignment.center,
                          child: Icon(
                            item.icon,
                            size: 24,
                            color: isSelected
                                ? Theme.of(context).colorScheme.primary
                                : isDarkMode
                                ? Colors.white70
                                : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.title,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : isDarkMode
                            ? Colors.white70
                            : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class BottomNavItem {
  final String title;
  final IconData icon;
  final Widget? location;

  BottomNavItem({required this.title, required this.icon, this.location});
}
