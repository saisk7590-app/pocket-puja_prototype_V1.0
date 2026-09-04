import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../data/audio/audio_data.dart';
import '../common/glass.dart';

/// Tiered visibility per our design decisions:
/// 0-50%: invisible. 50-80%: quiet muted text. 80-100%: amber warning.
/// 100%: handled by a separate blocking modal, not this banner.
class UsageBanner extends StatelessWidget {
  final UsageState usage;
  final VoidCallback onUpgrade;
  const UsageBanner({super.key, required this.usage, required this.onUpgrade});

  @override
  Widget build(BuildContext context) {
    if (usage.fraction < 0.5) return const SizedBox.shrink();

    final remaining = usage.totalMinutes - usage.usedMinutes;
    final remainingText = '${(remaining / 60).floor()}h ${remaining % 60}m left this month';

    if (usage.isWarning) {
      return GlassPanelAmber(
        onTap: onUpgrade,
        child: Row(
          children: [
            const Icon(Icons.timer, color: GlassPanelAmber.amber, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(remainingText, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                  Text('Resets in ${usage.daysUntilReset} days', style: const TextStyle(color: Colors.white54, fontSize: 11)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: GlassPanelAmber.amber, borderRadius: BorderRadius.circular(20)),
              child: const Text('Upgrade', style: TextStyle(color: Color(0xFF3C2F00), fontWeight: FontWeight.w700, fontSize: 12)),
            ),
          ],
        ),
      );
    }

    // 50-80%: quiet, muted, text-only — not a colored warning yet.
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(remainingText, style: const TextStyle(color: Colors.white38, fontSize: 12)),
    );
  }
}
