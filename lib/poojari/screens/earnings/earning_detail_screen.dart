import 'package:flutter/material.dart';
import 'package:pocket_puja/core/models/earnings.dart';
import 'package:pocket_puja/core/services/poojari_controller.dart';
import 'package:pocket_puja/core/theme/app_theme.dart';
import 'package:pocket_puja/core/widgets/glass.dart';
import 'package:pocket_puja/poojari/screens/booking_detail/poojari_booking_detail_screen.dart';

/// Detailed earning breakdown screen pushed from the Earnings list.
/// Shows:
/// - Pooja name, customer name, date, Booking ID
/// - Always visible breakdown block (Gross Fee, Platform Fee, You Earned Net)
///   with percentage label derived from [platformFeeRate]
/// - Payout settlement status: "Paid" or "Pending settlement"
/// - Link/button to the related Booking Detail (Block 8)
class EarningDetailScreen extends StatelessWidget {
  final PoojariBooking booking;

  const EarningDetailScreen({
    super.key,
    required this.booking,
  });

  @override
  Widget build(BuildContext context) {
    final breakdown = booking.breakdown;
    final isPaid = booking.payoutStatus == PayoutStatus.paid;
    final statusColor = isPaid ? AppColors.success : const Color(0xFFFFB84D);

    return GlassScaffold(
      showAppBar: false,
      body: SafeArea(
        child: Column(
          children: [
            // Glass App Bar with back arrow
            GlassAppBar(
              title: 'Earning Detail',
              showBack: true,
              onBack: () => Navigator.of(context).pop(),
            ),

            // Scrollable Content
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
                children: [
                  // 1. Ritual & Devotee Summary Card
                  GlassPanel(
                    padding: const EdgeInsets.all(20),
                    borderRadius: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
                                      fontWeight: FontWeight.w800,
                                      fontSize: 18,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Booking ID: #${booking.ref}',
                                    style: const TextStyle(
                                      color: AppColors.primary,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: statusColor.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                              ),
                              child: Text(
                                isPaid ? 'PAID' : 'PENDING SETTLEMENT',
                                style: TextStyle(
                                  color: statusColor,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Divider(color: Colors.white12, height: 1),
                        const SizedBox(height: 14),

                        // Details Rows
                        _detailRow(
                          icon: Icons.person_outline,
                          label: 'Devotee',
                          value: '${booking.customerFirstName ?? 'Devotee'} (${booking.devoteeGotram} Gotram)',
                        ),
                        const SizedBox(height: 10),
                        _detailRow(
                          icon: Icons.calendar_today_outlined,
                          label: 'Date & Time',
                          value: '${booking.date} · ${booking.scheduledTime}',
                        ),
                        const SizedBox(height: 10),
                        _detailRow(
                          icon: Icons.location_on_outlined,
                          label: 'Location',
                          value: '${booking.customerArea ?? 'Hyderabad'} · ${booking.distanceKm ?? '4.2 km'} away',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 2. Earnings Breakdown Block (always visible)
                  GlassPanelGold(
                    padding: const EdgeInsets.all(20),
                    borderRadius: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'EARNINGS BREAKDOWN',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.1,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Gross Fee
                        _breakdownLine(
                          label: 'Gross Fee:',
                          amountText: '₹${_formatCurrency(breakdown.grossRupees)}',
                          isPositive: null,
                        ),
                        const SizedBox(height: 12),

                        // Platform Fee (derived percentage label)
                        _breakdownLine(
                          label: 'Platform Fee (${breakdown.platformFeePercentLabel}):',
                          amountText: '−₹${_formatCurrency(breakdown.platformFeeRupees)}',
                          isPositive: false,
                        ),
                        const SizedBox(height: 14),
                        const Divider(color: Colors.white12, height: 1),
                        const SizedBox(height: 14),

                        // Net Earned
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'You Earned:',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              '₹${_formatCurrency(breakdown.netRupees)}',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                shadows: AppTheme.goldGlow,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Commission of ${breakdown.platformFeePercentLabel} is deducted for secure platform maintenance, devotee coordination, and verified priest support.',
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 11,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 3. Payout Status Block
                  GlassPanel(
                    padding: const EdgeInsets.all(20),
                    borderRadius: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'PAYOUT STATUS',
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.0,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: statusColor.withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                isPaid ? Icons.check_circle_rounded : Icons.schedule_rounded,
                                color: statusColor,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isPaid ? 'Paid' : 'Pending settlement',
                                    style: TextStyle(
                                      color: statusColor,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    isPaid
                                        ? 'Successfully settled to your primary linked bank account.'
                                        : 'Will settle on the upcoming Monday batch transfer.',
                                    style: const TextStyle(
                                      color: Colors.white60,
                                      fontSize: 12,
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
                  const SizedBox(height: 24),

                  // 4. Link/Button to related Booking Detail (Block 8)
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.primary, width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => PoojariBookingDetailScreen(booking: booking),
                          ),
                        );
                      },
                      icon: const Icon(Icons.receipt_long_rounded, size: 20),
                      label: const Text(
                        'View Full Booking Details',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _breakdownLine({
    required String label,
    required String amountText,
    required bool? isPositive,
  }) {
    Color amountColor = Colors.white;
    if (isPositive == false) {
      amountColor = const Color(0xFFFF8B8B);
    } else if (isPositive == true) {
      amountColor = AppColors.success;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          amountText,
          style: TextStyle(
            color: amountColor,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  String _formatCurrency(int amount) {
    return amount.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }
}
