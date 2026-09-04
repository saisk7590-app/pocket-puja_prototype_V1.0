import 'package:flutter/material.dart';
import '../../data/audio/audio_data.dart';
import '../common/network_image_placeholder.dart';

class ChantCarousel extends StatelessWidget {
  final String headerLabel;
  final List<TrackData> tracks;
  final ValueChanged<TrackData> onTap;
  const ChantCarousel({super.key, required this.headerLabel, required this.tracks, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(headerLabel, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 18)),
        const SizedBox(height: 12),
        SizedBox(
          height: 190,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: tracks.length,
            separatorBuilder: (_, __) => const SizedBox(width: 14),
            itemBuilder: (_, i) => GestureDetector(onTap: () => onTap(tracks[i]), child: _Card(track: tracks[i])),
          ),
        ),
      ],
    );
  }
}

class _Card extends StatelessWidget {
  final TrackData track;
  const _Card({required this.track});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Stack(
          fit: StackFit.expand,
          children: [
            NetworkImageWithPlaceholder(imageUrl: 'https://picsum.photos/seed/${track.seed}/300/400'),
            Container(decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Colors.black87]))),
            Positioned(
              left: 10, right: 10, bottom: 10,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(track.deity, style: const TextStyle(color: Color(0xFFF2CA50), fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1)),
                  Text(track.title, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700), maxLines: 2, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
