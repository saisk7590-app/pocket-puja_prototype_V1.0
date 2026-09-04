import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../data/audio/audio_data.dart';
import '../common/glass.dart';
import '../common/network_image_placeholder.dart';

class PodcastRow extends StatelessWidget {
  final PodcastData podcast;
  final VoidCallback onTap;
  const PodcastRow({super.key, required this.podcast, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      padding: const EdgeInsets.all(10),
      borderRadius: 18,
      onTap: onTap,
      child: Row(
        children: [
          ClipRRect(borderRadius: BorderRadius.circular(12), child: NetworkImageWithPlaceholder(imageUrl: 'https://picsum.photos/seed/${podcast.seed}/120', width: 52, height: 52)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(podcast.title, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
                Text(podcast.host, style: const TextStyle(color: Colors.white54, fontSize: 12)),
                Text(podcast.duration, style: const TextStyle(color: AppColors.primary, fontSize: 11)),
              ],
            ),
          ),
          const Icon(Icons.play_circle_fill, color: AppColors.primary, size: 32),
        ],
      ),
    );
  }
}
