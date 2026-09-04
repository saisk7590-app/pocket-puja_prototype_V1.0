import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../data/shop/shop_data.dart';
import '../common/network_image_placeholder.dart';

/// Compact grid tile — the majority of the catalog gets this efficient
/// treatment, not the old full-bleed "fatty" card style.
class ProductCard extends StatelessWidget {
  final ProductData product;
  final VoidCallback onAdd;
  const ProductCard({super.key, required this.product, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final discount = ((product.mrpPaise - product.pricePaise) / product.mrpPaise * 100).round();
    return Container(
      decoration: BoxDecoration(color: AppColors.surfaceContainer, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                ClipRRect(borderRadius: const BorderRadius.vertical(top: Radius.circular(16)), child: NetworkImageWithPlaceholder(imageUrl: 'https://picsum.photos/seed/${product.seed}/200', width: double.infinity, fit: BoxFit.cover)),
                if (discount > 0)
                  Positioned(left: 6, top: 6, child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: const Color(0xFFE05353), borderRadius: BorderRadius.circular(6)),
                    child: Text('$discount% OFF', style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: Colors.white)),
                  )),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.name, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Row(children: [
                  Text('₹${(product.pricePaise / 100).toStringAsFixed(0)}', style: const TextStyle(color: AppColors.primary, fontSize: 14, fontWeight: FontWeight.w800)),
                  const Spacer(),
                  GestureDetector(onTap: onAdd, child: const Icon(Icons.add_circle, color: AppColors.primary, size: 22)),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
