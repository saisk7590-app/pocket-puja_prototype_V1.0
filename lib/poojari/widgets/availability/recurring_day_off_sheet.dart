import 'package:flutter/material.dart';
import 'package:pocket_puja/core/services/poojari_controller.dart';
import 'package:pocket_puja/core/theme/app_theme.dart';
import 'package:pocket_puja/core/widgets/glass.dart';

/// Bottom sheet dialog allowing Poojaris to configure their recurring off-day pattern.
/// Uses the exact FilterChip styling established in Block 1 registration (Specializations / Languages).
class RecurringDayOffSheet extends StatefulWidget {
  final Set<int> initialSelectedWeekdays;
  final ValueChanged<Set<int>> onSave;

  const RecurringDayOffSheet({
    super.key,
    required this.initialSelectedWeekdays,
    required this.onSave,
  });

  static Future<void> show(
    BuildContext context, {
    required PoojariController controller,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => RecurringDayOffSheet(
        initialSelectedWeekdays: controller.recurringOffWeekdays,
        onSave: (weekdays) {
          controller.setRecurringOffWeekdays(weekdays);
        },
      ),
    );
  }

  @override
  State<RecurringDayOffSheet> createState() => _RecurringDayOffSheetState();
}

class _RecurringDayOffSheetState extends State<RecurringDayOffSheet> {
  late final Set<int> _selectedWeekdays;

  static const List<MapEntry<int, String>> _weekdays = [
    MapEntry(DateTime.monday, 'Mon'),
    MapEntry(DateTime.tuesday, 'Tue'),
    MapEntry(DateTime.wednesday, 'Wed'),
    MapEntry(DateTime.thursday, 'Thu'),
    MapEntry(DateTime.friday, 'Fri'),
    MapEntry(DateTime.saturday, 'Sat'),
    MapEntry(DateTime.sunday, 'Sun'),
  ];

  @override
  void initState() {
    super.initState();
    _selectedWeekdays = Set<int>.from(widget.initialSelectedWeekdays);
  }

  void _handleSave() {
    widget.onSave(_selectedWeekdays);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _selectedWeekdays.isEmpty
              ? 'Recurring off-days cleared.'
              : 'Recurring off-day pattern saved (${_selectedWeekdays.length} day${_selectedWeekdays.length > 1 ? 's' : ''}/week).',
        ),
        backgroundColor: const Color(0xFF1E1C16),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.primary),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(
          top: BorderSide(color: Colors.white12, width: 1),
          left: BorderSide(color: Colors.white12, width: 1),
          right: BorderSide(color: Colors.white12, width: 1),
        ),
      ),
      padding: EdgeInsets.fromLTRB(
        20,
        14,
        20,
        MediaQuery.of(context).padding.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.repeat_rounded, color: AppColors.primary, size: 22),
                  SizedBox(width: 8),
                  Text(
                    'Set Recurring Day Off',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white60, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Select weekdays you routinely take off. Future dates matching these weekdays will automatically show as recurring off-days on your calendar.',
            style: TextStyle(color: Colors.white60, fontSize: 13, height: 1.4),
          ),
          const SizedBox(height: 20),

          // Weekday chips row (Mon-Sun) reusing Block 1 registration chip styling
          Wrap(
            spacing: 8,
            runSpacing: 10,
            children: _weekdays.map((entry) {
              final weekday = entry.key;
              final label = entry.value;
              final isSelected = _selectedWeekdays.contains(weekday);

              return FilterChip(
                label: Text(label),
                selected: isSelected,
                onSelected: (val) {
                  setState(() {
                    if (val) {
                      _selectedWeekdays.add(weekday);
                    } else {
                      _selectedWeekdays.remove(weekday);
                    }
                  });
                },
                backgroundColor: Colors.white.withValues(alpha: 0.05),
                selectedColor: AppColors.primary.withValues(alpha: 0.25),
                checkmarkColor: AppColors.primary,
                labelStyle: TextStyle(
                  color: isSelected ? AppColors.primary : Colors.white70,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  fontSize: 13,
                ),
                side: BorderSide(
                  color: isSelected ? AppColors.primary : Colors.white12,
                  width: isSelected ? 1.4 : 1.0,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          // Action row
          Row(
            children: [
              if (_selectedWeekdays.isNotEmpty) ...[
                Expanded(
                  flex: 1,
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _selectedWeekdays.clear();
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white70,
                      side: const BorderSide(color: Colors.white24),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text('Clear All'),
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                flex: 2,
                child: PrimaryButton(
                  label: 'Save Pattern',
                  onTap: _handleSave,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
