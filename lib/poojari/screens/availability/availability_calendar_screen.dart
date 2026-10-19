import 'package:flutter/material.dart';
import 'package:pocket_puja/core/services/poojari_controller.dart';
import 'package:pocket_puja/core/theme/app_theme.dart';
import 'package:pocket_puja/core/widgets/glass.dart';
import 'package:pocket_puja/shared/widgets/calendar/month_grid.dart';
import 'package:pocket_puja/poojari/screens/booking_detail/poojari_booking_detail_screen.dart';
import 'package:pocket_puja/poojari/widgets/availability/availability_day_cell.dart';
import 'package:pocket_puja/poojari/widgets/availability/availability_legend.dart';
import 'package:pocket_puja/poojari/widgets/availability/recurring_day_off_sheet.dart';

/// BLOCK 11 — Poojari Availability Calendar Screen
///
/// The one and only grid-based date screen on the Poojari side.
/// Reuses MonthGrid from shared calendar (`lib/shared/widgets/calendar/month_grid.dart`)
/// by injecting a custom [cellBuilder] and [onDayTap] callback.
///
/// Day states strictly adhere to [DayAvailabilityState] precedence in [PoojariController].
class AvailabilityCalendarScreen extends StatefulWidget {
  final bool? showBack;

  const AvailabilityCalendarScreen({
    super.key,
    this.showBack,
  });

  @override
  State<AvailabilityCalendarScreen> createState() => _AvailabilityCalendarScreenState();
}

class _AvailabilityCalendarScreenState extends State<AvailabilityCalendarScreen> {
  late DateTime _focusedMonth;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _focusedMonth = DateTime(now.year, now.month, 1);
  }

  String _monthName(DateTime d) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[d.month - 1]} ${d.year}';
  }

  void _handleDayTap(DateTime date, PoojariController controller) {
    final state = controller.availabilityStateFor(date);

    if (state == DayAvailabilityState.booked) {
      final booking = controller.getBookingForDate(date);
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            booking != null
                ? 'Booked: ${booking.poojaName} • ${booking.scheduledTime}'
                : 'Booked: view details',
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFF1E1C16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: AppColors.primary),
          ),
          action: SnackBarAction(
            label: 'View details',
            textColor: AppColors.primary,
            onPressed: () {
              if (booking != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PoojariBookingDetailScreen(booking: booking),
                  ),
                );
              }
            },
          ),
        ),
      );
      return;
    }

    if (state == DayAvailabilityState.recurringOff) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Recurring off-day: use "Set Recurring Day Off" below to modify weekly schedule.',
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFF1E1C16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Colors.white24),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    if (state == DayAvailabilityState.past) {
      return;
    }

    controller.toggleDateBlock(date);
  }

  String _formatRecurringSummary(Set<int> weekdays) {
    if (weekdays.isEmpty) return 'No recurring days off set';
    const names = {
      DateTime.monday: 'Mon',
      DateTime.tuesday: 'Tue',
      DateTime.wednesday: 'Wed',
      DateTime.thursday: 'Thu',
      DateTime.friday: 'Fri',
      DateTime.saturday: 'Sat',
      DateTime.sunday: 'Sun',
    };
    final sorted = weekdays.toList()..sort();
    return 'Off every ${sorted.map((d) => names[d]).join(', ')}';
  }

  @override
  Widget build(BuildContext context) {
    final controller = PoojariControllerScope.maybeOf(context) ?? PoojariController.instance;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final canPop = widget.showBack ?? Navigator.canPop(context);

    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        return GlassScaffold(
          title: 'Availability Calendar',
          showBack: canPop,
          body: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Info banner explaining tap behavior
                GlassPanelGold(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  borderRadius: 16,
                  child: const Row(
                    children: [
                      Icon(Icons.touch_app_rounded, color: AppColors.primary, size: 24),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Declare Your Availability',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Tap any available date to block it off. Tap again to unblock. Booked dates are auto-locked.',
                              style: TextStyle(color: Colors.white70, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Month navigation row (matches Customer's calendar navigation)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _monthName(_focusedMonth),
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontSize: 20),
                    ),
                    Row(
                      children: [
                        _RoundBtn(
                          icon: Icons.chevron_left,
                          onTap: () => setState(
                            () => _focusedMonth = DateTime(
                              _focusedMonth.year,
                              _focusedMonth.month - 1,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        _RoundBtn(
                          icon: Icons.chevron_right,
                          onTap: () => setState(
                            () => _focusedMonth = DateTime(
                              _focusedMonth.year,
                              _focusedMonth.month + 1,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Reused MonthGrid from Customer's Calendar with custom cellBuilder and onDayTap
                GlassPanel(
                  padding: const EdgeInsets.all(12),
                  borderRadius: 18,
                  child: MonthGrid(
                    focusedMonth: _focusedMonth,
                    cellBuilder: (ctx, date, isSelected) {
                      final state = controller.availabilityStateFor(date);
                      final isToday = date.year == today.year &&
                          date.month == today.month &&
                          date.day == today.day;
                      return AvailabilityDayCell(
                        date: date,
                        state: state,
                        isToday: isToday,
                      );
                    },
                    onDayTap: (date) => _handleDayTap(date, controller),
                  ),
                ),
                const SizedBox(height: 14),

                // Legend (always visible directly below the grid)
                const AvailabilityLegend(),
                const SizedBox(height: 20),

                // Recurring Day Off control section
                GlassPanel(
                  padding: const EdgeInsets.all(16),
                  borderRadius: 16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.repeat_rounded, color: AppColors.primary, size: 20),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text(
                              'Recurring Days Off',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          TextButton.icon(
                            onPressed: () => RecurringDayOffSheet.show(
                              context,
                              controller: controller,
                            ),
                            icon: const Icon(Icons.tune_rounded, size: 16, color: AppColors.primary),
                            label: const Text(
                              'Configure',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatRecurringSummary(controller.recurringOffWeekdays),
                        style: TextStyle(
                          color: controller.recurringOffWeekdays.isNotEmpty
                              ? Colors.white70
                              : Colors.white38,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
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
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white24),
        ),
        child: Icon(icon, color: Colors.white70, size: 20),
      ),
    );
  }
}
