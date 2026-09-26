import 'package:flutter/material.dart';
import 'package:pocket_puja/core/models/user_account.dart';
import 'package:pocket_puja/core/services/poojari_controller.dart';
import 'package:pocket_puja/core/services/session_service.dart';
import 'package:pocket_puja/core/theme/app_theme.dart';
import 'package:pocket_puja/core/widgets/glass.dart';
import 'package:pocket_puja/core/widgets/poojari_mode_badge.dart';
import 'package:pocket_puja/core/widgets/verification_banner.dart';
import 'package:pocket_puja/poojari/screens/availability/poojari_availability_screen.dart';
import 'package:pocket_puja/poojari/screens/booking_detail/poojari_booking_detail_screen.dart';
import 'package:pocket_puja/poojari/screens/notifications/poojari_notifications_screen.dart';
import 'package:pocket_puja/poojari/widgets/dashboard/availability_nudge_card.dart';
import 'package:pocket_puja/poojari/widgets/dashboard/poojari_kpi_square.dart';
import 'package:pocket_puja/poojari/widgets/dashboard/todays_assignment_card.dart';
import 'package:pocket_puja/poojari/widgets/dashboard/upcoming_booking_tile.dart';

/// Landing screen for a Poojari account upon login or registration.
///
/// Follows the strict 6-section order:
/// 1. Header (Poojari name + time-of-day greeting + PoojariModeBadge)
/// 2. Verification status banner (conditional, zero space when verified)
/// 3. Today's Assignment(s) (One card per today's booking from shared controller, privacy rules applied, empty state)
/// 4. Quick Stats row (LIVE 4 KPI squares reusing Customer Home's reflowing layout)
/// 5. Upcoming This Week (preview list of bookings in next 7 days, tap-through to details)
/// 6. Availability nudge (conditional, dismissible, links to availability calendar)
///
/// Explicitly excludes Customer-specific features (no audio/chants, no shop, no festival banners).
class PoojariDashboardScreen extends StatelessWidget {
  final VoidCallback? onSwitchToCustomer;

  const PoojariDashboardScreen({
    super.key,
    this.onSwitchToCustomer,
  });

