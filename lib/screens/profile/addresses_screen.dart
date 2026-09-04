import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/glass.dart';
import '../../data/profile/profile_data.dart';

/// When [pickMode] is true (opened from Booking/Cart), tapping an address
/// pops it back to the caller instead of just viewing/editing.
class AddressesScreen extends StatelessWidget {
  final bool pickMode;
  const AddressesScreen({super.key, this.pickMode = false});

  @override
  Widget build(BuildContext context) {
    return GlassScaffold(
      title: pickMode ? 'Select Address' : 'Saved Addresses',
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
        children: [
          ...addresses.map((a) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: GlassPanel(
                  padding: const EdgeInsets.all(16),
                  onTap: pickMode ? () => Navigator.of(context).pop(a) : null,
                  child: Row(children: [
                    Container(width: 40, height: 40, decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)), child: Icon(a.label == 'Home' ? Icons.home : Icons.business, color: AppColors.primary, size: 20)),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Row(children: [
                          Text(a.label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
                          if (a.isDefault) Padding(padding: const EdgeInsets.only(left: 8), child: Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)), child: const Text('DEFAULT', style: TextStyle(color: AppColors.primary, fontSize: 8, fontWeight: FontWeight.w800)))),
                        ]),
                        const SizedBox(height: 4),
                        Text(a.line, style: const TextStyle(color: Colors.white60, fontSize: 12)),
                        Text(a.landmark, style: const TextStyle(color: Colors.white38, fontSize: 11)),
                      ]),
                    ),
                    if (!pickMode) ...[
                      IconButton(icon: const Icon(Icons.edit, color: Colors.white38, size: 18), onPressed: () {}),
                    ] else
                      const Icon(Icons.chevron_right, color: Colors.white38),
                  ]),
                ),
              )),
          const SizedBox(height: 8),
          GlassPanel(
            padding: const EdgeInsets.all(16),
            onTap: () {},
            child: Row(children: const [
              Icon(Icons.add_circle_outline, color: AppColors.primary),
              SizedBox(width: 12),
              Text('Add New Address', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
            ]),
          ),
        ],
      ),
    );
  }
}
