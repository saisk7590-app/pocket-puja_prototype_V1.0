import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/glass.dart';
import '../../widgets/common/network_image_placeholder.dart';
import '../../data/audio/audio_data.dart';
import 'podcast_player_screen.dart';

class PodcastDetailScreen extends StatelessWidget {
  final PodcastData podcast;
  const PodcastDetailScreen({super.key, required this.podcast});

  @override
  Widget build(BuildContext context) {
    return GlassScaffold(
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
        children: [
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: NetworkImageWithPlaceholder(imageUrl: 'https://picsum.photos/seed/${podcast.seed}/400', width: 220, height: 220),
            ),
          ),
          const SizedBox(height: 20),
          Text(podcast.title, textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineLarge?.copyWith(color: AppColors.primary, fontSize: 22, shadows: AppTheme.goldGlow)),
          const SizedBox(height: 6),
          Text('${podcast.host} • ${podcast.publishDate}', textAlign: TextAlign.center, style: const TextStyle(color: Colors.white60, fontSize: 13)),
          const SizedBox(height: 20),
          PrimaryButton(label: 'Play Episode', icon: Icons.play_arrow, onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => PodcastPlayerScreen(podcast: podcast)))),
          const SizedBox(height: 12),
          GhostButton(label: 'Download for Offline (Premium)', onTap: () {}),
          const SizedBox(height: 24),
          GlassPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionLabel('SHOW NOTES'),
                const SizedBox(height: 10),
                Text(podcast.showNotes, style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.6)),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const SectionLabel('MORE FROM THIS SHOW'),
          const SizedBox(height: 12),
          ...podcasts.where((p) => p.id != podcast.id).map((p) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: GlassPanel(
                  padding: const EdgeInsets.all(10),
                  borderRadius: 16,
                  onTap: () => Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => PodcastDetailScreen(podcast: p))),
                  child: Row(children: [
                    ClipRRect(borderRadius: BorderRadius.circular(10), child: NetworkImageWithPlaceholder(imageUrl: 'https://picsum.photos/seed/${p.seed}/100', width: 44, height: 44)),
                    const SizedBox(width: 12),
                    Expanded(child: Text(p.title, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis)),
                    const Icon(Icons.play_circle_outline, color: AppColors.primary),
                  ]),
                ),
              )),
        ],
      ),
    );
  }
}
