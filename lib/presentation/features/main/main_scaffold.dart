import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:anote/core/icons/lucide_icons.dart';
import '../../../core/design_system/glass_surface.dart';

class MainScaffold extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const MainScaffold({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      extendBody: true, // Important for Glassmorphism nav bar
      body: navigationShell,
      bottomNavigationBar: _buildBottomNavBar(context),
    );
  }

  Widget _buildBottomNavBar(BuildContext context) {
    // Wrap with padding so it floats slightly above the bottom on most screens
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 24),
      child: GlassSurface(
        tier: GlassTier.tier1,
        borderRadius: BorderRadius.circular(32), // More pill-shaped
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _NavBarIcon(
              icon: LucideIcons.home,
              label: 'Home',
              isSelected: navigationShell.currentIndex == 0,
              onTap: () => navigationShell.goBranch(0),
            ),
            _NavBarIcon(
              icon: LucideIcons.fileText,
              label: 'Notes',
              isSelected: navigationShell.currentIndex == 1,
              onTap: () => navigationShell.goBranch(1),
            ),
            _NavBarIcon(
              icon: LucideIcons.folder,
              label: 'Files',
              isSelected: navigationShell.currentIndex == 2,
              onTap: () => navigationShell.goBranch(2),
            ),
            _NavBarIcon(
              icon: LucideIcons.settings,
              label: 'Settings',
              isSelected: navigationShell.currentIndex == 3,
              onTap: () => navigationShell.goBranch(3),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavBarIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavBarIcon({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? Theme.of(context).colorScheme.primary : Colors.grey;
    
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
