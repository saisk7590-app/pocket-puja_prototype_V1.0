import 'package:flutter/material.dart';
//import '../../theme/app_theme.dart';
import '../../widgets/common/glass.dart';
import '../../data/calendar/calendar_data.dart';

class FestivalsScreen extends StatelessWidget {
  const FestivalsScreen({super.key});

  IconData _iconFor(String type) {
    switch (type) {
      case 'amavasya': return Icons.brightness_2;
      case 'pournami': return Icons.brightness_1;
      case 'ekadasi': return Icons.self_improvement;
      default: return Icons.celebration;
    }
  }

  Color _colorFor(String type) {
    switch (type) {
      case 'amavasya': return Colors.white70;
      case 'pournami': return const Color(0xFFF2CA50);
      case 'ekadasi': return const Color(0xFF9DE6B4);
      default: return const Color(0xFFE05353);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 110),
      children: [
        Text('Upcoming Festivals', style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontSize: 22)),
        const SizedBox(height: 6),
        const Text('Browse festivals and special tithis, plan ahead.', style: TextStyle(color: Colors.white60, fontSize: 13)),
        const SizedBox(height: 16),
        ...festivals.map((f) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GlassPanel(
                padding: const EdgeInsets.all(14),
                borderRadius: 18,
                child: Row(children: [
                  Container(width: 44, height: 44, decoration: BoxDecoration(color: _colorFor(f.type).withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)), child: Icon(_iconFor(f.type), color: _colorFor(f.type), size: 22)),
                  const SizedBox(width: 14),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(f.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15)),
                    Text('${f.day} Sep, 2026', style: const TextStyle(color: Colors.white54, fontSize: 12)),
                  ])),
                ]),
              ),
            )),
      ],
    );
  }
}
