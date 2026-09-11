import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

/// Appears only when the cart is non-empty. Deliberately slim and
/// close to the elements below it — a status bar, not a big floating
/// button — so it doesn't compete visually with the nav/mini-player.
class StickyCartBar extends StatelessWidget {
  final int itemCount;
  final int totalPaise;
  final VoidCallback onViewCart;
  const StickyCartBar({super.key, required this.itemCount, required this.totalPaise, required this.onViewCart});

  @override
  Widget build(BuildContext context) {
    if (itemCount == 0) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      child: GestureDetector(
        onTap: onViewCart,
        child: Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          decoration: BoxDecoration(
            gradient: AppGradients.goldButton,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.25), blurRadius: 10, offset: const Offset(0, 3))],
          ),
          child: Row(
            children: [
              Text('$itemCount item${itemCount > 1 ? 's' : ''} · ₹${(totalPaise / 100).toStringAsFixed(0)}', style: const TextStyle(color: AppColors.onPrimary, fontWeight: FontWeight.w700, fontSize: 13)),
              const Spacer(),
              const Text('View Cart', style: TextStyle(color: AppColors.onPrimary, fontWeight: FontWeight.w700, fontSize: 13)),
              const SizedBox(width: 6),
              const Icon(Icons.arrow_forward, color: AppColors.onPrimary, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}