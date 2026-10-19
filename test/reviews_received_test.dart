import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_puja/core/models/review.dart';
import 'package:pocket_puja/core/services/poojari_controller.dart';
import 'package:pocket_puja/core/theme/app_theme.dart';
import 'package:pocket_puja/customer/screens/booking/rating_screen.dart';
import 'package:pocket_puja/poojari/screens/reviews/reviews_received_screen.dart';
import 'package:pocket_puja/poojari/widgets/reviews/poojari_review_card.dart';
import 'package:pocket_puja/poojari/widgets/reviews/review_reply_sheet.dart';
import 'package:pocket_puja/poojari/widgets/reviews/reviews_summary_header.dart';

void main() {
  group('BLOCK 13: Reviews & Ratings Controller Unit Tests', () {
    late PoojariController controller;

    setUp(() {
      controller = PoojariController.instance;
      controller.reset();
    });

    test('Initial baseline seed math derives total count, distribution, and average rating', () {
      // 128 baseline ratings + 9 individual seeded review cards = 137 total
      expect(controller.totalReviewCount, 137);
      expect(controller.reviews.length, 9);

      final dist = controller.reviewDistribution;
      // Baseline 5★: 104 + 5 seeded = 109
      expect(dist[5], 109);
      // Baseline 4★: 18 + 2 seeded = 20
      expect(dist[4], 20);
      // Baseline 3★: 6 + 1 seeded = 7
      expect(dist[3], 7);
      // Baseline 2★: 0 + 1 seeded = 1
      expect(dist[2], 1);
      // Baseline 1★: 0
      expect(dist[1], 0);

      // Average rating ~ 4.7
      expect(controller.averageRating, greaterThan(4.6));
      expect(controller.averageRating, lessThan(4.9));
      expect(controller.rating, double.parse(controller.averageRating.toStringAsFixed(1)));
    });

    test('addReview adds new review, recomputes average and adds notification with real star count', () {
      final initialTotal = controller.totalReviewCount;
      final initialAvg = controller.averageRating;

      final newReview = Review(
        id: 'REV-NEW-01',
        bookingId: 'PP-LIVE-1',
        customerFirstName: 'Radha',
        stars: 5,
        comment: 'Truly transcendental chanting!',
        poojaName: 'Rudrabhishekam',
        date: 'Today',
        createdAt: DateTime.now(),
      );

      controller.addReview(newReview);

      expect(controller.totalReviewCount, initialTotal + 1);
      expect(controller.reviews.first.id, 'REV-NEW-01');
      expect(controller.reviews.first.customerFirstName, 'Radha');
      expect(controller.averageRating, greaterThanOrEqualTo(initialAvg));

      // Notification feed check
      expect(controller.reviewNotifications, isNotEmpty);
      final notif = controller.reviewNotifications.first;
      expect(notif.title, 'You received a new 5★ review!');
      expect(notif.body, contains('Radha: "Truly transcendental chanting!"'));
    });

    test('replyToReview updates reply and timestamp on specified review', () {
      final review = controller.reviews.firstWhere((r) => !r.hasReply);
      expect(review.hasReply, false);

      controller.replyToReview(review.id, 'Dhanyavadagalu for your kind words.');

      final updated = controller.reviews.firstWhere((r) => r.id == review.id);
      expect(updated.hasReply, true);
      expect(updated.poojariReply, 'Dhanyavadagalu for your kind words.');
      expect(updated.repliedAt, isNotNull);
    });
  });

  group('BLOCK 13: Reviews Received Widget Tests', () {
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
          child: const ReviewsReceivedScreen(),
        ),
      );
    }

    testWidgets('ReviewsReceivedScreen renders summary header, filter chips, and review cards',
        (tester) async {
      tester.view.physicalSize = const Size(800, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Screen title
      expect(find.text('Devotee Reviews'), findsOneWidget);

      // Summary header
      expect(find.byType(ReviewsSummaryHeader), findsOneWidget);
      expect(find.textContaining('reviews'), findsWidgets);

      // Filter chips
      expect(find.widgetWithText(FilterChip, 'All'), findsOneWidget);
      expect(find.widgetWithText(FilterChip, '5★'), findsOneWidget);
      expect(find.widgetWithText(FilterChip, '4★'), findsOneWidget);
      expect(find.widgetWithText(FilterChip, '3★'), findsOneWidget);
      expect(find.widgetWithText(FilterChip, '2★ & below'), findsOneWidget);

      // Seeded review cards present
      expect(find.byType(PoojariReviewCard), findsWidgets);
      expect(find.text('Anand'), findsOneWidget);
      expect(find.text('Priya'), findsOneWidget);
      expect(find.text('Your reply'), findsWidgets);
    });

    testWidgets('Tapping filter chips filters review list accordingly', (tester) async {
      tester.view.physicalSize = const Size(800, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Filter by 2★ & below
      await tester.tap(find.widgetWithText(FilterChip, '2★ & below'));
      await tester.pumpAndSettle();

      // Suresh has a 2★ review
      expect(find.text('Suresh'), findsOneWidget);
      // Anand (5★) should be hidden
      expect(find.text('Anand'), findsNothing);

      // Filter by 5★
      await tester.tap(find.widgetWithText(FilterChip, '5★'));
      await tester.pumpAndSettle();

      expect(find.text('Anand'), findsOneWidget);
      expect(find.text('Suresh'), findsNothing);
    });

    testWidgets('Tapping Respond opens ReviewReplySheet and submitting updates review with reply',
        (tester) async {
      tester.view.physicalSize = const Size(800, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Find first "Respond" button
      final respondBtn = find.text('Respond');
      expect(respondBtn, findsWidgets);

      await tester.tap(respondBtn.first);
      await tester.pumpAndSettle();

      // ReviewReplySheet open
      expect(find.byType(ReviewReplySheet), findsOneWidget);

      // Enter response
      await tester.enterText(find.byType(TextField), 'Subhamastu! May the divine blessings be with you.');
      await tester.pumpAndSettle();

      // Tap Send Reply
      await tester.tap(find.text('Send Reply'));
      await tester.pumpAndSettle();

      // Sheet closed and snackbar shown
      expect(find.byType(ReviewReplySheet), findsNothing);
      expect(find.textContaining('Your reply has been sent'), findsOneWidget);
    });
  });

  group('BLOCK 13: Customer RatingScreen Live Sync Integration Test', () {
    late PoojariController controller;

    setUp(() {
      controller = PoojariController.instance;
      controller.reset();
    });

    testWidgets('Customer submitting review hooks addReview and updates Poojari state live',
        (tester) async {
      tester.view.physicalSize = const Size(800, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final initialReviewsCount = controller.reviews.length;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.theme,
          home: const RatingScreen(
            bookingRef: 'PP-A1B2C3D4',
            poojaName: 'Ganesha Pooja',
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Rate & Review'), findsOneWidget);

      // Tap 5th star (5★)
      final starIcons = find.byIcon(Icons.star_border);
      expect(starIcons, findsNWidgets(5));
      await tester.tap(starIcons.last);
      await tester.pumpAndSettle();

      // Enter review comment
      await tester.enterText(
        find.byType(TextField),
        'Outstanding rituals performed with utmost sincerity!',
      );
      await tester.pumpAndSettle();

      // Tap Submit Review
      await tester.tap(find.text('Submit Review'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 700));
      await tester.pumpAndSettle();

      // Verify that controller received the review live
      expect(controller.reviews.length, initialReviewsCount + 1);
      final latest = controller.reviews.first;
      expect(latest.stars, 5);
      expect(latest.poojaName, 'Ganesha Pooja');
      expect(latest.comment, 'Outstanding rituals performed with utmost sincerity!');

      // Notification feed received the 5★ review notification
      expect(controller.reviewNotifications, isNotEmpty);
      expect(controller.reviewNotifications.first.title, 'You received a new 5★ review!');
    });
  });
}
