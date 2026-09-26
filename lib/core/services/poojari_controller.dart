import 'package:flutter/material.dart';
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
  });

  int get feeRupees => feePaise ~/ 100;
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
    );
  }
}

/// Central state controller for the Poojari Suite (Dashboard, Assigned Poojas, Schedule, Earnings).
/// Follows the exact same ChangeNotifier + InheritedNotifier pattern as AudioController.
class PoojariController extends ChangeNotifier {
  static final PoojariController _instance = PoojariController._internal();
  factory PoojariController() => _instance;
  static PoojariController get instance => _instance;

  PoojariController._internal() {
    _initFromSharedBookingSource();
  }

  // --- Quick Stats (LIVE) ---
  final double rating = 4.8;
  int _poojasCompleted = 24;
  int _thisMonthEarningsPaise = 3250000; // ₹32,500

  int get poojasCompleted => _poojasCompleted;
  int get thisMonthEarningsRupees => _thisMonthEarningsPaise ~/ 100;

  /// Reactive count of New/unconfirmed assignments for the nav badge (BLOCK 6b)
  int get newAssignmentsCount => _bookings.where((b) => b.isNew).length;
  int get pendingAssignmentsCount => newAssignmentsCount;

  // --- Availability Nudge Flag ---
  bool _availabilityNudgeDismissed = false;
  bool get showAvailabilityNudge => !_availabilityNudgeDismissed;

  void dismissAvailabilityNudge() {
    _availabilityNudgeDismissed = true;
    notifyListeners();
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
      // 4. Completed assignment (Done)
      const PoojariBooking(
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
        samagriSummary: ['Go-Pooja Items', 'Navagraha Vastram', 'Homa Samidhalu', 'Toranam Mango Leaves'],
        isToday: false,
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
  void completeBooking(String bookingRef) {
    final index = _bookings.indexWhere((b) => b.ref == bookingRef);
    if (index != -1) {
      final booking = _bookings[index];
      if (!booking.isDone) {
        _bookings[index] = booking.copyWith(status: 'DONE');
        _poojasCompleted += 1;
        _thisMonthEarningsPaise += booking.feePaise;
        _earningsNotifications.insert(
          0,
          PoojariNotificationItem(
            title: '₹${booking.feeRupees} Dakshina Credited',
            body: '₹${booking.feeRupees} credited for your completed pooja (${booking.poojaName})',
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

  /// Reset to initial seeded state (useful for tests and mock demo flows)
  void reset() {
    _availabilityNudgeDismissed = false;
    _poojasCompleted = 24;
    _thisMonthEarningsPaise = 3250000;
    _earningsNotifications.clear();
    _initFromSharedBookingSource();
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
