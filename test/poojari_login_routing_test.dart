import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_puja/app.dart';
import 'package:pocket_puja/core/models/user_account.dart';
import 'package:pocket_puja/core/services/session_service.dart';
import 'package:pocket_puja/core/services/poojari_controller.dart';
import 'package:pocket_puja/customer/shell/customer_shell.dart';
import 'package:pocket_puja/poojari/screens/dashboard/poojari_dashboard_screen.dart';
import 'package:pocket_puja/poojari/screens/profile/poojari_profile_screen.dart';
import 'package:pocket_puja/poojari/shell/poojari_shell.dart';
import 'package:pocket_puja/shared/auth/mobile_number_screen.dart';
import 'package:pocket_puja/shared/auth/otp_verification_screen.dart';
import 'package:pocket_puja/customer/screens/profile/profile_screen.dart';

void main() {
  group('BUGFIX VERIFICATION: Poojari Login Routing After Logout + Re-login', () {
    testWidgets('Executes exact 8-step user verification sequence', (tester) async {
      tester.view.physicalSize = const Size(800, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      // Reset session service before start
      final session = SessionService.instance;
      session.logout();

      // =======================================================================
      // STEP 1: Launch → Login screen appears
      // =======================================================================
      await tester.pumpWidget(const PocketPujaApp());
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(MobileNumberScreen), findsOneWidget);
      expect(session.isLoggedIn, isFalse);
      expect(session.currentRole, isNull);
      debugPrint('[STEP 1 PASS] Launch -> Login screen appears, session role is null.');

      // Helper for logging in with Poojari number
      Future<void> loginAsPoojari() async {
        // Tap Poojari demo pill ("🪔 Poojari Login")
        final poojariPill = find.text('🪔 Poojari Login');
        expect(poojariPill, findsOneWidget);
        await tester.tap(poojariPill);
        await tester.pump();

        // Tap "SEND OTP"
        final sendOtpBtn = find.text('SEND OTP');
        expect(sendOtpBtn, findsOneWidget);
        await tester.tap(sendOtpBtn);
        await tester.pump();

        // Advance 600ms for delay in _handleSendOTP and 400ms for route push
        await tester.pump(const Duration(milliseconds: 700));
        await tester.pump(const Duration(milliseconds: 400));

        // Expect OTP verification screen
        expect(find.byType(OTPVerificationScreen), findsOneWidget);

        // Tap dummy OTP pill ("Prototype Auto-Fill: 123456")
        final dummyPill = find.text('Prototype Auto-Fill: 123456');
        expect(dummyPill, findsOneWidget);
        await tester.tap(dummyPill);
        await tester.pump();

        // Advance 500ms for verify delay and 400ms for route push
        await tester.pump(const Duration(milliseconds: 600));
        await tester.pump(const Duration(milliseconds: 400));
      }

      // Helper for logging out from Poojari side
      Future<void> logoutFromPoojari() async {
        // Tap Profile icon in Dashboard header
        final profileIcon = find.descendant(
          of: find.byType(PoojariDashboardScreen),
          matching: find.byTooltip('Profile'),
        );
        expect(profileIcon, findsOneWidget);
        await tester.tap(profileIcon);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        // Expect PoojariProfileScreen
        expect(find.byType(PoojariProfileScreen), findsOneWidget);

        // Tap Sign Out
        final signOutBtn = find.text('Sign Out');
        expect(signOutBtn, findsOneWidget);
        await tester.tap(signOutBtn);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));
      }

      // =======================================================================
      // STEP 2: Login with the POOJARI number + OTP → expect PoojariShell / Dashboard
      // =======================================================================
      await loginAsPoojari();

      expect(find.byType(PoojariShell), findsOneWidget);
      expect(find.byType(PoojariDashboardScreen), findsOneWidget);
      expect(find.byType(AppShell), findsNothing);
      expect(session.isLoggedIn, isTrue);
      expect(session.currentRole, equals(AppRole.poojari));
      expect(session.currentUser?.fullName, equals('Shri Venkata Ramana'));
      debugPrint('[STEP 2 PASS] Login with POOJARI number -> lands on PoojariShell / Dashboard.');

      // =======================================================================
      // STEP 3: Profile icon → Sign Out → expect Login screen; back button must not return into the app
      // =======================================================================
      await logoutFromPoojari();

      expect(find.byType(MobileNumberScreen), findsOneWidget);
      expect(find.byType(PoojariShell), findsNothing);
      expect(find.byType(AppShell), findsNothing);
      expect(session.isLoggedIn, isFalse);
      expect(session.currentRole, isNull);

      // Verify cannot back into the app
      final canPop = await tester.binding.handlePopRoute();
      expect(canPop, isFalse);
      expect(find.byType(MobileNumberScreen), findsOneWidget);
      debugPrint('[STEP 3 PASS] Profile -> Sign Out -> Login screen; back button does not return to app.');

      // =======================================================================
      // STEP 4: Login again with the SAME Poojari number → expect PoojariShell / Dashboard
      // =======================================================================
      await loginAsPoojari();

      expect(find.byType(PoojariShell), findsOneWidget);
      expect(find.byType(PoojariDashboardScreen), findsOneWidget);
      expect(find.byType(AppShell), findsNothing);
      expect(session.isLoggedIn, isTrue);
      expect(session.currentRole, equals(AppRole.poojari));
      expect(session.currentUser?.fullName, equals('Shri Venkata Ramana'));
      debugPrint('[STEP 4 PASS] Re-login with SAME Poojari number -> correctly lands on PoojariShell / Dashboard.');

      // =======================================================================
      // STEP 5: Sign Out → login with the CUSTOMER number → expect Customer Home
      // =======================================================================
      await logoutFromPoojari();

      expect(find.byType(MobileNumberScreen), findsOneWidget);

      // Tap Customer demo pill ("👤 Customer Login")
      final customerPill = find.text('👤 Customer Login');
      expect(customerPill, findsOneWidget);
      await tester.tap(customerPill);
      await tester.pump();

      // Tap SEND OTP
      await tester.tap(find.text('SEND OTP'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 700));
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.byType(OTPVerificationScreen), findsOneWidget);

      // Tap dummy OTP pill
      await tester.tap(find.text('Prototype Auto-Fill: 123456'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pump(const Duration(milliseconds: 400));

      // Expect Customer AppShell
      expect(find.byType(AppShell), findsOneWidget);
      expect(find.byType(PoojariShell), findsNothing);
      expect(session.isLoggedIn, isTrue);
      expect(session.currentRole, equals(AppRole.customer));
      expect(session.currentUser?.fullName, equals('Sai Kiran Sharma'));
      debugPrint('[STEP 5 PASS] Sign Out -> login with CUSTOMER number -> lands on Customer Home (AppShell).');

      // =======================================================================
      // STEP 6: Sign Out → login with the POOJARI number → expect PoojariShell
      // =======================================================================
      // Open Profile from Customer AppShell
      final custProfileIcon = find.byIcon(Icons.account_circle_outlined).first;
      await tester.tap(custProfileIcon);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(ProfileScreen), findsOneWidget);

      // Tap Sign Out in Customer Profile
      await tester.tap(find.text('Sign Out'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(MobileNumberScreen), findsOneWidget);

      // Login with Poojari number again
      await loginAsPoojari();

      expect(find.byType(PoojariShell), findsOneWidget);
      expect(find.byType(PoojariDashboardScreen), findsOneWidget);
      expect(find.byType(AppShell), findsNothing);
      expect(session.isLoggedIn, isTrue);
      expect(session.currentRole, equals(AppRole.poojari));
      debugPrint('[STEP 6 PASS] Sign Out -> login with POOJARI number -> lands on PoojariShell.');

      // =======================================================================
      // STEP 7: Repeat steps 2-4 once more (Poojari → logout → Poojari) to confirm stability
      // =======================================================================
      await logoutFromPoojari();
      expect(find.byType(MobileNumberScreen), findsOneWidget);

      await loginAsPoojari();
      expect(find.byType(PoojariShell), findsOneWidget);
      expect(find.byType(PoojariDashboardScreen), findsOneWidget);
      expect(find.byType(AppShell), findsNothing);
      expect(session.isLoggedIn, isTrue);
      expect(session.currentRole, equals(AppRole.poojari));
      debugPrint('[STEP 7 PASS] Repeated Poojari -> logout -> Poojari cycle confirms routing stability.');

      // =======================================================================
      // STEP 8: Verify Poojari's data (stats, bookings, verification banner) still shows correctly
      // =======================================================================
      final poojariController = PoojariController.instance;

      // Header greeting shows Poojari's name
      expect(find.textContaining('Shri Venkata Ramana'), findsOneWidget);

      // Poojari status is verified
      expect(session.currentUser?.poojariStatus, equals(PoojariVerificationStatus.verified));

      // Stats KPI values render
      expect(find.text('${poojariController.poojasCompleted}'), findsWidgets);
      expect(find.text('${poojariController.pendingAssignmentsCount}'), findsWidgets);

      // Verified account does not show verification pending banner
      expect(find.text('ACCOUNT UNDER REVIEW'), findsNothing);
      debugPrint("[STEP 8 PASS] Poojari's data (stats, name, verified status) verified intact after re-login.");
    });
  });
}
