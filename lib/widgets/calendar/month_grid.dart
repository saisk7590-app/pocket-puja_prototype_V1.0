import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../data/calendar/calendar_data.dart';

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

    return Column(
      children: [
        Row(children: ['SUN', 'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT'].map((d) => Expanded(child: Center(child: Text(d, style: const TextStyle(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.w600))))).toList()),
        const SizedBox(height: 8),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7, childAspectRatio: 1),
          itemCount: 42,
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
                  Text('$dayNum', style: TextStyle(color: selected ? AppColors.primary : Colors.white, fontWeight: selected ? FontWeight.w700 : FontWeight.w500, fontSize: 15)),
                  if (fest.isNotEmpty)
                    Positioned(bottom: 5, child: Container(width: 5, height: 5, decoration: BoxDecoration(color: _festivalColor(fest.first.type), shape: BoxShape.circle))),
                ]),
              ),
            );
          },
        ),
      ],
    );
  }
}
