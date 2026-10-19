import 'package:flutter/material.dart';
import 'package:pocket_puja/core/models/profile_models.dart';
import 'package:pocket_puja/core/models/user_account.dart';
import 'package:pocket_puja/core/services/poojari_controller.dart';
import 'package:pocket_puja/core/services/session_service.dart';
import 'package:pocket_puja/core/theme/app_theme.dart';
import 'package:pocket_puja/core/widgets/glass.dart';
import 'package:pocket_puja/core/widgets/nav_constants.dart';
import 'package:pocket_puja/shared/widgets/profile/about_screen.dart';
import 'package:pocket_puja/shared/widgets/profile/addresses_screen.dart';
import 'package:pocket_puja/shared/widgets/profile/notification_preferences_screen.dart';
import 'package:pocket_puja/shared/widgets/profile/personal_info_screen.dart';
import 'package:pocket_puja/shared/widgets/profile/support_screen.dart';
import 'package:pocket_puja/poojari/screens/reviews/reviews_received_screen.dart';
import 'package:pocket_puja/poojari/widgets/profile/poojari_identity_header.dart';
import 'package:pocket_puja/poojari/widgets/profile/professional_info_card.dart';

/// Poojari-specific notification preference categories matching Block 7 notifications
const List<NotificationPref> poojariNotificationPrefs = [
  NotificationPref(
    '🔔',
    'New Assignments',
    'Direct booking alerts & confirm receipt reminders',
    true,
    isLocked: true,
  ),
  NotificationPref(
    '📅',
    'Schedule Changes',
    'Time shifts, devotee updates, ritual reminders',
    true,
  ),
  NotificationPref(
    '⭐',
    'Reviews & Ratings',
    'New devotee ratings and feedback notifications',
    true,
  ),
  NotificationPref(
    '💰',
    'Earnings & Settlements',
    'Dakshina credited alerts and weekly payout notices',
    true,
  ),
];

/// BLOCK 14: Poojari Profile Screen (Tab 4)
///
/// Structurally mirrors Customer's Profile: one continuous scrollable page in
/// GlassScaffold, NO internal tab bar. Reuses Customer Profile's shell,
/// SectionLabel, SettingsTile, and DestructiveButton.
class PoojariProfileScreen extends StatefulWidget {
  final VoidCallback onLogout;
  final VoidCallback? onSwitchToCustomer;

  const PoojariProfileScreen({
    super.key,
    required this.onLogout,
    this.onSwitchToCustomer,
  });

  @override
  State<PoojariProfileScreen> createState() => _PoojariProfileScreenState();
}

class _PoojariProfileScreenState extends State<PoojariProfileScreen> {
  bool _teluguLang = true;

  void _handleSignOut(BuildContext context) {
    SessionService.instance.logout();
    widget.onLogout();
  }

