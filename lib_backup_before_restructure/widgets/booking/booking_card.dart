import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../data/booking/booking_data.dart';
import '../common/glass.dart';

class BookingCard extends StatelessWidget {
  final BookingData booking;
  final VoidCallback onTap;
  final VoidCallback? onRate;
  const BookingCard({super.key, required this.booking, required this.onTap, this.onRate});

  Color _statusColor(String status) {
    switch (status) {
      case 'PENDING': return const Color(0xFFFFC27A);
      case 'ASSIGNED': return AppColors.primary;
      case 'CONFIRMED': return const Color(0xFF7FC8F8);
      case 'DONE': return const Color(0xFF9DE6B4);
      case 'COMPLETED': return const Color(0xFF9DE6B4);
      case 'RATED': return AppColors.secondary;
      case 'CANCELLED': return Colors.white38;
      default: return Colors.white54;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(booking.status);
    final canRate = booking.status == 'COMPLETED' || booking.status == 'DONE';
    final isCancelled = booking.status == 'CANCELLED';
    final isRated = booking.status == 'RATED';

    return GlassPanel(
      padding: const EdgeInsets.all(16),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(booking.poojaName, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(booking.ref, style: const TextStyle(color: Colors.white38, fontSize: 11)),
              ]),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(20)),
              child: Text(booking.status == 'PENDING' ? 'Finding your Poojari...' : booking.status, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w800)),
            ),
          ]),
          const SizedBox(height: 14),
          const Divider(color: Colors.white12, height: 1),
          const SizedBox(height: 14),
          Row(children: [
            const Icon(Icons.calendar_today, size: 14, color: Colors.white38),
            const SizedBox(width: 8),
            Text(booking.date, style: const TextStyle(color: Colors.white60, fontSize: 12)),
            const Spacer(),
            Text('₹${(booking.feePaise / 100).toStringAsFixed(0)}', style: const TextStyle(color: AppColors.primary, fontSize: 16, fontWeight: FontWeight.w800)),
          ]),
          if (booking.status == 'PENDING')
            const Padding(padding: EdgeInsets.only(top: 8), child: Text('We typically assign within 4 hours.', style: TextStyle(color: Colors.white38, fontSize: 11))),
          if (booking.status == 'CONFIRMED')
            const Padding(padding: EdgeInsets.only(top: 8), child: Text('Your Poojari is confirmed for this date.', style: TextStyle(color: Colors.white38, fontSize: 11))),
          if (isCancelled && booking.cancelReason != null)
            Padding(padding: const EdgeInsets.only(top: 8), child: Row(children: [
              const Icon(Icons.info_outline, size: 14, color: Colors.white38),
              const SizedBox(width: 6),
              Expanded(child: Text(booking.cancelReason!, style: const TextStyle(color: Colors.white38, fontSize: 11))),
            ])),
          // Already-rated bookings show the rating given, not a re-prompt.
          if (isRated && booking.myRating != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Row(children: [
                ...List.generate(5, (i) => Icon(i < booking.myRating! ? Icons.star : Icons.star_border, color: AppColors.secondary, size: 16)),
                const SizedBox(width: 8),
                const Text('You rated this', style: TextStyle(color: Colors.white38, fontSize: 11)),
              ]),
            ),
          if (canRate && onRate != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: SizedBox(width: double.infinity, child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(foregroundColor: AppColors.primary, side: const BorderSide(color: AppColors.primary)),
                onPressed: onRate, icon: const Icon(Icons.star_border, size: 18), label: const Text('Rate & Review'),
              )),
            ),
        ],
      ),
    );
  }
}