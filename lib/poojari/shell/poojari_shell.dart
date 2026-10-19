import 'package:flutter/material.dart';
import 'package:pocket_puja/core/models/user_account.dart';
import 'package:pocket_puja/core/services/poojari_controller.dart';
import 'package:pocket_puja/core/services/session_service.dart';
import 'package:pocket_puja/core/theme/app_theme.dart';
import 'package:pocket_puja/core/widgets/verification_banner.dart';
import 'package:pocket_puja/poojari/screens/dashboard/poojari_dashboard_screen.dart';
import 'package:pocket_puja/poojari/screens/earnings/earnings_screen.dart';
import 'package:pocket_puja/poojari/screens/requests/assigned_poojas_screen.dart';
import 'package:pocket_puja/poojari/screens/schedule/poojari_schedule_screen.dart';
import 'package:pocket_puja/poojari/shell/tab_nav/poojari_bottom_nav.dart';

/// BLOCK 15 (CORRECTED): Poojari Shell + Bottom Navigation
///
/// Mirrors Customer's AppShell (lib/customer/shell/app_shell.dart) with:
/// - Same 4-tab IndexedStack mechanism preserving tab state across switches
/// - Same GlassBottomNav floating navigation bar
/// - Profile is NOT a bottom tab; it lives in the header (reached via profile icon)
/// - Exact 4 tabs in specified order:
///     0. Dashboard        Icons.dashboard_rounded     (Block 3)
///     1. Assigned Poojas  Icons.assignment_turned_in  (Block 6)
///     2. Schedule         Icons.event_note            (Block 10)
///     3. Earnings         Icons.payments_outlined     (Block 12)
/// - Tab 1 (Assigned Poojas) displays a reactive red count badge for bookings
///   in 'New' status (reading controller.newAssignmentsCount), hidden at 0.
/// - Shell-level VerificationPendingBanner rendered once across all 4 tabs
///   when poojariStatus != verified (duplicate instances removed from screens).
/// - "🪔 Poojari Mode" badge: Dashboard header only.
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
    final session = SessionScope.maybeOf(context) ?? SessionService.instance;
    final controller =
        PoojariControllerScope.maybeOf(context) ?? PoojariController.instance;

    return ListenableBuilder(
      listenable: Listenable.merge([session, controller]),
      builder: (context, _) {
        final user = session.currentUser;
        final showVerificationBanner =
            user == null || user.poojariStatus != PoojariVerificationStatus.verified;
        final newCount = controller.newAssignmentsCount;

        final pages = [
          PoojariDashboardScreen(
            onSwitchToCustomer: widget.onSwitchToCustomer,
            onLogout: widget.onLogout,
          ),
          AssignedPoojasScreen(
            onSwitchToCustomer: widget.onSwitchToCustomer,
            onLogout: widget.onLogout,
          ),
          PoojariScheduleScreen(
            onSwitchToCustomer: widget.onSwitchToCustomer,
            onLogout: widget.onLogout,
          ),
          EarningsScreen(
            onSwitchToCustomer: widget.onSwitchToCustomer,
            onLogout: widget.onLogout,
          ),
        ];

        return Scaffold(
          backgroundColor: AppColors.background,
          body: Stack(
            children: [
              // Main tab contents with shell-level verification banner
              Positioned.fill(
                child: Column(
                  children: [
                    if (showVerificationBanner)
                      const SafeArea(
                        bottom: false,
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          child: VerificationPendingBanner(),
                        ),
                      ),
                    Expanded(
                      child: IndexedStack(
                        index: _currentIndex,
                        children: pages,
                      ),
                    ),
                  ],
                ),
              ),

              // Bottom Nav Bar with reactive red badge on Assigned Poojas tab (index 1)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: PoojariBottomNav(
                  currentIndex: _currentIndex,
                  onTap: _goToTab,
                  newAssignmentsCount: newCount,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
