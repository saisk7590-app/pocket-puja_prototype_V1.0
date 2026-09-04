import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/glass.dart';
import '../../widgets/home/hero_panchangam_card.dart';
import '../../widgets/home/rashi_chip.dart';
import '../../widgets/home/active_booking_card.dart';
import '../../widgets/home/festival_banner.dart';
import '../../widgets/home/chant_carousel.dart';
import '../../data/home/home_data.dart';
import '../../data/audio/audio_data.dart';
import '../audio/audio_player_screen.dart';

class HomeScreen extends StatelessWidget {
  final VoidCallback? onBookPooja;
  final VoidCallback? onListenAudio;
  final VoidCallback? onPanchangam;
  final VoidCallback? onNotifications;
  final VoidCallback? onProfile;

  const HomeScreen({super.key, this.onBookPooja, this.onListenAudio, this.onPanchangam, this.onNotifications, this.onProfile});

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final todaysDeities = weekdayDeities[today.weekday % 7];
    // Pull tracks whose deity matches today's associated gods; fallback to first few.
    final focusTracks = tracks.where((t) => todaysDeities.deities.any((d) => t.deity.toLowerCase().contains(d.toLowerCase().split('/').first))).toList();
    final todaysFocus = focusTracks.isNotEmpty ? focusTracks : tracks.take(3).toList();
    final pickedForYou = tracks.reversed.take(3).toList(); // mock "listening history" based picks

    return GlassScaffold(
      showBack: false,
      leading: IconButton(icon: const Icon(Icons.person_outline), color: AppColors.primary, onPressed: onProfile),
      trailing: IconButton(icon: const Icon(Icons.notifications_none), color: AppColors.primary, onPressed: onNotifications),
      body: RefreshIndicator(
        color: AppColors.primary,
        backgroundColor: AppColors.surfaceContainer,
        onRefresh: () async => Future.delayed(const Duration(seconds: 1)),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 110),
          children: [
            HeroPanchangamCard(data: todayPanchangam, onTap: onPanchangam ?? () {}),
            const SizedBox(height: 12),
            RashiChip(rashi: currentUserRashi, onTap: onPanchangam ?? () {}),
            const SizedBox(height: 12),
            ActiveBookingCard(booking: activeBooking, onTap: onBookPooja ?? () {}),
            const SizedBox(height: 12),
            FestivalBanner(festival: upcomingFestival, onBookNow: onBookPooja ?? () {}),
            const SizedBox(height: 28),
            ChantCarousel(
              headerLabel: "Today's Focus: ${todaysDeities.deities.join(' & ')}",
              tracks: todaysFocus,
              onTap: (t) => Navigator.of(context).push(MaterialPageRoute(builder: (_) => AudioPlayerScreen(track: t))),
            ),
            const SizedBox(height: 24),
            ChantCarousel(
              headerLabel: 'Picked For You',
              tracks: pickedForYou,
              onTap: (t) => Navigator.of(context).push(MaterialPageRoute(builder: (_) => AudioPlayerScreen(track: t))),
            ),
            const SizedBox(height: 24),
            GlassPanelGold(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Icon(Icons.auto_awesome, color: AppColors.primary.withValues(alpha: 0.6), size: 16),
                    const SizedBox(width: 8),
                    const SectionLabel('Daily Wisdom'),
                  ]),
                  const SizedBox(height: 12),
                  Text(dailyWisdom.teluguQuote, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontStyle: FontStyle.italic, fontSize: 17)),
                  const SizedBox(height: 8),
                  Text(dailyWisdom.englishMeaning, style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
