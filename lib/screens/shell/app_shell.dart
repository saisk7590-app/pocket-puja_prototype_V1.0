import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/glass.dart';
import '../../widgets/audio/mini_player.dart';
import '../../data/audio/audio_data.dart';
import '../home/home_screen.dart';
import '../audio/audio_browse_screen.dart';
import '../booking/booking_list_screen.dart';
import '../shop/shop_screen.dart';
import '../calendar/calendar_screen.dart';
import '../notifications/notification_centre_screen.dart';
import '../profile/profile_screen.dart';

class AppShell extends StatefulWidget {
  final VoidCallback onLogout;
  const AppShell({super.key, required this.onLogout});
  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;
  TrackData? _nowPlaying = tracks.first; // mock: something is "playing" globally

  void _goToTab(int i) => setState(() => _currentIndex = i);
  void _openNotifications() => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const NotificationCentreScreen()));
  void _openProfile() => Navigator.of(context).push(MaterialPageRoute(builder: (_) => ProfileScreen(onLogout: widget.onLogout)));

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomeScreen(onBookPooja: () => _goToTab(2), onListenAudio: () => _goToTab(1), onPanchangam: () => _goToTab(4), onNotifications: _openNotifications, onProfile: _openProfile),
      const AudioBrowseScreen(),
      const BookingListScreen(),
      const ShopScreen(),
      const CalendarScreen(),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      extendBody: true,
      body: IndexedStack(index: _currentIndex, children: pages),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Global mini-player — floats above every tab, Spotify-style.
          MiniPlayer(nowPlaying: _nowPlaying, onDismiss: () => setState(() => _nowPlaying = null)),
          GlassBottomNav(
            currentIndex: _currentIndex,
            onTap: _goToTab,
            icons: const [Icons.home_rounded, Icons.headphones, Icons.event_available, Icons.shopping_bag, Icons.calendar_month],
          ),
        ],
      ),
    );
  }
}
