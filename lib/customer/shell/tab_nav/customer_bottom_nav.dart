import 'package:flutter/material.dart';
import 'package:pocket_puja/core/widgets/glass.dart';
import 'customer_nav_tabs.dart';

/// Customer bottom navigation bar widget.
/// Renders floating pill glass nav using [CustomerNavTabs.icons] and shared [GlassBottomNav].
class CustomerBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final Map<int, int>? badges;

  const CustomerBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.badges,
  });

  @override
  Widget build(BuildContext context) {
    return GlassBottomNav(
      currentIndex: currentIndex,
      onTap: onTap,
      icons: CustomerNavTabs.icons,
      badges: badges,
    );
  }
}
