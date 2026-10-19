import 'package:flutter/material.dart';
import 'package:pocket_puja/core/widgets/glass.dart';
import 'poojari_nav_tabs.dart';

/// Poojari bottom navigation bar widget.
/// Renders floating pill glass nav with 4 tabs and live red badge on Assigned Poojas tab.
class PoojariBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final int newAssignmentsCount;

  const PoojariBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.newAssignmentsCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return GlassBottomNav(
      currentIndex: currentIndex,
      onTap: onTap,
      icons: PoojariNavTabs.icons,
      badges: PoojariNavTabs.badgeMapForNewCount(newAssignmentsCount),
    );
  }
}
