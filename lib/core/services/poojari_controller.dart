import 'package:flutter/material.dart';
import 'package:pocket_puja/core/models/earnings.dart';
import 'package:pocket_puja/core/models/review.dart';
import 'package:pocket_puja/customer/data/booking/booking_data.dart';

/// Representation of a booking from the Poojari's perspective,
/// strictly respecting privacy rules:
/// - Customer first name + area only are shown on cards (e.g. "Ganesha Pooja for Priya").
/// - Full street address stays hidden until the booking is Confirmed/Completed.
class PoojariBooking {
  final String ref;
  final String poojaName;
  final String status; // 'NEW', 'CONFIRMED', 'EN_ROUTE', 'DONE'
  final String date;
  final String scheduledTime;
  final int feePaise;
  final String? customerFirstName;
  final String? customerArea;
  final String? distanceKm;
  final String fullAddress;
  final String customerPhone;
  final String devoteeGotram;
  final List<String> samagriSummary;
  final bool isToday;
  final bool itemsListSent;
  final String? itemsListSentAt;
  final List<String> itemsList;
  final DateTime? scheduledDate;
  final DateTime? completedDate;

  const PoojariBooking({
    required this.ref,
    required this.poojaName,
    required this.status,
    required this.date,
    required this.scheduledTime,
    required this.feePaise,
    this.customerFirstName = 'Devotee',
    this.customerArea = 'Hyderabad',
    this.distanceKm = '4.2 km',
    required this.fullAddress,
    required this.customerPhone,
    this.devoteeGotram = 'Kashyapa',
    this.samagriSummary = const ['Haldi & Kumkum', 'Pooja Ghee', 'Coconuts (2)', 'Flowers & Betel Leaves'],
    this.isToday = false,
    this.itemsListSent = false,
    this.itemsListSentAt,
    this.itemsList = const [],
    this.scheduledDate,
    this.completedDate,
  });

  int get feeRupees => feePaise ~/ 100;
  EarningBreakdown get breakdown => breakdownFor(this);
  DateTime get effectiveCompletionDate => completedDate ?? scheduledDate ?? normalizedDate;
  PayoutStatus get payoutStatus => payoutStatusFor(effectiveCompletionDate);

  bool get isNew => status == 'NEW' || status == 'ASSIGNED' || status == 'PENDING';
  bool get isConfirmed => status == 'CONFIRMED';
  bool get isEnRoute => status == 'EN_ROUTE';
  bool get isArrived => status == 'ARRIVED';
  bool get isDone => status == 'DONE' || status == 'COMPLETED' || status == 'RATED';
  bool get isCompleted => isDone;
  bool get isPending => isNew;
  bool get isAssigned => isNew;
  bool get isDeclined => status == 'DECLINED';
  bool get isCancelled => status == 'CANCELLED' || status == 'DECLINED';

  /// Resolves the booking date normalized to midnight
  DateTime get normalizedDate {
    if (scheduledDate != null) {
      return DateTime(scheduledDate!.year, scheduledDate!.month, scheduledDate!.day);
    }
    final now = DateTime.now();
    final todayMidnight = DateTime(now.year, now.month, now.day);
    final d = date.toLowerCase();
    if (isToday || d.contains('today')) {
      return todayMidnight;
    }
    if (d.contains('tomorrow')) {
      return todayMidnight.add(const Duration(days: 1));
    }
    if (d.contains('yesterday')) {
      return todayMidnight.subtract(const Duration(days: 1));
    }
    if (d.contains('jun 29')) {
      return DateTime(2026, 6, 29);
    }
    if (d.contains('jun 10')) {
      return DateTime(2026, 6, 10);
    }
    return todayMidnight;
  }

  /// Checks if this booking is scheduled on targetDate
  bool matchesDate(DateTime targetDate) {
    final norm = normalizedDate;
    return norm.year == targetDate.year && norm.month == targetDate.month && norm.day == targetDate.day;
  }

  /// Privacy display rule: customer's first name + area only
  String get privacyDevoteeLabel => '${customerFirstName ?? 'Devotee'} • ${customerArea ?? 'Hyderabad'}';

