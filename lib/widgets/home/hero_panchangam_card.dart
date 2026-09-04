import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../data/home/home_data.dart';
import '../common/glass.dart';

class HeroPanchangamCard extends StatelessWidget {
  final HeroPanchangamData data;
  final VoidCallback onTap;
  const HeroPanchangamCard({super.key, required this.data, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(data.tithi, style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: AppColors.primary, shadows: AppTheme.goldGlow, fontSize: 20)),
                    const SizedBox(height: 4),
                    Text(data.nakshatram, style: const TextStyle(color: Colors.white70, fontSize: 13)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(data.dateDay, style: Theme.of(context).textTheme.headlineMedium),
                  Text(data.dateMonth, style: Theme.of(context).textTheme.labelLarge),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          GlassPanelGold(
            padding: const EdgeInsets.all(12),
            borderRadius: 14,
            child: Row(
              children: [
                Icon(data.isFestival ? Icons.celebration : Icons.wb_sunny, color: AppColors.primary, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(data.calloutLabel, style: const TextStyle(color: Colors.white54, fontSize: 9, letterSpacing: 1)),
                      Text(data.calloutValue, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.white38, size: 18),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
