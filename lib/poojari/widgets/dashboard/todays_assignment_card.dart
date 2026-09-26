import 'package:flutter/material.dart';
import 'package:pocket_puja/core/services/poojari_controller.dart';
import 'package:pocket_puja/core/theme/app_theme.dart';
import 'package:pocket_puja/core/widgets/glass.dart';

/// Card for Today's Assignment on the Poojari Dashboard.
///
/// Adheres strictly to the privacy rule:
/// - Displays pooja name
/// - Customer's first name + area ONLY (no full street address)
/// - Scheduled time
/// - "View Details" button navigating to booking detail screen
/// - Quick "Mark Complete" action to test/demonstrate real-time KPI updates
class TodaysAssignmentCard extends StatelessWidget {
  final PoojariBooking booking;
  final VoidCallback onViewDetails;
  final VoidCallback? onComplete;

  const TodaysAssignmentCard({
    super.key,
    required this.booking,
    required this.onViewDetails,
    this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    return GlassPanelGold(
      padding: const EdgeInsets.all(16),
      borderRadius: 18,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: Pooja Title and Dakshina/Fee Badge
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      booking.poojaName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // PRIVACY RULE: First name + Area only (no street address)
                    Row(
                      children: [
                        const Icon(
                          Icons.person_pin_circle_outlined,
                          size: 15,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          booking.privacyDevoteeLabel,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.4),
                    width: 1,
                  ),
                ),
                child: Text(
                  '₹ ${booking.feeRupees}',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Middle row: Scheduled time & Status chip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white10),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.access_time_rounded,
                  size: 16,
                  color: Color(0xFFFFB84D),
                ),
                const SizedBox(width: 8),
                Text(
                  '${booking.date} • ${booking.scheduledTime}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: booking.isConfirmed
                        ? AppColors.success.withValues(alpha: 0.2)
                        : const Color(0xFFFFB84D).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    booking.status,
                    style: TextStyle(
                      color: booking.isConfirmed ? AppColors.success : const Color(0xFFFFB84D),
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Action row: View Details (primary) + Quick Complete
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onViewDetails,
                  icon: const Icon(Icons.visibility_outlined, size: 16),
                  label: const Text(
                    'View Details',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: AppColors.primary, width: 1.2),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
              if (onComplete != null) ...[
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onComplete,
                    icon: const Icon(Icons.check_circle_outline, size: 16),
                    label: const Text(
                      'Mark Complete',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.onPrimary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

/// Empty state card shown when zero assignments are scheduled today.
class TodaysAssignmentEmptyState extends StatelessWidget {
  const TodaysAssignmentEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      borderRadius: 18,
      child: Center(
        child: Column(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text('🪔', style: TextStyle(fontSize: 24)),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'No poojas scheduled today',
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Your schedule is clear today. Rest, study Vedas, or review upcoming bookings.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white54, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
