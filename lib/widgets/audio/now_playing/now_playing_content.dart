import 'package:flutter/material.dart';
import '../../../data/audio/audio_data.dart';
import '../../../services/audio_controller.dart';
import '../add_to_playlist_sheet.dart';
import 'header_bar.dart';
import 'album_art.dart';
import 'track_info_row.dart';
import 'seek_bar.dart';
import 'player_controls.dart';
import 'synced_lyrics_card.dart';
import 'bottom_utilities.dart';

class NowPlayingContent extends StatefulWidget {
  final VoidCallback onMinimize;
  final ScrollController? scrollController;
  const NowPlayingContent({super.key, required this.onMinimize, this.scrollController});

  @override
  State<NowPlayingContent> createState() => _NowPlayingContentState();
}

class _NowPlayingContentState extends State<NowPlayingContent> {
  LyricScript _script = LyricScript.telugu;

  @override
  Widget build(BuildContext context) {
    final controller = AudioControllerScope.of(context);
    final track = controller.currentTrack;
    if (track == null) return const SizedBox.shrink();

    final lyrics = track.lyrics.isNotEmpty ? track.lyrics : sampleLyrics;

    return SafeArea(
      child: SingleChildScrollView(
        controller: widget.scrollController,
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        child: Column(
          children: [
            NowPlayingHeaderBar(
              onMinimize: widget.onMinimize,
              subtitle: 'PLAYING FROM DAILY CHANTS',
              onOptionsTap: () => showAddToPlaylistSheet(context, track),
            ),
            const SizedBox(height: 16),
            NowPlayingAlbumArt(imageSeed: track.seed),
            const SizedBox(height: 24),
            NowPlayingTrackInfoRow(
              title: track.title,
              artist: '${track.artist} • Vedic Chants',
              isLiked: controller.isTrackLiked(track.id),
              onToggleLike: () => controller.toggleLikeForTrack(track.id),
            ),
            const SizedBox(height: 12),
            NowPlayingSeekBar(progress: controller.progress, elapsed: '1:42', total: track.duration, onChanged: controller.seek),
            const SizedBox(height: 8),
            NowPlayingControls(
              isPlaying: controller.isPlaying,
              isShuffle: controller.isShuffle,
              repeatMode: controller.repeatMode,
              onPlayPause: controller.togglePlay,
              onShuffle: controller.toggleShuffle,
              onRepeat: controller.cycleRepeat,
              onNext: () {},
              onPrevious: () {},
            ),
            const SizedBox(height: 20),
            SyncedLyricsCard(
              lyrics: lyrics,
              activeIndex: controller.activeLineIndex,
              repeatOccurrence: controller.repeatOccurrence,
              script: _script,
              onScriptChanged: (s) => setState(() => _script = s),
              onLineTap: controller.setActiveLine,
            ),
            const SizedBox(height: 12),
            NowPlayingBottomUtilities(onConnectDevice: () {}, onQueue: () {}),
          ],
        ),
      ),
    );
  }
}