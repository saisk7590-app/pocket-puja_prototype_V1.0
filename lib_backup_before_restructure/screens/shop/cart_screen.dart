import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/glass.dart';
import '../../widgets/common/network_image_placeholder.dart';
import '../../data/shop/shop_data.dart';
import '../../data/profile/profile_data.dart';
import '../profile/addresses_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});
  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  int _paymentMethod = 0;
  bool _isPaying = false;
  AddressData? _address = addresses.isNotEmpty ? addresses.first : null;

  Future<void> _pay() async {
    setState(() => _isPaying = true);
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Order placed! 🙏')));
  }

  @override
  Widget build(BuildContext context) {
    final subtotal = sampleCart.fold<int>(0, (sum, i) => sum + i.pricePaise * i.qty);
    final tax = (subtotal * 0.05).round();
    final total = subtotal + tax;

    return GlassScaffold(
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Order Summary', style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontSize: 22)),
            Text('${sampleCart.length} ITEMS', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 12)),
          ]),
          const SizedBox(height: 14),
          GlassPanel(
            child: Column(children: [
              ...sampleCart.map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Row(children: [
                      ClipRRect(borderRadius: BorderRadius.circular(12), child: NetworkImageWithPlaceholder(imageUrl: 'https://picsum.photos/seed/${item.seed}/120', width: 52, height: 52)),
                      const SizedBox(width: 14),
                      Expanded(child: Text(item.name, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600))),
                      Text('₹${(item.pricePaise / 100).toStringAsFixed(0)}', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700)),
                    ]),
                  )),
              const Divider(color: Colors.white12),
              Row(children: [const Text('Subtotal', style: TextStyle(color: Colors.white70)), const Spacer(), Text('₹${(subtotal / 100).toStringAsFixed(0)}', style: const TextStyle(color: Colors.white70))]),
              const SizedBox(height: 8),
              Row(children: [const Text('Tax', style: TextStyle(color: Colors.white70)), const Spacer(), Text('₹${(tax / 100).toStringAsFixed(0)}', style: const TextStyle(color: Colors.white70))]),
              const SizedBox(height: 12),
              const Divider(color: Colors.white12),
              Row(children: [const Text('Total', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16)), const Spacer(), Text('₹${(total / 100).toStringAsFixed(0)}', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800, fontSize: 20))]),
            ]),
          ),
          const SizedBox(height: 20),

          GlassPanel(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const SectionLabel('DELIVERY ADDRESS'),
              const SizedBox(height: 10),
              GlassPanel(
                padding: const EdgeInsets.all(12), borderRadius: 14,
                onTap: () async {
                  final picked = await Navigator.of(context).push<AddressData>(MaterialPageRoute(builder: (_) => const AddressesScreen(pickMode: true)));
                  if (picked != null) setState(() => _address = picked);
                },
                child: Row(children: [
                  const Icon(Icons.location_on_outlined, color: AppColors.primary, size: 18),
                  const SizedBox(width: 10),
                  Expanded(child: Text(_address?.line ?? 'Select address', style: const TextStyle(color: Colors.white, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis)),
                  const Icon(Icons.chevron_right, color: Colors.white38, size: 18),
                ]),
              ),
              if (_address != null) Padding(padding: const EdgeInsets.only(top: 8), child: Text('Arrives by Oct 22 — 2 days before your pooja', style: TextStyle(color: AppColors.primary.withValues(alpha: 0.8), fontSize: 11, fontWeight: FontWeight.w600))),
            ]),
          ),
          const SizedBox(height: 20),

          GlassPanel(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const SectionLabel('PAYMENT METHOD'),
              const SizedBox(height: 14),
              RadioGroup<int>(
                groupValue: _paymentMethod,
                onChanged: (v) => setState(() => _paymentMethod = v ?? 0),
                child: Column(
                  children: [
                    _payOption(0, Icons.qr_code, 'UPI / Google Pay', 'Instant & Secure'),
                    const SizedBox(height: 10),
                    _payOption(1, Icons.credit_card, 'Credit / Debit Card', 'Visa, Mastercard, Amex'),
                    const SizedBox(height: 10),
                    _payOption(2, Icons.account_balance, 'Netbanking', 'All major Indian banks'),
                  ],
                ),
              ),
            ]),
          ),
          const SizedBox(height: 24),
          PrimaryButton(label: 'Pay ₹${(total / 100).toStringAsFixed(0)}', icon: Icons.lock, isLoading: _isPaying, onTap: _pay, height: 56),
          const SizedBox(height: 8),
          const Center(child: Text('SECURE 256-BIT SSL ENCRYPTED PAYMENT', style: TextStyle(color: Colors.white24, fontSize: 10))),
        ],
      ),
    );
  }

  Widget _payOption(int index, IconData icon, String title, String sub) {
    final selected = _paymentMethod == index;
    return GestureDetector(
      onTap: () => setState(() => _paymentMethod = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.04), borderRadius: BorderRadius.circular(14), border: Border.all(color: selected ? AppColors.primary : Colors.white12)),
        child: Row(
          children: [
            Radio<int>(value: index, activeColor: AppColors.primary),
            Container(width: 36, height: 36, decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: AppColors.primary, size: 18)),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)), Text(sub, style: const TextStyle(color: Colors.white54, fontSize: 11))])),
          ],
        ),
      ),
    );
  }
}