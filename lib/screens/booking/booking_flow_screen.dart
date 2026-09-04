import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/glass.dart';
import '../../data/booking/booking_data.dart';
import '../profile/addresses_screen.dart';
import 'booking_detail_screen.dart';
import '../../data/profile/profile_data.dart';

class BookingFlowScreen extends StatefulWidget {
  const BookingFlowScreen({super.key});
  @override
  State<BookingFlowScreen> createState() => _BookingFlowScreenState();
}

class _BookingFlowScreenState extends State<BookingFlowScreen> {
  int _step = 0;
  OccasionData? _selectedOccasion;
  PoojaTypeData? _selectedPooja;
  int _selectedDay = 5;
  AddressData? _selectedAddress = addresses.isNotEmpty ? addresses.first : null;
  bool _isSubmitting = false;

  Future<void> _confirm() async {
    setState(() => _isSubmitting = true);
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    setState(() => _isSubmitting = false);
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (_) => BookingDetailScreen(poojaName: _selectedPooja?.name ?? 'Pooja', bookingId: 'PP-88291', status: 'PENDING'),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return GlassScaffold(
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
        children: [
          Row(children: [
            _StepCircle(number: '1', label: 'OCCASION', active: _step >= 0),
            Expanded(child: Container(height: 1, color: Colors.white24)),
            _StepCircle(number: '2', label: 'DETAILS', active: _step >= 1),
            Expanded(child: Container(height: 1, color: Colors.white24)),
            _StepCircle(number: '3', label: 'CONFIRM', active: _step >= 2),
          ]),
          const SizedBox(height: 28),

          if (_step == 0) ..._buildOccasionStep(),
          if (_step == 1) ..._buildDetailsStep(),
          if (_step == 2) ..._buildConfirmStep(),
        ],
      ),
    );
  }

  List<Widget> _buildOccasionStep() {
    return [
      Center(child: Column(children: [
        Text('పూజా రకం ఎంచుకోండి', style: Theme.of(context).textTheme.headlineLarge?.copyWith(color: AppColors.primary, fontSize: 24, shadows: AppTheme.goldGlow)),
        const SizedBox(height: 6),
        const Text("What's the occasion for your pooja?", textAlign: TextAlign.center, style: TextStyle(color: Colors.white60, fontSize: 13)),
      ])),
      const SizedBox(height: 20),
      ...occasions.map((occ) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: GlassPanel(
              padding: const EdgeInsets.all(16),
              borderRadius: 18,
              onTap: () => setState(() { _selectedOccasion = occ; _selectedPooja = occ.poojas.first; _step = 1; }),
              child: Row(children: [
                Text(occ.emoji, style: const TextStyle(fontSize: 28)),
                const SizedBox(width: 14),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(occ.name, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
                  Text(occ.poojas.map((p) => p.name).join(', '), style: const TextStyle(color: Colors.white54, fontSize: 12)),
                ])),
                const Icon(Icons.chevron_right, color: Colors.white38),
              ]),
            ),
          )),
    ];
  }

  List<Widget> _buildDetailsStep() {
    final occ = _selectedOccasion!;
    return [
      Row(children: [
        IconButton(onPressed: () => setState(() => _step = 0), icon: const Icon(Icons.arrow_back, color: Colors.white70, size: 18)),
        Text('${occ.emoji} ${occ.name}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
      ]),
      const SizedBox(height: 12),
      if (occ.poojas.length > 1) ...[
        const SectionLabel('SELECT SPECIFIC POOJA'),
        const SizedBox(height: 10),
        ...occ.poojas.map((p) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: GlassPanel(
                padding: const EdgeInsets.all(14),
                borderRadius: 16,
                tint: _selectedPooja == p ? AppColors.primary : Colors.white,
                onTap: () => setState(() => _selectedPooja = p),
                child: Row(children: [
                  Icon(p.icon, color: AppColors.primary, size: 20),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(p.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
                    Text(p.telugu, style: const TextStyle(color: Colors.white54, fontSize: 11)),
                  ])),
                  if (_selectedPooja == p) const Icon(Icons.check_circle, color: AppColors.primary),
                ]),
              ),
            )),
        const SizedBox(height: 20),
      ],
      const SectionLabel('DATE & TIME'),
      const SizedBox(height: 10),
      GlassPanel(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          Row(children: ['S', 'M', 'T', 'W', 'T', 'F', 'S'].map((d) => Expanded(child: Center(child: Text(d, style: const TextStyle(color: Colors.white38, fontSize: 11))))).toList()),
          const SizedBox(height: 8),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7, childAspectRatio: 1),
            itemCount: 14,
            itemBuilder: (_, i) {
              final dayNum = i - 2;
              if (dayNum < 1) return const SizedBox();
              final selected = dayNum == _selectedDay;
              return GestureDetector(
                onTap: () => setState(() => _selectedDay = dayNum),
                child: Container(
                  margin: const EdgeInsets.all(3),
                  decoration: BoxDecoration(color: selected ? AppColors.primary : null, shape: BoxShape.circle),
                  child: Center(child: Text('$dayNum', style: TextStyle(color: selected ? AppColors.onPrimary : Colors.white, fontWeight: selected ? FontWeight.w700 : FontWeight.w400))),
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          const Divider(color: Colors.white12),
          Row(children: const [
            Icon(Icons.access_time, color: Colors.white54, size: 18),
            SizedBox(width: 10),
            Text('06:00 AM - Brahma Muhurtham', style: TextStyle(color: Colors.white, fontSize: 13)),
            Spacer(),
            Icon(Icons.keyboard_arrow_down, color: Colors.white54),
          ]),
        ]),
      ),
      const SizedBox(height: 20),
      const SectionLabel('SERVICE LOCATION'),
      const SizedBox(height: 10),
      GlassPanel(
        padding: const EdgeInsets.all(14),
        onTap: () async {
          final picked = await Navigator.of(context).push<AddressData>(MaterialPageRoute(builder: (_) => const AddressesScreen(pickMode: true)));
          if (picked != null) setState(() => _selectedAddress = picked);
        },
        child: Row(children: [
          const Icon(Icons.location_on_outlined, color: AppColors.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(_selectedAddress?.label ?? 'Select an address', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
            if (_selectedAddress != null) Text(_selectedAddress!.line, style: const TextStyle(color: Colors.white54, fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis),
          ])),
          const Icon(Icons.chevron_right, color: Colors.white38),
        ]),
      ),
      const SizedBox(height: 8),
      const Text('Poojari travel charges might apply for locations >10km.', style: TextStyle(color: Colors.white38, fontSize: 11)),
      const SizedBox(height: 24),
      PrimaryButton(label: 'Review & Continue', icon: Icons.arrow_forward, onTap: () => setState(() => _step = 2)),
    ];
  }

  List<Widget> _buildConfirmStep() {
    return [
      Row(children: [
        IconButton(onPressed: () => setState(() => _step = 1), icon: const Icon(Icons.arrow_back, color: Colors.white70, size: 18)),
        const Text('Review Your Booking', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
      ]),
      const SizedBox(height: 16),
      GlassPanel(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _reviewRow(Icons.self_improvement, 'Pooja', _selectedPooja?.name ?? ''),
          const Divider(color: Colors.white12, height: 24),
          _reviewRow(Icons.calendar_today, 'Date & Time', 'Nov $_selectedDay, 2024 · 6:00 AM'),
          const Divider(color: Colors.white12, height: 24),
          _reviewRow(Icons.location_on_outlined, 'Location', _selectedAddress?.line ?? ''),
          const Divider(color: Colors.white12, height: 24),
          _reviewRow(Icons.currency_rupee, 'Estimated Fee', '₹1,500'),
        ]),
      ),
      const SizedBox(height: 24),
      PrimaryButton(label: 'Confirm Booking', icon: Icons.arrow_forward, isLoading: _isSubmitting, onTap: _confirm),
    ];
  }

  Widget _reviewRow(IconData icon, String label, String value) {
    return Row(children: [
      Icon(icon, color: AppColors.primary, size: 18),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(color: Colors.white38, fontSize: 11)),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
      ])),
    ]);
  }
}

class _StepCircle extends StatelessWidget {
  final String number, label;
  final bool active;
  const _StepCircle({required this.number, required this.label, required this.active});
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Container(width: 32, height: 32, decoration: BoxDecoration(shape: BoxShape.circle, color: active ? AppColors.primary : Colors.white24),
        child: Center(child: Text(number, style: TextStyle(color: active ? AppColors.onPrimary : Colors.white70, fontWeight: FontWeight.w700)))),
      const SizedBox(height: 4),
      Text(label, style: TextStyle(color: active ? AppColors.primary : Colors.white38, fontSize: 9, fontWeight: FontWeight.w600)),
    ]);
  }
}