  /// e.g. "Ganesha Pooja for Priya"
  String get formattedTitle => '$poojaName for ${customerFirstName ?? 'Devotee'}';

  /// e.g. "Hitech City · 4.2 km away"
  String get distanceAreaString => '${customerArea ?? 'Hyderabad'} · ${distanceKm ?? '4.2 km'} away';

  PoojariBooking copyWith({
    String? ref,
    String? poojaName,
    String? status,
    String? date,
    String? scheduledTime,
    int? feePaise,
    String? customerFirstName,
    String? customerArea,
    String? distanceKm,
    String? fullAddress,
    String? customerPhone,
    String? devoteeGotram,
    List<String>? samagriSummary,
    bool? isToday,
    bool? itemsListSent,
    String? itemsListSentAt,
    List<String>? itemsList,
    DateTime? scheduledDate,
    DateTime? completedDate,
  }) {
    return PoojariBooking(
      ref: ref ?? this.ref,
      poojaName: poojaName ?? this.poojaName,
      status: status ?? this.status,
      date: date ?? this.date,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      feePaise: feePaise ?? this.feePaise,
      customerFirstName: customerFirstName ?? this.customerFirstName,
      customerArea: customerArea ?? this.customerArea,
      distanceKm: distanceKm ?? this.distanceKm,
      fullAddress: fullAddress ?? this.fullAddress,
      customerPhone: customerPhone ?? this.customerPhone,
      devoteeGotram: devoteeGotram ?? this.devoteeGotram,
      samagriSummary: samagriSummary ?? this.samagriSummary,
      isToday: isToday ?? this.isToday,
      itemsListSent: itemsListSent ?? this.itemsListSent,
      itemsListSentAt: itemsListSentAt ?? this.itemsListSentAt,
      itemsList: itemsList ?? this.itemsList,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      completedDate: completedDate ?? this.completedDate,
    );
  }
}

/// Day availability states with strict precedence order:
/// 1. past
/// 2. booked
/// 3. recurringOff
/// 4. blockedByMe
/// 5. available
enum DayAvailabilityState {
  past,
  booked,
  recurringOff,
  blockedByMe,
  available,
}

/// Central state controller for the Poojari Suite (Dashboard, Assigned Poojas, Schedule, Earnings, Availability).
/// Follows the exact same ChangeNotifier + InheritedNotifier pattern as AudioController.
class PoojariController extends ChangeNotifier {
  static final PoojariController _instance = PoojariController._internal();
  factory PoojariController() => _instance;
  static PoojariController get instance => _instance;

  PoojariController._internal() {
    _initFromSharedBookingSource();
    _initSeededReviews();
  }

  // --- Reviews & Ratings State (BLOCK 13) ---
  /// Baseline counts representing established Vedic practice history (128 total, avg ~4.8★)
  static const Map<int, int> _baselineCounts = {
    5: 104,
    4: 18,
    3: 6,
    2: 0,
    1: 0,
  };

  late List<Review> _reviews;
  List<Review> get reviews => List.unmodifiable(_reviews);

  final List<PoojariNotificationItem> _reviewNotifications = [];
  List<PoojariNotificationItem> get reviewNotifications => List.unmodifiable(_reviewNotifications);

  /// Total count computed dynamically from baseline counts + all listed reviews
  int get totalReviewCount {
    final baselineTotal = _baselineCounts.values.fold(0, (sum, c) => sum + c);
    return baselineTotal + _reviews.length;
  }

  /// Star distribution computed dynamically from baseline counts + all listed reviews
  Map<int, int> get reviewDistribution {
    final dist = Map<int, int>.from(_baselineCounts);
    for (final r in _reviews) {
      dist[r.stars] = (dist[r.stars] ?? 0) + 1;
    }
    return dist;
  }

  /// Average rating dynamically derived from the distribution
  double get averageRating {
    final dist = reviewDistribution;
    int totalWeighted = 0;
    int total = 0;
    dist.forEach((stars, count) {
      totalWeighted += stars * count;
      total += count;
    });
    if (total == 0) return 0.0;
    return totalWeighted / total;
  }

  // --- Quick Stats (LIVE) ---
  /// Live average rating feeding Dashboard KPI square (no static seed value)
  double get rating => double.parse(averageRating.toStringAsFixed(1));
  int _poojasCompleted = 24;
  int _thisMonthEarningsPaise = 3250000; // ₹32,500

