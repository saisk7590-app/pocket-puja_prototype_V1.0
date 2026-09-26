import 'package:flutter/material.dart';
import 'package:pocket_puja/core/theme/app_theme.dart';
import 'package:pocket_puja/core/widgets/glass.dart';

/// Compact KPI square tile used on Poojari Dashboard for Quick Stats:
/// - Rating (4.8 ★)
/// - Poojas Completed (LIVE)
/// - This Month's Earnings (LIVE)
/// - Pending Assignments (LIVE)
///
/// Directly models the structure and styling of [HomeKpiSquare] from Customer Home.
class PoojariKpiSquare extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onTap;
  final bool gold;
  final Color? iconColor;

  const PoojariKpiSquare({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.onTap,
    this.gold = false,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final content = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          color: iconColor ?? (gold ? AppColors.primary : AppColors.primaryFixed),
          size: 24,
        ),
        const SizedBox(height: 6),
        Text(
          value,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );

    return AspectRatio(
      aspectRatio: 1,
      child: gold
          ? GlassPanelGold(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
              borderRadius: 16,
              onTap: onTap ?? () {},
              child: content,
            )
          : GlassPanel(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
              borderRadius: 16,
              onTap: onTap ?? () {},
              child: content,
            ),
    );
  }
}
