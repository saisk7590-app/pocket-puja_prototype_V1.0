import 'package:flutter/material.dart';
import 'package:pocket_puja/core/theme/app_theme.dart';
import 'package:pocket_puja/customer/screens/audio/audio_browse_screen.dart';
import 'package:pocket_puja/customer/screens/booking/booking_list_screen.dart';
import 'package:pocket_puja/customer/screens/calendar/calendar_screen.dart';
import 'package:pocket_puja/customer/screens/home/home_screen.dart';
import 'package:pocket_puja/customer/screens/profile/profile_screen.dart';
import 'package:pocket_puja/customer/screens/shop/shop_screen.dart';
import 'package:pocket_puja/customer/shell/tab_nav/customer_bottom_nav.dart';
import 'package:pocket_puja/customer/widgets/audio/player_overlay.dart';
import 'package:pocket_puja/shared/notifications/notification_centre_screen.dart';

/// Customer application shell: Scaffold, IndexedStack for tab preservation,
/// header wiring, and bottom navigation.
class CustomerShell extends StatefulWidget {
  final VoidCallback onLogout;
  const CustomerShell({super.key, required this.onLogout});

  @override
  State<CustomerShell> createState() => _CustomerShellState();
}

/// Backwards-compatible alias for existing imports
typedef AppShell = CustomerShell;

class _CustomerShellState extends State<CustomerShell> {
  int _currentIndex = 0;

  void _goToTab(int i) => setState(() => _currentIndex = i);
  void _openNotifications() => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const NotificationCentreScreen()),
      );
  void _openProfile() => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => ProfileScreen(onLogout: widget.onLogout)),
      );

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomeScreen(
        onBookPooja: () => _goToTab(2),
        onListenAudio: () => _goToTab(1),
        onPanchangam: () => _goToTab(4),
        onNotifications: _openNotifications,
        onProfile: _openProfile,
      ),
      const AudioBrowseScreen(),
      const BookingListScreen(),
      const ShopScreen(),
      const CalendarScreen(),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          IndexedStack(index: _currentIndex, children: pages),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: CustomerBottomNav(
              currentIndex: _currentIndex,
              onTap: _goToTab,
            ),
          ),
          const PlayerOverlay(),
        ],
      ),
    );
  }
}
