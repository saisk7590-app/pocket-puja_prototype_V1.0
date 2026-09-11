import 'package:flutter/material.dart';

class NowPlayingHeaderBar extends StatelessWidget {
  final VoidCallback onMinimize;
  final String subtitle;
  final VoidCallback? onOptionsTap;
  const NowPlayingHeaderBar({
    super.key,
    required this.onMinimize,
    this.subtitle = 'PLAYING FROM PLAYLIST',
    this.onOptionsTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 28),
          onPressed: onMinimize,
        ),
        Expanded(
          child: Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.more_vert, color: Colors.white),
          onPressed: onOptionsTap,
        ),
      ],
    );
  }
}