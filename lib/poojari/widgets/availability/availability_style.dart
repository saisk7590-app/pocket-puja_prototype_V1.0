import 'package:flutter/material.dart';
import 'package:pocket_puja/core/services/poojari_controller.dart';
import 'package:pocket_puja/core/theme/app_theme.dart';

/// Visual style configuration for a calendar day cell or legend swatch.
class DayStyle {
  final Color backgroundColor;
  final Color borderColor;
  final Color textColor;
  final FontWeight fontWeight;
  final IconData? icon;
  final Color? iconColor;
  final String label;
  final bool isInteractive;

  const DayStyle({
    required this.backgroundColor,
    required this.borderColor,
    required this.textColor,
    this.fontWeight = FontWeight.w600,
    this.icon,
    this.iconColor,
    required this.label,
    required this.isInteractive,
  });
}

/// Single source of truth for day-state styling across both MonthGrid cells and Legend.
DayStyle getDayStyle(DayAvailabilityState state) {
  switch (state) {
    case DayAvailabilityState.past:
      return DayStyle(
        backgroundColor: Colors.white.withValues(alpha: 0.02),
        borderColor: Colors.transparent,
        textColor: Colors.white24,
        fontWeight: FontWeight.w400,
        icon: null,
        iconColor: null,
        label: 'Past',
        isInteractive: false,
      );

    case DayAvailabilityState.booked:
      return DayStyle(
        // Gold confirmed tone matching Schedule status badge
        backgroundColor: AppColors.primary.withValues(alpha: 0.18),
        borderColor: AppColors.primary,
        textColor: AppColors.primary,
        fontWeight: FontWeight.w700,
        icon: Icons.lock_rounded,
        iconColor: AppColors.primary,
        label: 'Booked',
        isInteractive: true,
      );

    case DayAvailabilityState.recurringOff:
      return const DayStyle(
        // Muted off-day with small repeat icon
        backgroundColor: Color(0x1A9E9E9E),
        borderColor: Colors.white24,
        textColor: Colors.white54,
        fontWeight: FontWeight.w500,
        icon: Icons.repeat_rounded,
        iconColor: Colors.white60,
        label: 'Recurring off-day',
        isInteractive: false,
      );

    case DayAvailabilityState.blockedByMe:
      return const DayStyle(
        // Greyed with busy/blocked mark
        backgroundColor: Color(0x28EF4444),
        borderColor: Color(0x80EF4444),
        textColor: Colors.white70,
        fontWeight: FontWeight.w600,
        icon: Icons.block_rounded,
        iconColor: Color(0xFFEF4444),
        label: 'Blocked by me',
        isInteractive: true,
      );

    case DayAvailabilityState.available:
      return const DayStyle(
        // Default normal tappable cell
        backgroundColor: Color(0x0DFFFFFF),
        borderColor: Colors.white12,
        textColor: Colors.white,
        fontWeight: FontWeight.w600,
        icon: null,
        iconColor: null,
        label: 'Available',
        isInteractive: true,
      );
  }
}