  int get poojasCompleted => _poojasCompleted;
  int get thisMonthEarningsRupees => _thisMonthEarningsPaise ~/ 100;

  /// Total Lifetime Earnings: NET
  int get lifetimeEarningsRupees => 145000 + thisMonthEarningsRupees;

  /// Pending Payout: NET earned but not yet settled
  int get pendingPayoutRupees => _bookings
      .where((b) => b.isDone && b.payoutStatus == PayoutStatus.pending)
      .fold<int>(0, (sum, b) => sum + b.breakdown.netRupees);

  /// Completed poojas only
  List<PoojariBooking> get completedBookings =>
      _bookings.where((b) => b.isDone).toList();

  /// Reactive count of New/unconfirmed assignments for the nav badge (BLOCK 6b)
  int get newAssignmentsCount => _bookings.where((b) => b.isNew).length;
  int get pendingAssignmentsCount => newAssignmentsCount;

  /// Adds a new review submitted by a devotee:
  /// - Prepends to the review list
  /// - Dynamically recomputes averageRating, totalReviewCount, reviewDistribution
  /// - Updates Dashboard's Rating KPI tile reactively
  /// - Injects a notification into the reviewNotifications feed with real star value
  /// - Notifies all listeners
  void addReview(Review review) {
    _reviews.insert(0, review);
    _reviewNotifications.insert(
      0,
      PoojariNotificationItem(
        title: 'You received a new ${review.stars}★ review!',
        body: '${review.customerFirstName}: "${review.comment?.isNotEmpty == true ? review.comment : 'Rated ${review.stars} stars for ${review.poojaName}'}"',
        time: 'Just now',
        icon: Icons.stars_rounded,
      ),
    );
    notifyListeners();
  }

  /// Submits or updates the Poojari's single response to a review
  void replyToReview(String reviewId, String replyText) {
    final index = _reviews.indexWhere((r) => r.id == reviewId);
    if (index != -1) {
      _reviews[index] = _reviews[index].copyWith(
        poojariReply: replyText.trim(),
        repliedAt: DateTime.now(),
      );
      notifyListeners();
    }
  }

  // --- Availability State (BLOCK 11) ---
  final Set<DateTime> _manuallyBlockedDates = <DateTime>{};
  Set<DateTime> get manuallyBlockedDates => Set.unmodifiable(_manuallyBlockedDates);

  final Set<int> _recurringOffWeekdays = <int>{};
  Set<int> get recurringOffWeekdays => Set.unmodifiable(_recurringOffWeekdays);

  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  /// Single source of truth for day availability precedence:
  /// 1. Past date: greyed out, non-interactive, no toggle.
  /// 2. Booked/Assigned: Confirmed/En Route/Arrived booking that day.
  ///    Auto-locked, NOT manually toggleable. Wins over recurring off & manual block.
  /// 3. Recurring off-day: weekday matches recurring off pattern.
  /// 4. Blocked by me: manually blocked by Poojari.
  /// 5. Available: normal, tappable, default.
  DayAvailabilityState availabilityStateFor(DateTime day) {
    final normDay = _normalizeDate(day);
    final now = DateTime.now();
    final today = _normalizeDate(now);

    // 1. Past date
    if (normDay.isBefore(today)) {
      return DayAvailabilityState.past;
    }

    // 2. Booked/Assigned (wins over recurring off and manual block)
    if (hasActiveBookingOn(normDay)) {
      return DayAvailabilityState.booked;
    }

    // 3. Recurring off-day
    if (_recurringOffWeekdays.contains(normDay.weekday)) {
      return DayAvailabilityState.recurringOff;
    }

    // 4. Blocked by me
    if (_manuallyBlockedDates.contains(normDay)) {
      return DayAvailabilityState.blockedByMe;
    }

    // 5. Available (default)
    return DayAvailabilityState.available;
  }

  /// Checks if any active confirmed/en route/arrived/assigned booking exists on this day
  bool hasActiveBookingOn(DateTime day) {
    final normDay = _normalizeDate(day);
    return _bookings.any((b) =>
        (b.isConfirmed || b.isEnRoute || b.isArrived || b.isAssigned) &&
        !b.isDone &&
        !b.isCancelled &&
        b.matchesDate(normDay));
  }

