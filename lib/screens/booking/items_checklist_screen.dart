import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/glass.dart';
import '../../widgets/common/network_image_placeholder.dart';
import '../../data/booking/booking_data.dart';
import '../shop/shop_screen.dart';

class ItemsChecklistScreen extends StatefulWidget {
  final String poojaName;
  const ItemsChecklistScreen({super.key, required this.poojaName});
  @override
  State<ItemsChecklistScreen> createState() => _ItemsChecklistScreenState();
}

class _ItemsChecklistScreenState extends State<ItemsChecklistScreen> {
  final Set<String> _added = {};

  void _addAllToCart() {
    setState(() => _added.addAll(poojaItems.where((i) => i.inShop).map((i) => i.nameEn)));
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${poojaItems.where((i) => i.inShop).length} items added to cart')));
  }

  @override
  Widget build(BuildContext context) {
    final inShopCount = poojaItems.where((i) => i.inShop).length;
    return GlassScaffold(
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 110),
        children: [
          Text('Pooja Items Checklist', style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontSize: 24)),
          const SizedBox(height: 8),
          const Text('Ensure you have everything ready for your daily rituals.', style: TextStyle(color: Colors.white60, fontSize: 13)),
          const SizedBox(height: 16),
          PrimaryButton(label: 'Add All to Cart ($inShopCount items)', icon: Icons.shopping_cart, onTap: _addAllToCart),
          const SizedBox(height: 20),
          ...poojaItems.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: GlassPanel(
                  padding: const EdgeInsets.all(12),
                  borderRadius: 18,
                  child: Row(children: [
                    Opacity(
                      opacity: item.inShop ? 1.0 : 0.4,
                      child: ClipRRect(borderRadius: BorderRadius.circular(12), child: NetworkImageWithPlaceholder(imageUrl: 'https://picsum.photos/seed/${item.seed}/120', width: 52, height: 52)),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('${item.nameTe} (${item.nameEn})', style: TextStyle(color: item.inShop ? Colors.white : Colors.white38, fontSize: 14, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 2),
                        Text(item.inShop ? item.desc : 'Not available in Pocket Puja Shop — please arrange this yourself', style: TextStyle(color: item.inShop ? Colors.white54 : Colors.white24, fontSize: 11)),
                        if (item.inShop && item.pricePaise != null) Text('₹${(item.pricePaise! / 100).toStringAsFixed(0)}', style: const TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w700)),
                      ]),
                    ),
                    if (item.inShop)
                      IconButton(
                        icon: Icon(_added.contains(item.nameEn) ? Icons.check_circle : Icons.add_circle_outline, color: AppColors.primary),
                        onPressed: () => setState(() => _added.contains(item.nameEn) ? _added.remove(item.nameEn) : _added.add(item.nameEn)),
                      )
                    else
                      const Padding(padding: EdgeInsets.only(right: 8), child: Icon(Icons.info_outline, color: Colors.white24, size: 18)),
                  ]),
                ),
              )),
          const SizedBox(height: 12),
          GlassPanelGold(
            child: Column(children: [
              const Icon(Icons.storefront, color: AppColors.primary, size: 32),
              const SizedBox(height: 10),
              Text('Devotional Shop', style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: AppColors.primary)),
              const SizedBox(height: 6),
              const Text('Get high-quality ritual items delivered to your doorstep.', textAlign: TextAlign.center, style: TextStyle(color: Colors.white60, fontSize: 12)),
              const SizedBox(height: 14),
              PrimaryButton(label: 'Browse Shop Items', onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ShopScreen()))),
            ]),
          ),
        ],
      ),
    );
  }
}
