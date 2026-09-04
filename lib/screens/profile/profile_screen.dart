import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/glass.dart';
import '../../widgets/common/network_image_placeholder.dart';
import '../../data/profile/profile_data.dart';
import '../../data/audio/audio_data.dart';
import '../subscription/subscription_screen.dart';
import 'personal_info_screen.dart';
import 'addresses_screen.dart';
import 'orders_screen.dart';
import 'notification_preferences_screen.dart';
import 'support_screen.dart';
import 'about_screen.dart';

class ProfileScreen extends StatefulWidget {
  final VoidCallback onLogout;
  const ProfileScreen({super.key, required this.onLogout});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _teluguLang = true;
  final bool _isPremium = false; // mock plan state

  @override
  Widget build(BuildContext context) {
    final usage = currentUsage;
    final remaining = usage.totalMinutes - usage.usedMinutes;
    final isWarning = usage.isWarning;

    return GlassScaffold(
      gradient: AppGradients.rust,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
        children: [
          Center(
            child: Column(children: [
              Stack(children: [
                ClipOval(child: NetworkImageWithPlaceholder(imageUrl: 'https://picsum.photos/seed/${currentUser.seed}/200', width: 100, height: 100)),
                Positioned(right: 0, bottom: 0, child: GestureDetector(onTap: () {}, child: Container(padding: const EdgeInsets.all(8), decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle), child: const Icon(Icons.edit, size: 16, color: AppColors.onPrimary)))),
              ]),
              const SizedBox(height: 16),
              Text('నమస్తే, ${currentUser.name}', style: Theme.of(context).textTheme.headlineLarge?.copyWith(color: AppColors.primary, fontSize: 22, shadows: AppTheme.goldGlow)),
              const SizedBox(height: 4),
              Text('${currentUser.level} • ${currentUser.city}', style: const TextStyle(color: Colors.white60, fontSize: 13)),
            ]),
          ),
          const SizedBox(height: 28),

          const SectionLabel('ACCOUNT'),
          const SizedBox(height: 10),
          SettingsTile(icon: Icons.person_outline, title: 'Personal Info', subtitle: 'Mobile, name, birth date, city', onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PersonalInfoScreen()))),

          // Dynamic subscription row — reflects actual plan + usage state.
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: (isWarning && !_isPremium)
                ? GlassPanelAmber(
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SubscriptionScreen(entryPoint: SubscriptionEntryPoint.browsing))),
                    child: Row(children: [
                      const Icon(Icons.notifications_active, color: GlassPanelAmber.amber, size: 20),
                      const SizedBox(width: 14),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        const Text('Free Plan — running low', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
                        Text('${(remaining/60).floor()}h ${remaining%60}m left · resets in ${usage.daysUntilReset} days', style: const TextStyle(color: Colors.white54, fontSize: 11)),
                      ])),
                      const Icon(Icons.chevron_right, color: Colors.white38),
                    ]),
                  )
                : SettingsTile(
                    icon: _isPremium ? Icons.star : Icons.notifications_none,
                    title: _isPremium ? 'Premium' : 'Free Plan',
                    subtitle: _isPremium ? 'Renews March 15' : '${(remaining/60).floor()}h ${remaining%60}m left this month',
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SubscriptionScreen(entryPoint: SubscriptionEntryPoint.browsing))),
                  ),
          ),

          const SizedBox(height: 8),
          const SectionLabel('ADDRESSES & ORDERS'),
          const SizedBox(height: 10),
          SettingsTile(icon: Icons.location_on_outlined, title: 'Saved Addresses', subtitle: 'For booking & delivery', onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AddressesScreen()))),
          SettingsTile(icon: Icons.shopping_bag_outlined, title: 'My Orders', subtitle: 'Shop purchase history', onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const OrdersScreen()))),

          const SizedBox(height: 8),
          const SectionLabel('PREFERENCES'),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: GlassPanel(
              padding: const EdgeInsets.all(14), borderRadius: 18,
              child: Row(children: [
                Container(width: 42, height: 42, decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.translate, color: AppColors.primary, size: 20)),
                const SizedBox(width: 14),
                const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('App Language', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)), Text('తెలుగు / English', style: TextStyle(color: Colors.white54, fontSize: 11))])),
                Switch(value: _teluguLang, activeColor: AppColors.onPrimary, activeTrackColor: AppColors.primary, onChanged: (v) => setState(() => _teluguLang = v)),
              ]),
            ),
          ),
          SettingsTile(icon: Icons.dark_mode_outlined, title: 'Theme', subtitle: 'Dark (Default)', onTap: () => _showThemeSheet(context)),
          SettingsTile(icon: Icons.notifications_none, title: 'Notification Preferences', subtitle: '6 categories', onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const NotificationPreferencesScreen()))),
          SettingsTile(
            icon: Icons.download_outlined, title: 'Downloads',
            subtitle: _isPremium ? 'Offline mantras & podcasts' : 'Premium feature — upgrade to unlock',
            onTap: () => _isPremium ? null : Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SubscriptionScreen())),
          ),

          const SizedBox(height: 8),
          const SectionLabel('SUPPORT & ABOUT'),
          const SizedBox(height: 10),
          SettingsTile(icon: Icons.help_outline, title: 'Support', subtitle: 'Help Center, Contact, Report a Problem', onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SupportScreen()))),
          SettingsTile(icon: Icons.info_outline, title: 'About', subtitle: 'Terms, Privacy, App Version', onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AboutScreen()))),

          const SizedBox(height: 12),
          DestructiveButton(label: 'Sign Out', icon: Icons.logout, onTap: widget.onLogout),
        ],
      ),
    );
  }

  void _showThemeSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(color: AppColors.surfaceContainerHigh, borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Theme', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          _themeOption('Dark (Default)', true, true),
          _themeOption('Light', false, false),
          _themeOption('System', false, false),
        ]),
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
          decoration: BoxDecoration(color: selected ? AppColors.primary.withValues(alpha: 0.12) : Colors.white.withValues(alpha: 0.04), borderRadius: BorderRadius.circular(14), border: Border.all(color: selected ? AppColors.primary : Colors.white12)),
          child: Row(children: [
            Expanded(child: Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600))),
            if (!available) const Text('Coming Soon', style: TextStyle(color: Colors.white38, fontSize: 11)) else const Icon(Icons.check_circle, color: AppColors.primary, size: 18),
          ]),
        ),
      ),
    );
  }
}
