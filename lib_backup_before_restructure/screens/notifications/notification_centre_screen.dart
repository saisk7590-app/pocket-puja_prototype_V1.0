import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/glass.dart';

class NotificationCentreScreen extends StatelessWidget {
  const NotificationCentreScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return GlassScaffold(
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
        children: [
          Text('Notifications', style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontSize: 26)),
          const SizedBox(height: 6),
          const Text('Stay blessed with your daily spiritual updates.', style: TextStyle(color: Colors.white60, fontSize: 13)),
          const SizedBox(height: 20),
          ..._sections.map((section) => Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [Icon(section.icon, color: AppColors.primary, size: 16), const SizedBox(width: 8), SectionLabel(section.title)]),
                  const SizedBox(height: 10),
                  ...section.items.map((item) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: GlassPanel(
                          padding: const EdgeInsets.all(14), borderRadius: 18,
                          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Container(width: 40, height: 40, decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)), child: Icon(item.icon, color: AppColors.primary, size: 18)),
                            const SizedBox(width: 12),
                            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Row(children: [Expanded(child: Text(item.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14))), Text(item.time, style: const TextStyle(color: Colors.white38, fontSize: 10))]),
                              const SizedBox(height: 4),
                              Text(item.body, style: const TextStyle(color: Colors.white60, fontSize: 12, height: 1.4)),
                            ])),
                          ]),
                        ),
                      )),
                ]),
              )),
        ],
      ),
    );
  }
}

class _NotifItem {
  final IconData icon;
  final String title, body, time;
  const _NotifItem(this.icon, this.title, this.body, this.time);
}

class _NotifSection {
  final IconData icon;
  final String title;
  final List<_NotifItem> items;
  const _NotifSection(this.icon, this.title, this.items);
}

const _sections = [
  _NotifSection(Icons.auto_awesome, 'UPCOMING FESTIVALS', [
    _NotifItem(Icons.wb_sunny, 'Maha Shivaratri Special', 'Prepare for the grand Abhishekam at midnight. New mantra guides are now available.', '2h ago'),
  ]),
  _NotifSection(Icons.event_available, 'PUJA BOOKINGS', [
    _NotifItem(Icons.check_circle_outline, 'Puja Confirmed', 'Your Satyanarayana Swamy Vratam has been scheduled. Pandit Venkata Rama Rao will lead the ceremony.', 'Yesterday'),
    _NotifItem(Icons.history, 'Recording Ready', 'The video recording of your previous Ganesha Puja is now available.', '2 days ago'),
  ]),
  _NotifSection(Icons.shopping_bag, 'DEVOTIONAL ORDERS', [
    _NotifItem(Icons.local_shipping, 'Order Dispatched', 'Your order is on its way to your home.', '4h ago'),
  ]),
];
