import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../common/glass.dart';

/// Compact square tile used on Home for Rashi / Active Booking / Festival.
/// Designed to be big-icon, short-text, and easy to scan at a glance
/// regardless of age — no dense paragraphs, just icon + label + one line.
class HomeKpiSquare extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;
  final bool gold;

  const HomeKpiSquare({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
    this.gold = false,
  });

  @override
  Widget build(BuildContext context) {
    final content = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: AppColors.primary, size: 26),
        const SizedBox(height: 8),
        Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: Colors.white60, fontSize: 10),
        ),
      ],
    );

    return AspectRatio(
      aspectRatio: 1,
      child: gold
          ? GlassPanelGold(padding: const EdgeInsets.all(10), borderRadius: 18, onTap: onTap, child: content)
          : GlassPanel(padding: const EdgeInsets.all(10), borderRadius: 18, onTap: onTap, child: content),
    );
  }
}