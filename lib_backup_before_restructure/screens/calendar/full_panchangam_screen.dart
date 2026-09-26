import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/glass.dart';
import '../../data/calendar/calendar_data.dart';

class FullPanchangamScreen extends StatelessWidget {
  final int day;
  final DateTime month;
  const FullPanchangamScreen({super.key, required this.day, required this.month});

  @override
  Widget build(BuildContext context) {
    final p = samplePanchangam;
    return GlassScaffold(
      title: 'Full Panchangam',
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
        children: [
          Text('$day ${_monthName(month)} ${month.year}', style: Theme.of(context).textTheme.headlineLarge?.copyWith(color: AppColors.primary, fontSize: 22, shadows: AppTheme.goldGlow)),
          const SizedBox(height: 16),
          GlassPanel(child: Column(children: [
            _row('వారం (Vaaram)', p.vaaram),
            const Divider(color: Colors.white12, height: 24),
            _row('తిథి (Tithi)', p.tithi),
            const Divider(color: Colors.white12, height: 24),
            _row('నక్షత్రం (Nakshatram)', p.nakshatram),
            const Divider(color: Colors.white12, height: 24),
            _row('యోగం (Yogam)', p.yogam),
            const Divider(color: Colors.white12, height: 24),
            _row('కరణం (Karanam)', p.karanam),
            const Divider(color: Colors.white12, height: 24),
            Row(children: [Expanded(child: _row('సూర్యోదయం', p.sunrise)), Expanded(child: _row('సూర్యాస్తమయం', p.sunset))]),
          ])),
          const SizedBox(height: 16),
          const SectionLabel('AUSPICIOUS TIMES'),
          const SizedBox(height: 10),
          GlassPanel(
            borderColor: const Color(0xFF9DE6B4), tint: const Color(0xFF9DE6B4),
            child: Column(children: [
              _timeRow('అమృత ఘడియలు (Amrutha Gadiyalu)', p.amruthaGadiyalu, const Color(0xFF9DE6B4)),
              const Divider(color: Colors.white12, height: 20),
              _timeRow('అభిజిత్ ముహూర్తం (Abhijith Muhurtham)', p.abhijitMuhurtham, const Color(0xFF9DE6B4)),
            ]),
          ),
          const SizedBox(height: 16),
          const SectionLabel('INAUSPICIOUS TIMES'),
          const SizedBox(height: 10),
          GlassPanel(
            borderColor: const Color(0xFFE05353), tint: const Color(0xFFE05353),
            child: Column(children: [
              _timeRow('రాహు కాలం (Rahu Kalam)', p.rahuKalam, const Color(0xFFFFA5A5)),
              const Divider(color: Colors.white12, height: 20),
              _timeRow('యమగండం (Yamagandam)', p.yamagandam, const Color(0xFFFFA5A5)),
              const Divider(color: Colors.white12, height: 20),
              _timeRow('గుళికకాలం (Gulika Kalam)', p.gulikaKalam, const Color(0xFFFFA5A5)),
              const Divider(color: Colors.white12, height: 20),
              _timeRow('దుర్ముహూర్తం (Durmuhurtham)', p.durmuhurtham, const Color(0xFFFFA5A5)),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(color: Colors.white38, fontSize: 11)),
      const SizedBox(height: 4),
      Text(value, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
    ]);
  }

  Widget _timeRow(String label, String value, Color color) {
    return Row(children: [
      Icon(Icons.circle, size: 8, color: color),
      const SizedBox(width: 10),
      Expanded(child: Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12))),
      Text(value, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w700)),
    ]);
  }

  String _monthName(DateTime d) {
    const months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
    return months[d.month - 1];
  }
}
