import 'package:flutter/material.dart';
import 'package:pocket_puja/core/services/poojari_controller.dart';
import 'package:pocket_puja/poojari/widgets/availability/availability_style.dart';

/// Small, always-visible legend beneath the Availability MonthGrid.
/// Built directly from [getDayStyle] so the legend swatches and calendar cells never drift apart.
class AvailabilityLegend extends StatelessWidget {
  const AvailabilityLegend({super.key});

  static const List<DayAvailabilityState> _legendStates = [
    DayAvailabilityState.available,
    DayAvailabilityState.blockedByMe,
    DayAvailabilityState.booked,
    DayAvailabilityState.recurringOff,
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white10),
      ),
      child: Wrap(
        spacing: 16,
        runSpacing: 8,
        alignment: WrapAlignment.spaceAround,
        children: _legendStates.map((state) {
          final style = getDayStyle(state);
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: style.backgroundColor,
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(color: style.borderColor, width: 1.1),
                ),
                alignment: Alignment.center,
                child: style.icon != null
                    ? Icon(
                        style.icon,
                        size: 10,
                        color: style.iconColor,
                      )
                    : null,
              ),
              const SizedBox(width: 6),
              Text(
                style.label,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}
