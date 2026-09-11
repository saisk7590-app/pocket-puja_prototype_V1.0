import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../../common/glass.dart';
import '../../../data/audio/audio_data.dart';

enum LyricScript { telugu, meaning }

class SyncedLyricsCard extends StatefulWidget {
  final List<LyricLine> lyrics;
  final int activeIndex;
  final int repeatOccurrence;
  final LyricScript script;
  final ValueChanged<LyricScript> onScriptChanged;
  final ValueChanged<int> onLineTap;

  const SyncedLyricsCard({
    super.key,
    required this.lyrics,
    required this.activeIndex,
    required this.repeatOccurrence,
    required this.script,
    required this.onScriptChanged,
    required this.onLineTap,
  });

  @override
  State<SyncedLyricsCard> createState() => _SyncedLyricsCardState();
}

class _SyncedLyricsCardState extends State<SyncedLyricsCard> {
  final ScrollController _scrollController = ScrollController();
  final Map<int, GlobalKey> _lineKeys = {};

  @override
  void didUpdateWidget(covariant SyncedLyricsCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.activeIndex != widget.activeIndex) {
      _scrollToActiveLine();
    }
  }

  void _scrollToActiveLine() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final key = _lineKeys[widget.activeIndex];
      final ctx = key?.currentContext;
      if (ctx != null) {
        Scrollable.ensureVisible(ctx, duration: const Duration(milliseconds: 350), curve: Curves.easeOutCubic, alignment: 0.5);
      }
    });
  }

  String _textFor(LyricLine line) => widget.script == LyricScript.telugu ? line.telugu : line.meaning;

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      borderRadius: 22,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: LyricScript.values.map((s) {
              final label = s == LyricScript.telugu ? 'TELUGU' : 'MEANING';
              final selected = widget.script == s;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: GestureDetector(
                  onTap: () => widget.onScriptChanged(s),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: selected ? AppColors.primary : Colors.white24),
                      color: selected ? AppColors.primary.withValues(alpha: 0.12) : Colors.transparent,
                    ),
                    child: Text(label, style: TextStyle(color: selected ? AppColors.primary : Colors.white54, fontSize: 12, fontWeight: FontWeight.w700)),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          Container(
            height: 280,
            decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(16)),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(vertical: 100, horizontal: 16),
                itemCount: widget.lyrics.length,
                itemBuilder: (context, i) {
                  _lineKeys[i] ??= GlobalKey();
                  final isActive = i == widget.activeIndex;
                  return GestureDetector(
                    key: _lineKeys[i],
                    onTap: () => widget.onLineTap(i),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Column(
                        children: [
                          AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 250),
                            style: TextStyle(
                              color: isActive ? Colors.white : Colors.white.withValues(alpha: 0.35),
                              fontSize: isActive ? 18 : 15,
                              fontWeight: isActive ? FontWeight.w800 : FontWeight.w400,
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                            child: Text(_textFor(widget.lyrics[i])),
                          ),
                          if (isActive && widget.lyrics[i].repeatCount > 1)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text('Repeat ${widget.repeatOccurrence} / ${widget.lyrics[i].repeatCount}', style: const TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.w700)),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}