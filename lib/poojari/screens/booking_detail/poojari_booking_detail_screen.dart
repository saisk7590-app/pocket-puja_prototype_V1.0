import 'package:flutter/material.dart';
import 'package:pocket_puja/core/models/pooja_suggested_items.dart';
import 'package:pocket_puja/core/services/poojari_controller.dart';
import 'package:pocket_puja/core/theme/app_theme.dart';
import 'package:pocket_puja/core/widgets/glass.dart';
import 'package:pocket_puja/customer/widgets/booking/status_stepper.dart';
import 'package:pocket_puja/poojari/screens/booking_detail/items_list_builder_screen.dart';
import 'package:pocket_puja/poojari/widgets/booking_detail/customer_card.dart';

/// BLOCK 8 — Booking Detail, Poojari's View
///
/// Mirrors Customer's Booking Detail structurally (same GlassScaffold shell,
/// same card ordering logic), but content flips to show Devotee details
/// and Poojari forward-only execution controls.
class PoojariBookingDetailScreen extends StatelessWidget {
  final PoojariBooking booking;

  const PoojariBookingDetailScreen({
    super.key,
    required this.booking,
  });

  static const _steps = ['Confirmed', 'En Route', 'Arrived', 'Done'];
  static const _stepIcons = [
    Icons.verified,
    Icons.directions_bike,
    Icons.location_on,
    Icons.check_circle,
  ];

  int _stepperIndex(String status) {
    switch (status) {
      case 'EN_ROUTE':
        return 1;
      case 'ARRIVED':
        return 2;
      case 'DONE':
      case 'COMPLETED':
        return 3;
      case 'CONFIRMED':
      case 'NEW':
      case 'PENDING':
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: PoojariController.instance,
      builder: (context, _) {
        final currentBooking = PoojariController.instance.getBookingByRef(booking.ref) ?? booking;
        final currentStep = _stepperIndex(currentBooking.status);
        final isDone = currentBooking.isDone;

        return GlassScaffold(
          gradient: AppGradients.rust,
          title: 'Booking Detail',
          showBack: true,
          body: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
            children: [
              // 1. Header: Pooja name + Booking ID (exact mirror of Customer's Booking Detail)
              Center(
                child: Column(
                  children: [
                    Text(
                      currentBooking.poojaName,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                            color: AppColors.primary,
                            fontSize: 24,
                            shadows: AppTheme.goldGlow,
                          ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Booking ID: #${currentBooking.ref}',
                      style: const TextStyle(color: Colors.white54, fontSize: 13),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 2. Customer card (reusing PanditCard's exact structure)
              CustomerCard(
                customerName: currentBooking.customerFirstName ?? 'Devotee',
                fullAddress: currentBooking.fullAddress,
                phone: currentBooking.customerPhone,
                gotram: currentBooking.devoteeGotram,
                badgeLabel: isDone
                    ? 'Completed Ritual'
                    : (currentBooking.isConfirmed ? 'Confirmed Devotee' : 'Assigned Devotee'),
              ),
              const SizedBox(height: 16),

              // 3. Status Stepper: Confirmed → En Route → Arrived → Done
              GlassPanel(
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
                child: Column(
                  children: [
                    StatusStepper(
                      steps: _steps,
                      icons: _stepIcons,
                      currentIndex: currentStep,
                    ),
                    const SizedBox(height: 18),
                    _buildForwardActionButton(context, currentBooking),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 4. Items List Card
              _buildItemsListCard(context, currentBooking),
              const SizedBox(height: 16),

              // 5. Date / Location Cards + Customer Location Map Tile
              Row(
                children: [
                  Expanded(
                    child: _infoTile(
                      Icons.calendar_today,
                      'DATE & TIME',
                      '${currentBooking.date} • ${currentBooking.scheduledTime}',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _infoTile(
                      Icons.location_on_outlined,
                      'LOCATION',
                      currentBooking.customerArea ?? 'Hyderabad',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Map placeholder tile showing Customer's location
              _buildCustomerLocationMapTile(context, currentBooking),
              const SizedBox(height: 14),

              // Dakshina / Payment summary
              GlassPanel(
                padding: const EdgeInsets.all(16),
                borderRadius: 16,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Dakshina Offered',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          isDone ? 'Credited to your balance' : 'Payable upon ritual completion',
                          style: const TextStyle(color: Colors.white54, fontSize: 11),
                        ),
                      ],
                    ),
                    Text(
                      '₹ ${currentBooking.feeRupees}',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Forward-only action button for the stepper:
  /// Confirmed -> Mark En Route
  /// En Route  -> Mark Arrived
  /// Arrived   -> Mark Complete
  Widget _buildForwardActionButton(BuildContext context, PoojariBooking b) {
    if (b.isDone) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.success.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.success.withValues(alpha: 0.4)),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, color: AppColors.success, size: 18),
            SizedBox(width: 8),
            Text(
              'Ritual Completed & Dakshina Credited',
              style: TextStyle(
                color: AppColors.success,
                fontWeight: FontWeight.w800,
                fontSize: 13,
              ),
            ),
          ],
        ),
      );
    }

    if (b.status == 'NEW' || b.status == 'PENDING') {
      return PrimaryButton(
        label: 'Confirm Receipt',
        icon: Icons.check_circle_outline,
        onTap: () {
          PoojariController.instance.confirmReceipt(b.ref);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✓ Receipt confirmed! Full assignment details unlocked.'),
              backgroundColor: AppColors.success,
            ),
          );
        },
      );
    }

    if (b.status == 'CONFIRMED') {
      return PrimaryButton(
        label: 'Mark En Route',
        icon: Icons.directions_bike_rounded,
        onTap: () {
          PoojariController.instance.updateBookingStatus(b.ref, 'EN_ROUTE');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('🚗 En route to ${b.customerFirstName ?? 'devotee'}!'),
              backgroundColor: AppColors.primary,
            ),
          );
        },
      );
    }

    if (b.status == 'EN_ROUTE') {
      return PrimaryButton(
        label: 'Mark Arrived',
        icon: Icons.location_on_rounded,
        onTap: () {
          PoojariController.instance.updateBookingStatus(b.ref, 'ARRIVED');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('📍 Arrived at venue: ${b.customerArea ?? 'Madhapur'}!'),
              backgroundColor: AppColors.primary,
            ),
          );
        },
      );
    }

    // ARRIVED -> Mark Complete
    return PrimaryButton(
      label: 'Mark Complete',
      icon: Icons.verified_rounded,
      onTap: () {
        PoojariController.instance.completeBooking(b.ref);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('🎉 ${b.poojaName} completed! ₹${b.feeRupees} credited to your earnings.'),
            backgroundColor: AppColors.success,
          ),
        );
      },
    );
  }

  /// 4. Items List Card with two states:
  /// - Not sent yet: prompt card "Create Pooja Items List"
  /// - Already sent: read-only list view, "Sent ✓" badge + timestamp, plus "Edit List" button
  Widget _buildItemsListCard(BuildContext context, PoojariBooking b) {
    if (!b.itemsListSent) {
      return GlassPanelGold(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ItemsListBuilderScreen(
              bookingRef: b.ref,
              poojaName: b.poojaName,
            ),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.playlist_add_check_rounded, color: AppColors.primary),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Create Pooja Items List',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Select and send required Samagri checklist to customer.',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.primary),
          ],
        ),
      );
    }

