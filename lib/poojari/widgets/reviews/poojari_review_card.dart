import 'package:flutter/material.dart';
import 'package:pocket_puja/core/models/review.dart';
import 'package:pocket_puja/core/theme/app_theme.dart';
import 'package:pocket_puja/core/widgets/glass.dart';
import 'package:pocket_puja/poojari/widgets/reviews/star_rating_display.dart';

/// Card displaying an individual devotee review with privacy rules and Poojari reply area.
class PoojariReviewCard extends StatelessWidget {
  final Review review;
  final VoidCallback onRespond;

  const PoojariReviewCard({
    super.key,
    required this.review,
    required this.onRespond,
  });

  @override
  Widget build(BuildContext context) {
    final firstInitial = review.customerFirstName.isNotEmpty
        ? review.customerFirstName[0].toUpperCase()
        : 'D';

    return GlassPanel(
      padding: const EdgeInsets.all(16),
      borderRadius: 18,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Top row: Devotee Avatar + First Name only (privacy rule) + Relative timestamp
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.18),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.5),
                        width: 1.2,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      firstInitial,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    review.customerFirstName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              Text(
                review.relativeTime,
                style: const TextStyle(
                  color: Colors.white38,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // 2. Stars row + Pooja name and date
          Row(
            children: [
              StarRatingDisplay(rating: review.stars, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${review.poojaName} • ${review.date}',
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white60,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),

          // 3. Devotee comment (omitted entirely if null or empty)
          if (review.comment != null && review.comment!.trim().isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              '"${review.comment!.trim()}"',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontStyle: FontStyle.italic,
                height: 1.4,
              ),
            ),
          ],
          const SizedBox(height: 14),

          // 4. Reply area (Unreplied -> "Respond" button; Replied -> Nested quoted response box with "Edit")
          if (!review.hasReply)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: onRespond,
                icon: const Icon(Icons.reply_rounded, size: 16, color: AppColors.primary),
                label: const Text(
                  'Respond',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
                style: TextButton.styleFrom(
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(color: AppColors.primary.withValues(alpha: 0.3)),
                  ),
                ),
              ),
            )
          else
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.check_circle_outline_rounded,
                            size: 14,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            'Your reply',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          if (review.replyRelativeTime.isNotEmpty) ...[
                            const SizedBox(width: 6),
                            Text(
                              '• ${review.replyRelativeTime}',
                              style: const TextStyle(color: Colors.white38, fontSize: 11),
                            ),
                          ],
                        ],
                      ),
                      GestureDetector(
                        onTap: onRespond,
                        behavior: HitTestBehavior.opaque,
                        child: const Row(
                          children: [
                            Icon(Icons.edit_outlined, size: 13, color: AppColors.primary),
                            SizedBox(width: 4),
                            Text(
                              'Edit',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    review.poojariReply!,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12.5,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