  String _getTimeGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }

  /// Reusable stats row layout matching Customer Home's [_buildKpiRow] structure.
  /// Reflowing row of expanded AspectRatio(1) squares.
  Widget _buildStatsRow(BuildContext context, PoojariController controller) {
    final earningsFormatted = controller.thisMonthEarningsRupees >= 1000
        ? '₹${(controller.thisMonthEarningsRupees / 1000).toStringAsFixed(controller.thisMonthEarningsRupees % 1000 == 0 ? 0 : 1)}k'
        : '₹${controller.thisMonthEarningsRupees}';

    final squares = <Widget>[
      // a. Rating — static seed value
      PoojariKpiSquare(
        icon: Icons.star_rounded,
        iconColor: const Color(0xFFFFB84D),
        label: 'Rating',
        value: '${controller.rating} ★',
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Devotee rating based on verified rituals'),
              duration: Duration(seconds: 1),
            ),
          );
        },
      ),
      // b. Poojas Completed — LIVE
      PoojariKpiSquare(
        icon: Icons.task_alt_rounded,
        iconColor: AppColors.success,
        label: 'Completed',
        value: '${controller.poojasCompleted}',
        onTap: () {},
      ),
      // c. This Month's Earnings — LIVE
      PoojariKpiSquare(
        icon: Icons.currency_rupee_rounded,
        iconColor: AppColors.primary,
        gold: true,
        label: 'This Month',
        value: earningsFormatted,
        onTap: () {},
      ),
      // d. Pending Assignments — LIVE count
      PoojariKpiSquare(
        icon: Icons.pending_actions_rounded,
        iconColor: const Color(0xFFFF8A80),
        label: 'Pending',
        value: '${controller.pendingAssignmentsCount}',
        onTap: () {},
      ),
    ];

    return Row(
      children: [
        for (int i = 0; i < squares.length; i++) ...[
          if (i > 0) const SizedBox(width: 8),
          Expanded(child: squares[i]),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final session = SessionService.instance;
    final user = session.currentUser;
    final poojariController = PoojariControllerScope.maybeOf(context) ?? PoojariController.instance;

    final displayName = user?.fullName ?? 'Shri Venkata Ramana';
    final isVerified = user?.poojariStatus == PoojariVerificationStatus.verified;

    return GlassScaffold(
      showAppBar: false,
      body: SafeArea(
        child: AnimatedBuilder(
          animation: poojariController,
          builder: (context, _) {
            final todaysAssignments = poojariController.todaysAssignments;
            final upcomingBookings = poojariController.upcomingThisWeek;

            return RefreshIndicator(
              color: AppColors.primary,
              backgroundColor: AppColors.surfaceContainer,
              onRefresh: () async => Future.delayed(const Duration(milliseconds: 600)),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
                children: [
                  // ==========================================
                  // SECTION 1: HEADER
                  // ==========================================
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${_getTimeGreeting()},',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '$displayName 🙏',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 20,
                                    shadows: AppTheme.goldGlow,
                                  ),
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
                            onToggle: onSwitchToCustomer,
                          ),
                        ],
                      ),
                    ],
                  ),

                  // ==========================================
                  // SECTION 2: VERIFICATION STATUS BANNER (CONDITIONAL)
                  // Takes zero space if status == verified
                  // ==========================================
                  if (!isVerified) ...[
                    const SizedBox(height: 16),
                    const VerificationPendingBanner(),
                  ],

                  const SizedBox(height: 22),

                  // ==========================================
                  // SECTION 3: TODAY'S ASSIGNMENT(S)
                  // ==========================================
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "TODAY'S ASSIGNMENT",
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: Colors.white70,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2,
                            ),
                      ),
                      if (todaysAssignments.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${todaysAssignments.length} ACTIVE',
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  if (todaysAssignments.isEmpty)
                    const TodaysAssignmentEmptyState()
                  else
                    for (final booking in todaysAssignments) ...[
                      TodaysAssignmentCard(
                        booking: booking,
                        onViewDetails: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PoojariBookingDetailScreen(booking: booking),
                            ),
                          );
                        },
                        onComplete: () {
                          poojariController.completeBooking(booking.ref);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                '🎉 ${booking.poojaName} marked complete! Dakshina added.',
                              ),
                              backgroundColor: AppColors.primary,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 10),
                    ],

                  const SizedBox(height: 20),

                  // ==========================================
                  // SECTION 4: QUICK STATS ROW (LIVE)
                  // Reflowing layout matching Customer Home
                  // ==========================================
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'QUICK STATS',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: Colors.white70,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2,
                            ),
                      ),
                      const Text(
                        'LIVE',
                        style: TextStyle(
                          color: AppColors.success,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _buildStatsRow(context, poojariController),

                  const SizedBox(height: 24),

                  // ==========================================
                  // SECTION 5: UPCOMING THIS WEEK
                  // Next 7 days excluding today's
                  // ==========================================
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'UPCOMING THIS WEEK (${upcomingBookings.length})',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: Colors.white70,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2,
                            ),
                      ),
                      TextButton(
                        onPressed: () {
                          if (upcomingBookings.isNotEmpty) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => PoojariBookingDetailScreen(
                                  booking: upcomingBookings.first,
                                ),
                              ),
                            );
                          }
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(50, 24),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text(
                          'View All',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  if (upcomingBookings.isEmpty)
                    GlassPanel(
                      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                      borderRadius: 16,
                      child: const Center(
                        child: Text(
                          'No further upcoming bookings this week',
                          style: TextStyle(color: Colors.white54, fontSize: 12),
                        ),
                      ),
                    )
                  else
                    for (final booking in upcomingBookings) ...[
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: UpcomingBookingTile(
                          booking: booking,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => PoojariBookingDetailScreen(booking: booking),
                              ),
                            );
                          },
                        ),
                      ),
                    ],

                  // ==========================================
                  // SECTION 6: AVAILABILITY NUDGE (CONDITIONAL)
                  // Stubbed condition as true for prototype:
                  // // TODO: replace with real availability check once lib/poojari/screens/availability/ exists
                  // ==========================================
                  if (poojariController.showAvailabilityNudge) ...[
                    const SizedBox(height: 14),
                    AvailabilityNudgeCard(
                      onUpdateAvailability: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const PoojariAvailabilityScreen(),
                          ),
                        );
                      },
                      onDismiss: () {
                        poojariController.dismissAvailabilityNudge();
                      },
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