  /// Retrieves the active booking scheduled on this day, if any
  PoojariBooking? getBookingForDate(DateTime day) {
    final normDay = _normalizeDate(day);
    try {
      return _bookings.firstWhere((b) =>
          (b.isConfirmed || b.isEnRoute || b.isArrived || b.isAssigned) &&
          !b.isDone &&
          !b.isCancelled &&
          b.matchesDate(normDay));
    } catch (_) {
      return null;
    }
  }

  /// Toggles manual block for a date:
  /// - Available -> Blocked
  /// - Blocked by me -> Available
  /// - Booked or Past date -> No toggle (returns false)
  /// - Recurring off -> No toggle via single tap (returns false)
  bool toggleDateBlock(DateTime day) {
    final normDay = _normalizeDate(day);
    final state = availabilityStateFor(normDay);

    if (state == DayAvailabilityState.past ||
        state == DayAvailabilityState.booked ||
        state == DayAvailabilityState.recurringOff) {
      return false;
    }

    if (state == DayAvailabilityState.blockedByMe) {
      _manuallyBlockedDates.remove(normDay);
      notifyListeners();
      return true;
    } else if (state == DayAvailabilityState.available) {
      _manuallyBlockedDates.add(normDay);
      notifyListeners();
      return true;
    }
    return false;
  }

  /// Replaces the recurring off weekdays pattern with a new set (Mon=1..Sun=7)
  void setRecurringOffWeekdays(Set<int> weekdays) {
    _recurringOffWeekdays
      ..clear()
      ..addAll(weekdays);
    notifyListeners();
  }

  /// Toggles a single recurring off weekday
  void toggleRecurringOffWeekday(int weekday) {
    if (_recurringOffWeekdays.contains(weekday)) {
      _recurringOffWeekdays.remove(weekday);
    } else {
      _recurringOffWeekdays.add(weekday);
    }
    notifyListeners();
  }

  /// Clears all recurring off days
  void clearRecurringOffWeekdays() {
    _recurringOffWeekdays.clear();
    notifyListeners();
  }

  /// Checks whether the Poojari's calendar is fully open for the next 7 days (today through today + 6).
  /// Returns true only if NO day in this window is blocked or recurring off.
  bool get isCalendarFullyOpenNext7Days {
    final now = DateTime.now();
    final today = _normalizeDate(now);
    for (int i = 0; i < 7; i++) {
      final day = today.add(Duration(days: i));
      final state = availabilityStateFor(day);
      if (state == DayAvailabilityState.blockedByMe ||
          state == DayAvailabilityState.recurringOff) {
        return false;
      }
    }
    return true;
  }

  // --- Availability Nudge Flag ---
  bool _availabilityNudgeDismissed = false;

  /// Show the nudge only if not dismissed AND calendar is fully open next 7 days
  bool get showAvailabilityNudge =>
      !_availabilityNudgeDismissed && isCalendarFullyOpenNext7Days;

  void dismissAvailabilityNudge() {
    _availabilityNudgeDismissed = true;
    notifyListeners();
  }

  /// Mock assignment check: skip any date where availabilityStateFor(date)
  /// is Blocked, Recurring off, or Past.
  bool canAcceptAssignmentOn(DateTime date) {
    final state = availabilityStateFor(date);
    return state != DayAvailabilityState.past &&
        state != DayAvailabilityState.recurringOff &&
        state != DayAvailabilityState.blockedByMe;
  }

  /// Assigns a new booking if the Poojari is available on that date.
  bool assignBookingIfAvailable(PoojariBooking newBooking, DateTime date) {
    if (!canAcceptAssignmentOn(date)) {
      return false;
    }
    _bookings.add(newBooking.copyWith(scheduledDate: date));
    notifyListeners();
    return true;
  }

  // --- Bookings State ---
  late List<PoojariBooking> _bookings;

  List<PoojariBooking> get allBookings => List.unmodifiable(_bookings);

  /// Section 3: Today's Assignment(s)
  List<PoojariBooking> get todaysAssignments =>
      _bookings.where((b) => b.isToday && !b.isDone).toList();

