import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../../../services/audio_controller.dart' as audio;

class NowPlayingControls extends StatelessWidget {
  final bool isPlaying, isShuffle;
  final audio.RepeatMode repeatMode;
  final VoidCallback onPlayPause, onShuffle, onRepeat, onNext, onPrevious;
  const NowPlayingControls({
    super.key,
    required this.isPlaying,
    required this.isShuffle,
    required this.repeatMode,
    required this.onPlayPause,
    required this.onShuffle,
    required this.onRepeat,
    required this.onNext,
    required this.onPrevious,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton(icon: Icon(Icons.shuffle, color: isShuffle ? AppColors.primary : Colors.white54), onPressed: onShuffle),
        IconButton(icon: const Icon(Icons.skip_previous, color: Colors.white, size: 32), onPressed: onPrevious),
        GestureDetector(
          onTap: onPlayPause,
          child: Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary,
              boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.4), blurRadius: 20)],
            ),
            child: Icon(isPlaying ? Icons.pause : Icons.play_arrow, color: AppColors.onPrimary, size: 34),
          ),
        ),
        IconButton(icon: const Icon(Icons.skip_next, color: Colors.white, size: 32), onPressed: onNext),
        IconButton(
          icon: Icon(repeatMode == audio.RepeatMode.one ? Icons.repeat_one : Icons.repeat, color: repeatMode == audio.RepeatMode.off ? Colors.white54 : AppColors.primary),
          onPressed: onRepeat,
        ),
      ],
    );
  }
}