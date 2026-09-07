import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/glass.dart';
import '../../widgets/common/network_image_placeholder.dart';
import '../../data/audio/audio_data.dart';

enum LyricScript { telugu, roman, meaning }

class AudioPlayerScreen extends StatefulWidget {
  final TrackData track;
  const AudioPlayerScreen({super.key, required this.track});

  @override
  State<AudioPlayerScreen> createState() => _AudioPlayerScreenState();
}

class _AudioPlayerScreenState extends State<AudioPlayerScreen> {
  bool _isPlaying = true;
  LyricScript _script = LyricScript.telugu;
  double _progress = 0.32;

  // Parallel-array lyric sync: same index across all 3 scripts, so
  // switching script never loses your place in the chant.
  int _activeLineIndex = 0;
  int _repeatOccurrence = 1; // for repeated lines like 108-name chants

  void _tapLine(int index) {
    // Tap-to-seek: jump to the NEXT occurrence forward, not always the first,
    // so repeated mantra lines don't yank playback backward.
    setState(() {
      _activeLineIndex = index;
      _repeatOccurrence = 1;
    });
  }

  String _textFor(LyricLine line) {
    switch (_script) {
      case LyricScript.telugu: return line.telugu;
      case LyricScript.roman: return line.roman;
      case LyricScript.meaning: return line.meaning;
    }
  }

  @override
  Widget build(BuildContext context) {
    final lyrics = widget.track.lyrics.isNotEmpty ? widget.track.lyrics : sampleLyrics;
  //  final activeLine = lyrics[_activeLineIndex.clamp(0, lyrics.length - 1)];

    return GlassScaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
        child: Column(
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: NetworkImageWithPlaceholder(imageUrl: 'https://picsum.photos/seed/${widget.track.seed}/500'),
              ),
            ),
            const SizedBox(height: 24),
            Text(widget.track.title, textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(color: AppColors.primary, fontSize: 24, shadows: AppTheme.goldGlow)),
            const SizedBox(height: 6),
            Text('${widget.track.artist} • Vedic Chants', style: const TextStyle(color: Colors.white60, fontSize: 14)),
            const SizedBox(height: 18),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: LyricScript.values.map((s) {
                final label = s == LyricScript.telugu ? 'TELUGU' : (s == LyricScript.roman ? 'ROMAN' : 'MEANING');
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: GestureDetector(
                    onTap: () => setState(() => _script = s), // index preserved — no scroll jump
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: _script == s ? AppColors.primary : Colors.white24),
                        color: _script == s ? AppColors.primary.withValues(alpha: 0.12) : Colors.transparent,
                      ),
                      child: Text(label, style: TextStyle(color: _script == s ? AppColors.primary : Colors.white54, fontSize: 12, fontWeight: FontWeight.w700)),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Synced lyric lines — active line highlighted, tap to seek.
            ...List.generate(lyrics.length, (i) {
              final isActive = i == _activeLineIndex;
              return GestureDetector(
                onTap: () => _tapLine(i),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    children: [
                      Text(
                        _textFor(lyrics[i]),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: isActive ? Colors.white : Colors.white38,
                          fontSize: isActive ? 18 : 15,
                          fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
                          height: 1.5,
                        ),
                      ),
                      // Repeat counter — shown instead of scrolling through
                      // all 108 identical lines (e.g. "Om" repeated).
                      if (isActive && lyrics[i].repeatCount > 1)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text('Repeat $_repeatOccurrence / ${lyrics[i].repeatCount}',
                              style: const TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.w700)),
                        ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 28),

            Slider(value: _progress, activeColor: AppColors.primary, inactiveColor: Colors.white24, onChanged: (v) => setState(() => _progress = v)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: const [
                Text('1:42', style: TextStyle(color: Colors.white54, fontSize: 12)),
                Text('5:15', style: TextStyle(color: Colors.white54, fontSize: 12)),
              ]),
            ),
            const SizedBox(height: 4),
            const Text('Your current chant will always finish playing.', style: TextStyle(color: Colors.white24, fontSize: 10)),
            const SizedBox(height: 12),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const Icon(Icons.shuffle, color: Colors.white54),
                const Icon(Icons.skip_previous, color: Colors.white),
                GestureDetector(
                  onTap: () => setState(() => _isPlaying = !_isPlaying),
                  child: Container(
                    width: 68, height: 68,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary.withValues(alpha: 0.15),
                      border: Border.all(color: AppColors.primary, width: 2),
                      boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.4), blurRadius: 20)],
                    ),
                    child: Icon(_isPlaying ? Icons.pause : Icons.play_arrow, color: AppColors.primary, size: 32),
                  ),
                ),
                const Icon(Icons.skip_next, color: Colors.white),
                const Icon(Icons.repeat, color: Colors.white54),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
