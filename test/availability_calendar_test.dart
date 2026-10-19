import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_puja/core/services/poojari_controller.dart';
import 'package:pocket_puja/core/theme/app_theme.dart';
import 'package:pocket_puja/poojari/screens/availability/availability_calendar_screen.dart';
import 'package:pocket_puja/poojari/screens/booking_detail/poojari_booking_detail_screen.dart';
import 'package:pocket_puja/poojari/widgets/availability/availability_day_cell.dart';
import 'package:pocket_puja/poojari/widgets/availability/availability_legend.dart';
import 'package:pocket_puja/poojari/widgets/availability/recurring_day_off_sheet.dart';

void main() {
  group('BLOCK 11: Poojari Availability Controller Unit Tests', () {
    late PoojariController controller;

    setUp(() {
      controller = PoojariController.instance;
      controller.reset();
    });

    test('Precedence 1: Past dates are non-interactive and return past state', () {
      final now = DateTime.now();
      final pastDate = DateTime(now.year, now.month, now.day - 5);

      expect(controller.availabilityStateFor(pastDate), DayAvailabilityState.past);
      final toggled = controller.toggleDateBlock(pastDate);
      expect(toggled, false);
      expect(controller.manuallyBlockedDates.contains(pastDate), false);
    });

    test('Precedence 2: Booked date auto-locks, cannot be manually blocked, and wins over recurring off', () {
      final now = DateTime.now();
      final tomorrow = DateTime(now.year, now.month, now.day + 1);

      // Tomorrow has Satyanarayana Vratam (CONFIRMED)
      expect(controller.hasActiveBookingOn(tomorrow), true);
      expect(controller.availabilityStateFor(tomorrow), DayAvailabilityState.booked);

      // Cannot block a date that already has a confirmed booking
      final toggled = controller.toggleDateBlock(tomorrow);
      expect(toggled, false);
      expect(controller.availabilityStateFor(tomorrow), DayAvailabilityState.booked);

      // Booked wins over recurring off-day
      controller.setRecurringOffWeekdays({tomorrow.weekday});
      expect(controller.availabilityStateFor(tomorrow), DayAvailabilityState.booked);
    });

    test('Precedence 3 & 4: Recurring off-day pattern and manual blocks', () {
      final now = DateTime.now();
      // Pick a future date that is NOT tomorrow (e.g. 10 days out)
      final futureDate = DateTime(now.year, now.month, now.day + 10);

      // Initially available
      expect(controller.availabilityStateFor(futureDate), DayAvailabilityState.available);

      // Tap to block
      final blocked = controller.toggleDateBlock(futureDate);
      expect(blocked, true);
      expect(controller.availabilityStateFor(futureDate), DayAvailabilityState.blockedByMe);

      // Tap to unblock
      final unblocked = controller.toggleDateBlock(futureDate);
      expect(unblocked, true);
      expect(controller.availabilityStateFor(futureDate), DayAvailabilityState.available);

      // Set recurring off-day for futureDate's weekday
      controller.setRecurringOffWeekdays({futureDate.weekday});
      expect(controller.availabilityStateFor(futureDate), DayAvailabilityState.recurringOff);

      // Single tap on recurring off does not toggle
      final recurToggle = controller.toggleDateBlock(futureDate);
      expect(recurToggle, false);
      expect(controller.availabilityStateFor(futureDate), DayAvailabilityState.recurringOff);

      // Clearing recurring weekday restores state
      controller.clearRecurringOffWeekdays();
      expect(controller.availabilityStateFor(futureDate), DayAvailabilityState.available);
    });

    test('Dashboard nudge check: isCalendarFullyOpenNext7Days behaves correctly', () {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      // Fresh state: fully open next 7 days
      expect(controller.isCalendarFullyOpenNext7Days, true);
      expect(controller.showAvailabilityNudge, true);

      // Block a date within next 7 days (e.g. 3 days from now)
      final nearDate = today.add(const Duration(days: 3));
      controller.toggleDateBlock(nearDate);

      expect(controller.isCalendarFullyOpenNext7Days, false);
      expect(controller.showAvailabilityNudge, false);

      // Unblock it
      controller.toggleDateBlock(nearDate);
      expect(controller.isCalendarFullyOpenNext7Days, true);
      expect(controller.showAvailabilityNudge, true);

      // Set recurring day off that falls in next 7 days
      controller.setRecurringOffWeekdays({nearDate.weekday});
      expect(controller.isCalendarFullyOpenNext7Days, false);
      expect(controller.showAvailabilityNudge, false);

      // Dismiss nudge
      controller.clearRecurringOffWeekdays();
      expect(controller.showAvailabilityNudge, true);
      controller.dismissAvailabilityNudge();
      expect(controller.showAvailabilityNudge, false);
    });

    test('Mock assignment check: canAcceptAssignmentOn and assignBookingIfAvailable', () {
      final now = DateTime.now();
      final pastDate = DateTime(now.year, now.month, now.day - 2);
      final openDate = DateTime(now.year, now.month, now.day + 12);

      expect(controller.canAcceptAssignmentOn(pastDate), false);
      expect(controller.canAcceptAssignmentOn(openDate), true);

      // Block openDate
      controller.toggleDateBlock(openDate);
      expect(controller.canAcceptAssignmentOn(openDate), false);

      const testBooking = PoojariBooking(
        ref: 'PP-TEST-1234',
        poojaName: 'Ganapati Homa',
        status: 'NEW',
        date: 'Future',
        scheduledTime: '10:00 AM',
        feePaise: 150000,
        fullAddress: 'Test Address',
        customerPhone: '+91 99999 88888',
      );

      final failedAssign = controller.assignBookingIfAvailable(testBooking, openDate);
      expect(failedAssign, false);

      controller.toggleDateBlock(openDate); // Unblock
      final successAssign = controller.assignBookingIfAvailable(testBooking, openDate);
      expect(successAssign, true);
      expect(controller.getBookingByRef('PP-TEST-1234'), isNotNull);
    });
  });

  group('BLOCK 11: Availability Calendar Widget Tests', () {
    late PoojariController controller;

    setUp(() {
      controller = PoojariController.instance;
      controller.reset();
    });

    Widget createTestWidget() {
      return MaterialApp(
        theme: AppTheme.theme,
        home: PoojariControllerScope(
          controller: controller,
          child: const AvailabilityCalendarScreen(showBack: false),
        ),
      );
    }

    testWidgets('AvailabilityCalendarScreen renders MonthGrid, legend, recurring section and header',
        (tester) async {
      tester.view.physicalSize = const Size(800, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Availability Calendar'), findsOneWidget);
      expect(find.text('Declare Your Availability'), findsOneWidget);
      expect(find.text('Recurring Days Off'), findsOneWidget);
      expect(find.byType(AvailabilityLegend), findsOneWidget);
      expect(find.text('Available'), findsOneWidget);
      expect(find.text('Blocked by me'), findsOneWidget);
      expect(find.text('Booked'), findsOneWidget);
      expect(find.text('Recurring off-day'), findsOneWidget);
    });

    testWidgets('Tapping an Available date blocks it, and tapping again unblocks it',
        (tester) async {
      tester.view.physicalSize = const Size(800, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final availableCells = find.byWidgetPredicate(
        (w) => w is AvailabilityDayCell && w.state == DayAvailabilityState.available,
      );
      expect(availableCells, findsWidgets);

      final targetCell = tester.widget<AvailabilityDayCell>(availableCells.first);
      final targetDate = targetCell.date;

      // Tap to block
      await tester.tap(availableCells.first);
      await tester.pumpAndSettle();

      expect(controller.availabilityStateFor(targetDate), DayAvailabilityState.blockedByMe);

      // Tap again to unblock
      final blockedCell = find.byWidgetPredicate(
        (w) => w is AvailabilityDayCell && w.date == targetDate && w.state == DayAvailabilityState.blockedByMe,
      );
      expect(blockedCell, findsOneWidget);

      await tester.tap(blockedCell);
      await tester.pumpAndSettle();

      expect(controller.availabilityStateFor(targetDate), DayAvailabilityState.available);
    });

    testWidgets('Tapping a Booked date shows SnackBar with "View details" linking to booking detail',
        (tester) async {
      tester.view.physicalSize = const Size(800, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Find booked cell
      final bookedCells = find.byWidgetPredicate(
        (w) => w is AvailabilityDayCell && w.state == DayAvailabilityState.booked,
      );
      expect(bookedCells, findsWidgets);

      await tester.tap(bookedCells.first);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.textContaining('Booked:'), findsOneWidget);
      expect(find.text('View details'), findsOneWidget);

      // Tapping "View details" navigates to PoojariBookingDetailScreen
      await tester.tap(find.text('View details'));
      await tester.pumpAndSettle();

      expect(find.byType(PoojariBookingDetailScreen), findsOneWidget);
    });

    testWidgets('Tapping "Configure" opens RecurringDayOffSheet with FilterChips and saves pattern',
        (tester) async {
      tester.view.physicalSize = const Size(800, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Tap Configure
      final configureBtn = find.text('Configure');
      expect(configureBtn, findsOneWidget);
      await tester.tap(configureBtn);
      await tester.pumpAndSettle();

      expect(find.byType(RecurringDayOffSheet), findsOneWidget);
      expect(find.text('Set Recurring Day Off'), findsOneWidget);
      expect(find.text('Mon'), findsOneWidget);
      expect(find.text('Sun'), findsOneWidget);

      // Tap 'Mon' chip
      await tester.tap(find.text('Mon'));
      await tester.pumpAndSettle();

      // Tap Save Pattern
      await tester.tap(find.text('Save Pattern'));
      await tester.pumpAndSettle();

      // Recurring pattern updated
      expect(controller.recurringOffWeekdays.contains(DateTime.monday), true);
      expect(find.textContaining('Off every Mon'), findsOneWidget);
    });
  });
}
