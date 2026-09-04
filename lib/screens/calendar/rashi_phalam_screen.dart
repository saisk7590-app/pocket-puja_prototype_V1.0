import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/glass.dart';
import '../../data/calendar/calendar_data.dart';

enum RashiPeriod { daily, weekly, yearly }

class RashiPhalamScreen extends StatefulWidget {
  final String? initialSign; // pre-selected if user has DOB set
  const RashiPhalamScreen({super.key, this.initialSign});

  @override
  State<RashiPhalamScreen> createState() => _RashiPhalamScreenState();
}

class _RashiPhalamScreenState extends State<RashiPhalamScreen> {
  late RashiSign _selected;
  RashiPeriod _period = RashiPeriod.daily;

  @override
  void initState() {
    super.initState();
    _selected = rashiSigns.firstWhere((s) => s.name == widget.initialSign, orElse: () => rashiSigns.first);
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 110),
      children: [
        Text('రాశి ఫలాలు', style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontSize: 22)),
        const SizedBox(height: 6),
        const Text('Select your zodiac sign for personalized predictions.', style: TextStyle(color: Colors.white60, fontSize: 13)),
        const SizedBox(height: 16),
        SizedBox(
          height: 90,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: rashiSigns.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (_, i) {
              final s = rashiSigns[i];
              final sel = s.name == _selected.name;
              return GestureDetector(
                onTap: () => setState(() => _selected = s),
                child: Container(
                  width: 70,
                  decoration: BoxDecoration(
                    color: sel ? AppColors.primary.withValues(alpha: 0.15) : Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: sel ? AppColors.primary : Colors.white24),
                  ),
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text(s.symbol, style: TextStyle(fontSize: 22, color: sel ? AppColors.primary : Colors.white70)),
                    const SizedBox(height: 4),
                    Text(s.telugu, style: TextStyle(fontSize: 10, color: sel ? AppColors.primary : Colors.white54)),
                  ]),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: RashiPeriod.values.map((p) {
            final label = p == RashiPeriod.daily ? 'Daily' : (p == RashiPeriod.weekly ? 'Weekly' : 'Yearly');
            final sel = _period == p;
            return Padding(
              padding: const EdgeInsets.only(right: 10),
              child: GestureDetector(
                onTap: () => setState(() => _period = p),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
                  decoration: BoxDecoration(color: sel ? AppColors.primary.withValues(alpha: 0.15) : Colors.transparent, borderRadius: BorderRadius.circular(20), border: Border.all(color: sel ? AppColors.primary : Colors.white24)),
                  child: Text(label, style: TextStyle(color: sel ? AppColors.primary : Colors.white60, fontWeight: FontWeight.w600, fontSize: 13)),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        GlassPanelGold(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Text(_selected.symbol, style: const TextStyle(fontSize: 28, color: AppColors.primary)),
              const SizedBox(width: 12),
              Text('${_selected.name} (${_selected.telugu})', style: const TextStyle(color: AppColors.primary, fontSize: 18, fontWeight: FontWeight.w800)),
            ]),
            const SizedBox(height: 14),
            Text(sampleRashiPrediction, style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.6)),
          ]),
        ),
      ],
    );
  }
}
