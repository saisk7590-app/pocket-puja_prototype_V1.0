import 'package:flutter/material.dart';
import 'package:pocket_puja/core/theme/app_theme.dart';
import 'package:pocket_puja/core/widgets/glass.dart';
import 'package:pocket_puja/customer/widgets/booking/pooja_item_row.dart';
import 'package:pocket_puja/customer/data/booking/booking_data.dart';
import 'package:pocket_puja/customer/screens/shop/shop_screen.dart';

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
                child: PoojaItemRow(
                  title: '${item.nameTe} (${item.nameEn})',
                  subtitle: item.inShop ? item.desc : 'Not available in Pocket Puja Shop — please arrange this yourself',
                  pricePaise: item.pricePaise,
                  seed: item.seed,
                  inShop: item.inShop,
                  isChecked: _added.contains(item.nameEn),
                  onToggle: item.inShop
                      ? () => setState(() => _added.contains(item.nameEn) ? _added.remove(item.nameEn) : _added.add(item.nameEn))
                      : null,
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
