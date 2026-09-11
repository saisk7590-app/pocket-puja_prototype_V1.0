import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/glass.dart';
import '../../widgets/common/network_image_placeholder.dart';
import '../../services/audio_controller.dart';
import 'playlist_detail_screen.dart';

class PlaylistsScreen extends StatelessWidget {
  const PlaylistsScreen({super.key});

  void _showCreateSheet(BuildContext context) {
    final controller = AudioControllerScope.of(context);
    final nameController = TextEditingController();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
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
              decoration: InputDecoration(
                hintText: 'Playlist name',
                hintStyle: const TextStyle(color: Colors.white38),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.05),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 16),
            PrimaryButton(
              label: 'Create',
              onTap: () {
                if (nameController.text.trim().isEmpty) return;
                controller.createPlaylist(nameController.text.trim());
                Navigator.pop(ctx);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = AudioControllerScope.of(context);
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return GlassScaffold(
          title: 'Playlists',
          floatingActionButton: FloatingActionButton(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.onPrimary,
            onPressed: () => _showCreateSheet(context),
            child: const Icon(Icons.add),
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 110),
            children: controller.playlists.map((p) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: GlassPanel(
                    padding: const EdgeInsets.all(12),
                    borderRadius: 18,
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => PlaylistDetailScreen(playlist: p))),
                    child: Row(
                      children: [
                        ClipRRect(borderRadius: BorderRadius.circular(12), child: NetworkImageWithPlaceholder(imageUrl: 'https://picsum.photos/seed/${p.seed}/120', width: 52, height: 52)),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(p.name, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700)),
                              Text('${p.trackIds.length} track${p.trackIds.length == 1 ? '' : 's'}', style: const TextStyle(color: Colors.white54, fontSize: 12)),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right, color: Colors.white38),
                      ],
                    ),
                  ),
                )).toList(),
          ),
        );
      },
    );
  }
}