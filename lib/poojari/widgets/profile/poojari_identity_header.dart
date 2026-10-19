import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pocket_puja/core/theme/app_theme.dart';
import 'package:pocket_puja/core/widgets/network_image_placeholder.dart';

/// Identity header for Poojari Profile:
/// - Profile photo (picked at registration or gold Vedic placeholder avatar)
/// - Name and city / service area
/// - Account verification status badge ("Verified ✓" or "Under Review")
/// - Poojari Mode toggle badge
class PoojariIdentityHeader extends StatelessWidget {
  final String name;
  final String city;
  final String serviceRadius;
  final String? photoPath;
  final bool isVerified;
  final VoidCallback? onSwitchToCustomer;

  const PoojariIdentityHeader({
    super.key,
    required this.name,
    required this.city,
    required this.serviceRadius,
    this.photoPath,
    required this.isVerified,
    this.onSwitchToCustomer,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = isVerified ? AppColors.success : const Color(0xFFFFB84D);

    return Center(
      child: Column(
        children: [
          // 1. Profile Photo
          _buildAvatar(),
          const SizedBox(height: 14),

          // 2. Name
          Text(
            name,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  color: AppColors.primary,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  shadows: AppTheme.goldGlow,
                ),
          ),
          const SizedBox(height: 4),

          // 3. City & Service Radius
          Text(
            '$city · $serviceRadius Radius',
            style: const TextStyle(
              color: Colors.white60,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),

          // 4. Badges Row: Verification Status + Poojari Mode Badge
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              // Verification Status Badge (Matches Block 1 verification banner styling)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: statusColor, width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isVerified ? Icons.verified_rounded : Icons.pending_actions_rounded,
                      size: 13,
                      color: statusColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isVerified ? 'Verified ✓' : 'Under Review',
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    const double size = 96;

    if (photoPath != null && photoPath!.isNotEmpty) {
      if (photoPath!.startsWith('http')) {
        return ClipOval(
          child: NetworkImageWithPlaceholder(
            imageUrl: photoPath!,
            width: size,
            height: size,
          ),
        );
      }
      try {
        final file = File(photoPath!);
        if (file.existsSync()) {
          return ClipOval(
            child: Image.file(
              file,
              width: size,
              height: size,
              fit: BoxFit.cover,
            ),
          );
        }
      } catch (_) {}
    }

    // Default Vedic Golden Avatar
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.primary.withValues(alpha: 0.15),
        border: Border.all(color: AppColors.primary, width: 2),
        boxShadow: const [
          BoxShadow(
            color: Colors.black38,
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: const Center(
        child: Text('🪔', style: TextStyle(fontSize: 44)),
      ),
    );
  }
}
