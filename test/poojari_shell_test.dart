import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_puja/core/models/user_account.dart';
import 'package:pocket_puja/core/services/poojari_controller.dart';
import 'package:pocket_puja/core/services/session_service.dart';
import 'package:pocket_puja/core/theme/app_theme.dart';
import 'package:pocket_puja/core/widgets/glass.dart';
import 'package:pocket_puja/core/widgets/verification_banner.dart';
import 'package:pocket_puja/poojari/screens/dashboard/poojari_dashboard_screen.dart';
import 'package:pocket_puja/poojari/screens/earnings/earnings_screen.dart';
import 'package:pocket_puja/poojari/screens/profile/poojari_profile_screen.dart';
import 'package:pocket_puja/poojari/screens/requests/assigned_poojas_screen.dart';
import 'package:pocket_puja/poojari/screens/schedule/poojari_schedule_screen.dart';
import 'package:pocket_puja/poojari/shell/poojari_shell.dart';

void main() {
  group('BLOCK 15 (CORRECTED): Poojari Shell + Bottom Navigation Tests', () {
    late SessionService session;
    late PoojariController controller;

    setUp(() {
      session = SessionService.instance;
      controller = PoojariController.instance;
      controller.reset();
    });

    testWidgets('Renders exact 4 tabs and GlassBottomNav with correct icons in order, Profile is NOT a tab', (tester) async {
      tester.view.physicalSize = const Size(800, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      session.loginWithMobile('+919988776655'); // Verified poojari

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.theme,
          home: PoojariShell(
            onLogout: () {},
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      // Confirm GlassBottomNav exists with 4 icons
      final bottomNavFinder = find.byType(GlassBottomNav);
      expect(bottomNavFinder, findsOneWidget);
      final bottomNav = tester.widget<GlassBottomNav>(bottomNavFinder);
      expect(bottomNav.icons, equals([
        Icons.dashboard_rounded,
        Icons.assignment_turned_in,
        Icons.event_note,
        Icons.payments_outlined,
      ]));

      // Confirm the 4 screens exist in IndexedStack
      expect(find.byType(PoojariDashboardScreen, skipOffstage: false), findsOneWidget);
      expect(find.byType(AssignedPoojasScreen, skipOffstage: false), findsOneWidget);
      expect(find.byType(PoojariScheduleScreen, skipOffstage: false), findsOneWidget);
      expect(find.byType(EarningsScreen, skipOffstage: false), findsOneWidget);

      // Confirm Profile is NOT in IndexedStack (it lives in the header)
      expect(find.byType(PoojariProfileScreen, skipOffstage: false), findsNothing);

      // Confirm default tab is Dashboard (tab 0)
      expect(find.text("TODAY'S ASSIGNMENT"), findsOneWidget);
    });

    testWidgets('Tapping bottom nav icons switches between the 4 active tabs', (tester) async {
      tester.view.physicalSize = const Size(800, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      session.loginWithMobile('+919988776655'); // Verified poojari

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.theme,
          home: PoojariShell(
            onLogout: () {},
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      // Tap Tab 1: Assigned Poojas (Icons.assignment_turned_in)
      await tester.tap(find.byIcon(Icons.assignment_turned_in));
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('Assigned Poojas'), findsOneWidget);

      // Tap Tab 2: Schedule (Icons.event_note)
      await tester.tap(find.byIcon(Icons.event_note));
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('My Schedule'), findsOneWidget);

      // Tap Tab 3: Earnings (Icons.payments_outlined)
      await tester.tap(find.byIcon(Icons.payments_outlined));
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('Dakshina Ledger'), findsOneWidget);

      // Tap Tab 0: Dashboard (Icons.dashboard_rounded)
      await tester.tap(find.byIcon(Icons.dashboard_rounded));
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text("TODAY'S ASSIGNMENT"), findsOneWidget);
    });

    testWidgets('Tapping profile icon in header pushes PoojariProfileScreen', (tester) async {
      tester.view.physicalSize = const Size(800, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      session.loginWithMobile('+919988776655');

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.theme,
          home: PoojariShell(
            onLogout: () {},
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      // Find profile icon button in Dashboard header
      final profileIcon = find.descendant(
        of: find.byType(PoojariDashboardScreen),
        matching: find.byTooltip('Profile'),
      );
      expect(profileIcon, findsOneWidget);

      await tester.tap(profileIcon);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Successfully pushed PoojariProfileScreen
      expect(find.byType(PoojariProfileScreen), findsOneWidget);
      expect(find.text('PROFESSIONAL CREDENTIALS'), findsOneWidget);
      // Pushed screen has back arrow
      expect(find.byIcon(Icons.arrow_back_ios_new), findsOneWidget);
    });

    testWidgets('Assigned Poojas tab shows live badge count and hides when zero', (tester) async {
      tester.view.physicalSize = const Size(800, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      session.loginWithMobile('+919988776655');

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.theme,
          home: PoojariShell(
            onLogout: () {},
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      // Controller starts with 2 new assignments
      expect(controller.newAssignmentsCount, equals(2));
      expect(find.text('2'), findsWidgets);

      // Confirm all new bookings to reduce count to 0
      final newBookings = controller.allBookings.where((b) => b.isNew).toList();
      for (final b in newBookings) {
        controller.confirmReceipt(b.ref);
      }
      await tester.pump(const Duration(milliseconds: 100));

      expect(controller.newAssignmentsCount, equals(0));
      // Badge count should no longer show 2
      expect(find.text('2'), findsNothing);
    });

    testWidgets('VerificationPendingBanner renders once in shell when under review across all 4 tabs', (tester) async {
      tester.view.physicalSize = const Size(800, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      // Log in under-review poojari
      session.loginWithMobile('+919123456780');

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.theme,
          home: PoojariShell(
            onLogout: () {},
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      // Exactly ONE VerificationPendingBanner rendered at shell level on Dashboard tab
      expect(find.byType(VerificationPendingBanner), findsOneWidget);

      // Switch to Tab 1: Assigned Poojas
      await tester.tap(find.byIcon(Icons.assignment_turned_in));
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(VerificationPendingBanner), findsOneWidget);

      // Switch to Tab 2: Schedule
      await tester.tap(find.byIcon(Icons.event_note));
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(VerificationPendingBanner), findsOneWidget);

      // Switch to Tab 3: Earnings
      await tester.tap(find.byIcon(Icons.payments_outlined));
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(VerificationPendingBanner), findsOneWidget);

      // When status becomes verified, banner disappears
      session.updatePoojariStatus(PoojariVerificationStatus.verified);
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(VerificationPendingBanner), findsNothing);
    });
  });
}
