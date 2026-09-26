import 'package:flutter/material.dart';
import 'package:pocket_puja/core/services/session_service.dart';
import 'package:pocket_puja/core/theme/app_theme.dart';
import 'package:pocket_puja/core/widgets/glass.dart';
import 'package:pocket_puja/core/widgets/poojari_mode_badge.dart';

/// Interactive landing dashboard for Poojari portal.
/// Fully active and usable immediately after submission, even while under review.
class PoojariDashboardScreen extends StatelessWidget {
  final VoidCallback? onSwitchToCustomer;

  const PoojariDashboardScreen({
    super.key,
    this.onSwitchToCustomer,
  });

  @override
  Widget build(BuildContext context) {
    final session = SessionService.instance;
    final user = session.currentUser;
    final fullName = user?.fullName ?? 'Shri Venkata Ramana';
    final isUnderReview = user?.isUnderReview ?? true;

    return GlassScaffold(
      showAppBar: false,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with Title & Poojari Mode Badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Namaste, $fullName 🙏',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w800,
                              fontSize: 18,
                              shadows: AppTheme.goldGlow,
                            ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'VEDIC SCHOLAR',
                              style: TextStyle(
                                color: AppColors.primaryFixed,
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            '• Hyderabad Central',
                            style: TextStyle(color: Colors.white54, fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                  PoojariModeBadge(
                    isPoojari: true,
                    onToggle: onSwitchToCustomer,
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Overview Metric Cards Grid
              Row(
                children: [
                  Expanded(
                    child: _MetricCard(
                      label: 'TODAY\'S PUJAS',
                      value: '2 Scheduled',
                      icon: Icons.temple_hindu_rounded,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _MetricCard(
                      label: 'DAKSHINA BALANCE',
                      value: '₹ 14,500',
                      icon: Icons.account_balance_wallet_rounded,
                      color: const Color(0xFF81C784),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _MetricCard(
                      label: 'DEVOTEE RATING',
                      value: '4.9 ★ (128)',
                      icon: Icons.star_rounded,
                      color: const Color(0xFFFFB74D),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _MetricCard(
                      label: 'REQUESTS',
                      value: '3 Pending',
                      icon: Icons.notifications_active_rounded,
                      color: const Color(0xFFFF8A80),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Verification Pipeline Progress Card
              if (isUnderReview) ...[
                GlassPanelAmber(
                  padding: const EdgeInsets.all(18),
                  borderRadius: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFB84D).withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.verified_user_outlined,
                              color: Color(0xFFFFB84D),
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Verification Roadmap',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                Text(
                                  'Your profile is active in prototype mode',
                                  style: TextStyle(color: Colors.white60, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      _TimelineStep(
                        step: '1',
                        title: 'Profile & Credentials Submitted',
                        status: 'Completed',
                        isCompleted: true,
                        isCurrent: false,
                      ),
                      _TimelineStep(
                        step: '2',
                        title: 'Vedic Scholar Council Review',
                        status: 'In Progress (Est. 24h)',
                        isCompleted: false,
                        isCurrent: true,
                      ),
                      _TimelineStep(
                        step: '3',
                        title: 'Live Devotee Booking Dispatch',
                        status: 'Upcoming',
                        isCompleted: false,
                        isCurrent: false,
                        isLast: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Quick Actions Row
              Text(
                'QUICK ACTIONS',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Colors.white60,
                      fontSize: 11,
                      letterSpacing: 1.2,
                    ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _ActionPill(
                      icon: Icons.event_available_rounded,
                      label: 'Set Hours',
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Availability schedule opened'),
                            duration: Duration(seconds: 1),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _ActionPill(
                      icon: Icons.checklist_rtl_rounded,
                      label: 'Samagri List',
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Ritual samagri requirements loaded'),
                            duration: Duration(seconds: 1),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _ActionPill(
                      icon: Icons.brightness_high_rounded,
                      label: 'Panchangam',
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Auspicious muhurtham panchangam open'),
                            duration: Duration(seconds: 1),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Incoming Puja Requests Preview
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'INCOMING PUJA REQUESTS (3)',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: Colors.white60,
                          fontSize: 11,
                          letterSpacing: 1.2,
                        ),
                  ),
                  TextButton(
                    onPressed: () {},
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
              const SizedBox(height: 8),

              // Mock Booking Card
              _BookingRequestCard(
                title: 'Sri Satyanarayana Vratam',
                devoteeName: 'K. Rajesh & Family',
                time: 'Tomorrow, 08:30 AM',
                location: 'Madhapur, Hyderabad • 4.2 km',
                dakshina: '₹ 2,500',
              ),
              const SizedBox(height: 12),
              _BookingRequestCard(
                title: 'Gruhapravesham & Ganapathi Homam',
                devoteeName: 'Dr. Suresh Varma',
                time: 'Jun 28, 2026 • 06:15 AM (Muhurtham)',
                location: 'Gachibowli, Hyderabad • 6.8 km',
                dakshina: '₹ 5,100',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _MetricCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      padding: const EdgeInsets.all(16),
      borderRadius: 18,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                ),
              ),
              Icon(icon, color: color, size: 18),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelineStep extends StatelessWidget {
  final String step;
  final String title;
  final String status;
  final bool isCompleted;
  final bool isCurrent;
  final bool isLast;

  const _TimelineStep({
    required this.step,
    required this.title,
    required this.status,
    required this.isCompleted,
    required this.isCurrent,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCompleted
                    ? AppColors.success
                    : (isCurrent
                        ? const Color(0xFFFFB84D)
                        : Colors.white.withValues(alpha: 0.1)),
                border: Border.all(
                  color: isCompleted
                      ? AppColors.success
                      : (isCurrent ? const Color(0xFFFFB84D) : Colors.white24),
                ),
              ),
              child: Center(
                child: isCompleted
                    ? const Icon(Icons.check, size: 13, color: Colors.black)
                    : Text(
                        step,
                        style: TextStyle(
                          color: isCurrent ? Colors.black : Colors.white60,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 26,
                color: isCompleted ? AppColors.success : Colors.white12,
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: isCurrent || isCompleted ? Colors.white : Colors.white60,
                  fontSize: 13,
                  fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
              Text(
                status,
                style: TextStyle(
                  color: isCompleted
                      ? AppColors.success
                      : (isCurrent ? const Color(0xFFFFB84D) : Colors.white38),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (!isLast) const SizedBox(height: 10),
            ],
          ),
        ),
      ],
    );
  }
}

class _ActionPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionPill({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      borderRadius: 14,
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, color: AppColors.primary, size: 22),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _BookingRequestCard extends StatelessWidget {
  final String title;
  final String devoteeName;
  final String time;
  final String location;
  final String dakshina;

  const _BookingRequestCard({
    required this.title,
    required this.devoteeName,
    required this.time,
    required this.location,
    required this.dakshina,
  });

  @override
  Widget build(BuildContext context) {
    return GlassPanelGold(
      padding: const EdgeInsets.all(16),
      borderRadius: 18,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  dakshina,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Devotee: $devoteeName',
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.access_time_rounded, size: 13, color: Colors.white54),
              const SizedBox(width: 4),
              Text(
                time,
                style: const TextStyle(color: Colors.white60, fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.location_on_outlined, size: 13, color: Colors.white54),
              const SizedBox(width: 4),
              Text(
                location,
                style: const TextStyle(color: Colors.white60, fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Request declined')),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white70,
                    side: const BorderSide(color: Colors.white24),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  child: const Text('Decline', style: TextStyle(fontSize: 12)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Puja accepted! Muhurtham confirmed.')),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  child: const Text(
                    'Accept Puja',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
