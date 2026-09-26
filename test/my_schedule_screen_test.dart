import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_puja/core/services/poojari_controller.dart';
import 'package:pocket_puja/core/widgets/glass.dart';
import 'package:pocket_puja/poojari/screens/booking_detail/poojari_booking_detail_screen.dart';
import 'package:pocket_puja/poojari/screens/schedule/my_schedule_screen.dart';
import 'package:pocket_puja/poojari/widgets/booking/poojari_assignment_card.dart';

void main() {
  setUp(() {
    PoojariController.instance.reset();
  });

  group('BLOCK 10: My Schedule Screen Tests', () {
    Finder tabFinder(String text) => find.widgetWithText(GestureDetector, text).first;

    testWidgets('MyScheduleScreen renders tabs with exact Block 6 vocabulary', (tester) async {
      tester.view.physicalSize = const Size(800, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const MaterialApp(
          home: MyScheduleScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Confirm header
      expect(find.text('My Schedule'), findsOneWidget);

      // Confirm exact tab labels exist in the tab bar
      expect(tabFinder('All'), findsOneWidget);
      expect(tabFinder('Upcoming'), findsOneWidget);
      expect(tabFinder('Done'), findsOneWidget);
      expect(tabFinder('Cancelled'), findsOneWidget);
    });

    testWidgets('MyScheduleScreen groups bookings under SectionLabel date headers', (tester) async {
      tester.view.physicalSize = const Size(800, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const MaterialApp(
          home: MyScheduleScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Check for SectionLabel date headers
      expect(find.byType(SectionLabel), findsWidgets);
      expect(find.text('TODAY'), findsOneWidget);
      expect(find.text('TOMORROW'), findsOneWidget);

      // Verify assignment cards are rendered
      expect(find.byType(PoojariAssignmentCard), findsWidgets);
      expect(find.textContaining('Ganesha Pooja'), findsOneWidget);
      expect(find.textContaining('Satyanarayana Vratam'), findsOneWidget);
    });

    testWidgets('Switching to Done tab displays only completed bookings grouped appropriately', (tester) async {
      tester.view.physicalSize = const Size(800, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const MaterialApp(
          home: MyScheduleScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Tap on 'Done' tab specifically
      await tester.tap(tabFinder('Done'));
      await tester.pumpAndSettle();

      // 'Gruhapravesham' is completed with date 'Yesterday'
      expect(find.text('YESTERDAY'), findsOneWidget);
      expect(find.textContaining('Gruhapravesham'), findsOneWidget);

      // Active bookings like 'Ganesha Pooja' should NOT appear here
      expect(find.textContaining('Ganesha Pooja'), findsNothing);
    });

    testWidgets('Switching to Cancelled tab displays cancelled bookings', (tester) async {
      tester.view.physicalSize = const Size(800, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const MaterialApp(
          home: MyScheduleScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Tap on 'Cancelled' tab specifically
      await tester.tap(tabFinder('Cancelled'));
      await tester.pumpAndSettle();

      // 'Vastu Shanti' is seeded as Cancelled
      expect(find.textContaining('Vastu Shanti'), findsOneWidget);
      expect(find.text('EARLIER'), findsOneWidget);
    });

    testWidgets('Tapping on a card opens PoojariBookingDetailScreen', (tester) async {
      tester.view.physicalSize = const Size(800, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const MaterialApp(
          home: MyScheduleScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Tap on first card
      await tester.tap(find.byType(PoojariAssignmentCard).first);
      await tester.pumpAndSettle();

      // Must have navigated to PoojariBookingDetailScreen
      expect(find.byType(PoojariBookingDetailScreen), findsOneWidget);
      expect(find.text('Booking Detail'), findsOneWidget);
    });
  });
}
