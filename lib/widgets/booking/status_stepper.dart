import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

/// Reused for both Booking status AND Order tracking (relabeled), so the
/// same visual pattern is learned once and applied twice.
class StatusStepper extends StatelessWidget {
  final List<String> steps;
  final List<IconData> icons;
  final int currentIndex;
  const StatusStepper({super.key, required this.steps, required this.icons, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(steps.length, (i) {
        final active = i <= currentIndex;
        return Expanded(
          child: Column(
            children: [
              Row(children: [
                if (i > 0) Expanded(child: Container(height: 2, color: i <= currentIndex ? AppColors.primary : Colors.white24)),
                Container(
                  width: 34, height: 34,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: active ? AppColors.primary : Colors.white12),
                  child: Icon(icons[i], size: 16, color: active ? AppColors.onPrimary : Colors.white38),
                ),
                if (i < steps.length - 1) Expanded(child: Container(height: 2, color: i < currentIndex ? AppColors.primary : Colors.white24)),
              ]),
              const SizedBox(height: 6),
              Text(steps[i], style: TextStyle(color: active ? AppColors.primary : Colors.white38, fontSize: 9, fontWeight: FontWeight.w700)),
            ],
          ),
        );
      }),
    );
  }
}
