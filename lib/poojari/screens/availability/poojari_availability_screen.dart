import 'package:flutter/material.dart';
import 'package:pocket_puja/core/theme/app_theme.dart';
import 'package:pocket_puja/core/widgets/glass.dart';

/// Screen allowing the Poojari to configure weekly availability blocks.
/// Linked from the Section 6 Availability Nudge on the Poojari Dashboard.
class PoojariAvailabilityScreen extends StatefulWidget {
  const PoojariAvailabilityScreen({super.key});

  @override
  State<PoojariAvailabilityScreen> createState() => _PoojariAvailabilityScreenState();
}

class _PoojariAvailabilityScreenState extends State<PoojariAvailabilityScreen> {
  final Map<String, List<String>> _schedule = {
    'Monday': ['Morning (6:00 AM - 11:00 AM)', 'Evening (4:00 PM - 8:30 PM)'],
    'Tuesday': ['Morning (6:00 AM - 11:00 AM)', 'Evening (4:00 PM - 8:30 PM)'],
    'Wednesday': ['Morning (6:00 AM - 11:00 AM)', 'Evening (4:00 PM - 8:30 PM)'],
    'Thursday': ['Morning (6:00 AM - 11:00 AM)', 'Evening (4:00 PM - 8:30 PM)'],
    'Friday': ['Morning (6:00 AM - 12:00 PM)', 'Evening (4:00 PM - 9:00 PM)'],
    'Saturday': ['Full Day (6:00 AM - 9:00 PM)'],
    'Sunday': ['Full Day (6:00 AM - 9:00 PM)'],
  };

  void _saveSchedule() {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Weekly availability updated successfully!'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GlassScaffold(
      title: 'Availability Calendar',
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        children: [
          GlassPanelGold(
            padding: const EdgeInsets.all(16),
            borderRadius: 18,
            child: const Row(
              children: [
                Icon(Icons.calendar_month, color: AppColors.primary, size: 28),
                SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Weekly Ritual Slots',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Devotees can only book during your declared auspicious hours.',
                        style: TextStyle(color: Colors.white60, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          for (final entry in _schedule.entries) ...[
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: GlassPanel(
                padding: const EdgeInsets.all(14),
                borderRadius: 14,
                child: Row(
                  children: [
                    SizedBox(
                      width: 90,
                      child: Text(
                        entry.key,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (final slot in entry.value)
                            Container(
                              margin: const EdgeInsets.only(bottom: 4),
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                slot,
                                style: const TextStyle(
                                  color: AppColors.primaryFixed,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const Icon(Icons.edit_outlined, size: 18, color: Colors.white38),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 16),

          ElevatedButton(
            onPressed: _saveSchedule,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.onPrimary,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: const Text(
              'Save Availability',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}
