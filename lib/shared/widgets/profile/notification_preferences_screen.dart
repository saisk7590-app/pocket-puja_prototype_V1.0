import 'package:flutter/material.dart';
import 'package:pocket_puja/core/models/profile_models.dart';
import 'package:pocket_puja/core/theme/app_theme.dart';
import 'package:pocket_puja/core/widgets/glass.dart';

const List<NotificationPref> _defaultNotificationPrefs = [
  NotificationPref('📿', 'Daily Panchangam', "Today's Tithi & auspicious timings", true),
  NotificationPref('🎉', 'Festival Alerts', 'Upcoming festivals & special poojas', true),
  NotificationPref('📅', 'Booking Updates', 'Assigned Poojari, status changes', true, isLocked: true),
  NotificationPref('📦', 'Order & Delivery Updates', 'Shop order status, dispatch, delivery', true),
  NotificationPref('🎵', 'Audio Recommendations', 'New chants, "Today\'s Focus" picks', false),
  NotificationPref('⭐', 'Subscription & Offers', 'Usage warnings, plan renewal reminders', true),
];

class NotificationPreferencesScreen extends StatefulWidget {
  final List<NotificationPref>? customPrefs;
  final String? title;

  const NotificationPreferencesScreen({
    super.key,
    this.customPrefs,
    this.title,
  });

  @override
  State<NotificationPreferencesScreen> createState() =>
      _NotificationPreferencesScreenState();
}

class _NotificationPreferencesScreenState
    extends State<NotificationPreferencesScreen> {
  late Map<String, bool> _states;

  List<NotificationPref> get _effectivePrefs =>
      widget.customPrefs ?? _defaultNotificationPrefs;

  @override
  void initState() {
    super.initState();
    _states = {for (var p in _effectivePrefs) p.title: p.enabled};
  }

  void _tryToggle(NotificationPref p) {
    if (p.isLocked && _states[p.title] == true) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: AppColors.surfaceContainerHigh,
          title: const Text('Are you sure?', style: TextStyle(color: Colors.white)),
          content: Text(
            widget.customPrefs != null
                ? 'You may miss critical booking assignments and schedule updates.'
                : 'You may miss updates about your Poojari\'s arrival.',
            style: const TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Keep On', style: TextStyle(color: AppColors.primary)),
            ),
            TextButton(
              onPressed: () {
                setState(() => _states[p.title] = false);
                Navigator.pop(ctx);
              },
              child: const Text('Turn Off', style: TextStyle(color: Colors.white54)),
            ),
          ],
        ),
      );
    } else {
      setState(() => _states[p.title] = !(_states[p.title] ?? false));
    }
  }

  @override
  Widget build(BuildContext context) {
    return GlassScaffold(
      title: widget.title ?? 'Notifications',
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
        children: _effectivePrefs
            .map(
              (p) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: GlassPanel(
                  padding: const EdgeInsets.all(14),
                  borderRadius: 18,
                  child: Row(
                    children: [
                      Text(p.icon, style: const TextStyle(fontSize: 22)),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              p.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              p.subtitle,
                              style: const TextStyle(
                                color: Colors.white54,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: _states[p.title] ?? false,
                        activeThumbColor: AppColors.onPrimary,
                        activeTrackColor: AppColors.primary,
                        onChanged: (_) => _tryToggle(p),
                      ),
                    ],
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
