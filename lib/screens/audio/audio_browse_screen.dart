import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/glass.dart';
import '../../widgets/audio/track_row.dart';
import '../../widgets/audio/podcast_row.dart';
import '../../widgets/audio/usage_banner.dart';
import '../../widgets/subscription/block_modal.dart';
import '../../data/audio/audio_data.dart';
import 'audio_player_screen.dart';
import 'podcast_detail_screen.dart';
import '../subscription/subscription_screen.dart';

class AudioBrowseScreen extends StatefulWidget {
  const AudioBrowseScreen({super.key});
  @override
  State<AudioBrowseScreen> createState() => _AudioBrowseScreenState();
}

class _AudioBrowseScreenState extends State<AudioBrowseScreen> {
  bool _showingPodcasts = false;
  String _filter = 'ALL';
  final _filters = ['ALL', 'DEVI', 'SHIVA', 'VISHNU', 'GANESHA', 'HANUMAN'];

  bool _searchActive = false;
  final _searchController = TextEditingController();
  String _query = '';

  void _openUpgrade() => Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) =>
          const SubscriptionScreen(entryPoint: SubscriptionEntryPoint.browsing),
    ),
  );

  // Block only fires on the NEXT play attempt once 100% is reached —
  // never mid-track. Today's Mantra always bypasses this entirely.
  void _openTrack(TrackData track) {
    if (currentUsage.isBlocked) {
      showUsageBlockModal(context);
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => AudioPlayerScreen(track: track)),
      );
    }
  }

  void _toggleSearch() {
    setState(() {
      _searchActive = !_searchActive;
      if (!_searchActive) {
        _searchController.clear();
        _query = '';
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final byFilter = _filter == 'ALL'
        ? tracks
        : tracks.where((t) => t.deity.toUpperCase().contains(_filter)).toList();
    final filteredTracks = _query.isEmpty
        ? byFilter
        : byFilter
              .where(
                (t) =>
                    t.title.toLowerCase().contains(_query.toLowerCase()) ||
                    t.deity.toLowerCase().contains(_query.toLowerCase()),
              )
              .toList();
    final filteredPodcasts = _query.isEmpty
        ? podcasts
        : podcasts
              .where(
                (p) =>
                    p.title.toLowerCase().contains(_query.toLowerCase()) ||
                    p.host.toLowerCase().contains(_query.toLowerCase()),
              )
              .toList();

    return GlassScaffold(
      showBack: false,
      title: 'Music',
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 110),
        children: [
          Text(
            'ఆధ్యాత్మిక భాండాగారం',
            style: Theme.of(
              context,
            ).textTheme.headlineLarge?.copyWith(fontSize: 24),
          ),
          const SizedBox(height: 8),
          const Text(
            'Explore sacred chants, stotrams, and ashtothrams for your daily sadhana.',
            style: TextStyle(color: Colors.white60, fontSize: 13),
          ),
          const SizedBox(height: 14),
          UsageBanner(usage: currentUsage, onUpgrade: _openUpgrade),
          const SizedBox(height: 14),

          // Always-free floor content — plays even at 100% block.
          GlassPanelGold(
            padding: const EdgeInsets.all(12),
            borderRadius: 16,
            onTap: () {},
            child: Row(
              children: [
                const Icon(Icons.wb_sunny, color: AppColors.primary, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Today's Mantra — always free",
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        '${todaysMantra.title} • ${todaysMantra.duration}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.play_circle_fill,
                  color: AppColors.primary,
                  size: 28,
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          Row(
            children: [
              if (!_searchActive) ...[
                _SegTab(
                  label: 'Chants',
                  selected: !_showingPodcasts,
                  onTap: () => setState(() => _showingPodcasts = false),
                ),
                const SizedBox(width: 10),
                _SegTab(
                  label: 'Podcasts',
                  selected: _showingPodcasts,
                  onTap: () => setState(() => _showingPodcasts = true),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.search, color: Colors.white54),
                  onPressed: _toggleSearch,
                ),
              ] else ...[
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    autofocus: true,
                    style: const TextStyle(color: Colors.white),
                    onChanged: (v) => setState(() => _query = v),
                    decoration: InputDecoration(
                      hintText: 'Search chants & podcasts...',
                      hintStyle: const TextStyle(color: Colors.white38),
                      filled: true,
                      fillColor: Colors.white.withValues(alpha: 0.06),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white54),
                  onPressed: _toggleSearch,
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),

          if (!_showingPodcasts) ...[
            if (!_searchActive) ...[
              SizedBox(
                height: 40,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _filters.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (_, i) => _FilterChip(
                    label: _filters[i],
                    selected: _filter == _filters[i],
                    onTap: () => setState(() => _filter = _filters[i]),
                  ),
                ),
              ),
              const SizedBox(height: 18),
            ],
            if (filteredTracks.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text(
                    'No chants found',
                    style: TextStyle(color: Colors.white38),
                  ),
                ),
              )
            else
              ...filteredTracks.map(
                (t) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: TrackRow(track: t, onTap: () => _openTrack(t)),
                ),
              ),
          ] else if (filteredPodcasts.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  'No podcasts found',
                  style: TextStyle(color: Colors.white38),
                ),
              ),
            )
          else
            ...filteredPodcasts.map(
              (p) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: PodcastRow(
                  podcast: p,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => PodcastDetailScreen(podcast: p),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SegTab extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _SegTab({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withValues(alpha: 0.15)
              : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppColors.primary : Colors.white24,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? AppColors.primary : Colors.white70,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppColors.primary : Colors.white24,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: selected ? AppColors.primary : Colors.white54,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
