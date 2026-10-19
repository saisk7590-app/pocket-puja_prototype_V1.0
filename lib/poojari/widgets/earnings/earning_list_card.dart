import 'package:flutter/material.dart';
import 'package:pocket_puja/core/models/earnings.dart';
import 'package:pocket_puja/core/services/poojari_controller.dart';
import 'package:pocket_puja/core/theme/app_theme.dart';
import 'package:pocket_puja/core/widgets/glass.dart';

/// Earning list card structurally mirroring My Orders list card shape:
/// - GlassPanel shell
/// - Top row: Pooja name and prominent Net Earned on the right
/// - Middle row: Customer name & ritual date
/// - Bottom row: Secondary Gross and Platform Fee breakdown, plus Payout settlement badge
/// - Tap to view detailed earning breakdown
class EarningListCard extends StatelessWidget {
  final PoojariBooking booking;
  final VoidCallback onTap;

  const EarningListCard({
    super.key,
    required this.booking,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final breakdown = booking.breakdown;
    final isPaid = booking.payoutStatus == PayoutStatus.paid;
    final statusColor = isPaid ? AppColors.success : const Color(0xFFFFB84D);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassPanel(
        onTap: onTap,
        padding: const EdgeInsets.all(16),
        borderRadius: 18,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Pooja Title + Prominent Net Earned
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    booking.poojaName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ),
                Text(
                  '+₹${breakdown.netRupees}',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    shadows: AppTheme.goldGlow,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),

            // Middle Row: Devotee & Date
            Row(
              children: [
                const Icon(Icons.person_outline, size: 13, color: Colors.white54),
                const SizedBox(width: 4),
                Text(
                  booking.customerFirstName ?? 'Devotee',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
                const Text(' · ', style: TextStyle(color: Colors.white38)),
                const Icon(Icons.calendar_today_outlined, size: 12, color: Colors.white54),
                const SizedBox(width: 4),
                Text(
                  booking.date,
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Bottom Row: Secondary Fee line + Settlement Status Chip
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Gross: ₹${breakdown.grossRupees} · Fee (${breakdown.platformFeePercentLabel}): −₹${breakdown.platformFeeRupees}',
                  style: const TextStyle(
                    color: Colors.white38,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isPaid ? Icons.check_circle_outline : Icons.schedule,
                        size: 11,
                        color: statusColor,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        isPaid ? 'PAID' : 'PENDING',
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
