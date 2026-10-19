import 'package:flutter/material.dart';
import 'package:pocket_puja/core/theme/app_theme.dart';
import 'package:pocket_puja/core/widgets/glass.dart';

/// Professional Info Card (Poojari-only read-only credentials in a GlassPanel):
/// - Locked specializations chips + Support note
/// - Years of experience + Training/Lineage (if entered)
/// - Languages spoken
/// - Service radius
/// - Certificate verification status
class ProfessionalInfoCard extends StatelessWidget {
  final List<String> specializations;
  final int experienceYears;
  final String? trainingLineage;
  final List<String> languages;
  final String serviceRadius;
  final bool isVerified;
  final VoidCallback onContactSupport;

  const ProfessionalInfoCard({
    super.key,
    required this.specializations,
    required this.experienceYears,
    this.trainingLineage,
    required this.languages,
    required this.serviceRadius,
    required this.isVerified,
    required this.onContactSupport,
  });

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      padding: const EdgeInsets.all(18),
      borderRadius: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Specializations (LOCKED)
          const Text(
            'SPECIALIZATIONS',
            style: TextStyle(
              color: Colors.white54,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.9,
            ),
          ),
          const SizedBox(height: 8),

          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: specializations.map((spec) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.25),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.lock_outline, size: 10, color: AppColors.primary),
                    const SizedBox(width: 4),
                    Text(
                      spec,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),

          // Locked Specializations Note
          GestureDetector(
            onTap: onContactSupport,
            child: const Text(
              'Contact Support to update your specializations.',
              style: TextStyle(
                color: Colors.white38,
                fontSize: 11,
                decoration: TextDecoration.underline,
                decorationColor: Colors.white38,
              ),
            ),
          ),
          const SizedBox(height: 14),
          const Divider(color: Colors.white12, height: 1),
          const SizedBox(height: 14),

          // 2. Read-only Detail Rows
          _row('Experience', '$experienceYears Years Practice'),
          const SizedBox(height: 12),

          if (trainingLineage != null && trainingLineage!.trim().isNotEmpty) ...[
            _row('Lineage / Sanad', trainingLineage!.trim()),
            const SizedBox(height: 12),
          ],

          _row('Languages Spoken', languages.join(', ')),
          const SizedBox(height: 12),

          _row('Service Radius', serviceRadius),
          const SizedBox(height: 12),

          _row(
            'Certificate',
            isVerified ? 'Verified ✓' : 'Pending Review',
            valueColor: isVerified ? AppColors.success : const Color(0xFFFFB84D),
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value, {Color? valueColor}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: valueColor ?? Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
