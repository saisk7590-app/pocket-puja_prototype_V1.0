import 'package:flutter/material.dart';
import 'package:pocket_puja/core/theme/app_theme.dart';
import 'package:pocket_puja/core/widgets/glass.dart';
import 'package:pocket_puja/poojari/widgets/reviews/rating_distribution_bar.dart';
import 'package:pocket_puja/poojari/widgets/reviews/star_rating_display.dart';

/// Summary card displaying aggregate rating, total review count, and the 5-star distribution bar.
class ReviewsSummaryHeader extends StatelessWidget {
  final double averageRating;
  final int totalCount;
  final Map<int, int> distribution;

  const ReviewsSummaryHeader({
    super.key,
    required this.averageRating,
    required this.totalCount,
    required this.distribution,
  });

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      padding: const EdgeInsets.all(20),
      borderRadius: 20,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left side: large rating display & total reviews
          SizedBox(
            width: 110,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  averageRating.toStringAsFixed(1),
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        fontSize: 40,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                        height: 1.0,
                        shadows: AppTheme.goldGlow,
                      ),
                ),
                const SizedBox(height: 6),
                StarRatingDisplay(
                  rating: averageRating.round(),
                  size: 15,
                ),
                const SizedBox(height: 6),
                Text(
                  '$totalCount reviews',
                  style: const TextStyle(
                    color: Colors.white60,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Vertical divider line
          Container(
            width: 1,
            height: 90,
            color: Colors.white12,
          ),
          const SizedBox(width: 16),
          // Right side: 5-level distribution bars
          Expanded(
            child: RatingDistributionBar(
              distribution: distribution,
              totalCount: totalCount,
            ),
          ),
        ],
      ),
    );
  }
}
