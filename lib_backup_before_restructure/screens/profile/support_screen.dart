import 'package:flutter/material.dart';
//import '../../theme/app_theme.dart';
import '../../widgets/common/glass.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return GlassScaffold(
      title: 'Support',
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
        children: [
          SettingsTile(icon: Icons.help_outline, title: 'Help Center', subtitle: 'FAQs on booking, payment, audio & delivery', onTap: () {}),
          SettingsTile(icon: Icons.chat_bubble_outline, title: 'Contact Us', subtitle: 'Chat with us on WhatsApp or call', onTap: () {}),
          SettingsTile(icon: Icons.bug_report_outlined, title: 'Report a Problem', subtitle: 'App crash, payment issue, or other bug', onTap: () {}),
        ],
      ),
    );
  }
}
