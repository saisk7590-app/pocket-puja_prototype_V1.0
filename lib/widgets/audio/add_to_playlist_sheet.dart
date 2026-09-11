import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../common/glass.dart';
import '../../services/audio_controller.dart';
import '../../data/audio/audio_data.dart';

void showAddToPlaylistSheet(BuildContext context, TrackData track) {
  final controller = AudioControllerScope.of(context);
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (ctx) => AnimatedBuilder(
      animation: controller,
      builder: (context, _) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(color: AppColors.surfaceContainerHigh, borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Add to Playlist', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            ...controller.playlists.map((p) {
              final alreadyIn = p.trackIds.contains(track.id);
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: GlassPanel(
                  padding: const EdgeInsets.all(12),
                  borderRadius: 14,
                  onTap: () => controller.addTrackToPlaylist(p.id, track),
                  child: Row(
                    children: [
                      Expanded(child: Text(p.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600))),
                      Icon(alreadyIn ? Icons.check_circle : Icons.add_circle_outline, color: AppColors.primary),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () {
                Navigator.pop(ctx);
                final nameController = TextEditingController();
                showModalBottomSheet(
                  context: context,
                  backgroundColor: Colors.transparent,
                  builder: (ctx2) => Container(
                    padding: const EdgeInsets.all(24),
                    decoration: const BoxDecoration(color: AppColors.surfaceContainerHigh, borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('New Playlist', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 16),
                        TextField(
                          controller: nameController,
                          autofocus: true,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(hintText: 'Playlist name', hintStyle: const TextStyle(color: Colors.white38), filled: true, fillColor: Colors.white.withValues(alpha: 0.05), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)),
                        ),
                        const SizedBox(height: 16),
                        PrimaryButton(
                          label: 'Create & Add',
                          onTap: () {
                            if (nameController.text.trim().isEmpty) return;
                            final p = controller.createPlaylist(nameController.text.trim());
                            controller.addTrackToPlaylist(p.id, track);
                            Navigator.pop(ctx2);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.add, color: AppColors.primary, size: 18),
              label: const Text('New Playlist', style: TextStyle(color: AppColors.primary)),
            ),
          ],
        ),
      ),
    ),
  );
}