import 'package:flutter/material.dart';
//import '../../theme/app_theme.dart';
import '../../widgets/common/glass.dart';
import '../../widgets/audio/track_row.dart';
import '../../services/audio_controller.dart';
import '../../data/audio/playlist_data.dart';

class PlaylistDetailScreen extends StatelessWidget {
  final Playlist playlist;
  const PlaylistDetailScreen({super.key, required this.playlist});

  @override
  Widget build(BuildContext context) {
    final controller = AudioControllerScope.of(context);
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final playlistTracks = controller.tracksInPlaylist(playlist);
        return GlassScaffold(
          title: playlist.name,
          body: playlistTracks.isEmpty
              ? Center(
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.music_off, size: 56, color: Colors.white.withValues(alpha: 0.2)),
                    const SizedBox(height: 12),
                    const Text('No tracks in this playlist yet', style: TextStyle(color: Colors.white38)),
                  ]),
                )
              : ListView(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
                  children: playlistTracks.map((t) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Dismissible(
                          key: ValueKey(t.id),
                          direction: DismissDirection.endToStart,
                          onDismissed: (_) => controller.removeTrackFromPlaylist(playlist.id, t.id),
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            decoration: BoxDecoration(color: const Color(0xFFE05353).withValues(alpha: 0.2), borderRadius: BorderRadius.circular(18)),
                            child: const Icon(Icons.delete_outline, color: Color(0xFFE05353)),
                          ),
                          child: TrackRow(track: t, onTap: () => controller.playTrack(t)),
                        ),
                      )).toList(),
                ),
        );
      },
    );
  }
}