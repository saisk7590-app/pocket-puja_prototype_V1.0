import 'package:flutter/material.dart';
import 'package:pocket_puja/core/services/poojari_controller.dart';
import 'package:pocket_puja/core/theme/app_theme.dart';
import 'package:pocket_puja/core/widgets/glass.dart';
import 'package:pocket_puja/core/widgets/nav_constants.dart';
import 'package:pocket_puja/core/widgets/poojari_mode_badge.dart';
import 'package:pocket_puja/poojari/screens/booking_detail/poojari_booking_detail_screen.dart';
import 'package:pocket_puja/poojari/screens/notifications/poojari_notifications_screen.dart';
import 'package:pocket_puja/poojari/widgets/booking/poojari_assignment_card.dart';

/// BLOCK 10 — My Schedule Screen
///
/// Mirrors Customer's Booking List structurally with:
/// - Same tab bar pattern matching Block 6's Assigned Poojas vocabulary:
///   ['All', 'Upcoming', 'Done', 'Cancelled']
/// - Cards grouped under section headers by date bucket:
///   Today → Tomorrow → This Week → Later (or Yesterday/Earlier for past tabs)
/// - Reuses SectionLabel from core/widgets/glass.dart (same as Block 7 Notifications)
/// - Reuses PoojariAssignmentCard from Block 6
/// - Reads from PoojariController shared state
/// - Empty state matching Customer's Booking List pattern
/// - List-only view (no calendar grid)
class MyScheduleScreen extends StatefulWidget {
  final VoidCallback? onSwitchToCustomer;

  const MyScheduleScreen({
    super.key,
    this.onSwitchToCustomer,
  });

  @override
  State<MyScheduleScreen> createState() => _MyScheduleScreenState();
}

class _MyScheduleScreenState extends State<MyScheduleScreen> {
  int _selectedTab = 0;

  /// Tab labels matching Block 6 Assigned Poojas vocabulary:
  /// 'Upcoming' matches active/upcoming poojas, 'Done' matches completed poojas,
  /// 'Cancelled' matches cancelled rituals.
  final List<String> _tabs = const ['All', 'Upcoming', 'Done', 'Cancelled'];

  List<PoojariBooking> _filterBookings(List<PoojariBooking> all) {
    switch (_selectedTab) {
      case 0: // All
        return all;
      case 1: // Upcoming (active, not done, not cancelled)
        return all.where((b) => !b.isDone && !b.isCancelled).toList();
      case 2: // Done
        return all.where((b) => b.isDone).toList();
      case 3: // Cancelled
      default:
        return all.where((b) => b.isCancelled).toList();
    }
  }

  Map<String, List<PoojariBooking>> _groupByDate(List<PoojariBooking> list) {
    final Map<String, List<PoojariBooking>> groups = {};
    final isPastOriented = _selectedTab == 2 || _selectedTab == 3;

    for (final b in list) {
      final dateLower = b.date.toLowerCase();
      String bucket;

      if (dateLower.contains('today')) {
        bucket = 'TODAY';
      } else if (dateLower.contains('tomorrow')) {
        bucket = 'TOMORROW';
      } else if (dateLower.contains('yesterday')) {
        bucket = isPastOriented ? 'YESTERDAY' : 'PAST';
      } else if (dateLower.contains('this week')) {
        bucket = 'THIS WEEK';
      } else {
        bucket = isPastOriented ? 'EARLIER' : 'LATER';
      }

      groups.putIfAbsent(bucket, () => []).add(b);
    }

    return groups;
  }

  List<String> _orderedBucketKeys(Map<String, List<PoojariBooking>> groups) {
    const preferredOrder = [
      'TODAY',
      'TOMORROW',
      'THIS WEEK',
      'LATER',
      'YESTERDAY',
      'EARLIER',
      'PAST',
    ];

    final keys = <String>[];
    for (final k in preferredOrder) {
      if (groups.containsKey(k) && groups[k]!.isNotEmpty) {
        keys.add(k);
      }
    }
    // Any other bucket not in preferred list
    for (final k in groups.keys) {
      if (!keys.contains(k) && groups[k]!.isNotEmpty) {
        keys.add(k);
      }
    }
    return keys;
  }

  @override
  Widget build(BuildContext context) {
    final controller = PoojariControllerScope.maybeOf(context) ?? PoojariController.instance;

    return GlassScaffold(
      showAppBar: false,
      body: SafeArea(
        child: AnimatedBuilder(
          animation: controller,
          builder: (context, _) {
            final allBookings = controller.allBookings;
            final displayedBookings = _filterBookings(allBookings);
            final dateGroups = _groupByDate(displayedBookings);
            final bucketKeys = _orderedBucketKeys(dateGroups);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Header Row
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'My Schedule',
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 24,
                                    shadows: AppTheme.goldGlow,
                                  ),
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              'Auspicious timings & confirmed ritual calendar',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: Colors.white70, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            tooltip: 'Notifications',
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const PoojariNotificationsScreen(),
                                ),
                              );
                            },
                            icon: const Icon(
                              Icons.notifications_none_rounded,
                              color: AppColors.primary,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 4),
                          PoojariModeBadge(
                            isPoojari: true,
                            onToggle: widget.onSwitchToCustomer,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // 1. FILTER TABS (Reusing Customer Booking List tab pattern with Block 6 vocabulary)
                SizedBox(
                  height: 40,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    scrollDirection: Axis.horizontal,
                    itemCount: _tabs.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 10),
                    itemBuilder: (_, i) {
                      final isSelected = _selectedTab == i;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedTab = i),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary.withValues(alpha: 0.18)
                                : Colors.white.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected ? AppColors.primary : Colors.white24,
                              width: isSelected ? 1.5 : 1.0,
                            ),
                          ),
                          child: Text(
                            _tabs[i],
                            style: TextStyle(
                              color: isSelected ? AppColors.primary : Colors.white70,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),

                // 2. GROUPED SCHEDULE LIST (Today → Tomorrow → This Week → Later)
                Expanded(
                  child: displayedBookings.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.event_busy,
                                size: 56,
                                color: Colors.white.withValues(alpha: 0.2),
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'No rituals scheduled in this category',
                                style: TextStyle(color: Colors.white38, fontSize: 14),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: EdgeInsets.fromLTRB(20, 0, 20, tabBottomPadding(context)),
                          itemCount: bucketKeys.length,
                          itemBuilder: (context, bucketIndex) {
                            final bucketName = bucketKeys[bucketIndex];
                            final bucketBookings = dateGroups[bucketName]!;

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Date Section Header reusing SectionLabel from Notifications
                                Padding(
                                  padding: const EdgeInsets.only(top: 14, bottom: 8),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.calendar_today_rounded,
                                        color: AppColors.primary,
                                        size: 14,
                                      ),
                                      const SizedBox(width: 8),
                                      SectionLabel(bucketName),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 1,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.primary.withValues(alpha: 0.12),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Text(
                                          '${bucketBookings.length}',
                                          style: const TextStyle(
                                            color: AppColors.primary,
                                            fontSize: 10,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Cards in this date section
                                ...bucketBookings.map(
                                  (booking) => Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: PoojariAssignmentCard(
                                      booking: booking,
                                      showConfirmReceipt: false,
                                      onTap: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (_) => PoojariBookingDetailScreen(
                                              booking: booking,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
