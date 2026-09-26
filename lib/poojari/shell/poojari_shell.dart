import 'package:flutter/material.dart';
import 'package:pocket_puja/core/models/user_account.dart';
import 'package:pocket_puja/core/services/session_service.dart';
import 'package:pocket_puja/core/theme/app_theme.dart';
import 'package:pocket_puja/core/widgets/glass.dart';
import 'package:pocket_puja/core/widgets/verification_banner.dart';
import 'package:pocket_puja/poojari/screens/dashboard/poojari_dashboard_screen.dart';
import 'package:pocket_puja/poojari/screens/under_construction_screen.dart';

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

    final pages = [
      PoojariDashboardScreen(
        onSwitchToCustomer: widget.onSwitchToCustomer,
      ),
      PoojariUnderConstructionScreen(
        title: 'Booking Requests',
        subtitle:
            'Incoming devotee puja requests, samagri verification, and accept/decline flows.',
        icon: Icons.assignment_turned_in_rounded,
        onSwitchToCustomer: widget.onSwitchToCustomer,
      ),
      PoojariUnderConstructionScreen(
        title: 'Puja Schedule & Calendar',
        subtitle:
            'Daily & monthly ritual schedule, panchangam alignment, and devotee locations.',
        icon: Icons.calendar_month_rounded,
        onSwitchToCustomer: widget.onSwitchToCustomer,
      ),
      PoojariUnderConstructionScreen(
        title: 'Earnings & Dakshina',
        subtitle: 'Dakshina payouts, transaction history, and settlement ledger.',
        icon: Icons.account_balance_wallet_rounded,
        onSwitchToCustomer: widget.onSwitchToCustomer,
      ),
      PoojariUnderConstructionScreen(
        title: 'Poojari Profile & Vedic Credentials',
        subtitle: 'Veda shakha verification, temple affiliations, languages, and settings.',
        icon: Icons.person_pin_rounded,
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
              padding: EdgeInsets.only(top: showVerificationBanner ? 54 : 0),
              child: IndexedStack(
                index: _currentIndex,
                children: pages,
              ),
            ),
          ),

          // Persistent Verification Banner at the top if status != verified
          if (showVerificationBanner)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: VerificationPendingBanner(
                    message: "🕒 Verification pending — you'll be notified once approved",
                  ),
                ),
              ),
            ),

          // Bottom Nav Bar
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: GlassBottomNav(
              currentIndex: _currentIndex,
              onTap: _goToTab,
              icons: const [
                Icons.dashboard_rounded,
                Icons.assignment_turned_in_rounded,
                Icons.calendar_month_rounded,
                Icons.account_balance_wallet_rounded,
                Icons.person_pin_rounded,
              ],
            ),
          ),
        ],
      ),
    );
  }
}
