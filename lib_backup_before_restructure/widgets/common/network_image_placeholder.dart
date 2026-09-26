import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../theme/app_theme.dart';

class NetworkImageWithPlaceholder extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadiusGeometry? borderRadius;

  const NetworkImageWithPlaceholder({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        width: width,
        height: height,
        fit: fit,
        placeholder: (context, url) => Container(
          width: width, height: height, color: AppColors.surfaceContainerHigh,
          child: const Center(child: Icon(Icons.auto_awesome, color: AppColors.primary, size: 20)),
        ),
        errorWidget: (context, url, error) => Container(
          width: width, height: height, color: AppColors.surfaceContainerHigh,
          child: const Center(child: Icon(Icons.broken_image, color: AppColors.outline)),
        ),
      ),
    );
  }
}
