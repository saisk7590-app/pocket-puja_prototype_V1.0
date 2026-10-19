import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_puja/core/models/earnings.dart';
import 'package:pocket_puja/core/services/poojari_controller.dart';
import 'package:pocket_puja/core/theme/app_theme.dart';
import 'package:pocket_puja/poojari/screens/booking_detail/poojari_booking_detail_screen.dart';
import 'package:pocket_puja/poojari/screens/earnings/earning_detail_screen.dart';
import 'package:pocket_puja/poojari/screens/earnings/earnings_screen.dart';
import 'package:pocket_puja/poojari/widgets/earnings/earning_list_card.dart';
import 'package:pocket_puja/poojari/widgets/earnings/earnings_filter_chips.dart';
import 'package:pocket_puja/poojari/widgets/earnings/earnings_summary_card.dart';
import 'package:pocket_puja/poojari/widgets/earnings/settlement_info_card.dart';

void main() {
  group('BLOCK 12: Commission Model & Single Source of Truth Tests', () {
    test('platformFeeRate is 0.15 and breakdownFor calculates gross, fee, and net consistently', () {
      expect(platformFeeRate, 0.15);

      // Test case 1: ₹1,500 gross
      final b1 = breakdownForFeeRupees(1500);
      expect(b1.grossRupees, 1500);
      expect(b1.platformFeeRupees, 225);
      expect(b1.netRupees, 1275);
      expect(b1.grossRupees, b1.platformFeeRupees + b1.netRupees);
      expect(b1.platformFeePercentLabel, '15%');

      // Test case 2: ₹2,500 gross
      final b2 = breakdownForFeeRupees(2500);
      expect(b2.grossRupees, 2500);
      expect(b2.platformFeeRupees, 375);
      expect(b2.netRupees, 2125);
      expect(b2.grossRupees, b2.platformFeeRupees + b2.netRupees);

      // Test case 3: ₹1,200 gross
      final b3 = breakdownForFeeRupees(1200);
      expect(b3.grossRupees, 1200);
      expect(b3.platformFeeRupees, 180);
      expect(b3.netRupees, 1020);
      expect(b3.grossRupees, b3.platformFeeRupees + b3.netRupees);

      // Test case 4: paise consistency
      final b4 = breakdownForFeePaise(150000);
      expect(b4.grossPaise, 150000);
      expect(b4.platformFeePaise, 22500);
      expect(b4.netPaise, 127500);
    });

    test('payoutStatusFor derives Paid vs Pending settlement strictly from next Monday', () {
      final now = DateTime.now();

      // Completed today -> next Monday is in the future -> Pending settlement
      final todayStatus = payoutStatusFor(now, now);
      expect(todayStatus, PayoutStatus.pending);

      // Completed 15 days ago -> next Monday has passed -> Paid
      final pastDate = now.subtract(const Duration(days: 15));
      final pastStatus = payoutStatusFor(pastDate, now);
      expect(pastStatus, PayoutStatus.paid);
    });
  });

  group('BLOCK 12: PoojariController Live Updates & Net Dakshina', () {
    setUp(() {
      PoojariController.instance.reset();
    });

    test('completeBooking increments This Month by NET amount and triggers NET notification', () {
      final controller = PoojariController.instance;
      final initialCompleted = controller.poojasCompleted;
      final initialThisMonthNet = controller.thisMonthEarningsRupees;
      final initialPending = controller.pendingPayoutRupees;

      // Find an active uncompleted booking
      final target = controller.allBookings.firstWhere((b) => !b.isDone && !b.isCancelled);
      final expectedBreakdown = target.breakdown;

      controller.completeBooking(target.ref);

      // Verify poojasCompleted incremented by 1
      expect(controller.poojasCompleted, initialCompleted + 1);

      // Verify This Month's earnings incremented by NET (not gross fee)
      expect(controller.thisMonthEarningsRupees, initialThisMonthNet + expectedBreakdown.netRupees);

      // Newly completed booking is pending settlement -> pending payout increases by net
      expect(controller.pendingPayoutRupees, initialPending + expectedBreakdown.netRupees);

      // Verify notification uses NET amount
      final notif = controller.earningsNotifications.first;
      expect(notif.title, '₹${expectedBreakdown.netRupees} Dakshina Credited');
      expect(notif.body, contains('₹${expectedBreakdown.netRupees} credited for your completed pooja'));
    });

    test('Seeded historical bookings span This Month (Paid & Pending), Last Month, and Older', () {
      final controller = PoojariController.instance;
      final completed = controller.completedBookings;
      expect(completed.length, greaterThanOrEqualTo(4));

      final now = DateTime.now();

      // This Month bookings (mix of Paid and Pending)
      final thisMonth = completed.where((b) {
        final d = b.effectiveCompletionDate;
        return d.year == now.year && d.month == now.month;
      }).toList();
      expect(thisMonth, isNotEmpty);
      expect(thisMonth.any((b) => b.payoutStatus == PayoutStatus.pending), isTrue);

      // Last Month bookings
      final lastMonthDate = DateTime(now.year, now.month - 1, 1);
      final lastMonth = completed.where((b) {
        final d = b.effectiveCompletionDate;
        return d.year == lastMonthDate.year && d.month == lastMonthDate.month;
      }).toList();
      expect(lastMonth, isNotEmpty);
      expect(lastMonth.every((b) => b.payoutStatus == PayoutStatus.paid), isTrue);

      // Older bookings
      final older = completed.where((b) {
        final d = b.effectiveCompletionDate;
        return d.isBefore(lastMonthDate);
      }).toList();
      expect(older, isNotEmpty);
      expect(older.every((b) => b.payoutStatus == PayoutStatus.paid), isTrue);
    });
  });

  group('BLOCK 12: EarningsScreen Widget Tests', () {
    setUp(() {
      PoojariController.instance.reset();
    });

    testWidgets('EarningsScreen renders GlassAppBar, Summary Card, Time Filter Chips, List, and Settlement Card', (tester) async {
      tester.view.physicalSize = const Size(800, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.theme,
          home: const EarningsScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // 1. GlassAppBar Header
      expect(find.text('Dakshina Ledger'), findsOneWidget);
      expect(find.byTooltip('Profile'), findsOneWidget);
      expect(find.byTooltip('Notifications'), findsOneWidget);

      // 2. Summary Card with live metrics
      expect(find.byType(EarningsSummaryCard), findsOneWidget);
      final controller = PoojariController.instance;
      expect(find.text("THIS MONTH'S EARNINGS (NET)"), findsOneWidget);
      expect(find.text('₹ ${controller.thisMonthEarningsRupees}'), findsOneWidget);
      expect(find.text('TOTAL LIFETIME'), findsOneWidget);
      expect(find.text('₹ ${controller.lifetimeEarningsRupees}'), findsOneWidget);
      expect(find.text('PENDING PAYOUT'), findsOneWidget);
      expect(find.text('₹ ${controller.pendingPayoutRupees}'), findsOneWidget);

      // 3. Time Filter Chips
      expect(find.byType(EarningsTimeFilterBar), findsOneWidget);
      expect(find.text('This Month'), findsOneWidget);
      expect(find.text('Last Month'), findsOneWidget);
      expect(find.text('All Time'), findsOneWidget);
      expect(find.text('Custom Range'), findsOneWidget);

      // 4. Completed Rituals List
      expect(find.byType(EarningListCard), findsWidgets);

      // 5. Settlement Info Card
      expect(find.byType(SettlementInfoCard), findsOneWidget);
      expect(
        find.text('Payouts settle every Monday to your linked bank account'),
        findsOneWidget,
      );
    });

    testWidgets('Tapping time filter chips filters list while Summary Card totals remain fixed', (tester) async {
      tester.view.physicalSize = const Size(800, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.theme,
          home: const EarningsScreen(),
        ),
      );
      await tester.pumpAndSettle();

      final controller = PoojariController.instance;
      final fixedThisMonthNetText = '₹ ${controller.thisMonthEarningsRupees}';

      // Initially 'This Month' is selected
      expect(find.text('This Month'), findsOneWidget);
      expect(find.text(fixedThisMonthNetText), findsOneWidget);

      // Tap 'Last Month'
      await tester.tap(find.text('Last Month'));
      await tester.pumpAndSettle();

      // Summary card still displays fixed This Month figure
      expect(find.text(fixedThisMonthNetText), findsOneWidget);
      // List shows Last Month's booking
      expect(find.text('Navagraha Pooja'), findsOneWidget);

      // Tap 'All Time'
      await tester.tap(find.text('All Time'));
      await tester.pumpAndSettle();

      // Summary card still displays fixed This Month figure
      expect(find.text(fixedThisMonthNetText), findsOneWidget);
      expect(find.text('Maha Mrityunjaya Homam'), findsOneWidget);
    });

    testWidgets('Tapping an EarningListCard navigates to EarningDetailScreen', (tester) async {
      tester.view.physicalSize = const Size(800, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.theme,
          home: const EarningsScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Tap first earning list card
      final firstCard = find.byType(EarningListCard).first;
      await tester.tap(firstCard);
      await tester.pumpAndSettle();

      // Verify EarningDetailScreen is pushed
      expect(find.byType(EarningDetailScreen), findsOneWidget);
      expect(find.text('Earning Detail'), findsOneWidget);
      expect(find.text('EARNINGS BREAKDOWN'), findsOneWidget);
      expect(find.text('Platform Fee (15%):'), findsOneWidget);
      expect(find.text('View Full Booking Details'), findsOneWidget);
    });
  });

  group('BLOCK 12: EarningDetailScreen Widget Tests', () {
    testWidgets('EarningDetailScreen renders breakdown, payout status, and links to PoojariBookingDetailScreen', (tester) async {
      tester.view.physicalSize = const Size(800, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      const booking = PoojariBooking(
        ref: 'PP-TEST1234',
        poojaName: 'Satyanarayana Vratam',
        status: 'DONE',
        date: 'Today',
        scheduledTime: '10:00 AM',
        feePaise: 200000, // ₹2,000 gross -> ₹300 fee (15%) -> ₹1,700 net
        customerFirstName: 'Radha',
        customerArea: 'Kondapur',
        fullAddress: 'Flat 302, Sai Residency, Kondapur',
        customerPhone: '+91 98765 12345',
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.theme,
          home: const EarningDetailScreen(booking: booking),
        ),
      );
      await tester.pumpAndSettle();

      // Check header info
      expect(find.text('Satyanarayana Vratam'), findsOneWidget);
      expect(find.text('Booking ID: #PP-TEST1234'), findsOneWidget);
      expect(find.textContaining('Radha'), findsOneWidget);

      // Check breakdown block
      expect(find.text('EARNINGS BREAKDOWN'), findsOneWidget);
      expect(find.text('Gross Fee:'), findsOneWidget);
      expect(find.text('₹2,000'), findsOneWidget);
      expect(find.text('Platform Fee (15%):'), findsOneWidget);
      expect(find.text('−₹300'), findsOneWidget);
      expect(find.text('You Earned:'), findsOneWidget);
      expect(find.text('₹1,700'), findsOneWidget);

      // Check Payout Status
      expect(find.text('PAYOUT STATUS'), findsOneWidget);
      expect(find.text('Pending settlement'), findsOneWidget);

      // Check Link to Booking Detail
      final viewButton = find.text('View Full Booking Details');
      expect(viewButton, findsOneWidget);

      await tester.tap(viewButton);
      await tester.pumpAndSettle();

      // Navigates to PoojariBookingDetailScreen
      expect(find.byType(PoojariBookingDetailScreen), findsOneWidget);
    });
  });
}
