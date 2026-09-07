import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/glass.dart';
import '../../widgets/shop/category_chips.dart';
import '../../widgets/shop/product_card.dart';
import '../../widgets/shop/kit_card.dart';
import '../../widgets/shop/sticky_cart_bar.dart';
import '../../widgets/common/network_image_placeholder.dart';
import '../../data/shop/shop_data.dart';
import 'cart_screen.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});
  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  String _category = 'All';
  int _cartCount = 0;
  int _cartTotal = 0;

  void _addToCart(int pricePaise) => setState(() { _cartCount++; _cartTotal += pricePaise; });

  @override
  Widget build(BuildContext context) {
    final filtered = _category == 'All' ? products : products.where((p) => p.category == _category).toList();
    final essentials = products.where((p) => p.isEssential).toList();

    return GlassScaffold(
      showBack: false,
      title: 'Shop',
      trailing: Stack(clipBehavior: Clip.none, children: [
        IconButton(icon: const Icon(Icons.shopping_cart_outlined), color: AppColors.primary, onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CartScreen()))),
        if (_cartCount > 0) Positioned(right: 2, top: 2, child: Container(padding: const EdgeInsets.all(3), decoration: const BoxDecoration(color: Color(0xFFE05353), shape: BoxShape.circle), child: Text('$_cartCount', style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700)))),
      ]),
      body: Stack(
        children: [
          ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              children: [
                Text('Devotional Shop', style: Theme.of(context).textTheme.headlineLarge?.copyWith(color: AppColors.primary, fontSize: 24, shadows: AppTheme.goldGlow)),
                const SizedBox(height: 6),
                const Text('Curated sacred essentials, delivered with purity and grace.', style: TextStyle(color: Colors.white60, fontSize: 13)),
                const SizedBox(height: 16),
                CategoryChips(selected: _category, onSelect: (c) => setState(() => _category = c)),
                const SizedBox(height: 20),

                // Seasonal Specials — hero treatment, rare/promotional only.
                const SectionLabel('SEASONAL SPECIALS'),
                const SizedBox(height: 10),
                SizedBox(
                  height: 120,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: seasonalBanners.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 12),
                    itemBuilder: (_, i) => ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: SizedBox(width: 200, child: Stack(fit: StackFit.expand, children: [
                        NetworkImageWithPlaceholder(imageUrl: 'https://picsum.photos/seed/${seasonalBanners[i].seed}/400/300'),
                        Container(decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Colors.black87]))),
                        Positioned(left: 12, bottom: 12, right: 12, child: Text(seasonalBanners[i].title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700))),
                      ])),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Essentials — curated shortcut strip, not a category.
                const SectionLabel('ESSENTIALS'),
                const SizedBox(height: 10),
                SizedBox(
                  height: 170,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: essentials.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 12),
                    itemBuilder: (_, i) => SizedBox(width: 130, child: ProductCard(product: essentials[i], onAdd: () => _addToCart(essentials[i].pricePaise))),
                  ),
                ),
                const SizedBox(height: 20),

                // Kits — distinct wide cards.
                ...kits.map((k) => Padding(padding: const EdgeInsets.only(bottom: 14), child: KitCard(kit: k, onAdd: () => _addToCart(k.pricePaise)))),
                const SizedBox(height: 6),

                // Everyday grid — compact, majority of catalog.
                const SectionLabel('ALL PRODUCTS'),
                const SizedBox(height: 10),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 0.72),
                  itemCount: filtered.length,
                  itemBuilder: (_, i) => ProductCard(product: filtered[i], onAdd: () => _addToCart(filtered[i].pricePaise)),
                ),
                const SizedBox(height: 140),
              ],
            ),
          Positioned(
            left: 0, right: 0, bottom: 90,
            child: StickyCartBar(itemCount: _cartCount, totalPaise: _cartTotal, onViewCart: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CartScreen()))),
          ),
        ],
      ),
    );
  }
}