    // Already sent state
    return GlassPanel(
      padding: const EdgeInsets.all(16),
      borderRadius: 18,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Icon(Icons.inventory_2_outlined, color: AppColors.primary, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Pooja Items List',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.success.withValues(alpha: 0.4)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.check, color: AppColors.success, size: 13),
                    const SizedBox(width: 4),
                    Text(
                      'Sent ✓ • ${b.itemsListSentAt ?? 'Sent'}',
                      style: const TextStyle(
                        color: AppColors.success,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: b.itemsList.map((id) {
              final prod = findProductById(id);
              final label = prod != null ? prod.name : id;
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.check_circle, color: AppColors.primary, size: 12),
                    const SizedBox(width: 5),
                    Text(
                      label,
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ItemsListBuilderScreen(
                    bookingRef: b.ref,
                    poojaName: b.poojaName,
                    initialSelectedIds: b.itemsList,
                  ),
                ),
              ),
              icon: const Icon(Icons.edit_note, size: 18),
              label: const Text('Edit List'),
            ),
          ),
        ],
      ),
    );
  }

  /// 5. Map placeholder tile showing Customer's location
  Widget _buildCustomerLocationMapTile(BuildContext context, PoojariBooking b) {
    return GlassPanel(
      padding: const EdgeInsets.all(14),
      borderRadius: 18,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.map_outlined, color: AppColors.primary, size: 18),
              const SizedBox(width: 8),
              const Text(
                'CUSTOMER LOCATION ROUTE',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${b.distanceKm} away',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            height: 110,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: const LinearGradient(
                colors: [Color(0xFF1B232E), Color(0xFF131720)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(color: Colors.white12),
            ),
            child: Stack(
              children: [
                CustomPaint(
                  size: const Size(double.infinity, 110),
                  painter: _MockMapPainter(),
                ),
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.4),
                              blurRadius: 12,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: const Icon(Icons.location_on, color: AppColors.onPrimary, size: 20),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.black87,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          b.customerFirstName ?? 'Devotee Venue',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            b.fullAddress,
            style: const TextStyle(color: Colors.white60, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _infoTile(IconData icon, String label, String value) {
    return GlassPanel(
      padding: const EdgeInsets.all(14),
      borderRadius: 16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary, size: 18),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white38,
              fontSize: 10,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _MockMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.05)
      ..strokeWidth = 1.0;

    for (double x = 20; x < size.width; x += 30) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 20; y < size.height; y += 30) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    final routePaint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.35)
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..moveTo(20, size.height - 20)
      ..cubicTo(
        size.width * 0.3,
        size.height * 0.8,
        size.width * 0.4,
        size.height * 0.3,
        size.width * 0.5,
        size.height * 0.5,
      );
    canvas.drawPath(path, routePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
