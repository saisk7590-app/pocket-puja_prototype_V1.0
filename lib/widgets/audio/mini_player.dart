import 'package:flutter/material.dart';
import 'dart:ui';
import '../../theme/app_theme.dart';
import '../../data/audio/audio_data.dart';
import '../common/network_image_placeholder.dart';
import '../../screens/audio/audio_player_screen.dart';

/// Global mini-player — floats above every screen (Home, Calendar,
/// Booking, Shop too) whenever something is playing, Spotify-style.
/// Tapping expands to the full player.
class MiniPlayer extends StatefulWidget {
  final TrackData? nowPlaying;
  final VoidCallback onDismiss;
  const MiniPlayer({super.key, required this.nowPlaying, required this.onDismiss});

  @override
  State<MiniPlayer> createState() => _MiniPlayerState();
}

class _MiniPlayerState extends State<MiniPlayer> {
  bool _isPlaying = true;

  @override
  Widget build(BuildContext context) {
    if (widget.nowPlaying == null) return const SizedBox.shrink();
    final track = widget.nowPlaying!;

    return GestureDetector(
      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => AudioPlayerScreen(track: track))),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerHigh.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white12),
              boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.15), blurRadius: 16)],
            ),
            child: Row(
              children: [
                ClipRRect(borderRadius: BorderRadius.circular(10), child: NetworkImageWithPlaceholder(imageUrl: 'https://picsum.photos/seed/${track.seed}/100', width: 40, height: 40)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(track.title, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
                      Text(track.artist, style: const TextStyle(color: Colors.white54, fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
                IconButton(icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow, color: AppColors.primary), onPressed: () => setState(() => _isPlaying = !_isPlaying)),
                IconButton(icon: const Icon(Icons.close, color: Colors.white54, size: 18), onPressed: widget.onDismiss),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
