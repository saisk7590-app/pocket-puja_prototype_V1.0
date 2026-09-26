import 'package:flutter/material.dart';
import 'package:pocket_puja/core/models/user_account.dart';
import 'package:pocket_puja/core/services/poojari_controller.dart';
import 'package:pocket_puja/core/services/session_service.dart';
import 'package:pocket_puja/core/theme/app_theme.dart';
import 'package:pocket_puja/core/widgets/glass.dart';

/// Screen 7: Poojari Notifications Screen (BLOCK 7)
///
/// Reuses Customer Notifications' exact visual structure:
/// Grouped SectionLabels, GlassPanel rows, icon container + title + body + muted timestamp.
///
/// Sections in exact order:
/// 1. NEW ASSIGNMENTS
/// 2. SCHEDULE UPDATES
/// 3. REVIEWS & RATINGS
/// 4. EARNINGS
/// 5. VERIFICATION (conditionally shown)
class PoojariNotificationsScreen extends StatelessWidget {
  const PoojariNotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final session = SessionService.instance;
    final poojariController = PoojariControllerScope.maybeOf(context) ?? PoojariController.instance;
    final isVerified = session.currentUser?.poojariStatus == PoojariVerificationStatus.verified;

    final newBookings = poojariController.allBookings.where((b) => b.isNew).toList();
    final firstNew = newBookings.isNotEmpty ? newBookings.first : null;

    final sections = <_PoojariNotifSection>[
      // 1. NEW ASSIGNMENTS
      _PoojariNotifSection(
        icon: Icons.assignment_ind_rounded,
        title: 'NEW ASSIGNMENTS',
        items: [
          _PoojariNotifItem(
            icon: Icons.temple_hindu_rounded,
            title: firstNew != null
                ? 'New Pooja Assigned: ${firstNew.poojaName}'
                : 'New Pooja Assigned: Ganesha Pooja',
            body: firstNew != null
                ? 'You have been assigned to ${firstNew.poojaName} for ${firstNew.customerFirstName} on ${firstNew.date} at ${firstNew.scheduledTime}. Tap to confirm receipt.'
                : 'You have been assigned to Ganesha Pooja for Priya on Today at 09:00 AM. Tap to confirm receipt.',
            time: '10m ago',
          ),
        ],
      ),

      // 2. SCHEDULE UPDATES
      const _PoojariNotifSection(
        icon: Icons.calendar_month_rounded,
        title: 'SCHEDULE UPDATES',
        items: [
          _PoojariNotifItem(
            icon: Icons.alarm_rounded,
            title: 'Ritual Reminder: Today at 09:00 AM',
            body: 'Your sacred ritual for Priya in Hitech City is scheduled today at 09:00 AM. Please arrive 15 minutes prior for altar setup.',
            time: '1h ago',
          ),
          _PoojariNotifItem(
            icon: Icons.update_rounded,
            title: 'Schedule Adjusted: Satyanarayana Vratam',
            body: 'Devotee Srinivas in Kondapur confirmed tomorrow morning slot at 10:30 AM.',
            time: '3h ago',
          ),
        ],
      ),

      // 3. REVIEWS & RATINGS
      const _PoojariNotifSection(
        icon: Icons.star_rounded,
        title: 'REVIEWS & RATINGS',
        items: [
          _PoojariNotifItem(
            icon: Icons.stars_rounded,
            title: 'You received a new 5★ review!',
            body: 'Anand Sharma: "Shri Panditji performed our Gruhapravesham with deep Vedic devotion and divine grace. Highly blessed!"',
            time: 'Yesterday',
          ),
        ],
      ),

      // 4. EARNINGS
      _PoojariNotifSection(
        icon: Icons.account_balance_wallet_rounded,
        title: 'EARNINGS',
        items: [
          ...poojariController.earningsNotifications.map(
            (n) => _PoojariNotifItem(
              icon: n.icon,
              title: n.title,
              body: n.body,
              time: n.time,
            ),
          ),
          const _PoojariNotifItem(
            icon: Icons.currency_rupee_rounded,
            title: '₹2,500 Dakshina Credited',
            body: 'Dakshina fee for Gruhapravesham pooja has been credited to your verified bank settlement balance.',
            time: 'Yesterday',
          ),
        ],
      ),

      // 5. VERIFICATION (conditionally shown)
      if (isVerified)
        const _PoojariNotifSection(
          icon: Icons.verified_rounded,
          title: 'VERIFICATION',
          items: [
            _PoojariNotifItem(
              icon: Icons.check_circle_rounded,
              title: 'Credentials Verified — You are Live!',
              body: 'Your Vedic scholar degree and lineage documentation have been fully approved by the Pocket Puja Council. Devotees can now book rituals with you.',
              time: 'Verified',
            ),
          ],
        )
      else
        const _PoojariNotifSection(
          icon: Icons.hourglass_top_rounded,
          title: 'VERIFICATION',
          items: [
            _PoojariNotifItem(
              icon: Icons.pending_actions_rounded,
              title: 'Verification In Progress',
              body: 'Your application is actively under review by the Vedic Scholar Council. You can explore the dashboard while verification completes.',
              time: 'Under Review',
            ),
          ],
        ),
    ];

    return GlassScaffold(
      showAppBar: true,
      showBack: true,
      title: 'Poojari Notifications',
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
        children: [
          Text(
            'Notifications & Alerts',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w800,
                  fontSize: 24,
                  shadows: AppTheme.goldGlow,
                ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Live assignments, muhurtham reminders, dakshina, and council updates.',
            style: TextStyle(color: Colors.white60, fontSize: 13),
          ),
          const SizedBox(height: 22),
          ...sections.map(
            (section) => Padding(
              padding: const EdgeInsets.only(bottom: 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(section.icon, color: AppColors.primary, size: 16),
                      const SizedBox(width: 8),
                      SectionLabel(section.title),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ...section.items.map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: GlassPanel(
                        padding: const EdgeInsets.all(14),
                        borderRadius: 18,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppColors.primary.withValues(alpha: 0.3),
                                ),
                              ),
                              child: Icon(
                                item.icon,
                                color: AppColors.primary,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          item.title,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        item.time,
                                        style: const TextStyle(
                                          color: Colors.white38,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    item.body,
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PoojariNotifItem {
  final IconData icon;
  final String title, body, time;
  const _PoojariNotifItem({
    required this.icon,
    required this.title,
    required this.body,
    required this.time,
  });
}

class _PoojariNotifSection {
  final IconData icon;
  final String title;
  final List<_PoojariNotifItem> items;
  const _PoojariNotifSection({
    required this.icon,
    required this.title,
    required this.items,
  });
}