  /// Section 5: Upcoming This Week
  List<PoojariBooking> get upcomingThisWeek =>
      _bookings.where((b) => !b.isToday && !b.isDone).toList();

  /// Initialized from the shared booking data source
  void _initFromSharedBookingSource() {
    _bookings = [
      // 1. Today's New assignment (Needs Confirm Receipt)
      PoojariBooking(
        ref: activeBookings[0].ref,
        poojaName: 'Ganesha Pooja',
        status: 'NEW',
        date: 'Today',
        scheduledTime: '09:00 AM',
        feePaise: activeBookings[0].feePaise,
        customerFirstName: 'Priya',
        customerArea: 'Hitech City',
        distanceKm: '4.2 km',
        fullAddress: 'Flat 402, Sai Residency, Ayyappa Society, Madhapur, Hyderabad',
        customerPhone: '+91 98765 43210',
        devoteeGotram: 'Kashyapa',
        samagriSummary: const ['Homa Kunda Samagri', 'Ghee 1kg', 'Modak Prasaadam', 'Dry Coconut & Navadhanyam'],
        isToday: true,
      ),
      // 2. Tomorrow's Confirmed assignment
      PoojariBooking(
        ref: activeBookings[1].ref,
        poojaName: 'Satyanarayana Vratam',
        status: 'CONFIRMED',
        date: 'Tomorrow',
        scheduledTime: '10:30 AM',
        feePaise: activeBookings[1].feePaise,
        customerFirstName: 'Srinivas',
        customerArea: 'Kondapur',
        distanceKm: '5.8 km',
        fullAddress: 'Villa 18, Green Meadows, Kondapur, Hyderabad',
        customerPhone: '+91 98112 34567',
        devoteeGotram: 'Bharadwaja',
        samagriSummary: const ['Vrata Katha Pustakam', 'Panchamrutham', 'Banana Stems (4)', 'Tulasi Leaves'],
        isToday: false,
        itemsListSent: true,
        itemsListSentAt: 'Today, 10:15 AM',
        itemsList: const ['pr4', 'pr7', 'pr1', 'pr2', 'pr9', 'pr10'],
      ),
      // 3. Today's En Route ritual
      PoojariBooking(
        ref: activeBookings[2].ref,
        poojaName: 'Rudrabhishekam',
        status: 'EN_ROUTE',
        date: 'Today',
        scheduledTime: '02:00 PM',
        feePaise: activeBookings[2].feePaise,
        customerFirstName: 'Venkata',
        customerArea: 'Gachibowli',
        distanceKm: '6.5 km',
        fullAddress: 'Plot 55, Telecom Nagar, Gachibowli, Hyderabad',
        customerPhone: '+91 98450 12345',
        devoteeGotram: 'Gauthama',
        samagriSummary: const ['Vibhuti & Bilva Patra', 'Pure Cow Milk & Honey', 'Panchamrutham', 'Shiva Sahasranamam'],
        isToday: true,
      ),
      // 4. Completed assignment (This Month - Paid)
      PoojariBooking(
        ref: 'PP-H8J9K0L1',
        poojaName: 'Gruhapravesham',
        status: 'DONE',
        date: 'Yesterday',
        scheduledTime: '06:15 AM',
        feePaise: 250000,
        customerFirstName: 'Anand',
        customerArea: 'Jubilee Hills',
        distanceKm: '3.9 km',
        fullAddress: 'Road No. 36, Jubilee Hills, Hyderabad',
        customerPhone: '+91 99001 22334',
        devoteeGotram: 'Vashishta',
        samagriSummary: const ['Go-Pooja Items', 'Navagraha Vastram', 'Homa Samidhalu', 'Toranam Mango Leaves'],
        isToday: false,
        completedDate: DateTime.now().day > 8
            ? DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day - 8)
            : DateTime(DateTime.now().year, DateTime.now().month, 1),
      ),
      // 4b. Completed assignment (This Month - Pending settlement)
      PoojariBooking(
        ref: 'PP-E1P2P3P4',
        poojaName: 'Ayushya Homam',
        status: 'DONE',
        date: 'Today',
        scheduledTime: '07:30 AM',
        feePaise: 150000,
        customerFirstName: 'Aarav',
        customerArea: 'Madhapur',
        distanceKm: '2.1 km',
        fullAddress: 'Flat 101, Lakeview Apts, Madhapur, Hyderabad',
        customerPhone: '+91 98777 55443',
        devoteeGotram: 'Kashyapa',
        samagriSummary: const ['Modak Prasaadam', 'Durva Grass', 'Coconut & Betel Leaves'],
        isToday: true,
        completedDate: DateTime.now(),
      ),
      // 4c. Completed assignment (Last Month - Paid)
      PoojariBooking(
        ref: 'PP-L1M2N3P4',
        poojaName: 'Navagraha Pooja',
        status: 'DONE',
        date: 'Last Month',
        scheduledTime: '10:00 AM',
        feePaise: 200000,
        customerFirstName: 'Meera',
        customerArea: 'Kondapur',
        distanceKm: '5.2 km',
        fullAddress: 'Villa 12, Palm Meadows, Kondapur, Hyderabad',
        customerPhone: '+91 98111 88776',
        devoteeGotram: 'Bharadwaja',
        samagriSummary: const ['Panchamrutham', 'Vrata Katha Book', 'Banana Plantain'],
        isToday: false,
        completedDate: DateTime(DateTime.now().year, DateTime.now().month - 1, 15),
      ),
      // 4d. Completed assignment (Older / 2 Months ago - Paid)
      PoojariBooking(
        ref: 'PP-O1P2Q3R4',
        poojaName: 'Maha Mrityunjaya Homam',
        status: 'DONE',
        date: '2 months ago',
        scheduledTime: '06:00 AM',
        feePaise: 300000,
        customerFirstName: 'Dr. Suresh',
        customerArea: 'Banjara Hills',
        distanceKm: '6.8 km',
        fullAddress: 'Road No. 10, Banjara Hills, Hyderabad',
        customerPhone: '+91 98450 77889',
        devoteeGotram: 'Gauthama',
        samagriSummary: const ['Bilva Leaves', 'Panchamrutham', 'Vibhuti & Ganga Jal'],
        isToday: false,
        completedDate: DateTime(DateTime.now().year, DateTime.now().month - 2, 12),
      ),
      // 5. Additional upcoming New assignment
      const PoojariBooking(
        ref: 'PP-V4W5X6Y7',
        poojaName: 'Vehicle Pooja',
        status: 'NEW',
        date: 'Jun 29, 2026',
        scheduledTime: '11:00 AM',
        feePaise: 120000,
        customerFirstName: 'Rajesh',
        customerArea: 'Madhapur',
        distanceKm: '2.4 km',
        fullAddress: 'Plot 12, Kavuri Hills, Madhapur, Hyderabad',
        customerPhone: '+91 98888 11223',
        devoteeGotram: 'Kashyapa',
        samagriSummary: ['Lemons (4)', 'Coconut (1)', 'Kumkum & Turmeric', 'Flower Garland'],
        isToday: false,
      ),
      // 6. Cancelled booking
      const PoojariBooking(
        ref: 'PP-Z9Y8X7W6',
        poojaName: 'Vastu Shanti',
        status: 'CANCELLED',
        date: 'Jun 10, 2026',
        scheduledTime: '08:00 AM',
        feePaise: 200000,
        customerFirstName: 'Ramesh',
        customerArea: 'Banjara Hills',
        distanceKm: '7.1 km',
        fullAddress: 'Road No. 12, Banjara Hills, Hyderabad',
        customerPhone: '+91 97777 66554',
        devoteeGotram: 'Sandilya',
        samagriSummary: ['Navaratna Pack', 'Copper Plate', 'Panchamrutham'],
        isToday: false,
      ),
    ];
  }

  /// BLOCK 6: Confirm Receipt for an assigned pooja.
  /// Tapping it:
  /// - Updates status to 'CONFIRMED'
  /// - Removes the button from the card
  /// - Decrements the New count for the nav badge reactively
  /// - Triggers notifyListeners() for instant live update
  void confirmReceipt(String bookingRef) {
    final index = _bookings.indexWhere((b) => b.ref == bookingRef);
    if (index != -1) {
      _bookings[index] = _bookings[index].copyWith(status: 'CONFIRMED');
      notifyListeners();
    }
  }

  /// Backwards-compatible alias for confirmReceipt
  void acceptBooking(String bookingRef) => confirmReceipt(bookingRef);

  /// Updates status of booking (e.g. EN_ROUTE, ARRIVED, DONE)
  void updateBookingStatus(String bookingRef, String newStatus) {
    final index = _bookings.indexWhere((b) => b.ref == bookingRef);
    if (index != -1) {
      if (newStatus == 'DONE' || newStatus == 'COMPLETED') {
        completeBooking(bookingRef);
      } else {
        _bookings[index] = _bookings[index].copyWith(status: newStatus);
        notifyListeners();
      }
    }
  }

  /// BLOCK 9: Writes items list and sets sent=true
  void sendItemsList(String bookingRef, List<String> itemIds, {String? sentAt}) {
    final index = _bookings.indexWhere((b) => b.ref == bookingRef);
    if (index != -1) {
      _bookings[index] = _bookings[index].copyWith(
        itemsList: itemIds,
        itemsListSent: true,
        itemsListSentAt: sentAt ?? 'Today, 11:30 AM',
      );
      notifyListeners();
    }
  }

  final List<PoojariNotificationItem> _earningsNotifications = [];
  List<PoojariNotificationItem> get earningsNotifications => List.unmodifiable(_earningsNotifications);

  /// Marks a booking Complete in real time.
  /// LIVE UPDATE (BLOCK 12):
  /// - Dashboard "This Month's Earnings" increments by NET (from breakdownFor)
  /// - Notification reads "₹[net] credited for your completed pooja"
  void completeBooking(String bookingRef) {
    final index = _bookings.indexWhere((b) => b.ref == bookingRef);
    if (index != -1) {
      final booking = _bookings[index];
      if (!booking.isDone) {
        final now = DateTime.now();
        final updated = booking.copyWith(
          status: 'DONE',
          completedDate: now,
        );
        _bookings[index] = updated;
        _poojasCompleted += 1;
        final breakdown = breakdownFor(updated);
        _thisMonthEarningsPaise += breakdown.netPaise;
        _earningsNotifications.insert(
          0,
          PoojariNotificationItem(
            title: '₹${breakdown.netRupees} Dakshina Credited',
            body: '₹${breakdown.netRupees} credited for your completed pooja (${updated.poojaName})',
            time: 'Just now',
          ),
        );
        notifyListeners();
      }
    }
  }

  /// Find booking by reference
  PoojariBooking? getBookingByRef(String ref) {
    try {
      return _bookings.firstWhere((b) => b.ref == ref);
    } catch (_) {
      return null;
    }
  }

  /// Initializes 8-10 baseline seeded review cards spanning various star ratings and pooja types
  void _initSeededReviews() {
    final now = DateTime.now();
    _reviews = [
      Review(
        id: 'REV-001',
        bookingId: 'PP-H8J9K0L1',
        customerFirstName: 'Anand',
        stars: 5,
        comment: 'Shri Panditji performed our Gruhapravesham with deep Vedic devotion and divine grace. Highly blessed!',
        poojaName: 'Gruhapravesham',
        date: 'Jun 20, 2026',
        createdAt: now.subtract(const Duration(days: 2)),
        poojariReply: 'Dhanyavadagalu Anand garu. May Lord Venkateswara bestow harmony and prosperity upon your new home.',
        repliedAt: now.subtract(const Duration(days: 1)),
      ),
      Review(
        id: 'REV-002',
        bookingId: 'PP-A1B2C3D4',
        customerFirstName: 'Priya',
        stars: 5,
        comment: 'Very punctual and explained the significance of each mantra so clearly. Our family felt truly peaceful.',
        poojaName: 'Ganesha Pooja',
        date: 'Jun 18, 2026',
        createdAt: now.subtract(const Duration(days: 4)),
        poojariReply: 'Subhamastu Priya garu! It was an honor invoking Lord Vighnaharta for your household.',
        repliedAt: now.subtract(const Duration(days: 3)),
      ),
      Review(
        id: 'REV-003',
        bookingId: 'PP-E5F6G7H8',
        customerFirstName: 'Srinivas',
        stars: 4,
        comment: 'Wonderful puja recitation and sankalpam. Samagri checklist was also very comprehensive.',
        poojaName: 'Satyanarayana Vratam',
        date: 'Jun 12, 2026',
        createdAt: now.subtract(const Duration(days: 8)),
      ),
      Review(
        id: 'REV-004',
        bookingId: 'PP-Q1R2S3T4',
        customerFirstName: 'Venkata',
        stars: 5,
        comment: 'The Shiva abhishekam chantings reverberated through the entire house. Unmatched Vedic rigor.',
        poojaName: 'Rudrabhishekam',
        date: 'Jun 08, 2026',
        createdAt: now.subtract(const Duration(days: 12)),
      ),
      Review(
        id: 'REV-005',
        bookingId: 'PP-V4W5X6Y7',
        customerFirstName: 'Rajesh',
        stars: 3,
        comment: 'Pooja was done properly, but arrived 15 mins late due to traffic.',
        poojaName: 'Vehicle Pooja',
        date: 'May 28, 2026',
        createdAt: now.subtract(const Duration(days: 22)),
        poojariReply: 'Apologies for the delay caused by heavy rain traffic, Rajesh garu. Thank you for your patience.',
        repliedAt: now.subtract(const Duration(days: 21)),
      ),
      Review(
        id: 'REV-006',
        bookingId: 'PP-Z9Y8X7W6',
        customerFirstName: 'Ramesh',
        stars: 5,
        comment: 'Extremely knowledgeable pandit. Resolved all our doubts regarding the northeast corner.',
        poojaName: 'Vastu Shanti',
        date: 'May 20, 2026',
        createdAt: now.subtract(const Duration(days: 30)),
      ),
      Review(
        id: 'REV-007',
        bookingId: 'PP-L3M4N5O6',
        customerFirstName: 'Kavitha',
        stars: 4,
        comment: 'Very serene atmosphere. Completed all 16 upacharas with patience.',
        poojaName: 'Lakshmi Pooja',
        date: 'May 14, 2026',
        createdAt: now.subtract(const Duration(days: 36)),
      ),
      Review(
        id: 'REV-008',
        bookingId: 'PP-U5V6W7X8',
        customerFirstName: 'Suresh',
        stars: 2,
        comment: 'Ritual was fast, felt a bit rushed towards the end.',
        poojaName: 'Naming Ceremony',
        date: 'May 02, 2026',
        createdAt: now.subtract(const Duration(days: 48)),
      ),
      Review(
        id: 'REV-009',
        bookingId: 'PP-G1H2I3J4',
        customerFirstName: 'Madhav',
        stars: 5,
        comment: 'Grand homam experience. The agni sankalpam was inspiring.',
        poojaName: 'Ganapati Homam',
        date: 'Apr 25, 2026',
        createdAt: now.subtract(const Duration(days: 55)),
      ),
    ];
  }

  /// Reset to initial seeded state (useful for tests and mock demo flows)
  void reset() {
    _availabilityNudgeDismissed = false;
    _poojasCompleted = 24;
    _thisMonthEarningsPaise = 3250000;
    _earningsNotifications.clear();
    _reviewNotifications.clear();
    _manuallyBlockedDates.clear();
    _recurringOffWeekdays.clear();
    _initFromSharedBookingSource();
    _initSeededReviews();
    notifyListeners();
  }
}

class PoojariNotificationItem {
  final String title;
  final String body;
  final String time;
  final IconData icon;

  const PoojariNotificationItem({
    required this.title,
    required this.body,
    required this.time,
    this.icon = Icons.currency_rupee_rounded,
  });
}

/// Inherited notifier for PoojariController.
class PoojariControllerScope extends InheritedNotifier<PoojariController> {
  const PoojariControllerScope({
    super.key,
    required PoojariController controller,
    required super.child,
  }) : super(notifier: controller);

  static PoojariController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<PoojariControllerScope>();
    assert(scope != null, 'No PoojariControllerScope found in context');
    return scope!.notifier!;
  }

  static PoojariController? maybeOf(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<PoojariControllerScope>();
    return scope?.notifier;
  }
}
