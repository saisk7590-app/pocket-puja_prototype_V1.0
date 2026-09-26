import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../data/shop/shop_data.dart';
import '../common/glass.dart';

/// Wider, visually distinct card for Kits/Bundles — deserves more weight
/// since it's a higher-consideration purchase, but not full-bleed hero
/// treatment (that's reserved for Seasonal Specials only).
class KitCard extends StatelessWidget {
  final KitData kit;
  final VoidCallback onAdd;
  const KitCard({super.key, required this.kit, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return GlassPanelGold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(10)), child: const Text('KIT', style: TextStyle(color: AppColors.onPrimary, fontSize: 9, fontWeight: FontWeight.w800))),
            const SizedBox(width: 8),
            Text(kit.tag, style: const TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.w700)),
          ]),
          const SizedBox(height: 6),
          Text(kit.name, style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(kit.desc, style: const TextStyle(color: Colors.white60, fontSize: 12)),
          const SizedBox(height: 12),
          Row(children: [
            Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9), decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(12)), child: Text('₹${(kit.pricePaise / 100).toStringAsFixed(0)}', style: const TextStyle(color: AppColors.onPrimary, fontWeight: FontWeight.w800))),
            const SizedBox(width: 10),
            Expanded(child: OutlinedButton.icon(style: OutlinedButton.styleFrom(foregroundColor: Colors.white, side: const BorderSide(color: Colors.white24)), onPressed: onAdd, icon: const Icon(Icons.add, size: 16), label: const Text('Add to Cart'))),
          ]),
        ],
      ),
    );
  }
}
