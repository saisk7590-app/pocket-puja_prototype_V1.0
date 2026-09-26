import 'package:flutter/material.dart';
import 'package:pocket_puja/core/services/poojari_controller.dart';
import 'package:pocket_puja/core/theme/app_theme.dart';
import 'package:pocket_puja/core/widgets/glass.dart';
import 'package:pocket_puja/core/widgets/poojari_mode_badge.dart';
import 'package:pocket_puja/poojari/screens/notifications/poojari_notifications_screen.dart';

/// Tab 3: Earnings & Dakshina Ledger for Poojari.
/// Reads live monthly earnings and completed counts from PoojariController.
class PoojariEarningsScreen extends StatelessWidget {
  final VoidCallback? onSwitchToCustomer;

  const PoojariEarningsScreen({
    super.key,
    this.onSwitchToCustomer,
  });

  @override
  Widget build(BuildContext context) {
    final controller = PoojariControllerScope.maybeOf(context) ?? PoojariController.instance;

    return GlassScaffold(
      showAppBar: false,
      body: SafeArea(
        child: AnimatedBuilder(
          animation: controller,
          builder: (context, _) {
            final earningsRupees = controller.thisMonthEarningsRupees;
            final completedCount = controller.poojasCompleted;

            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Dakshina Ledger',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w800,
                                fontSize: 22,
                                shadows: AppTheme.goldGlow,
                              ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Earnings, settlements & payout ledger',
                          style: TextStyle(color: Colors.white60, fontSize: 12),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          tooltip: 'Notifications',
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const PoojariNotificationsScreen(),
                              ),
                            );
                          },
                          icon: const Icon(
                            Icons.notifications_none_rounded,
                            color: AppColors.primary,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 4),
                        PoojariModeBadge(
                          isPoojari: true,
                          onToggle: onSwitchToCustomer,
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Hero Dakshina Card
                GlassPanelGold(
                  padding: const EdgeInsets.all(20),
                  borderRadius: 22,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'THIS MONTH\'S DAKSHINA',
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
                              color: AppColors.success.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              '● LIVE SETTLED',
                              style: TextStyle(
                                color: AppColors.success,
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '₹ $earningsRupees',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          shadows: AppTheme.goldGlow,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'From $completedCount completed Vedic rituals',
                        style: const TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Dakshina payout initiated to linked bank account (IFSC: HDFC0001234)'),
                                backgroundColor: AppColors.success,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                          icon: const Icon(Icons.account_balance, size: 18),
                          label: const Text('Request Payout to Bank'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.onPrimary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Breakdown stats
                Row(
                  children: [
                    Expanded(
                      child: GlassPanel(
                        padding: const EdgeInsets.all(14),
                        borderRadius: 16,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('AVG PER PUJA', style: TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.w700)),
                            const SizedBox(height: 6),
                            Text(
                              '₹ ${(earningsRupees / (completedCount > 0 ? completedCount : 1)).round()}',
                              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GlassPanel(
                        padding: const EdgeInsets.all(14),
                        borderRadius: 16,
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('PLATFORM DEDUCTION', style: TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.w700)),
                            SizedBox(height: 6),
                            Text('0% (Zero Fee)', style: TextStyle(color: AppColors.success, fontSize: 18, fontWeight: FontWeight.w800)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Recent Settlements
                Text(
                  'RECENT RITUAL DAKSHINA',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: Colors.white60,
                        fontSize: 11,
                        letterSpacing: 1.2,
                      ),
                ),
                const SizedBox(height: 10),

                for (final item in [
                  {'title': 'Ganapathi Homam', 'devotee': 'K. Rajesh', 'amount': '₹ 1,500', 'status': 'Credited'},
                  {'title': 'Satyanarayana Vratam', 'devotee': 'M. Srinivas', 'amount': '₹ 2,000', 'status': 'Pending'},
                  {'title': 'Rudrabhishekam', 'devotee': 'Dr. Suresh Varma', 'amount': '₹ 1,750', 'status': 'Credited'},
                  {'title': 'Gruhapravesham', 'devotee': 'V. Anand Kumar', 'amount': '₹ 2,500', 'status': 'Credited'},
                ]) ...[
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: GlassPanel(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      borderRadius: 14,
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.currency_rupee, color: AppColors.primary, size: 18),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item['title']!, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
                                Text('Devotee: ${item['devotee']}', style: const TextStyle(color: Colors.white54, fontSize: 12)),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(item['amount']!, style: const TextStyle(color: AppColors.primary, fontSize: 14, fontWeight: FontWeight.w800)),
                              Text(item['status']!, style: TextStyle(color: item['status'] == 'Credited' ? AppColors.success : const Color(0xFFFFB84D), fontSize: 11)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}
