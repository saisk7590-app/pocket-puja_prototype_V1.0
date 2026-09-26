import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/audio_controller.dart';
import '../common/network_image_placeholder.dart';
import '../common/nav_constants.dart';
import 'now_playing/now_playing_content.dart';

/// The Spotify-style player: collapsed = mini-player bar sitting just
/// above the nav bar. Expanded = full Now Playing screen that physically
/// covers the nav bar (drawn on top of it in the parent Stack).
class PlayerOverlay extends StatefulWidget {
  const PlayerOverlay({super.key});

  @override
  State<PlayerOverlay> createState() => _PlayerOverlayState();
}

class _PlayerOverlayState extends State<PlayerOverlay> with SingleTickerProviderStateMixin {
  late final AnimationController _anim;
  
  AudioController? _controller;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(vsync: this, duration: const Duration(milliseconds: 320));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final controller = AudioControllerScope.of(context);
    if (_controller != controller) {
      _controller?.playEvents.removeListener(_onNewTrack);
      _controller = controller;
      _controller!.playEvents.addListener(_onNewTrack);
    }
  }

  @override
  void dispose() {
    _controller?.playEvents.removeListener(_onNewTrack);
    _anim.dispose();
    super.dispose();
  }

  // A new track starting always opens straight to full-screen, per Spotify.
  void _onNewTrack() {
    _anim.animateTo(1.0, curve: Curves.easeOutCubic);
  }

  void _expand() => _anim.animateTo(1.0, curve: Curves.easeOutCubic);
  void _collapse() => _anim.animateTo(0.0, curve: Curves.easeOutCubic);

    void _onDragStart(DragStartDetails details) {}

  void _onDragUpdate(DragUpdateDetails details, double screenHeight) {
    final delta = -details.delta.dy / screenHeight;
    _anim.value = (_anim.value + delta).clamp(0.0, 1.0);
  }

  void _onDragEnd(DragEndDetails details) {
    final velocity = details.velocity.pixelsPerSecond.dy;
    if (velocity > 600) {
      _collapse();
    } else if (velocity < -600) {
      _expand();
    } else if (_anim.value > 0.5) {
      _expand();
    } else {
      _collapse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = AudioControllerScope.of(context);
    final screenHeight = MediaQuery.of(context).size.height;

    return AnimatedBuilder(
      animation: Listenable.merge([controller, _anim]),
      builder: (context, _) {
        final track = controller.currentTrack;
        if (track == null) return const SizedBox.shrink();

        final extent = _anim.value; // 0 = collapsed mini-player, 1 = full screen
        final height = lerpDouble(kMiniPlayerHeight, screenHeight, extent);
        final bottom = lerpDouble(kNavBarHeight, 0, extent);
        final radius = lerpDouble(18, 0, extent).clamp(0, 18);
        final showFull = extent > 0.55;

        return Positioned(
          left: 0,
          right: 0,
          bottom: bottom,
          height: height,
          child: GestureDetector(
            onTap: extent < 0.1 ? _expand : null,
            onVerticalDragStart: _onDragStart,
            onVerticalDragUpdate: (d) => _onDragUpdate(d, screenHeight),
            onVerticalDragEnd: _onDragEnd,
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: lerpDouble(16, 0, extent)),
              decoration: BoxDecoration(
                gradient: AppGradients.sacred,
                borderRadius: BorderRadius.vertical(top: Radius.circular(radius.toDouble())),
                border: extent < 0.1
                    ? Border.all(color: AppColors.primary.withValues(alpha: 0.3))
                    : null,
                boxShadow: extent < 0.1
                    ? [BoxShadow(color: AppColors.primary.withValues(alpha: 0.2), blurRadius: 18, offset: const Offset(0, 4))]
                    : null,
              ),
              clipBehavior: Clip.antiAlias,
              child: showFull
                  ? Opacity(
                      opacity: ((extent - 0.55) / 0.45).clamp(0.0, 1.0),
                      child: NowPlayingContent(onMinimize: _collapse),
                    )
                  : Opacity(
                      opacity: (1 - extent / 0.55).clamp(0.0, 1.0),
                      child: _MiniPlayerBar(controller: controller),
                    ),
            ),
          ),
        );
      },
    );
  }
}

double lerpDouble(num a, num b, double t) => a + (b - a) * t;

class _MiniPlayerBar extends StatelessWidget {
  final AudioController controller;
  const _MiniPlayerBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    final track = controller.currentTrack!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: NetworkImageWithPlaceholder(imageUrl: 'https://picsum.photos/seed/${track.seed}/100', width: 40, height: 40),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(track.title, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
                Text(track.artist, style: const TextStyle(color: Colors.white54, fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          IconButton(icon: Icon(controller.isPlaying ? Icons.pause : Icons.play_arrow, color: AppColors.primary), onPressed: controller.togglePlay),
          IconButton(icon: const Icon(Icons.close, color: Colors.white54, size: 18), onPressed: controller.stop),
        ],
      ),
    );
  }
}