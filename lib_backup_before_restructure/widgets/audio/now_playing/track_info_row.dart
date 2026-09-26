import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

class NowPlayingTrackInfoRow extends StatelessWidget {
  final String title, artist;
  final bool isLiked;
  final VoidCallback onToggleLike;
  const NowPlayingTrackInfoRow({
    super.key,
    required this.title,
    required this.artist,
    required this.isLiked,
    required this.onToggleLike,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 4),
              Text(artist, style: const TextStyle(color: Colors.white54, fontSize: 14)),
            ],
          ),
        ),
        IconButton(
          icon: Icon(isLiked ? Icons.favorite : Icons.favorite_border, color: isLiked ? AppColors.primary : Colors.white70),
          onPressed: onToggleLike,
        ),
      ],
    );
  }
}