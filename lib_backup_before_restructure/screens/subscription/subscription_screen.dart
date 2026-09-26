import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/glass.dart';
import '../../widgets/subscription/usage_ring.dart';
import '../../data/audio/audio_data.dart';
import '../../data/subscription/subscription_data.dart';

/// Screen adapts tone based on how the user arrived — a calm browsing
/// moment (from Profile) vs. having just been interrupted (from the
/// 100% block). Same screen, different header framing.
enum SubscriptionEntryPoint { browsing, blocked }

class SubscriptionScreen extends StatefulWidget {
  final SubscriptionEntryPoint entryPoint;
  const SubscriptionScreen({super.key, this.entryPoint = SubscriptionEntryPoint.browsing});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  bool _isLoading = false;

  Future<void> _upgrade() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Welcome to Premium! 🙏')));
    Navigator.of(context).pop();
  }

  void _showAnnualDetails() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(color: AppColors.surfaceContainerHigh, borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 20),
            const Text('Annual Plan', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(child: _priceCompare('Monthly', '$premiumPriceLabel/mo', false)),
              const SizedBox(width: 12),
              Expanded(child: _priceCompare('Annual', '${(49*12*0.85).round()}/yr', true)),
            ]),
            const SizedBox(height: 8),
            const Text('Billed once per year. Cancel anytime.', style: TextStyle(color: Colors.white38, fontSize: 11)),
            const SizedBox(height: 20),
            PrimaryButton(label: 'Switch to Annual', onTap: () { Navigator.pop(context); _upgrade(); }),
          ],
        ),
      ),
    );
  }

  Widget _priceCompare(String label, String price, bool highlight) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: highlight ? AppColors.primary.withValues(alpha: 0.12) : Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: highlight ? AppColors.primary : Colors.white24),
      ),
      child: Column(children: [
        Text(label, style: TextStyle(color: highlight ? AppColors.primary : Colors.white70, fontSize: 12, fontWeight: FontWeight.w700)),
        const SizedBox(height: 6),
        Text(price, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
        if (highlight) const Text('Save 15%', style: TextStyle(color: AppColors.primary, fontSize: 10)),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isBlocked = widget.entryPoint == SubscriptionEntryPoint.blocked;
    final usage = currentUsage;

    return GlassScaffold(
      title: 'Premium',
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
        children: [
          GlassPanel(
            child: Column(
              children: [
                Text(
                  isBlocked ? "You've used all your sadhana minutes this month" : 'Daily Sadhana Limit',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: AppColors.primary, fontSize: isBlocked ? 18 : 20),
                ),
                const SizedBox(height: 8),
                Text(
                  isBlocked
                      ? "Don't worry — Today's Mantra is always free, and your minutes reset soon."
                      : "You've explored the sacred depths for ${usage.usedMinutes} minutes this month.",
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white60, fontSize: 13),
                ),
                const SizedBox(height: 24),
                UsageRing(usage: usage),
                const SizedBox(height: 12),
                Text('Resets in ${usage.daysUntilReset} days', style: const TextStyle(color: Colors.white54, fontSize: 12)),
                const SizedBox(height: 6),
                const Text('Applies across chants, ashtothram, shathanamalu, namalu & podcasts.', textAlign: TextAlign.center, style: TextStyle(color: Colors.white24, fontSize: 10)),
                if (isBlocked) ...[
                  const SizedBox(height: 14),
                  GlassPanelGold(
                    padding: const EdgeInsets.all(10),
                    borderRadius: 12,
                    child: Row(mainAxisSize: MainAxisSize.min, children: const [
                      Icon(Icons.wb_sunny, color: AppColors.primary, size: 16),
                      SizedBox(width: 8),
                      Flexible(child: Text("You can still play Today's Mantra", style: TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w600))),
                    ]),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),

          GlassPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(20)),
                  child: const Text('CURRENT PLAN', style: TextStyle(color: Colors.white60, fontSize: 10, fontWeight: FontWeight.w700)),
                ),
                const SizedBox(height: 10),
                const Text('Free', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
                const Text('Basic spiritual access for daily rituals.', style: TextStyle(color: Colors.white60, fontSize: 13)),
                const SizedBox(height: 14),
                ...freeFeatures.map((f) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(children: [
                        Icon(f.included ? Icons.check_circle : Icons.cancel, size: 16, color: f.included ? AppColors.primary : Colors.white24),
                        const SizedBox(width: 10),
                        Text(f.label, style: TextStyle(color: f.included ? Colors.white70 : Colors.white24, fontSize: 13)),
                      ]),
                    )),
              ],
            ),
          ),
          const SizedBox(height: 20),

          GlassPanelGold(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(20)),
                    child: const Text('Most Devout', style: TextStyle(color: AppColors.onPrimary, fontSize: 11, fontWeight: FontWeight.w700)),
                  ),
                  const Icon(Icons.star, color: AppColors.primary),
                ]),
                const SizedBox(height: 10),
                const Text('Premium', style: TextStyle(color: AppColors.primary, fontSize: 20, fontWeight: FontWeight.w800)),
                const Text('The ultimate digital sanctuary experience.', style: TextStyle(color: Colors.white60, fontSize: 13)),
                const SizedBox(height: 14),
                ...premiumFeatures.map((f) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        const Icon(Icons.check_circle, size: 16, color: AppColors.primary),
                        const SizedBox(width: 10),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(f.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
                          Text(f.sub, style: const TextStyle(color: Colors.white54, fontSize: 11)),
                        ])),
                      ]),
                    )),
                const SizedBox(height: 14),
                Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Text(premiumPriceLabel, style: Theme.of(context).textTheme.headlineLarge?.copyWith(color: Colors.white, fontSize: 28)),
                  const Padding(padding: EdgeInsets.only(bottom: 4, left: 4), child: Text('/ month', style: TextStyle(color: Colors.white54))),
                ]),
                const SizedBox(height: 12),
                PrimaryButton(label: 'UPGRADE NOW', isLoading: _isLoading, onTap: _upgrade),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: _showAnnualDetails,
                  child: Row(children: [
                    const Icon(Icons.info_outline, color: AppColors.primary, size: 14),
                    const SizedBox(width: 6),
                    Expanded(child: RichText(text: const TextSpan(style: TextStyle(fontSize: 11, color: Colors.white54), children: [
                      TextSpan(text: 'Upgrade for '),
                      TextSpan(text: '15% off', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700)),
                      TextSpan(text: ' annual plans. '),
                      TextSpan(text: 'Details', style: TextStyle(decoration: TextDecoration.underline, color: AppColors.primary)),
                    ]))),
                  ]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
