import 'package:flutter/material.dart';

class NowPlayingBottomUtilities extends StatelessWidget {
  final VoidCallback? onConnectDevice, onQueue;
  const NowPlayingBottomUtilities({super.key, this.onConnectDevice, this.onQueue});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(icon: const Icon(Icons.cast_connected, color: Colors.white54), onPressed: onConnectDevice),
        IconButton(icon: const Icon(Icons.queue_music, color: Colors.white54), onPressed: onQueue),
      ],
    );
  }
}