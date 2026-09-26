import 'package:flutter/material.dart';
import 'package:pocket_puja/core/services/poojari_controller.dart';
import 'package:pocket_puja/core/theme/app_theme.dart';
import 'package:pocket_puja/core/widgets/glass.dart';
import 'package:pocket_puja/core/widgets/nav_constants.dart';
import 'package:pocket_puja/core/widgets/poojari_mode_badge.dart';
import 'package:pocket_puja/poojari/screens/notifications/poojari_notifications_screen.dart';
import 'package:pocket_puja/poojari/widgets/booking/poojari_assignment_card.dart';

/// Tab 1: Assigned Poojas Screen (BLOCK 6)
///
/// Renamed from "Requests" to "Assigned Poojas".
/// Shows devotee ritual assignments pushed to this Poojari with:
/// 1. Filter tabs: All / Today / Upcoming / Done (reusing Customer Booking List tab pattern)
/// 2. Cards showing Pooja title for Customer first name ("Ganesha Pooja for Priya"), date/time,
///    distance/area ("Hitech City · 4.2 km away"), status badge, and fee.
/// 3. "Confirm Receipt" button (ONLY on New status cards, tapping updates status to Confirmed
///    and decrements the New count nav badge reactively).
/// 4. NO Accept/Decline anywhere — assignments are direct.
/// 5. Subtle gold glow pulse on New status cards for visual urgency.
/// 6. Empty state matching Customer's Booking List pattern.
class AssignedPoojasScreen extends StatefulWidget {
  final VoidCallback? onSwitchToCustomer;

  const AssignedPoojasScreen({
    super.key,
    this.onSwitchToCustomer,
  });

  @override
  State<AssignedPoojasScreen> createState() => _AssignedPoojasScreenState();
}

class _AssignedPoojasScreenState extends State<AssignedPoojasScreen> with SingleTickerProviderStateMixin {
  int _selectedTab = 0;
  final List<String> _tabs = const ['All', 'Today', 'Upcoming', 'Done'];

  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    // Subtle, gentle pulse animation for New cards (slow 1600ms cycle)
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);

    _pulseAnimation = CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  List<PoojariBooking> _filterBookings(List<PoojariBooking> all) {
    switch (_selectedTab) {
      case 0:
        return all;
      case 1:
        return all.where((b) => b.isToday).toList();
      case 2:
        return all.where((b) => !b.isToday && !b.isDone).toList();
      case 3:
      default:
        return all.where((b) => b.isDone).toList();
    }
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
            final newCount = controller.newAssignmentsCount;

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
                              'Assigned Poojas',
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 24,
                                    shadows: AppTheme.goldGlow,
                                  ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              newCount > 0
                                  ? '$newCount new pooja assignment${newCount > 1 ? 's' : ''} awaiting receipt'
                                  : 'All assignments confirmed and scheduled',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: Colors.white70, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Bell icon routing to PoojariNotificationsScreen
                          IconButton(
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

                // 1. FILTER TABS (Reusing Customer's Booking List horizontal tab bar pattern)
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
                const SizedBox(height: 16),

                // 2. ASSIGNMENT CARDS LIST
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
                                'No assigned poojas in this category',
                                style: TextStyle(color: Colors.white38, fontSize: 14),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: EdgeInsets.fromLTRB(20, 0, 20, tabBottomPadding(context)),
                          itemCount: displayedBookings.length,
                          itemBuilder: (context, index) {
                            final booking = displayedBookings[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 14),
                              child: PoojariAssignmentCard(
                                booking: booking,
                                pulseAnimation: _pulseAnimation,
                                showConfirmReceipt: true,
                              ),
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
