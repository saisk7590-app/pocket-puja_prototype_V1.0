import 'package:flutter/material.dart';
import 'package:pocket_puja/core/models/pooja_suggested_items.dart';
import 'package:pocket_puja/core/services/poojari_controller.dart';
import 'package:pocket_puja/core/theme/app_theme.dart';
import 'package:pocket_puja/core/widgets/glass.dart';
import 'package:pocket_puja/customer/data/shop/shop_data.dart';
import 'package:pocket_puja/customer/widgets/booking/pooja_item_row.dart';

/// BLOCK 9 — Items List Builder
/// Enables the Poojari to prepare and send a required samagri checklist to the customer.
/// Uses suggested defaults pre-populated by pooja type, plus search-to-add from Shop catalog.
class ItemsListBuilderScreen extends StatefulWidget {
  final String bookingRef;
  final String poojaName;
  final List<String>? initialSelectedIds;

  const ItemsListBuilderScreen({
    super.key,
    required this.bookingRef,
    required this.poojaName,
    this.initialSelectedIds,
  });

  @override
  State<ItemsListBuilderScreen> createState() => _ItemsListBuilderScreenState();
}

class _ItemsListBuilderScreenState extends State<ItemsListBuilderScreen> {
  late final List<ProductData> _suggestedProducts;
  final List<ProductData> _additionalProducts = [];
  late final Set<String> _selectedIds;
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _suggestedProducts = getSuggestedProductsForPooja(widget.poojaName);

    if (widget.initialSelectedIds != null && widget.initialSelectedIds!.isNotEmpty) {
      // Edit mode: restore previously selected items
      _selectedIds = widget.initialSelectedIds!.toSet();
      final suggestedIds = _suggestedProducts.map((p) => p.id).toSet();
      for (final id in _selectedIds) {
        if (!suggestedIds.contains(id)) {
          final prod = findProductById(id);
          if (prod != null) {
            _additionalProducts.add(prod);
          }
        }
      }
    } else {
      // New mode: pre-select all suggested products by default
      _selectedIds = _suggestedProducts.map((p) => p.id).toSet();
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _toggleProduct(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
  }

  void _addSearchedProduct(ProductData prod) {
    setState(() {
      if (!_suggestedProducts.any((p) => p.id == prod.id) &&
          !_additionalProducts.any((p) => p.id == prod.id)) {
        _additionalProducts.add(prod);
      }
      _selectedIds.add(prod.id);
      _searchCtrl.clear();
      _searchQuery = '';
    });
  }

  void _sendToCustomer() {
    if (_selectedIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least 1 item before sending to customer.'),
          backgroundColor: Colors.orangeAccent,
        ),
      );
      return;
    }

    PoojariController.instance.sendItemsList(
      widget.bookingRef,
      _selectedIds.toList(),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Items list sent to customer (${_selectedIds.length} items) ✓'),
        backgroundColor: AppColors.primary,
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    // Filter search results against products catalog
    final existingIds = {
      ..._suggestedProducts.map((p) => p.id),
      ..._additionalProducts.map((p) => p.id),
    };

    final searchResults = _searchQuery.trim().isEmpty
        ? <ProductData>[]
        : products
            .where((p) =>
                !existingIds.contains(p.id) &&
                (p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                    p.category.toLowerCase().contains(_searchQuery.toLowerCase())))
            .toList();

    return GlassScaffold(
      gradient: AppGradients.rust,
      title: 'Items List — ${widget.poojaName}',
      showBack: true,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 110),
        children: [
          // Header info banner
          GlassPanelGold(
            padding: const EdgeInsets.all(14),
            borderRadius: 16,
            child: Row(
              children: [
                const Icon(Icons.checklist_rtl_rounded, color: AppColors.primary, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Pooja Samagri Checklist',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Check the items required for this ritual. The customer will see this list ready in their booking detail.',
                        style: TextStyle(color: Colors.white70, fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Suggested items section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Suggested Items',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_selectedIds.intersection(_suggestedProducts.map((p) => p.id).toSet()).length}/${_suggestedProducts.length} Selected',
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
          ..._suggestedProducts.map((prod) {
            final isChecked = _selectedIds.contains(prod.id);
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: PoojaItemRow.fromProduct(
                product: prod,
                isChecked: isChecked,
                onToggle: () => _toggleProduct(prod.id),
              ),
            );
          }),

          const SizedBox(height: 16),

          // Additional items section (if any added via search)
          if (_additionalProducts.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Additional Items Added',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                Text(
                  '${_selectedIds.intersection(_additionalProducts.map((p) => p.id).toSet()).length} item(s)',
                  style: const TextStyle(color: Colors.white54, fontSize: 11),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ..._additionalProducts.map((prod) {
              final isChecked = _selectedIds.contains(prod.id);
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: PoojaItemRow.fromProduct(
                  product: prod,
                  isChecked: isChecked,
                  onToggle: () => _toggleProduct(prod.id),
                ),
              );
            }),
            const SizedBox(height: 16),
          ],

          // Search to add another item
          Text(
            '+ Add Another Item from Shop Catalog',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 8),
          GlassPanel(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            borderRadius: 14,
            child: TextField(
              controller: _searchCtrl,
              onChanged: (val) => setState(() => _searchQuery = val),
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Search items (e.g. Diyas, Wood, Ghee)...',
                hintStyle: const TextStyle(color: Colors.white38, fontSize: 13),
                icon: const Icon(Icons.search, color: AppColors.primary, size: 20),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.white54, size: 18),
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
              ),
            ),
          ),

          // Search results dropdown list
          if (searchResults.isNotEmpty) ...[
            const SizedBox(height: 8),
            GlassPanel(
              padding: const EdgeInsets.all(8),
              borderRadius: 14,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Text(
                      'Matching Shop Items (${searchResults.length}) — tap to add:',
                      style: const TextStyle(color: Colors.white54, fontSize: 11),
                    ),
                  ),
                  const Divider(color: Colors.white12, height: 8),
                  ...searchResults.map(
                    (p) => ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      dense: true,
                      leading: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.add, color: AppColors.primary, size: 18),
                      ),
                      title: Text(
                        p.name,
                        style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        '${p.category} • ₹${(p.pricePaise / 100).toStringAsFixed(0)}',
                        style: const TextStyle(color: Colors.white54, fontSize: 11),
                      ),
                      trailing: const Text(
                        '+ Add',
                        style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 12),
                      ),
                      onTap: () => _addSearchedProduct(p),
                    ),
                  ),
                ],
              ),
            ),
          ] else if (_searchQuery.trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                'No matching catalog items found.',
                style: TextStyle(color: Colors.white38, fontSize: 11, fontStyle: FontStyle.italic),
              ),
            ),
          ],

          const SizedBox(height: 30),

          // Bottom send button
          PrimaryButton(
            label: 'Send to Customer (${_selectedIds.length} items)',
            icon: Icons.send_rounded,
            onTap: _sendToCustomer,
          ),
        ],
      ),
    );
  }
}
