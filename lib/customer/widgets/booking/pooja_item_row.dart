import 'package:flutter/material.dart';
import 'package:pocket_puja/core/theme/app_theme.dart';
import 'package:pocket_puja/core/widgets/glass.dart';
import 'package:pocket_puja/core/widgets/network_image_placeholder.dart';
import 'package:pocket_puja/customer/data/shop/shop_data.dart';

/// Reusable item row for Customer's checklist and Poojari's items builder.
/// Displays item thumbnail, name, description, price, and selection toggle.
class PoojaItemRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final int? pricePaise;
  final String seed;
  final bool isChecked;
  final VoidCallback? onToggle;
  final bool inShop;

  const PoojaItemRow({
    super.key,
    required this.title,
    required this.subtitle,
    this.pricePaise,
    required this.seed,
    this.isChecked = false,
    this.onToggle,
    this.inShop = true,
  });

  /// Factory helper to build row directly from a Shop ProductData catalog entry
  factory PoojaItemRow.fromProduct({
    Key? key,
    required ProductData product,
    required bool isChecked,
    VoidCallback? onToggle,
  }) {
    return PoojaItemRow(
      key: key,
      title: product.name,
      subtitle: '${product.category} • Essential Samagri',
      pricePaise: product.pricePaise,
      seed: product.seed,
      isChecked: isChecked,
      onToggle: onToggle,
      inShop: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      padding: const EdgeInsets.all(12),
      borderRadius: 18,
      onTap: onToggle,
      child: Row(children: [
        Opacity(
          opacity: inShop ? 1.0 : 0.4,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: NetworkImageWithPlaceholder(
              imageUrl: 'https://picsum.photos/seed/$seed/120',
              width: 52,
              height: 52,
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: inShop ? Colors.white : Colors.white38,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  color: inShop ? Colors.white54 : Colors.white24,
                  fontSize: 11,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (inShop && pricePaise != null) ...[
                const SizedBox(height: 2),
                Text(
                  '₹${(pricePaise! / 100).toStringAsFixed(0)}',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (inShop)
          IconButton(
            icon: Icon(
              isChecked ? Icons.check_circle : Icons.add_circle_outline,
              color: isChecked ? AppColors.primary : Colors.white54,
            ),
            onPressed: onToggle,
          )
        else
          const Padding(
            padding: EdgeInsets.only(right: 8),
            child: Icon(Icons.info_outline, color: Colors.white24, size: 18),
          ),
      ]),
    );
  }
}
