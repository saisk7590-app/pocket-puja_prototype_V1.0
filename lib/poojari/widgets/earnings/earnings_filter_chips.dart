import 'package:flutter/material.dart';
import 'package:pocket_puja/core/theme/app_theme.dart';

/// Individual filter chip structurally and visually mirroring Customer My Orders filter chip pattern:
/// - Horizontal capsule with rounded corners (18px)
/// - Gold border and 0.15 alpha primary gold fill when selected
/// - Semi-transparent white border and white54 text when unselected
class EarningsFilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;

  const EarningsFilterChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary.withValues(alpha: 0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? AppColors.primary : Colors.white24,
            width: selected ? 1.5 : 1.0,
          ),
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 13,
                color: selected ? AppColors.primary : Colors.white54,
              ),
              const SizedBox(width: 5),
            ],
            Text(
              label,
              style: TextStyle(
                color: selected ? AppColors.primary : Colors.white54,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Horizontal scrollable bar for time filters:
/// - This Month
/// - Last Month
/// - All Time
/// - Custom Range
class EarningsTimeFilterBar extends StatelessWidget {
  final String selectedFilter;
  final ValueChanged<String> onFilterSelected;
  final DateTimeRange? customDateRange;
  final VoidCallback onCustomRangeTap;

  const EarningsTimeFilterBar({
    super.key,
    required this.selectedFilter,
    required this.onFilterSelected,
    this.customDateRange,
    required this.onCustomRangeTap,
  });

  static const List<String> defaultFilters = [
    'This Month',
    'Last Month',
    'All Time',
    'Custom Range',
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: defaultFilters.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final filter = defaultFilters[i];
          final isSelected = selectedFilter == filter;

          if (filter == 'Custom Range') {
            String label = 'Custom Range';
            if (isSelected && customDateRange != null) {
              final start = customDateRange!.start;
              final end = customDateRange!.end;
              label = '${start.day}/${start.month} - ${end.day}/${end.month}';
            }
            return EarningsFilterChip(
              label: label,
              selected: isSelected,
              icon: Icons.date_range_rounded,
              onTap: () {
                onFilterSelected('Custom Range');
                onCustomRangeTap();
              },
            );
          }

          return EarningsFilterChip(
            label: filter,
            selected: isSelected,
            onTap: () => onFilterSelected(filter),
          );
        },
      ),
    );
  }
}
