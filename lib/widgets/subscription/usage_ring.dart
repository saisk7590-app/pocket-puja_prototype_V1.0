import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../data/audio/audio_data.dart';

class UsageRing extends StatelessWidget {
  final UsageState usage;
  const UsageRing({super.key, required this.usage});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160, height: 160,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 160, height: 160,
            child: CircularProgressIndicator(
              value: usage.fraction.clamp(0, 1),
              strokeWidth: 10,
              backgroundColor: Colors.white12,
              color: usage.isWarning || usage.isBlocked ? const Color(0xFFFFB84D) : AppColors.primary,
            ),
          ),
          Column(
            children: [
              Text('${usage.usedMinutes}', style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w800)),
              Text('/ ${usage.totalMinutes} MIN', style: const TextStyle(color: Colors.white54, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
}
