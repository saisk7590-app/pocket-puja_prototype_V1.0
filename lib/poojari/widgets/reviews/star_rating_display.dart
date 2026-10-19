import 'package:flutter/material.dart';
import 'package:pocket_puja/core/theme/app_theme.dart';

/// Reusable star rating row displaying filled and unfilled stars.
class StarRatingDisplay extends StatelessWidget {
  final int rating;
  final double size;
  final Color color;

  const StarRatingDisplay({
    super.key,
    required this.rating,
    this.size = 16,
    this.color = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        5,
        (i) => Icon(
          i < rating ? Icons.star_rounded : Icons.star_border_rounded,
          color: color,
          size: size,
        ),
      ),
    );
  }
}
