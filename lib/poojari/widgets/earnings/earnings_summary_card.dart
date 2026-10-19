import 'package:flutter/material.dart';
import 'package:pocket_puja/core/theme/app_theme.dart';
import 'package:pocket_puja/core/widgets/glass.dart';

/// Summary card displaying the Poojari's three primary net financial metrics:
/// 1. This Month's Earnings (large, primary): NET, live from PoojariController
/// 2. Total Lifetime Earnings: NET
/// 3. Pending Payout: NET earned but not yet settled
class EarningsSummaryCard extends StatelessWidget {
  final int thisMonthEarningsRupees;
  final int lifetimeEarningsRupees;
  final int pendingPayoutRupees;

  const EarningsSummaryCard({
    super.key,
    required this.thisMonthEarningsRupees,
    required this.lifetimeEarningsRupees,
    required this.pendingPayoutRupees,
  });

  @override
  Widget build(BuildContext context) {
    return GlassPanelGold(
      padding: const EdgeInsets.all(20),
      borderRadius: 22,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "THIS MONTH'S EARNINGS (NET)",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.1,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  '● LIVE',
                  style: TextStyle(
                    color: AppColors.success,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '₹ $thisMonthEarningsRupees',
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.w800,
              shadows: AppTheme.goldGlow,
            ),
          ),
          const SizedBox(height: 16),
          const Divider(color: Colors.white12, height: 1),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'TOTAL LIFETIME',
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '₹ $lifetimeEarningsRupees',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Container(width: 1, height: 32, color: Colors.white12),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'PENDING PAYOUT',
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          '₹ $pendingPayoutRupees',
                          style: const TextStyle(
                            color: Color(0xFFFFB84D),
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFB84D).withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'PENDING',
                            style: TextStyle(
                              color: Color(0xFFFFB84D),
                              fontSize: 8,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
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
}
