import 'package:flutter/material.dart';
import 'package:pocket_puja/core/models/user_account.dart';
import 'package:pocket_puja/core/services/poojari_controller.dart';
import 'package:pocket_puja/core/services/session_service.dart';
import 'package:pocket_puja/core/theme/app_theme.dart';
import 'package:pocket_puja/core/widgets/glass.dart';
import 'package:pocket_puja/core/widgets/verification_banner.dart';
import 'package:pocket_puja/poojari/screens/dashboard/poojari_dashboard_screen.dart';
import 'package:pocket_puja/poojari/screens/earnings/poojari_earnings_screen.dart';
import 'package:pocket_puja/poojari/screens/profile/poojari_profile_screen.dart';
import 'package:pocket_puja/poojari/screens/requests/assigned_poojas_screen.dart';
import 'package:pocket_puja/poojari/screens/schedule/poojari_schedule_screen.dart';

class PoojariShell extends StatefulWidget {
  final VoidCallback onLogout;
  final VoidCallback? onSwitchToCustomer;

  const PoojariShell({
    super.key,
    required this.onLogout,
    this.onSwitchToCustomer,
  });

  @override
  State<PoojariShell> createState() => _PoojariShellState();
}

class _PoojariShellState extends State<PoojariShell> {
  int _currentIndex = 0;

  void _goToTab(int i) => setState(() => _currentIndex = i);

  @override
  Widget build(BuildContext context) {
    final session = SessionService.instance;
    final user = session.currentUser;
    final showVerificationBanner =
        user == null || user.poojariStatus != PoojariVerificationStatus.verified;
    final controller =
        PoojariControllerScope.maybeOf(context) ?? PoojariController.instance;

    final pages = [
      PoojariDashboardScreen(
        onSwitchToCustomer: widget.onSwitchToCustomer,
      ),
      // BLOCK 6: Assigned Poojas Tab
      AssignedPoojasScreen(
        onSwitchToCustomer: widget.onSwitchToCustomer,
      ),
      PoojariScheduleScreen(
        onSwitchToCustomer: widget.onSwitchToCustomer,
      ),
      PoojariEarningsScreen(
        onSwitchToCustomer: widget.onSwitchToCustomer,
      ),
      PoojariProfileScreen(
        onLogout: widget.onLogout,
        onSwitchToCustomer: widget.onSwitchToCustomer,
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Main tab contents
          Positioned.fill(
            child: Padding(
              padding: EdgeInsets.only(top: (showVerificationBanner && _currentIndex != 0) ? 54 : 0),
              child: IndexedStack(
                index: _currentIndex,
                children: pages,
              ),
            ),
          ),

          // Persistent Verification Banner at the top for sub-tabs if status != verified
          // (Dashboard has its own Section 2 banner in the scrollable view)
          if (showVerificationBanner && _currentIndex != 0)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: const SafeArea(
                bottom: false,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: VerificationPendingBanner(),
                ),
              ),
            ),

          // Bottom Nav Bar with BLOCK 6b reactive red badge on Assigned Poojas tab (index 1)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: AnimatedBuilder(
              animation: controller,
              builder: (context, _) {
                final newCount = controller.newAssignmentsCount;
                return GlassBottomNav(
                  currentIndex: _currentIndex,
                  onTap: _goToTab,
                  badges: newCount > 0 ? {1: newCount} : null,
                  icons: const [
                    Icons.dashboard_rounded,
                    Icons.assignment_turned_in_rounded, // Assigned Poojas tab (index 1)
                    Icons.calendar_month_rounded,
                    Icons.account_balance_wallet_rounded,
                    Icons.person_pin_rounded,
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
