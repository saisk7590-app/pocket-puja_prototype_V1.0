import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../data/home/home_data.dart';
import '../common/glass.dart';

class RashiChip extends StatelessWidget {
  final RashiInsight rashi;
  final VoidCallback onTap;
  const RashiChip({super.key, required this.rashi, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      borderRadius: 16,
      child: Row(
        children: [
          Container(
            width: 34, height: 34,
            decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.15), shape: BoxShape.circle),
            child: const Icon(Icons.auto_awesome, color: AppColors.primary, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 12, color: Colors.white70),
                children: [
                  TextSpan(text: 'Your Rashi Today · ', style: TextStyle(color: AppColors.primary.withValues(alpha: 0.9), fontWeight: FontWeight.w700)),
                  TextSpan(text: rashi.oneLiner),
                ],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const Icon(Icons.chevron_right, color: Colors.white38, size: 18),
        ],
      ),
    );
  }
}
