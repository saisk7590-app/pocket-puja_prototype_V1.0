import 'package:flutter/material.dart';
import 'package:pocket_puja/core/models/user_account.dart';
import 'package:pocket_puja/core/services/session_service.dart';
import 'package:pocket_puja/core/theme/app_theme.dart';
import 'package:pocket_puja/core/widgets/glass.dart';
import 'package:pocket_puja/core/widgets/poojari_mode_badge.dart';
import 'package:pocket_puja/poojari/screens/notifications/poojari_notifications_screen.dart';

/// Tab 4: Poojari Profile & Vedic Credentials Screen.
class PoojariProfileScreen extends StatelessWidget {
  final VoidCallback onLogout;
  final VoidCallback? onSwitchToCustomer;

  const PoojariProfileScreen({
    super.key,
    required this.onLogout,
    this.onSwitchToCustomer,
  });

  @override
  Widget build(BuildContext context) {
    final session = SessionService.instance;
    final user = session.currentUser;
    final displayName = user?.fullName ?? 'Shri Venkata Ramana';
    final profile = user?.poojariProfile;
    final isVerified = user?.poojariStatus == PoojariVerificationStatus.verified;

    return GlassScaffold(
      showAppBar: false,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
          children: [
            // Top Bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Pandit Profile',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w800,
                        fontSize: 22,
                        shadows: AppTheme.goldGlow,
                      ),
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

            // Profile Card
            GlassPanelGold(
              padding: const EdgeInsets.all(20),
              borderRadius: 22,
              child: Column(
                children: [
                  Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary.withValues(alpha: 0.2),
                      border: Border.all(color: AppColors.primary, width: 2),
                    ),
                    child: const Center(
                      child: Text('🪔', style: TextStyle(fontSize: 38)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    displayName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'VEDIC SCHOLAR',
                          style: TextStyle(
                            color: AppColors.primaryFixed,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: isVerified
                              ? AppColors.success.withValues(alpha: 0.2)
                              : const Color(0xFFFFB84D).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          isVerified ? 'VERIFIED' : 'UNDER REVIEW',
                          style: TextStyle(
                            color: isVerified ? AppColors.success : const Color(0xFFFFB84D),
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),

            // Credentials Detail List
            Text(
              'CREDENTIALS & LINEAGE',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Colors.white60,
                    fontSize: 11,
                    letterSpacing: 1.2,
                  ),
            ),
            const SizedBox(height: 10),

            GlassPanel(
              padding: const EdgeInsets.all(16),
              borderRadius: 18,
              child: Column(
                children: [
                  _infoRow('Experience', '${profile?.experienceYears ?? 14} Years Active Practice'),
                  const Divider(color: Colors.white12, height: 20),
                  _infoRow('Service Area', '${profile?.city ?? "Hyderabad"} (${profile?.serviceRadius ?? "15km"} Radius)'),
                  const Divider(color: Colors.white12, height: 20),
                  _infoRow('Languages', (profile?.languages ?? ['Telugu', 'Sanskrit', 'English']).join(', ')),
                  const Divider(color: Colors.white12, height: 20),
                  _infoRow('Lineage / Sanad', profile?.trainingLineage ?? 'Sri Ramanuja Sampradaya & Tirumala Veda Pathashala'),
                ],
              ),
            ),
            const SizedBox(height: 22),

            // Actions: Switch to customer & Logout
            ElevatedButton.icon(
              onPressed: onSwitchToCustomer,
              icon: const Icon(Icons.swap_horiz_rounded),
              label: const Text('Switch to Customer / Devotee View'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white.withValues(alpha: 0.1),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: const BorderSide(color: Colors.white24),
                ),
              ),
            ),
            const SizedBox(height: 12),

            ElevatedButton.icon(
              onPressed: onLogout,
              icon: const Icon(Icons.logout, color: AppColors.error),
              label: const Text('Sign Out of Poojari Account', style: TextStyle(color: AppColors.error)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error.withValues(alpha: 0.12),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: BorderSide(color: AppColors.error.withValues(alpha: 0.3)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 110,
          child: Text(
            label,
            style: const TextStyle(color: Colors.white54, fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}
