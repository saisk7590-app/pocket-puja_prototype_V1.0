import 'package:flutter/material.dart';
import 'dart:ui';
import '../../theme/app_theme.dart';
import '../common/glass.dart';
import '../../screens/subscription/subscription_screen.dart';

/// Full-screen block modal — fires only on the NEXT play attempt after
/// hitting 100%, never mid-track. The one legitimate full modal in the
/// whole app.
Future<void> showUsageBlockModal(BuildContext context) {
  return showDialog(
    context: context,
    barrierColor: Colors.black87,
    builder: (ctx) => Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(24),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerHigh.withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: Colors.white12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64, height: 64,
                  decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.15), shape: BoxShape.circle),
                  child: const Icon(Icons.hourglass_bottom, color: AppColors.primary, size: 30),
                ),
                const SizedBox(height: 18),
                const Text("You've used all your\nsadhana minutes this month", textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
                const SizedBox(height: 10),
                const Text('Your minutes reset in 9 days — or upgrade for unlimited listening anytime.', textAlign: TextAlign.center, style: TextStyle(color: Colors.white60, fontSize: 13)),
                const SizedBox(height: 16),
                GlassPanelGold(
                  padding: const EdgeInsets.all(10),
                  borderRadius: 12,
                  child: Row(mainAxisSize: MainAxisSize.min, children: const [
                    Icon(Icons.wb_sunny, color: AppColors.primary, size: 16),
                    SizedBox(width: 8),
                    Flexible(child: Text("Today's Mantra is always free", style: TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w600))),
                  ]),
                ),
                const SizedBox(height: 20),
                PrimaryButton(label: 'Upgrade to Premium', onTap: () {
                  Navigator.of(ctx).pop();
                  Navigator.of(ctx).push(MaterialPageRoute(builder: (_) => const SubscriptionScreen(entryPoint: SubscriptionEntryPoint.blocked)));
                }),
                const SizedBox(height: 10),
                TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Not now', style: TextStyle(color: Colors.white38))),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
