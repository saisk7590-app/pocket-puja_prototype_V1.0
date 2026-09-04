import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/glass.dart';
import '../../widgets/calendar/month_grid.dart';
import '../../data/calendar/calendar_data.dart';
import '../../data/home/home_data.dart';
import 'full_panchangam_screen.dart';
import 'festivals_screen.dart';
import 'rashi_phalam_screen.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});
  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  int _tab = 0; // 0 Panchangam, 1 Festivals, 2 Rashi
  DateTime _focusedMonth = DateTime.now();
  int _selectedDay = DateTime.now().day;

  @override
  Widget build(BuildContext context) {
    return GlassScaffold(
      showBack: false,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: Row(children: [
              _MiniTab(label: 'పంచాంగం', selected: _tab == 0, onTap: () => setState(() => _tab = 0)),
              const SizedBox(width: 8),
              _MiniTab(label: 'పండుగలు', selected: _tab == 1, onTap: () => setState(() => _tab = 1)),
              const SizedBox(width: 8),
              _MiniTab(label: 'రాశిఫలం', selected: _tab == 2, onTap: () => setState(() => _tab = 2)),
            ]),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: _tab == 0 ? _buildPanchangamView() : (_tab == 1 ? const FestivalsScreen() : const RashiPhalamScreen(initialSign: 'Simha')),
          ),
        ],
      ),
    );
  }

  Widget _buildPanchangamView() {
    final festivalToday = festivals.where((f) => f.day == _selectedDay && f.month == _focusedMonth.month).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 110),
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(_monthName(_focusedMonth), style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontSize: 22)),
          Row(children: [
            _RoundBtn(icon: Icons.chevron_left, onTap: () => setState(() => _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1))),
            const SizedBox(width: 8),
            _RoundBtn(icon: Icons.chevron_right, onTap: () => setState(() => _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1))),
          ]),
        ]),
        const SizedBox(height: 12),
        GlassPanel(padding: const EdgeInsets.all(16), child: MonthGrid(focusedMonth: _focusedMonth, selectedDay: _selectedDay, onSelectDay: (d) => setState(() => _selectedDay = d))),
        const SizedBox(height: 16),

        // Tier 1 — glanceable summary only (persistent, not a sheet).
        if (festivalToday.isNotEmpty) ...[
          GlassPanelGold(
            padding: const EdgeInsets.all(14),
            borderRadius: 16,
            child: Row(children: [
              const Icon(Icons.celebration, color: AppColors.primary),
              const SizedBox(width: 12),
              Expanded(child: Text(festivalToday.first.name, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 14))),
            ]),
          ),
          const SizedBox(height: 12),
        ],
        GlassPanel(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('$_selectedDay ${_monthShort(_focusedMonth)} ${_focusedMonth.year}', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: _brief('TITHI', samplePanchangam.tithi.split(',').first)),
              Expanded(child: _brief('NAKSHATRAM', samplePanchangam.nakshatram.split(',').first)),
            ]),
          ]),
        ),
        const SizedBox(height: 12),
        // Optional Rashi card — only if DOB set (mocked here as present).
        GlassPanel(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          borderRadius: 16,
          onTap: () => setState(() => _tab = 2),
          child: Row(children: [
            const Icon(Icons.auto_awesome, color: AppColors.primary, size: 18),
            const SizedBox(width: 12),
            Expanded(child: Text('Your Rashi: ${currentUserRashi.oneLiner}', style: const TextStyle(color: Colors.white70, fontSize: 12))),
            const Icon(Icons.chevron_right, color: Colors.white38, size: 18),
          ]),
        ),
        const SizedBox(height: 16),
        PrimaryButton(label: 'View Full Panchangam', icon: Icons.arrow_forward, onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => FullPanchangamScreen(day: _selectedDay, month: _focusedMonth)))),
      ],
    );
  }

  Widget _brief(String label, String value) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(color: Colors.white38, fontSize: 10, letterSpacing: 0.5)),
      const SizedBox(height: 4),
      Text(value, style: const TextStyle(color: AppColors.primary, fontSize: 13, fontWeight: FontWeight.w700)),
    ]);
  }

  String _monthName(DateTime d) {
    const months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
    return '${months[d.month - 1]} ${d.year}';
  }

  String _monthShort(DateTime d) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[d.month - 1];
  }
}

class _MiniTab extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _MiniTab({required this.label, required this.selected, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(color: selected ? AppColors.primary.withValues(alpha: 0.15) : Colors.transparent, borderRadius: BorderRadius.circular(14), border: Border.all(color: selected ? AppColors.primary : Colors.white24)),
          alignment: Alignment.center,
          child: Text(label, style: TextStyle(color: selected ? AppColors.primary : Colors.white54, fontWeight: FontWeight.w600, fontSize: 12)),
        ),
      ),
    );
  }
}

class _RoundBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _RoundBtn({required this.icon, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(width: 36, height: 36, decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.08), shape: BoxShape.circle, border: Border.all(color: Colors.white24)), child: Icon(icon, color: Colors.white70, size: 20)),
    );
  }
}
