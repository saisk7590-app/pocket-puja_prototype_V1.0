import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_puja/core/services/poojari_controller.dart';
import 'package:pocket_puja/core/services/session_service.dart';
import 'package:pocket_puja/core/theme/app_theme.dart';
import 'package:pocket_puja/core/widgets/glass.dart';
import 'package:pocket_puja/core/widgets/poojari_mode_badge.dart';
import 'package:pocket_puja/shared/widgets/profile/addresses_screen.dart';
import 'package:pocket_puja/shared/widgets/profile/notification_preferences_screen.dart';
import 'package:pocket_puja/poojari/screens/profile/poojari_profile_screen.dart';
import 'package:pocket_puja/poojari/screens/reviews/reviews_received_screen.dart';
import 'package:pocket_puja/poojari/widgets/profile/poojari_identity_header.dart';
import 'package:pocket_puja/poojari/widgets/profile/professional_info_card.dart';

void main() {
  group('BLOCK 14: Poojari Profile Screen Widget Tests', () {
    setUp(() {
      PoojariController.instance.reset();
      // Ensure user is logged in as preseeded verified Poojari
      final session = SessionService.instance;
      session.loginWithMobile('+919988776655');
    });

    testWidgets('Renders all 10 sections top to bottom and omits Customer-only rows', (tester) async {
      tester.view.physicalSize = const Size(800, 3200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.theme,
          home: PoojariProfileScreen(
            onLogout: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      // 1. Identity Header
      expect(find.byType(PoojariIdentityHeader), findsOneWidget);
      expect(find.text('Shri Venkata Ramana'), findsOneWidget);
      expect(find.text('Hyderabad · 15km Radius'), findsOneWidget);
      expect(find.text('Verified ✓'), findsWidgets);
      expect(find.byType(PoojariModeBadge), findsNothing);

      // 2. Professional Credentials (Poojari-only)
      expect(find.text('PROFESSIONAL CREDENTIALS'), findsOneWidget);
      expect(find.byType(ProfessionalInfoCard), findsOneWidget);
      expect(find.text('Satyanarayana Vratam'), findsOneWidget);
      expect(find.text('Gruhapravesham'), findsOneWidget);
      expect(find.text('Ganesha Pooja'), findsOneWidget);
      expect(
        find.text('Contact Support to update your specializations.'),
        findsOneWidget,
      );

      // 3. Performance
      final controller = PoojariController.instance;
      expect(find.text('PERFORMANCE'), findsOneWidget);
      expect(find.text('Reviews & Ratings'), findsOneWidget);
      expect(
        find.text('${controller.rating} ★ · ${controller.totalReviewCount} devotee reviews'),
        findsOneWidget,
      );
      expect(find.text('Poojas Completed'), findsOneWidget);
      expect(
        find.text('${controller.poojasCompleted} Vedic rituals completed'),
        findsOneWidget,
      );

      // 4. Personal Info
      expect(find.text('PERSONAL INFO'), findsOneWidget);
      expect(find.text('Personal Info'), findsOneWidget);

      // 5. Service Locations
      expect(find.text('SERVICE LOCATIONS'), findsOneWidget);
      expect(find.text('Service Locations'), findsOneWidget);

      // 6. Preferences
      expect(find.text('PREFERENCES'), findsOneWidget);
      expect(find.text('App Language'), findsOneWidget);
      expect(find.text('Theme'), findsOneWidget);
      expect(find.text('Notification Preferences'), findsOneWidget);

      // 7 & 8. Support & About
      expect(find.text('SUPPORT & ABOUT'), findsOneWidget);
      expect(find.text('Support'), findsOneWidget);
      expect(find.text('About'), findsOneWidget);

      // 9. Sign Out
      expect(find.byType(DestructiveButton), findsOneWidget);
      expect(find.text('Sign Out'), findsOneWidget);

      // EXPLICITLY ABSENT:
      expect(find.text('Manage Availability'), findsNothing);
      expect(find.text('My Orders'), findsNothing);
      expect(find.text('Subscription'), findsNothing);
      expect(find.text('Free Plan'), findsNothing);
      expect(find.text('Premium'), findsNothing);
    });

    testWidgets('Tapping Reviews row navigates to ReviewsReceivedScreen', (tester) async {
      tester.view.physicalSize = const Size(800, 3200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.theme,
          home: PoojariProfileScreen(onLogout: () {}),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Reviews & Ratings'));
      await tester.pumpAndSettle();

      expect(find.byType(ReviewsReceivedScreen), findsOneWidget);
    });

    testWidgets('Tapping Service Locations navigates to AddressesScreen with parameterized title', (tester) async {
      tester.view.physicalSize = const Size(800, 3200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.theme,
          home: PoojariProfileScreen(onLogout: () {}),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Service Locations'));
      await tester.pumpAndSettle();

      expect(find.byType(AddressesScreen), findsOneWidget);
      expect(find.text('Service Locations'), findsWidgets);
    });

    testWidgets('Tapping Notification Preferences navigates with 4 Poojari categories', (tester) async {
      tester.view.physicalSize = const Size(800, 3200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.theme,
          home: PoojariProfileScreen(onLogout: () {}),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Notification Preferences'));
      await tester.pumpAndSettle();

      expect(find.byType(NotificationPreferencesScreen), findsOneWidget);
      expect(find.text('New Assignments'), findsOneWidget);
      expect(find.text('Schedule Changes'), findsOneWidget);
      expect(find.text('Reviews & Ratings'), findsOneWidget);
      expect(find.text('Earnings & Settlements'), findsOneWidget);
    });

    testWidgets('Tapping Sign Out invokes logout and onLogout callback', (tester) async {
      tester.view.physicalSize = const Size(800, 3200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      bool loggedOutCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.theme,
          home: PoojariProfileScreen(
            onLogout: () => loggedOutCalled = true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(SessionService.instance.isLoggedIn, isTrue);

      await tester.tap(find.text('Sign Out'));
      await tester.pumpAndSettle();

      expect(loggedOutCalled, isTrue);
      expect(SessionService.instance.isLoggedIn, isFalse);
    });
  });
}
