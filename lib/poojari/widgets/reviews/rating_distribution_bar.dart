import 'package:flutter/material.dart';
import 'package:pocket_puja/core/theme/app_theme.dart';

/// Shows a breakdown bar for each star level (5★ down to 1★) with filled bars and percentages.
class RatingDistributionBar extends StatelessWidget {
  final Map<int, int> distribution;
  final int totalCount;

  const RatingDistributionBar({
    super.key,
    required this.distribution,
    required this.totalCount,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [5, 4, 3, 2, 1].map((stars) {
        final count = distribution[stars] ?? 0;
        final fraction = totalCount > 0 ? count / totalCount : 0.0;
        final percent = (fraction * 100).round();

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 2.5),
          child: Row(
            children: [
              SizedBox(
                width: 24,
                child: Text(
                  '$stars★',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: fraction,
                    minHeight: 6,
                    backgroundColor: Colors.white.withValues(alpha: 0.08),
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: 32,
                child: Text(
                  '$percent%',
                  textAlign: TextAlign.end,
                  style: const TextStyle(
                    color: Colors.white38,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
