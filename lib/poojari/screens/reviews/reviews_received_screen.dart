import 'package:flutter/material.dart';
import 'package:pocket_puja/core/models/review.dart';
import 'package:pocket_puja/core/services/poojari_controller.dart';
import 'package:pocket_puja/core/theme/app_theme.dart';
import 'package:pocket_puja/core/widgets/glass.dart';
import 'package:pocket_puja/poojari/widgets/reviews/poojari_review_card.dart';
import 'package:pocket_puja/poojari/widgets/reviews/review_reply_sheet.dart';
import 'package:pocket_puja/poojari/widgets/reviews/reviews_summary_header.dart';

/// BLOCK 13 — Reviews Received Screen
///
/// Displays devotee reviews received by the Poojari with:
/// 1. Summary header (large average rating, total count, 5-level distribution bar)
/// 2. Filter chips (All / 5★ / 4★ / 3★ / 2★ & below)
/// 3. Review cards with customer FIRST NAME only, ratings, comments, and reply area
/// 4. Respond flow with bottom sheet dialog
/// 5. Back-arrow GlassAppBar
class ReviewsReceivedScreen extends StatefulWidget {
  const ReviewsReceivedScreen({super.key});

  @override
  State<ReviewsReceivedScreen> createState() => _ReviewsReceivedScreenState();
}

class _ReviewsReceivedScreenState extends State<ReviewsReceivedScreen> {
  int _selectedFilter = 0;

  static const List<String> _filters = [
    'All',
    '5★',
    '4★',
    '3★',
    '2★ & below',
  ];

  List<Review> _filterReviews(List<Review> all) {
    switch (_selectedFilter) {
      case 1:
        return all.where((r) => r.stars == 5).toList();
      case 2:
        return all.where((r) => r.stars == 4).toList();
      case 3:
        return all.where((r) => r.stars == 3).toList();
      case 4:
        return all.where((r) => r.stars <= 2).toList();
      case 0:
      default:
        return all;
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = PoojariControllerScope.maybeOf(context) ?? PoojariController.instance;

    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final reviews = controller.reviews;
        final filteredReviews = _filterReviews(reviews);

        return GlassScaffold(
          title: 'Devotee Reviews',
          showBack: true,
          body: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
            children: [
              // 1. Summary Header
              ReviewsSummaryHeader(
                averageRating: controller.averageRating,
                totalCount: controller.totalReviewCount,
                distribution: controller.reviewDistribution,
              ),
              const SizedBox(height: 18),

              // 2. Filter chips row reusing Block 1/11 FilterChip styling
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(_filters.length, (i) {
                    final label = _filters[i];
                    final isSelected = _selectedFilter == i;

                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(label),
                        selected: isSelected,
                        onSelected: (_) => setState(() => _selectedFilter = i),
                        backgroundColor: Colors.white.withValues(alpha: 0.05),
                        selectedColor: AppColors.primary.withValues(alpha: 0.25),
                        checkmarkColor: AppColors.primary,
                        labelStyle: TextStyle(
                          color: isSelected ? AppColors.primary : Colors.white70,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          fontSize: 13,
                        ),
                        side: BorderSide(
                          color: isSelected ? AppColors.primary : Colors.white12,
                          width: isSelected ? 1.4 : 1.0,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 18),

              // 3. Review cards or Empty State
              if (filteredReviews.isEmpty)
                GlassPanel(
                  padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                  borderRadius: 18,
                  child: const Column(
                    children: [
                      Icon(
                        Icons.rate_review_outlined,
                        size: 44,
                        color: Colors.white24,
                      ),
                      SizedBox(height: 12),
                      Text(
                        'No reviews in this category',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Devotee feedback matching this filter will appear here.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white60, fontSize: 12),
                      ),
                    ],
                  ),
                )
              else
                ...filteredReviews.map(
                  (review) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: PoojariReviewCard(
                      review: review,
                      onRespond: () => ReviewReplySheet.show(
                        context,
                        review: review,
                        controller: controller,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
