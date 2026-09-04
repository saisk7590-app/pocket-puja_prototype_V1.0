import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/glass.dart';
import '../../widgets/booking/pandit_card.dart';
import '../../widgets/booking/status_stepper.dart';
import '../../data/booking/booking_data.dart';
import 'items_checklist_screen.dart';

class BookingDetailScreen extends StatelessWidget {
  final String poojaName, bookingId, status;
  const BookingDetailScreen({super.key, required this.poojaName, required this.bookingId, this.status = 'ASSIGNED'});

  static const _steps = ['PENDING', 'ASSIGNED', 'CONFIRMED', 'DONE'];
  static const _stepIcons = [Icons.check, Icons.person, Icons.verified, Icons.auto_awesome];

  void _showCancelSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(color: AppColors.surfaceContainerHigh, borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 20),
            const Text('Need to make a change?', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            GlassPanel(padding: const EdgeInsets.all(14), borderRadius: 16, onTap: () => Navigator.pop(context), child: Row(children: const [
              Icon(Icons.edit_calendar, color: AppColors.primary), SizedBox(width: 12),
              Text('Reschedule', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
            ])),
            const SizedBox(height: 12),
            DestructiveButton(label: 'Cancel Booking', icon: Icons.close, onTap: () { Navigator.pop(context); Navigator.pop(context); }),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentStepIndex = _steps.indexOf(status);

    return GlassScaffold(
      gradient: AppGradients.rust,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
        children: [
          Center(child: Column(children: [
            Text(poojaName, textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineLarge?.copyWith(color: AppColors.primary, fontSize: 24, shadows: AppTheme.goldGlow)),
            const SizedBox(height: 6),
            Text('Booking ID: #$bookingId', style: const TextStyle(color: Colors.white54, fontSize: 13)),
          ])),
          const SizedBox(height: 20),

          if (status == 'PENDING')
            GlassPanel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: const [
                Icon(Icons.hourglass_top, color: AppColors.primary), SizedBox(width: 10),
                Text('Finding your Poojari...', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 15)),
              ]),
              const SizedBox(height: 8),
              const Text('We typically assign within 4 hours. Your booking details are confirmed below.', style: TextStyle(color: Colors.white60, fontSize: 12)),
            ]))
          else
            PanditCard(pandit: assignedPandit, onCall: () {}, onMessage: () {}),
          const SizedBox(height: 16),

          GlassPanel(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
            child: StatusStepper(steps: _steps, icons: _stepIcons, currentIndex: currentStepIndex),
          ),
          const SizedBox(height: 16),

          if (status != 'PENDING')
            GlassPanelGold(
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => ItemsChecklistScreen(poojaName: poojaName))),
              child: Row(children: [
                Container(width: 44, height: 44, decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.inventory_2_outlined, color: AppColors.primary)),
                const SizedBox(width: 14),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
                  Text('Items List Ready', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 15)),
                  SizedBox(height: 2),
                  Text('We\'ve updated the list of Samagri required for the Puja.', style: TextStyle(color: Colors.white70, fontSize: 12)),
                ])),
                const Icon(Icons.chevron_right, color: AppColors.primary),
              ]),
            ),
          const SizedBox(height: 14),

          Row(children: [
            Expanded(child: _infoTile(Icons.calendar_today, 'DATE', '24 Oct, 2023')),
            const SizedBox(width: 12),
            Expanded(child: _infoTile(Icons.location_on_outlined, 'LOCATION', 'Hitech City, Hyd')),
          ]),
          const SizedBox(height: 20),

          Center(
            child: GestureDetector(
              onTap: () => _showCancelSheet(context),
              child: const Text('Need to reschedule or cancel?', style: TextStyle(color: Colors.white38, fontSize: 12, decoration: TextDecoration.underline)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoTile(IconData icon, String label, String value) {
    return GlassPanel(
      padding: const EdgeInsets.all(14),
      borderRadius: 16,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, color: AppColors.primary, size: 18),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(color: Colors.white38, fontSize: 10, letterSpacing: 0.5)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
      ]),
    );
  }
}
