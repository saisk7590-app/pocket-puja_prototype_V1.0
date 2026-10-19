import 'package:flutter/material.dart';
import 'package:pocket_puja/core/services/poojari_controller.dart';
import 'package:pocket_puja/core/theme/app_theme.dart';
import 'package:pocket_puja/core/widgets/glass.dart';
import 'package:pocket_puja/core/widgets/nav_constants.dart';
import 'package:pocket_puja/poojari/screens/earnings/earning_detail_screen.dart';
import 'package:pocket_puja/poojari/screens/notifications/poojari_notifications_screen.dart';
import 'package:pocket_puja/poojari/screens/profile/poojari_profile_screen.dart';
import 'package:pocket_puja/poojari/widgets/earnings/earning_list_card.dart';
import 'package:pocket_puja/poojari/widgets/earnings/earnings_filter_chips.dart';
import 'package:pocket_puja/poojari/widgets/earnings/earnings_summary_card.dart';
import 'package:pocket_puja/poojari/widgets/earnings/settlement_info_card.dart';

/// BLOCK 12: Earnings Screen (Tab 3)
///
/// Structurally mirrors Customer's My Orders (filter chips, list, detail),
/// reframed around dakshina revenue coming in.
/// Reuses My Orders' filter-chip pattern and list-card shape.
class EarningsScreen extends StatefulWidget {
  final VoidCallback? onSwitchToCustomer;
  final VoidCallback? onLogout;

  const EarningsScreen({
    super.key,
    this.onSwitchToCustomer,
    this.onLogout,
  });

  @override
  State<EarningsScreen> createState() => _EarningsScreenState();
}

class _EarningsScreenState extends State<EarningsScreen> {
  String _selectedFilter = 'This Month';
  DateTimeRange? _customRange;

  Future<void> _pickCustomDateRange(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 2),
      lastDate: DateTime(now.year + 1),
      initialDateRange: _customRange ??
          DateTimeRange(
            start: DateTime(now.year, now.month, 1),
            end: now,
          ),
      builder: (context, child) {
        return Theme(
          data: AppTheme.theme.copyWith(
            colorScheme: AppTheme.theme.colorScheme.copyWith(
              primary: AppColors.primary,
              onPrimary: AppColors.onPrimary,
              surface: const Color(0xFF1E1D1A),
              onSurface: Colors.white,
            ),
            dialogTheme: const DialogThemeData(
              backgroundColor: Color(0xFF1E1D1A),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedFilter = 'Custom Range';
        _customRange = picked;
      });
    }
  }

  List<PoojariBooking> _filterBookings(List<PoojariBooking> completedList) {
    final now = DateTime.now();

    switch (_selectedFilter) {
      case 'This Month':
        return completedList.where((b) {
          final d = b.effectiveCompletionDate;
          return d.year == now.year && d.month == now.month;
        }).toList();

      case 'Last Month':
        final lastMonthDate = DateTime(now.year, now.month - 1, 1);
        return completedList.where((b) {
          final d = b.effectiveCompletionDate;
          return d.year == lastMonthDate.year && d.month == lastMonthDate.month;
        }).toList();

      case 'All Time':
        return completedList;

      case 'Custom Range':
        if (_customRange == null) return completedList;
        final start = DateTime(
          _customRange!.start.year,
          _customRange!.start.month,
          _customRange!.start.day,
        );
        final end = DateTime(
          _customRange!.end.year,
          _customRange!.end.month,
          _customRange!.end.day,
          23,
          59,
          59,
        );
        return completedList.where((b) {
          final d = b.effectiveCompletionDate;
          return !d.isBefore(start) && !d.isAfter(end);
        }).toList();

      default:
        return completedList;
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
            // Live financial metrics from PoojariController
            // Note: This Month Net figure matches Dashboard Quick Stats exactly
            final thisMonthNet = controller.thisMonthEarningsRupees;
            final lifetimeNet = controller.lifetimeEarningsRupees;
            final pendingPayoutNet = controller.pendingPayoutRupees;

            final completedBookings = controller.completedBookings;
            final displayedBookings = _filterBookings(completedBookings);
            final hasNotifications = controller.earningsNotifications.isNotEmpty ||
                controller.reviewNotifications.isNotEmpty;

            return Column(
              children: [
                // Standard Root Tab GlassAppBar with Profile icon left, Bell with badge right
                GlassAppBar(
                  title: 'Dakshina Ledger',
                  showBack: false,
                  leading: IconButton(
                    tooltip: 'Profile',
                    icon: const Icon(
                      Icons.account_circle_outlined,
                      color: AppColors.primary,
                      size: 24,
                    ),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => PoojariProfileScreen(
                            onLogout: widget.onLogout ?? () {},
                            onSwitchToCustomer: widget.onSwitchToCustomer,
                          ),
                        ),
                      );
                    },
                  ),
                  trailing: Stack(
                    alignment: Alignment.center,
                    children: [
                      IconButton(
                        tooltip: 'Notifications',
                        icon: const Icon(
                          Icons.notifications_none_rounded,
                          color: AppColors.primary,
                          size: 24,
                        ),
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const PoojariNotificationsScreen(),
                            ),
                          );
                        },
                      ),
                      if (hasNotifications)
                        Positioned(
                          top: 10,
                          right: 10,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.error,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                // Main Scrollable Area
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.fromLTRB(20, 16, 20, tabBottomPadding(context)),
                    children: [
                      // 1. Summary Card (always visible, three fixed net metrics)
                      EarningsSummaryCard(
                        thisMonthEarningsRupees: thisMonthNet,
                        lifetimeEarningsRupees: lifetimeNet,
                        pendingPayoutRupees: pendingPayoutNet,
                      ),
                      const SizedBox(height: 20),

                      // 2. Time Filter Chips (This Month / Last Month / All Time / Custom Range)
                      EarningsTimeFilterBar(
                        selectedFilter: _selectedFilter,
                        customDateRange: _customRange,
                        onFilterSelected: (filter) {
                          setState(() => _selectedFilter = filter);
                        },
                        onCustomRangeTap: () => _pickCustomDateRange(context),
                      ),
                      const SizedBox(height: 18),

                      // Section Label with count
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'COMPLETED RITUALS (${displayedBookings.length})',
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.0,
                            ),
                          ),
                          Text(
                            _selectedFilter == 'Custom Range' && _customRange != null
                                ? '${_customRange!.start.day}/${_customRange!.start.month} - ${_customRange!.end.day}/${_customRange!.end.month}'
                                : _selectedFilter.toUpperCase(),
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // 3. Per-booking earnings list
                      if (displayedBookings.isEmpty) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 36),
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.receipt_long_outlined,
                                  size: 48,
                                  color: Colors.white.withValues(alpha: 0.2),
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  'No completed poojas found for this period',
                                  style: TextStyle(
                                    color: Colors.white38,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ] else ...[
                        ...displayedBookings.map(
                          (booking) => EarningListCard(
                            booking: booking,
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => EarningDetailScreen(booking: booking),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),

                      // 5. Weekly Settlement Info Section (Static informational text card)
                      const SettlementInfoCard(),
                    ],
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
