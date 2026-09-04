import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/glass.dart';
import '../../widgets/common/network_image_placeholder.dart';
import '../../widgets/booking/status_stepper.dart';
import '../../data/shop/shop_data.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});
  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  String _timeFilter = 'Last 30 Days';
  String _statusFilter = 'All';
  final _timeFilters = ['Last 7 Days', 'Last 30 Days', 'This Year', 'Custom Range'];
  final _statusFilters = ['All', 'Placed', 'Dispatched', 'Delivered', 'Cancelled'];

  Color _statusColor(String s) {
    switch (s) {
      case 'Delivered': return const Color(0xFF9DE6B4);
      case 'Dispatched': return const Color(0xFFFFB84D);
      default: return Colors.white54;
    }
  }

  void _reorder(OrderData o) {
    // Honest unavailable-item notice rather than silently skipping.
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${o.itemCount - 1} of ${o.itemCount} items added — 1 item is no longer available')));
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _statusFilter == 'All' ? orders : orders.where((o) => o.status == _statusFilter).toList();

    return GlassScaffold(
      title: 'My Orders',
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
        children: [
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _timeFilters.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) => _chip(_timeFilters[i], _timeFilter == _timeFilters[i], () => setState(() => _timeFilter = _timeFilters[i])),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _statusFilters.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) => _chip(_statusFilters[i], _statusFilter == _statusFilters[i], () => setState(() => _statusFilter = _statusFilters[i])),
            ),
          ),
          const SizedBox(height: 16),
          ...filtered.map((o) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: GlassPanel(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      Expanded(child: Text('Order #${o.id}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13))),
                      Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: _statusColor(o.status).withValues(alpha: 0.15), borderRadius: BorderRadius.circular(20)), child: Text(o.status.toUpperCase(), style: TextStyle(color: _statusColor(o.status), fontSize: 9, fontWeight: FontWeight.w800))),
                    ]),
                    const SizedBox(height: 4),
                    Text('${o.date} · ${o.itemCount} items · ₹${(o.totalPaise / 100).toStringAsFixed(0)}', style: const TextStyle(color: Colors.white54, fontSize: 12)),
                    const SizedBox(height: 10),
                    Row(children: o.itemSeeds.take(3).map((s) => Padding(padding: const EdgeInsets.only(right: 8), child: ClipRRect(borderRadius: BorderRadius.circular(8), child: NetworkImageWithPlaceholder(imageUrl: 'https://picsum.photos/seed/$s/100', width: 44, height: 44)))).toList()),
                    const SizedBox(height: 12),
                    Row(children: [
                      Expanded(child: OutlinedButton(style: OutlinedButton.styleFrom(foregroundColor: AppColors.primary, side: const BorderSide(color: AppColors.primary)), onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => OrderDetailScreen(order: o))), child: const Text('View Details'))),
                      const SizedBox(width: 10),
                      Expanded(child: OutlinedButton.icon(style: OutlinedButton.styleFrom(foregroundColor: Colors.white70, side: const BorderSide(color: Colors.white24)), onPressed: () => _reorder(o), icon: const Icon(Icons.replay, size: 16), label: const Text('Reorder'))),
                    ]),
                  ]),
                ),
              )),
        ],
      ),
    );
  }

  Widget _chip(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(color: selected ? AppColors.primary.withValues(alpha: 0.15) : Colors.transparent, borderRadius: BorderRadius.circular(18), border: Border.all(color: selected ? AppColors.primary : Colors.white24)),
        alignment: Alignment.center,
        child: Text(label, style: TextStyle(color: selected ? AppColors.primary : Colors.white54, fontSize: 11, fontWeight: FontWeight.w600)),
      ),
    );
  }
}

class OrderDetailScreen extends StatefulWidget {
  final OrderData order;
  const OrderDetailScreen({super.key, required this.order});
  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  int? _rating;

  @override
  Widget build(BuildContext context) {
    final o = widget.order;
    final steps = ['Placed', 'Dispatched', 'Out for Delivery', 'Delivered'];
    final icons = [Icons.receipt_long, Icons.local_shipping, Icons.delivery_dining, Icons.check_circle];
    final currentIndex = steps.indexOf(o.status == 'Delivered' ? 'Delivered' : o.status);

    return GlassScaffold(
      title: 'Order #${o.id}',
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
        children: [
          GlassPanel(padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12), child: StatusStepper(steps: steps, icons: icons, currentIndex: currentIndex < 0 ? 0 : currentIndex)),
          const SizedBox(height: 16),
          GlassPanel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const SectionLabel('DELIVERY ADDRESS'), const SizedBox(height: 8),
            const Text('Flat 402, Sri Sai Residency, Hitech City, Hyderabad - 500081', style: TextStyle(color: Colors.white70, fontSize: 13)),
            const SizedBox(height: 14),
            const SectionLabel('PAYMENT'), const SizedBox(height: 8),
            const Text('Paid via UPI', style: TextStyle(color: Colors.white70, fontSize: 13)),
          ])),
          const SizedBox(height: 16),
          if (o.status == 'Delivered')
            GlassPanelGold(child: Column(children: [
              const Text('Rate your order', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700)),
              const SizedBox(height: 10),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(5, (i) => GestureDetector(onTap: () => setState(() => _rating = i + 1), child: Padding(padding: const EdgeInsets.symmetric(horizontal: 3), child: Icon(i < (_rating ?? 0) ? Icons.star : Icons.star_border, color: AppColors.primary, size: 28))))),
            ])),
        ],
      ),
    );
  }
}
