import 'package:flutter/material.dart';
import 'package:pocket_puja/core/services/poojari_controller.dart';
import 'package:pocket_puja/core/theme/app_theme.dart';
import 'package:pocket_puja/core/widgets/glass.dart';

/// Item tile/card for "Upcoming This Week" preview list on the Poojari Dashboard.
///
/// Shows:
/// - Pooja name
/// - Date
/// - Short time
/// - Devotee first name + area (privacy rule)
/// - Tap-through to booking detail screen
class UpcomingBookingTile extends StatelessWidget {
  final PoojariBooking booking;
  final VoidCallback onTap;

  const UpcomingBookingTile({
    super.key,
    required this.booking,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      borderRadius: 16,
      onTap: onTap,
      child: Row(
        children: [
          // Date badge
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Center(
              child: Icon(
                Icons.calendar_today_rounded,
                size: 20,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(width: 14),

          // Details column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  booking.poojaName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Text(
                      '${booking.date} • ${booking.scheduledTime}',
                      style: const TextStyle(
                        color: Color(0xFFFFB84D),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        '(${booking.privacyDevoteeLabel})',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Fee and Chevron
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '₹ ${booking.feeRupees}',
                style: const TextStyle(
                  color: AppColors.primaryFixed,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              const Icon(
                Icons.chevron_right_rounded,
                color: Colors.white38,
                size: 18,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
