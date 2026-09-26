import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/glass.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return GlassScaffold(
      title: 'About',
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
        children: [
          GlassPanelGold(
            child: Column(children: [
              const Text('🪔', style: TextStyle(fontSize: 40)),
              const SizedBox(height: 10),
              Text('Pocket Puja', style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: AppColors.primary)),
              const SizedBox(height: 8),
              const Text('A digital sanctuary for your daily rituals — bringing Telugu devotional practice into your pocket, wherever you are.', textAlign: TextAlign.center, style: TextStyle(color: Colors.white60, fontSize: 13)),
              const SizedBox(height: 12),
              const Text('Version 1.0.0', style: TextStyle(color: Colors.white38, fontSize: 11)),
            ]),
          ),
          const SizedBox(height: 20),
          SettingsTile(icon: Icons.description_outlined, title: 'Terms of Service', subtitle: 'Read our terms', onTap: () {}),
          SettingsTile(icon: Icons.lock_outline, title: 'Privacy Policy', subtitle: 'How we handle your data', onTap: () {}),
        ],
      ),
    );
  }
}