  void _showThemeSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: AppColors.surfaceContainerHigh,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Theme',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            _themeOption('Dark (Default)', true, true),
            _themeOption('Light', false, false),
            _themeOption('System', false, false),
          ],
        ),
      ),
    );
  }

  Widget _themeOption(String label, bool selected, bool available) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Opacity(
        opacity: available ? 1.0 : 0.4,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.primary.withValues(alpha: 0.12)
                : Colors.white.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? AppColors.primary : Colors.white12,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (!available)
                const Text(
                  'Coming Soon',
                  style: TextStyle(color: Colors.white38, fontSize: 11),
                )
              else
                const Icon(Icons.check_circle, color: AppColors.primary, size: 18),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final session = SessionScope.maybeOf(context) ?? SessionService.instance;
    final poojariController = PoojariControllerScope.maybeOf(context) ?? PoojariController.instance;

    return AnimatedBuilder(
      animation: Listenable.merge([session, poojariController]),
      builder: (context, _) {
        final user = session.currentUser;
        final profile = user?.poojariProfile;
        final isVerified = user?.poojariStatus == PoojariVerificationStatus.verified;
        final displayName = user?.fullName ?? 'Shri Venkata Ramana';
        final city = profile?.city ?? 'Hyderabad';
        final serviceRadius = profile?.serviceRadius ?? '15km';
        final specializations = profile?.specializations ??
            const ['Satyanarayana Vratam', 'Gruhapravesham', 'Ganesha Pooja'];
        final experienceYears = profile?.experienceYears ?? 14;
        final trainingLineage = profile?.trainingLineage ??
            'Trained under Sri Sitarama Shastri, Kanchi Kamakoti Peetham';
        final languages = profile?.languages ??
            const ['Telugu', 'Sanskrit', 'English'];

        return GlassScaffold(
          title: 'Profile',
          showBack: true,
          gradient: AppGradients.rust,
          body: ListView(
            padding: EdgeInsets.fromLTRB(20, 20, 20, tabBottomPadding(context)),
            children: [
              // 1. Identity Header
              PoojariIdentityHeader(
                name: displayName,
                city: city,
                serviceRadius: serviceRadius,
                photoPath: profile?.photoPath,
                isVerified: isVerified,
                onSwitchToCustomer: widget.onSwitchToCustomer,
              ),
              const SizedBox(height: 24),

              // 2. Professional Info (Poojari-only)
              const SectionLabel('PROFESSIONAL CREDENTIALS'),
              const SizedBox(height: 10),
              ProfessionalInfoCard(
                specializations: specializations,
                experienceYears: experienceYears,
                trainingLineage: trainingLineage,
                languages: languages,
                serviceRadius: serviceRadius,
                isVerified: isVerified,
                onContactSupport: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const SupportScreen()),
                  );
                },
              ),
              const SizedBox(height: 18),

              // 3. Performance (Live ratings and completed counts)
              const SectionLabel('PERFORMANCE'),
              const SizedBox(height: 10),
              SettingsTile(
                icon: Icons.star_rounded,
                title: 'Reviews & Ratings',
                subtitle: '${poojariController.rating} ★ · ${poojariController.totalReviewCount} devotee reviews',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const ReviewsReceivedScreen(),
                    ),
                  );
                },
              ),
              SettingsTile(
                icon: Icons.task_alt_rounded,
                title: 'Poojas Completed',
                subtitle: '${poojariController.poojasCompleted} Vedic rituals completed',
                onTap: null,
              ),
              const SizedBox(height: 18),

              // 4. Personal Info (Reused from Customer)
              const SectionLabel('PERSONAL INFO'),
              const SizedBox(height: 10),
              SettingsTile(
                icon: Icons.person_outline,
                title: 'Personal Info',
                subtitle: 'Mobile, name, birth date, city',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const PersonalInfoScreen()),
                  );
                },
              ),
              const SizedBox(height: 18),

              // 5. Service Locations (Reused from Customer's AddressesScreen)
              const SectionLabel('SERVICE LOCATIONS'),
              const SizedBox(height: 10),
              SettingsTile(
                icon: Icons.location_on_outlined,
                title: 'Service Locations',
                subtitle: 'Operating addresses & regional sacred hubs',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const AddressesScreen(title: 'Service Locations'),
                    ),
                  );
                },
              ),
              const SizedBox(height: 18),

              // 6. Preferences (Language, Theme, Notification Preferences)
              const SectionLabel('PREFERENCES'),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: GlassPanel(
                  padding: const EdgeInsets.all(14),
                  borderRadius: 18,
                  child: Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.translate,
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
                              'App Language',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              'తెలుగు / English',
                              style: TextStyle(
                                color: Colors.white54,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: _teluguLang,
                        activeThumbColor: AppColors.onPrimary,
                        activeTrackColor: AppColors.primary,
                        onChanged: (v) => setState(() => _teluguLang = v),
                      ),
                    ],
                  ),
                ),
              ),
              SettingsTile(
                icon: Icons.dark_mode_outlined,
                title: 'Theme',
                subtitle: 'Dark (Default)',
                onTap: () => _showThemeSheet(context),
              ),
              SettingsTile(
                icon: Icons.notifications_none_rounded,
                title: 'Notification Preferences',
                subtitle: '4 categories (Assignments, Schedule, Reviews, Earnings)',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const NotificationPreferencesScreen(
                        title: 'Notification Preferences',
                        customPrefs: poojariNotificationPrefs,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 18),

              // 7. Support (Help Center, Contact, Report a Problem)
              const SectionLabel('SUPPORT & ABOUT'),
              const SizedBox(height: 10),
              SettingsTile(
                icon: Icons.help_outline_rounded,
                title: 'Support',
                subtitle: 'Help Center, Contact, Report a Problem',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const SupportScreen()),
                  );
                },
              ),

              // 9. About & Legal
              SettingsTile(
                icon: Icons.info_outline_rounded,
                title: 'About',
                subtitle: 'Terms, Privacy, App Version',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const AboutScreen()),
                  );
                },
              ),
              const SizedBox(height: 16),

              // 10. Sign Out
              DestructiveButton(
                label: 'Sign Out',
                icon: Icons.logout,
                onTap: () => _handleSignOut(context),
              ),
            ],
          ),
        );
      },
    );
  }
}
