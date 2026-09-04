import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../data/home/home_data.dart';
import '../common/glass.dart';

class FestivalBanner extends StatelessWidget {
  final UpcomingFestivalBanner festival;
  final VoidCallback onBookNow;
  const FestivalBanner({super.key, required this.festival, required this.onBookNow});

  @override
  Widget build(BuildContext context) {
    return GlassPanelGold(
      child: Row(
        children: [
          const Icon(Icons.celebration, color: AppColors.primary, size: 28),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${festival.name} in ${festival.daysAway}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
                const Text('Book your Poojari early for this festival.', style: TextStyle(color: Colors.white60, fontSize: 11)),
              ],
            ),
          ),
          GestureDetector(
            onTap: onBookNow,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(14)),
              child: const Text('Book Now', style: TextStyle(color: AppColors.onPrimary, fontWeight: FontWeight.w700, fontSize: 12)),
            ),
          ),
        ],
      ),
    );
  }
}
