import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../data/shop/shop_data.dart';

class CategoryChips extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onSelect;
  const CategoryChips({super.key, required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final c = categories[i].label;
          final isSel = selected == c;
          return GestureDetector(
            onTap: () => onSelect(c),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSel ? AppColors.primary.withValues(alpha: 0.15) : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: isSel ? AppColors.primary : Colors.white24),
              ),
              alignment: Alignment.center,
              child: Text(c, style: TextStyle(color: isSel ? AppColors.primary : Colors.white54, fontSize: 12, fontWeight: FontWeight.w600)),
            ),
          );
        },
      ),
    );
  }
}
