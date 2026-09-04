import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../data/audio/audio_data.dart';
import '../common/glass.dart';
import '../common/network_image_placeholder.dart';

class TrackRow extends StatelessWidget {
  final TrackData track;
  final VoidCallback onTap;
  const TrackRow({super.key, required this.track, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      padding: const EdgeInsets.all(10),
      borderRadius: 18,
      onTap: onTap,
      child: Row(
        children: [
          Stack(
            children: [
              ClipRRect(borderRadius: BorderRadius.circular(12), child: NetworkImageWithPlaceholder(imageUrl: 'https://picsum.photos/seed/${track.seed}/120', width: 52, height: 52)),
              // Download status icon (idle state shown by default in this prototype)
              Positioned(right: 2, bottom: 2, child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                child: const Icon(Icons.download_outlined, color: Colors.white70, size: 12),
              )),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(track.title, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text('${track.duration} • ${track.deity}', style: const TextStyle(color: Colors.white54, fontSize: 12)),
              ],
            ),
          ),
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.15), shape: BoxShape.circle),
            child: const Icon(Icons.play_arrow, color: AppColors.primary),
          ),
        ],
      ),
    );
  }
}
