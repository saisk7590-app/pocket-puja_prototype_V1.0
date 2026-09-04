import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

/// Appears only when the cart is non-empty, sitting above the bottom
/// nav — the conversion-driving element (Instacart/Swiggy-style), while
/// the header cart icon stays a quiet always-present shortcut.
class StickyCartBar extends StatelessWidget {
  final int itemCount;
  final int totalPaise;
  final VoidCallback onViewCart;
  const StickyCartBar({super.key, required this.itemCount, required this.totalPaise, required this.onViewCart});

  @override
  Widget build(BuildContext context) {
    if (itemCount == 0) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
      child: GestureDetector(
        onTap: onViewCart,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(gradient: AppGradients.goldButton, borderRadius: BorderRadius.circular(18), boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.4), blurRadius: 16, offset: const Offset(0, 4))]),
          child: Row(children: [
            Text('$itemCount item${itemCount > 1 ? 's' : ''} · ₹${(totalPaise / 100).toStringAsFixed(0)}', style: const TextStyle(color: AppColors.onPrimary, fontWeight: FontWeight.w800, fontSize: 14)),
            const Spacer(),
            const Text('View Cart', style: TextStyle(color: AppColors.onPrimary, fontWeight: FontWeight.w800, fontSize: 14)),
            const Icon(Icons.arrow_forward, color: AppColors.onPrimary, size: 18),
          ]),
        ),
      ),
    );
  }
}
