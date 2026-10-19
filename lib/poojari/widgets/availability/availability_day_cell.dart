import 'package:flutter/material.dart';
import 'package:pocket_puja/core/services/poojari_controller.dart';
import 'package:pocket_puja/core/theme/app_theme.dart';
import 'package:pocket_puja/poojari/widgets/availability/availability_style.dart';

/// Renders a single calendar day cell on the Poojari Availability Calendar.
/// Adheres strictly to the 5 visual day states defined in [DayAvailabilityState].
class AvailabilityDayCell extends StatelessWidget {
  final DateTime date;
  final DayAvailabilityState state;
  final bool isToday;

  const AvailabilityDayCell({
    super.key,
    required this.date,
    required this.state,
    this.isToday = false,
  });

  @override
  Widget build(BuildContext context) {
    final style = getDayStyle(state);

    return Container(
      margin: const EdgeInsets.all(2.5),
      decoration: BoxDecoration(
        color: style.backgroundColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isToday && state == DayAvailabilityState.available
              ? AppColors.primary
              : style.borderColor,
          width: isToday || state == DayAvailabilityState.booked ? 1.4 : 1.0,
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Day number
          Text(
            '${date.day}',
            style: TextStyle(
              color: style.textColor,
              fontWeight: style.fontWeight,
              fontSize: 13,
            ),
          ),

          // State marker icon (lock for Booked, repeat for recurring-off, block for busy)
          if (style.icon != null)
            Positioned(
              bottom: 3,
              child: Icon(
                style.icon,
                size: 11,
                color: style.iconColor,
              ),
            ),

          // Small today indicator dot if today has no other badge
          if (isToday && style.icon == null)
            Positioned(
              bottom: 3,
              child: Container(
                width: 4,
                height: 4,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
