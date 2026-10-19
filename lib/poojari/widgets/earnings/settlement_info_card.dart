import 'package:flutter/material.dart';
import 'package:pocket_puja/core/theme/app_theme.dart';
import 'package:pocket_puja/core/widgets/glass.dart';

/// Informational settlement schedule card at the bottom of the earnings screen.
/// Informs the Poojari of the weekly Monday settlement cycle.
class SettlementInfoCard extends StatelessWidget {
  const SettlementInfoCard({super.key});

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      borderRadius: 18,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.account_balance_rounded,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'WEEKLY SETTLEMENT CYCLE',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.9,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Payouts settle every Monday to your linked bank account',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Net dakshina for all completed rituals settles automatically via secure direct deposit.',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 11,
                    height: 1.3,
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
