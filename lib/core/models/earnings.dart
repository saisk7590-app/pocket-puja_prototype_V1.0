/// Central commission model and earning breakdown calculations for Pocket Puja.
/// Single source of truth for all Poojari earnings, platform commission fee,
/// and payout settlement logic.
library;

/// Fixed platform fee rate: 15%
const double platformFeeRate = 0.15;

/// Earning breakdown model representing gross fee, platform commission, and net earning.
class EarningBreakdown {
  final int grossRupees;
  final int platformFeeRupees;
  final int netRupees;
  final int grossPaise;
  final int platformFeePaise;
  final int netPaise;

  const EarningBreakdown({
    required this.grossRupees,
    required this.platformFeeRupees,
    required this.netRupees,
    required this.grossPaise,
    required this.platformFeePaise,
    required this.netPaise,
  });

  /// Formatted platform commission percentage derived directly from [platformFeeRate] (e.g. "15%").
  /// Do not hardcode this label anywhere in UI.
  String get platformFeePercentLabel => '${(platformFeeRate * 100).round()}%';

  @override
  String toString() =>
      'EarningBreakdown(gross: ₹$grossRupees, fee: ₹$platformFeeRupees ($platformFeePercentLabel), net: ₹$netRupees)';
}

/// Computes the single source of truth earning breakdown for a given gross fee in paise.
/// Rounded to whole rupees consistently:
/// - platformFeeRupees = (grossRupees * platformFeeRate).round()
/// - netRupees = grossRupees - platformFeeRupees
/// The three numbers always add up exactly.
EarningBreakdown breakdownForFeePaise(int feePaise) {
  final grossRupees = feePaise ~/ 100;
  final platformFeeRupees = (grossRupees * platformFeeRate).round();
  final netRupees = grossRupees - platformFeeRupees;

  return EarningBreakdown(
    grossRupees: grossRupees,
    platformFeeRupees: platformFeeRupees,
    netRupees: netRupees,
    grossPaise: grossRupees * 100,
    platformFeePaise: platformFeeRupees * 100,
    netPaise: netRupees * 100,
  );
}

/// Computes the single source of truth earning breakdown for a given gross fee in rupees.
EarningBreakdown breakdownForFeeRupees(int feeRupees) {
  return breakdownForFeePaise(feeRupees * 100);
}

/// Helper: EarningBreakdown breakdownFor(Booking b)
/// Accepts any booking object having `feePaise` (e.g. PoojariBooking, BookingData)
/// or an integer fee in paise.
EarningBreakdown breakdownFor(dynamic booking) {
  if (booking == null) return breakdownForFeePaise(0);
  if (booking is int) return breakdownForFeePaise(booking);

  try {
    final dynamic feePaise = (booking as dynamic).feePaise;
    if (feePaise is int) {
      return breakdownForFeePaise(feePaise);
    }
  } catch (_) {}

  try {
    final dynamic feeRupees = (booking as dynamic).fee;
    if (feeRupees is int) {
      return breakdownForFeeRupees(feeRupees);
    } else if (feeRupees is num) {
      return breakdownForFeeRupees(feeRupees.round());
    }
  } catch (_) {}

  return breakdownForFeePaise(0);
}

/// Payout status for a completed booking.
enum PayoutStatus {
  paid('Paid'),
  pending('Pending settlement');

  final String label;
  const PayoutStatus(this.label);
}

/// Computes the next Monday midnight strictly after [date].
/// If [date] is Monday, returns Monday 7 days later.
/// If [date] is Sunday, returns Monday 1 day later.
DateTime nextMondayAfter(DateTime date) {
  final d = DateTime(date.year, date.month, date.day);
  final daysUntilNextMonday = 8 - d.weekday; // weekday 1=Mon .. 7=Sun
  return d.add(Duration(days: daysUntilNextMonday));
}

/// Computes payout settlement status for a completed booking at render time.
/// A completed booking is "Pending settlement" until the next Monday after
/// its completion date has passed, then "Paid".
PayoutStatus payoutStatusFor(DateTime completionDate, [DateTime? now]) {
  final current = now ?? DateTime.now();
  final nextMonday = nextMondayAfter(completionDate);
  final nextMondayMidnight = DateTime(nextMonday.year, nextMonday.month, nextMonday.day);
  return current.isBefore(nextMondayMidnight) ? PayoutStatus.pending : PayoutStatus.paid;
}
