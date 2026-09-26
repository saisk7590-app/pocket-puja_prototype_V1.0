import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_puja/core/services/poojari_controller.dart';
import 'package:pocket_puja/poojari/screens/notifications/poojari_notifications_screen.dart';
import 'package:pocket_puja/poojari/screens/requests/assigned_poojas_screen.dart';

void main() {
  group('BLOCK 6 & 6b: Poojari Controller & Assigned Poojas State Tests', () {
    late PoojariController controller;

    setUp(() {
      controller = PoojariController();
      controller.reset();
    });

    test('Initial state seeds bookings with New status and initial badge count', () {
      expect(controller.newAssignmentsCount, equals(2));
      final newBookings = controller.allBookings.where((b) => b.isNew).toList();
      expect(newBookings.length, equals(2));
      expect(newBookings.first.customerFirstName, equals('Priya'));
      expect(newBookings.first.distanceAreaString, contains('Hitech City'));
      expect(newBookings.first.distanceAreaString, contains('4.2 km'));
      expect(newBookings.first.formattedTitle, equals('Ganesha Pooja for Priya'));
    });

    test('confirmReceipt reactively updates status to CONFIRMED and decrements count', () {
      int notifyCount = 0;
      controller.addListener(() {
        notifyCount++;
      });

      final firstNewRef = controller.allBookings.firstWhere((b) => b.isNew).ref;
      controller.confirmReceipt(firstNewRef);

      expect(notifyCount, greaterThan(0));
      expect(controller.newAssignmentsCount, equals(1));

      final updatedBooking = controller.allBookings.firstWhere((b) => b.ref == firstNewRef);
      expect(updatedBooking.status, equals('CONFIRMED'));
      expect(updatedBooking.isNew, isFalse);
      expect(updatedBooking.isConfirmed, isTrue);

      // Confirm second new booking
      final secondNewRef = controller.allBookings.firstWhere((b) => b.isNew).ref;
      controller.confirmReceipt(secondNewRef);

      expect(controller.newAssignmentsCount, equals(0));
    });
  });

  group('BLOCK 6 & 7: Widget Tests', () {
    testWidgets('AssignedPoojasScreen renders filter tabs and handles confirm receipt tap', (tester) async {
      final controller = PoojariController();
      controller.reset();

      await tester.pumpWidget(
        MaterialApp(
          home: PoojariControllerScope(
            controller: controller,
            child: const AssignedPoojasScreen(),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      // Verify Screen title
      expect(find.text('Assigned Poojas'), findsOneWidget);

      // Verify 4 filter tabs
      expect(find.text('All'), findsOneWidget);
      expect(find.text('Today'), findsOneWidget);
      expect(find.text('Upcoming'), findsOneWidget);
      expect(find.text('Done'), findsAtLeastNWidgets(1));

      // Verify "Confirm Receipt" button is rendered on New cards
      expect(find.text('Confirm Receipt'), findsWidgets);

      // Tap Confirm Receipt on the first card
      await tester.tap(find.text('Confirm Receipt').first);
      await tester.pump(const Duration(milliseconds: 300));

      // Controller count should now be 1
      expect(controller.newAssignmentsCount, equals(1));
    });

    testWidgets('PoojariNotificationsScreen renders all 5 required sections in exact order', (tester) async {
      tester.view.physicalSize = const Size(800, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(
          home: PoojariNotificationsScreen(),
        ),
      );

      expect(find.text('Poojari Notifications'), findsOneWidget);
      expect(find.text('NEW ASSIGNMENTS'), findsOneWidget);
      expect(find.text('SCHEDULE UPDATES'), findsOneWidget);
      expect(find.text('REVIEWS & RATINGS'), findsOneWidget);
      expect(find.text('EARNINGS'), findsOneWidget);
      expect(find.text('VERIFICATION'), findsOneWidget);
    });
  });
}
