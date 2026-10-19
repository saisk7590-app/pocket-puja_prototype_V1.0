import 'package:flutter/material.dart';
import 'package:pocket_puja/core/theme/app_theme.dart';

typedef MonthGridCellBuilder = Widget Function(
  BuildContext context,
  DateTime date,
  bool isSelected,
);

/// Sizes itself to its actual content (no stretching to fill leftover
/// space) — 6 compact rows max, so it never leaves dead empty space
/// below the last date row.
///
/// Supports custom cell rendering and tap handling via [cellBuilder] and [onDayTap]
/// for screens like Poojari Availability Calendar.
/// Supports event dot indicator via [eventDotColor] without coupling to any data layer.
class MonthGrid extends StatelessWidget {
  final DateTime focusedMonth;
  final int selectedDay;
  final ValueChanged<int>? onSelectDay;
  final void Function(DateTime date)? onDayTap;
  final MonthGridCellBuilder? cellBuilder;
  final Color? Function(DateTime date)? eventDotColor;

  const MonthGrid({
    super.key,
    required this.focusedMonth,
    this.selectedDay = 0,
    this.onSelectDay,
    this.onDayTap,
    this.cellBuilder,
    this.eventDotColor,
  });

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
        Row(
          children: ['SUN', 'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT']
              .map((d) => Expanded(
                    child: Center(
                      child: Text(
                        d,
                        style: const TextStyle(
                          color: Colors.white38,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ))
              .toList(),
        ),
        const SizedBox(height: 6),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            childAspectRatio: 1.35,
          ),
          itemCount: rows * 7,
          itemBuilder: (ctx, i) {
            final dayNum = i - startWeekday + 1;
            if (dayNum < 1 || dayNum > daysInMonth) return const SizedBox();
            final cellDate = DateTime(focusedMonth.year, focusedMonth.month, dayNum);
            final selected = dayNum == selectedDay;

            void handleTap() {
              if (onDayTap != null) {
                onDayTap!(cellDate);
              } else if (onSelectDay != null) {
                onSelectDay!(dayNum);
              }
            }

            if (cellBuilder != null) {
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: handleTap,
                child: cellBuilder!(ctx, cellDate, selected),
              );
            }

            final dotColor = eventDotColor?.call(cellDate);

            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: handleTap,
              child: Container(
                margin: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: selected ? AppColors.primary.withValues(alpha: 0.2) : null,
                  borderRadius: BorderRadius.circular(10),
                  border: selected ? Border.all(color: AppColors.primary) : null,
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Text(
                      '$dayNum',
                      style: TextStyle(
                        color: selected ? AppColors.primary : Colors.white,
                        fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                    if (dotColor != null)
                      Positioned(
                        bottom: 3,
                        child: Container(
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(
                            color: dotColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
