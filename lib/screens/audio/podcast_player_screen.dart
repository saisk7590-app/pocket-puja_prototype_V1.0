import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/glass.dart';
import '../../widgets/common/network_image_placeholder.dart';
import '../../data/audio/audio_data.dart';

class PodcastPlayerScreen extends StatefulWidget {
  final PodcastData podcast;
  const PodcastPlayerScreen({super.key, required this.podcast});

  @override
  State<PodcastPlayerScreen> createState() => _PodcastPlayerScreenState();
}

class _PodcastPlayerScreenState extends State<PodcastPlayerScreen> {
  bool _isPlaying = true;
  bool _skipSilence = false;
  double _speed = 1.0;
  double _progress = 0.18;
  final _speeds = [1.0, 1.25, 1.5, 2.0];

  void _cycleSpeed() => setState(() => _speed = _speeds[(_speeds.indexOf(_speed) + 1) % _speeds.length]);

  @override
  Widget build(BuildContext context) {
    return GlassScaffold(
      title: 'Now Playing',
      trailing: PopupMenuButton<String>(
        icon: const Icon(Icons.more_vert, color: AppColors.primary),
        color: AppColors.surfaceContainerHigh,
        onSelected: (v) { if (v == 'silence') setState(() => _skipSilence = !_skipSilence); },
        itemBuilder: (_) => [
          CheckedPopupMenuItem(value: 'silence', checked: _skipSilence, child: const Text('Skip Silence', style: TextStyle(color: Colors.white))),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
        child: Column(
          children: [
            ClipRRect(borderRadius: BorderRadius.circular(28), child: NetworkImageWithPlaceholder(imageUrl: 'https://picsum.photos/seed/${widget.podcast.seed}/500', width: double.infinity, height: 280)),
            const SizedBox(height: 24),
            Text(widget.podcast.title, textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineLarge?.copyWith(color: AppColors.primary, fontSize: 22, shadows: AppTheme.goldGlow)),
            const SizedBox(height: 6),
            Text(widget.podcast.host, style: const TextStyle(color: Colors.white60, fontSize: 14)),
            const SizedBox(height: 32),
            Slider(value: _progress, activeColor: AppColors.primary, inactiveColor: Colors.white24, onChanged: (v) => setState(() => _progress = v)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: const [
                Text('6:20', style: TextStyle(color: Colors.white54, fontSize: 12)),
                Text('35:00', style: TextStyle(color: Colors.white54, fontSize: 12)),
              ]),
            ),
            const SizedBox(height: 20),
            // Podcast-specific chrome: speed control + ±15s skip (not shown for chants).
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                  onTap: _cycleSpeed,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white24)),
                    child: Text('${_speed}x', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
                  ),
                ),
                const Icon(Icons.replay_10, color: Colors.white, size: 30),
                GestureDetector(
                  onTap: () => setState(() => _isPlaying = !_isPlaying),
                  child: Container(
                    width: 64, height: 64,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.primary.withValues(alpha: 0.15), border: Border.all(color: AppColors.primary, width: 2)),
                    child: Icon(_isPlaying ? Icons.pause : Icons.play_arrow, color: AppColors.primary, size: 30),
                  ),
                ),
                const Icon(Icons.forward_10, color: Colors.white, size: 30),
                Icon(Icons.podcasts, color: _skipSilence ? AppColors.primary : Colors.white24, size: 24),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
