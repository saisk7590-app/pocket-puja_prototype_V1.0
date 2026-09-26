import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../data/calendar/calendar_data.dart';

/// Sizes itself to its actual content (no stretching to fill leftover
/// space) — 6 compact rows max, so it never leaves dead empty space
/// below the last date row.
class MonthGrid extends StatelessWidget {
  final DateTime focusedMonth;
  final int selectedDay;
  final ValueChanged<int> onSelectDay;
  const MonthGrid({super.key, required this.focusedMonth, required this.selectedDay, required this.onSelectDay});

  Color _festivalColor(String type) {
    switch (type) {
      case 'amavasya': return Colors.white70;
      case 'pournami': return const Color(0xFFF2CA50);
      case 'ekadasi': return const Color(0xFF9DE6B4);
      default: return const Color(0xFFE05353);
    }
  }

  @override
  Widget build(BuildContext context) {
    final firstDay = DateTime(focusedMonth.year, focusedMonth.month, 1);
    final daysInMonth = DateTime(focusedMonth.year, focusedMonth.month + 1, 0).day;
    final startWeekday = firstDay.weekday % 7;
    final totalCells = startWeekday + daysInMonth;
    final rows = (totalCells / 7).ceil(); // usually 5, sometimes 6

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(children: ['SUN', 'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT'].map((d) => Expanded(child: Center(child: Text(d, style: const TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.w600))))).toList()),
        const SizedBox(height: 6),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7, childAspectRatio: 1.35),
          itemCount: rows * 7,
          itemBuilder: (_, i) {
            final dayNum = i - startWeekday + 1;
            if (dayNum < 1 || dayNum > daysInMonth) return const SizedBox();
            final selected = dayNum == selectedDay;
            final fest = festivals.where((f) => f.day == dayNum && f.month == focusedMonth.month).toList();

            return GestureDetector(
              onTap: () => onSelectDay(dayNum),
              child: Container(
                margin: const EdgeInsets.all(2),
                decoration: BoxDecoration(color: selected ? AppColors.primary.withValues(alpha: 0.2) : null, borderRadius: BorderRadius.circular(10), border: selected ? Border.all(color: AppColors.primary) : null),
                child: Stack(alignment: Alignment.center, children: [
                  Text('$dayNum', style: TextStyle(color: selected ? AppColors.primary : Colors.white, fontWeight: selected ? FontWeight.w700 : FontWeight.w500, fontSize: 13)),
                  if (fest.isNotEmpty)
                    Positioned(bottom: 3, child: Container(width: 4, height: 4, decoration: BoxDecoration(color: _festivalColor(fest.first.type), shape: BoxShape.circle))),
                ]),
              ),
            );
          },
        ),
      ],
    );
  }
}