import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/glass.dart';
import '../../data/profile/profile_data.dart';

class NotificationPreferencesScreen extends StatefulWidget {
  const NotificationPreferencesScreen({super.key});
  @override
  State<NotificationPreferencesScreen> createState() => _NotificationPreferencesScreenState();
}

class _NotificationPreferencesScreenState extends State<NotificationPreferencesScreen> {
  late Map<String, bool> _states;

  @override
  void initState() {
    super.initState();
    _states = {for (var p in notificationPrefs) p.title: p.enabled};
  }

  void _tryToggle(NotificationPref p) {
    if (p.isLocked && _states[p.title] == true) {
      showDialog(context: context, builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceContainerHigh,
        title: const Text('Are you sure?', style: TextStyle(color: Colors.white)),
        content: const Text('You may miss updates about your Poojari\'s arrival.', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Keep On', style: TextStyle(color: AppColors.primary))),
          TextButton(onPressed: () { setState(() => _states[p.title] = false); Navigator.pop(ctx); }, child: const Text('Turn Off', style: TextStyle(color: Colors.white54))),
        ],
      ));
    } else {
      setState(() => _states[p.title] = !(_states[p.title] ?? false));
    }
  }

  @override
  Widget build(BuildContext context) {
    return GlassScaffold(
      title: 'Notifications',
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
        children: notificationPrefs.map((p) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: GlassPanel(
            padding: const EdgeInsets.all(14),
            borderRadius: 18,
            child: Row(children: [
              Text(p.icon, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(p.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
                Text(p.subtitle, style: const TextStyle(color: Colors.white54, fontSize: 11)),
              ])),
              Switch(value: _states[p.title] ?? false, activeThumbColor: AppColors.onPrimary, activeTrackColor: AppColors.primary, onChanged: (_) => _tryToggle(p)),
            ]),
          ),
        )).toList(),
      ),
    );
  }
}
