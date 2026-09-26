import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

class NowPlayingSeekBar extends StatelessWidget {
  final double progress; // 0..1
  final String elapsed, total;
  final ValueChanged<double> onChanged;
  const NowPlayingSeekBar({
    super.key,
    required this.progress,
    required this.elapsed,
    required this.total,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SliderTheme(
          data: SliderTheme.of(context).copyWith(trackHeight: 3, thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6)),
          child: Slider(value: progress.clamp(0, 1), activeColor: AppColors.primary, inactiveColor: Colors.white24, onChanged: onChanged),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(elapsed, style: const TextStyle(color: Colors.white54, fontSize: 12)),
              Text(total, style: const TextStyle(color: Colors.white54, fontSize: 12)),
            ],
          ),
        ),
      ],
    );
  }
}