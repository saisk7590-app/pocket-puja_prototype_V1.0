import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../data/booking/booking_data.dart';
import '../common/glass.dart';
import '../common/network_image_placeholder.dart';

class PanditCard extends StatelessWidget {
  final PanditData pandit;
  final VoidCallback onCall, onMessage;
  const PanditCard({super.key, required this.pandit, required this.onCall, required this.onMessage});

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(borderRadius: BorderRadius.circular(14), child: NetworkImageWithPlaceholder(imageUrl: 'https://picsum.photos/seed/${pandit.seed}/200', width: 64, height: 64)),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(20)),
                      child: const Text('Assigned', style: TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.w700)),
                    ),
                    const SizedBox(height: 6),
                    Text(pandit.name, style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700)),
                    Text(pandit.title, style: const TextStyle(color: Colors.white54, fontSize: 12)),
                    const SizedBox(height: 4),
                    Row(children: [
                      const Icon(Icons.star, color: AppColors.primary, size: 14),
                      const SizedBox(width: 4),
                      Text('${pandit.rating} · ${pandit.poojaCount} poojas', style: const TextStyle(color: Colors.white70, fontSize: 11)),
                    ]),
                    Row(children: [
                      const Icon(Icons.access_time, color: AppColors.primary, size: 14),
                      const SizedBox(width: 4),
                      Text('Arriving at ${pandit.arrivalTime}', style: const TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w600)),
                    ]),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(child: _ActionBtn(icon: Icons.call, label: 'Call', onTap: onCall)),
            const SizedBox(width: 12),
            Expanded(child: _ActionBtn(icon: Icons.message_outlined, label: 'Message', onTap: onMessage)),
          ]),
        ],
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _ActionBtn({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.06), borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.white24)),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, color: Colors.white70, size: 18),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
        ]),
      ),
    );
  }
}
