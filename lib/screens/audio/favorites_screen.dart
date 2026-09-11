import 'package:flutter/material.dart';
//import '../../theme/app_theme.dart';
import '../../widgets/common/glass.dart';
import '../../widgets/audio/track_row.dart';
import '../../services/audio_controller.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = AudioControllerScope.of(context);
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final liked = controller.likedTracks;
        return GlassScaffold(
          title: 'Favorites',
          body: liked.isEmpty
              ? Center(
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.favorite_border, size: 56, color: Colors.white.withValues(alpha: 0.2)),
                    const SizedBox(height: 12),
                    const Text('No liked songs yet', style: TextStyle(color: Colors.white38)),
                    const SizedBox(height: 4),
                    const Text('Tap the heart on any song to save it here.', style: TextStyle(color: Colors.white24, fontSize: 12)),
                  ]),
                )
              : ListView(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
                  children: liked.map((t) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: TrackRow(track: t, onTap: () => controller.playTrack(t)),
                      )).toList(),
                ),
        );
      },
    );
  }
}