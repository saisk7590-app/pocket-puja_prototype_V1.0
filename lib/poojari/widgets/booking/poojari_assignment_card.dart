import 'package:flutter/material.dart';
import 'package:pocket_puja/core/services/poojari_controller.dart';
import 'package:pocket_puja/core/theme/app_theme.dart';
import 'package:pocket_puja/core/widgets/glass.dart';
import 'package:pocket_puja/poojari/screens/booking_detail/poojari_booking_detail_screen.dart';

/// Reusable assignment card component for Poojari bookings.
/// Shared across Assigned Poojas (Block 6) and My Schedule (Block 10).
class PoojariAssignmentCard extends StatelessWidget {
  final PoojariBooking booking;
  final VoidCallback? onTap;
  final bool showConfirmReceipt;
  final Animation<double>? pulseAnimation;

  const PoojariAssignmentCard({
    super.key,
    required this.booking,
    this.onTap,
    this.showConfirmReceipt = true,
    this.pulseAnimation,
  });

  static Color statusColor(String status) {
    switch (status.toUpperCase()) {
      case 'NEW':
      case 'ASSIGNED':
      case 'PENDING':
        return const Color(0xFFFFC27A); // Warm golden amber
      case 'CONFIRMED':
        return const Color(0xFF7FC8F8); // Sky blue
      case 'EN_ROUTE':
        return const Color(0xFFFF9E7A); // Coral orange
      case 'ARRIVED':
        return const Color(0xFF7FC8F8); // Sky blue
      case 'DONE':
      case 'COMPLETED':
      case 'RATED':
        return const Color(0xFF9DE6B4); // Soft emerald green
      case 'CANCELLED':
      case 'DECLINED':
        return Colors.white38; // Muted grey
      default:
        return Colors.white70;
    }
  }

  static String statusLabel(String status) {
    switch (status.toUpperCase()) {
      case 'NEW':
      case 'ASSIGNED':
      case 'PENDING':
        return 'New';
      case 'CONFIRMED':
        return 'Confirmed';
      case 'EN_ROUTE':
        return 'En Route';
      case 'ARRIVED':
        return 'Arrived';
      case 'DONE':
      case 'COMPLETED':
      case 'RATED':
        return 'Done';
      case 'CANCELLED':
      case 'DECLINED':
        return 'Cancelled';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    final sColor = statusColor(booking.status);
    final sText = statusLabel(booking.status);
    final isNewCard = booking.isNew;

    final card = GlassPanel(
      padding: const EdgeInsets.all(16),
      borderRadius: 22,
      onTap: onTap ??
          () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => PoojariBookingDetailScreen(
                  booking: booking,
                ),
              ),
            );
          },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Title + Status Badge
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      booking.formattedTitle,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 13,
                          color: AppColors.primaryFixed,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            booking.distanceAreaString,
                            style: const TextStyle(
                              color: Colors.white60,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Status Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: sColor.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: sColor.withValues(alpha: 0.45),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isNewCard)
                      Container(
                        width: 6,
                        height: 6,
                        margin: const EdgeInsets.only(right: 5),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: sColor,
                        ),
                      ),
                    Text(
                      sText,
                      style: TextStyle(
                        color: sColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: Colors.white12, height: 1),
          const SizedBox(height: 12),

          // Bottom Row: Date & Time + Fee
          Row(
            children: [
              const Icon(
                Icons.calendar_today_rounded,
                size: 13,
                color: Colors.white54,
              ),
              const SizedBox(width: 6),
              Text(
                '${booking.date} • ${booking.scheduledTime}',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
              const Spacer(),
              Text(
                '₹${booking.feeRupees}',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),

          // Optional Confirm Receipt button on New cards
          if (isNewCard && showConfirmReceipt) ...[
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              height: 42,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.onPrimary,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () {
                  PoojariController.instance.confirmReceipt(booking.ref);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '✓ Receipt confirmed for ${booking.poojaName} (${booking.customerFirstName})',
                      ),
                      backgroundColor: AppColors.surfaceContainerHigh,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                icon: const Icon(Icons.check_circle_outline_rounded, size: 18),
                label: const Text(
                  'Confirm Receipt',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );

    if (pulseAnimation != null && isNewCard) {
      return AnimatedBuilder(
        animation: pulseAnimation!,
        builder: (context, child) {
          final pulseVal = pulseAnimation!.value;
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.15 + 0.25 * pulseVal),
                  blurRadius: 16 + 6 * pulseVal,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: card,
          );
        },
      );
    }

    return card;
  }
}
