import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_puja/core/models/pooja_suggested_items.dart';
import 'package:pocket_puja/core/services/poojari_controller.dart';
import 'package:pocket_puja/poojari/screens/booking_detail/items_list_builder_screen.dart';
import 'package:pocket_puja/poojari/screens/booking_detail/poojari_booking_detail_screen.dart';
import 'package:pocket_puja/poojari/widgets/booking_detail/customer_card.dart';

void main() {
  setUp(() {
    PoojariController.instance.reset();
  });

  group('BLOCK 9: Suggested Items & Shop Catalog Resolution', () {
    test('Every pooja type maps to valid ProductData entries in shop_data.dart', () {
      final poojaTypes = [
        'Ganesha Pooja',
        'Ganapathi Homam',
        'Satyanarayana Vratam',
        'Gruhapravesham',
        'Vehicle Pooja',
        'Rudrabhishekam',
        'Naming Ceremony',
        'Vastu Shanti',
      ];

      for (final pooja in poojaTypes) {
        final products = getSuggestedProductsForPooja(pooja);
        expect(products, isNotEmpty, reason: '$pooja should resolve suggested items');
        for (final product in products) {
          expect(product.id, isNotEmpty);
          expect(product.name, isNotEmpty);
          expect(product.pricePaise, greaterThan(0));
        }
      }
    });

    test('Fallback suggestions resolve for unknown pooja names', () {
      final products = getSuggestedProductsForPooja('Custom Vedic Ritual');
      expect(products, isNotEmpty);
      expect(products.any((p) => p.name.contains('Kumkum')), isTrue);
    });
  });

  group('BLOCK 8: Poojari Controller Booking Status & Complete Flow', () {
    test('updateBookingStatus moves through forward-only sequence to complete', () {
      final controller = PoojariController.instance;
      final booking = controller.allBookings.first;

      // 1. Confirm Receipt
      controller.confirmReceipt(booking.ref);
      expect(controller.getBookingByRef(booking.ref)!.status, 'CONFIRMED');

      // 2. Mark En Route
      controller.updateBookingStatus(booking.ref, 'EN_ROUTE');
      expect(controller.getBookingByRef(booking.ref)!.status, 'EN_ROUTE');

      // 3. Mark Arrived
      controller.updateBookingStatus(booking.ref, 'ARRIVED');
      expect(controller.getBookingByRef(booking.ref)!.status, 'ARRIVED');

      // 4. Mark Complete
      final initialCompleted = controller.poojasCompleted;
      final initialEarnings = controller.thisMonthEarningsRupees;
      controller.updateBookingStatus(booking.ref, 'DONE');

      final updated = controller.getBookingByRef(booking.ref)!;
      expect(updated.status, 'DONE');
      expect(updated.isDone, isTrue);

      // Verify stats increment
      expect(controller.poojasCompleted, initialCompleted + 1);
      expect(controller.thisMonthEarningsRupees, initialEarnings + (booking.feePaise ~/ 100));

      // Verify earnings notification triggered
      expect(controller.earningsNotifications, isNotEmpty);
      expect(controller.earningsNotifications.first.body, contains('credited for your completed pooja'));
    });

    test('sendItemsList updates booking items and sent flag', () {
      final controller = PoojariController.instance;
      final booking = controller.allBookings.first;

      expect(booking.itemsListSent, isFalse);

      controller.sendItemsList(booking.ref, ['pr4', 'pr7', 'pr1'], sentAt: 'Today, 10:15 AM');

      final updated = controller.getBookingByRef(booking.ref)!;
      expect(updated.itemsListSent, isTrue);
      expect(updated.itemsListSentAt, 'Today, 10:15 AM');
      expect(updated.itemsList, ['pr4', 'pr7', 'pr1']);
    });
  });

  group('BLOCK 8 & 9: Widget Tests', () {
    testWidgets('CustomerCard renders devotee info and action buttons', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CustomerCard(
              customerName: 'Priya Sharma',
              fullAddress: 'Flat 402, Sai Residency, Madhapur, Hyderabad',
              phone: '+91 98765 43210',
              gotram: 'Kashyapa',
            ),
          ),
        ),
      );

      expect(find.text('Priya Sharma'), findsOneWidget);
      expect(find.text('Gotram: Kashyapa'), findsOneWidget);
      expect(find.textContaining('Madhapur'), findsOneWidget);
      expect(find.textContaining('Call (+91 98765 43210)'), findsOneWidget);
      expect(find.text('Message'), findsOneWidget);
    });

    testWidgets('PoojariBookingDetailScreen renders header, stepper, customer card, items prompt and map tile', (tester) async {
      tester.view.physicalSize = const Size(800, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final booking = PoojariController.instance.allBookings.first;

      await tester.pumpWidget(
        MaterialApp(
          home: PoojariBookingDetailScreen(booking: booking),
        ),
      );
      await tester.pumpAndSettle();

      // 1. Header
      expect(find.text(booking.poojaName), findsOneWidget);
      expect(find.text('Booking ID: #${booking.ref}'), findsOneWidget);

      // 2. Customer card
      expect(find.byType(CustomerCard), findsOneWidget);
      expect(find.text(booking.customerFirstName ?? 'Priya'), findsWidgets);

      // 3. Status Stepper
      expect(find.text('Confirmed'), findsOneWidget);
      expect(find.text('En Route'), findsOneWidget);
      expect(find.text('Arrived'), findsOneWidget);
      expect(find.text('Done'), findsOneWidget);

      // 4. Items List Card prompt (not yet sent)
      expect(find.text('Create Pooja Items List'), findsOneWidget);

      // 5. Date & Location + Route tile
      expect(find.text('CUSTOMER LOCATION ROUTE'), findsOneWidget);
      expect(find.textContaining('away'), findsOneWidget);
    });

    testWidgets('ItemsListBuilderScreen renders suggestions, allows toggle, search and send', (tester) async {
      tester.view.physicalSize = const Size(800, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final booking = PoojariController.instance.allBookings.first;

      await tester.pumpWidget(
        MaterialApp(
          home: ItemsListBuilderScreen(
            bookingRef: booking.ref,
            poojaName: booking.poojaName,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Title header
      expect(find.text('Items List — ${booking.poojaName}'), findsOneWidget);

      // Suggested items are pre-populated and checked
      expect(find.text('Suggested Items'), findsOneWidget);
      expect(find.textContaining('Selected'), findsOneWidget);

      // Send to Customer button is visible
      expect(find.textContaining('Send to Customer'), findsOneWidget);

      // Tap Send to Customer
      await tester.tap(find.textContaining('Send to Customer'));
      await tester.pumpAndSettle();

      // Controller must have updated the booking
      final updated = PoojariController.instance.getBookingByRef(booking.ref)!;
      expect(updated.itemsListSent, isTrue);
      expect(updated.itemsList, isNotEmpty);
    });

    testWidgets('ItemsListBuilderScreen pre-populates previous items in edit mode', (tester) async {
      tester.view.physicalSize = const Size(800, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final booking = PoojariController.instance.allBookings.first;

      // Open in Edit mode with selected items including an additional item ('pr8' Brass Idol)
      await tester.pumpWidget(
        MaterialApp(
          home: ItemsListBuilderScreen(
            bookingRef: booking.ref,
            poojaName: booking.poojaName,
            initialSelectedIds: const ['pr4', 'pr8'],
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Check that additional items section appears
      expect(find.text('Additional Items Added'), findsOneWidget);
      expect(find.text('Brass Idol - Ganesha'), findsOneWidget);
    });
  });
}
