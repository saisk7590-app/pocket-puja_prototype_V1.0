import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/glass.dart';
import '../../widgets/home/hero_panchangam_card.dart';
import '../../widgets/home/home_kpi_square.dart';
import '../../widgets/home/chant_carousel.dart';
import '../../data/home/home_data.dart';
import '../../data/audio/audio_data.dart';
import '../../services/audio_controller.dart';
import '../../widgets/common/nav_constants.dart';

class HomeScreen extends StatelessWidget {
  final VoidCallback? onBookPooja;
  final VoidCallback? onListenAudio;
  final VoidCallback? onPanchangam;
  final VoidCallback? onNotifications;
  final VoidCallback? onProfile;

  const HomeScreen({super.key, this.onBookPooja, this.onListenAudio, this.onPanchangam, this.onNotifications, this.onProfile});

  Widget _buildKpiRow(BuildContext context) {
    final squares = <Widget>[
      HomeKpiSquare(
        icon: Icons.auto_awesome,
        label: 'Your Rashi',
        value: currentUserRashi.oneLiner,
        onTap: onPanchangam ?? () {},
      ),
      HomeKpiSquare(
        icon: Icons.event_available,
        label: activeBooking.status,
        value: activeBooking.poojaName,
        gold: true,
        onTap: onBookPooja ?? () {},
      ),
      HomeKpiSquare(
        icon: Icons.celebration,
        label: 'Festival',
        value: '${upcomingFestival.name} in ${upcomingFestival.daysAway}',
        onTap: onBookPooja ?? () {},
      ),
    ];

    return Row(
      children: [
        for (int i = 0; i < squares.length; i++) ...[
          if (i > 0) const SizedBox(width: 12),
          Expanded(child: squares[i]),
        ],
      ],
    );
  }

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
      leading: IconButton(icon: const Icon(Icons.account_circle_outlined), color: AppColors.primary, onPressed: onProfile),
      trailing: IconButton(icon: const Icon(Icons.notifications_none), color: AppColors.primary, onPressed: onNotifications),
      body: RefreshIndicator(
        color: AppColors.primary,
        backgroundColor: AppColors.surfaceContainer,
        onRefresh: () async => Future.delayed(const Duration(seconds: 1)),
        child: ListView(
                    padding: EdgeInsets.fromLTRB(20, 16, 20, tabBottomPadding(context)),
          children: [
            HeroPanchangamCard(data: todayPanchangam, onTap: onPanchangam ?? () {}),
            const SizedBox(height: 14),
            _buildKpiRow(context),
            const SizedBox(height: 28),
            ChantCarousel(
              headerLabel: "Today's Focus: ${todaysDeities.deities.join(' & ')}",
              tracks: todaysFocus,
                            onTap: (t) => AudioControllerScope.of(context).playTrack(t),
            ),
            const SizedBox(height: 24),
            ChantCarousel(
              headerLabel: 'Picked For You',
              tracks: pickedForYou,
              onTap: (t) => AudioControllerScope.of(context).playTrack(t),
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