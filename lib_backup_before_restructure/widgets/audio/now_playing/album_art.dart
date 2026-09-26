import 'package:flutter/material.dart';
import '../../common/network_image_placeholder.dart';

class NowPlayingAlbumArt extends StatelessWidget {
  final String imageSeed;
  const NowPlayingAlbumArt({super.key, required this.imageSeed});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: NetworkImageWithPlaceholder(imageUrl: 'https://picsum.photos/seed/$imageSeed/600'),
      ),
    );
  }
}