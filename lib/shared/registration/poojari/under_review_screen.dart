import 'package:flutter/material.dart';
import 'package:pocket_puja/app.dart';
import 'package:pocket_puja/core/models/user_account.dart';
import 'package:pocket_puja/core/services/session_service.dart';
import 'package:pocket_puja/core/theme/app_theme.dart';
import 'package:pocket_puja/core/widgets/glass.dart';
import 'package:pocket_puja/customer/shell/app_shell.dart';
import 'package:pocket_puja/poojari/shell/poojari_shell.dart';
import 'package:pocket_puja/shared/auth/mobile_number_screen.dart';

/// Screen 6: Under Review Confirmation Screen
/// Simple confirmation screen: checkmark/hourglass icon,
/// "Application Submitted" headline, verification note, and "Go to Dashboard" CTA.
class UnderReviewScreen extends StatelessWidget {
  final String mobile;
  final String fullName;
  final PoojariProfile profile;

  const UnderReviewScreen({
    super.key,
    required this.mobile,
    required this.fullName,
    required this.profile,
  });

  void _navigateToDashboard(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => PoojariShell(
          onLogout: () {
            SessionService.instance.logout();
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const MobileNumberScreen()),
              (route) => false,
            );
          },
          onSwitchToCustomer: () {
            SessionService.instance.switchRole(AppRole.customer);
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (_) => AppShell(
                  onLogout: () {
                    SessionService.instance.logout();
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const MobileNumberScreen()),
                      (route) => false,
                    );
                  },
                ),
              ),
              (route) => false,
            );
          },
        ),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GlassScaffold(
      showAppBar: false,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),

              // Sacred Pulsing Emblem
              Center(
                child: Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary.withValues(alpha: 0.16),
                    border: Border.all(
                      color: AppColors.primary,
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.35),
                        blurRadius: 30,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.verified_outlined,
                      size: 48,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Title
              Text(
                'Application Submitted',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: AppColors.primary,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      shadows: AppTheme.goldGlow,
                    ),
              ),
              const SizedBox(height: 10),

              // Subtitle
              const Text(
                'Your Poojari application is under review by our Vedic scholar council. Verification is in progress, and you will be notified once approved.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 28),

              // Submitted Details Summary Card
              GlassPanelGold(
                padding: const EdgeInsets.all(20),
                borderRadius: 20,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'STATUS',
                          style: TextStyle(
                            color: Colors.white60,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFB84D).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFFFFB84D).withValues(alpha: 0.5),
                            ),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('🕒', style: TextStyle(fontSize: 11)),
                              SizedBox(width: 4),
                              Text(
                                'UNDER REVIEW',
                                style: TextStyle(
                                  color: Color(0xFFFFE088),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Divider(color: Colors.white12, height: 24),
                    _SummaryRow(label: 'Applicant Name', value: fullName),
                    const SizedBox(height: 10),
                    _SummaryRow(label: 'Service Area', value: '${profile.city} (${profile.serviceRadius})'),
                    const SizedBox(height: 10),
                    _SummaryRow(label: 'Experience', value: '${profile.experienceYears} Years'),
                    const SizedBox(height: 10),
                    _SummaryRow(
                      label: 'Specializations',
                      value: '${profile.specializations.length} Rituals Selected',
                    ),
                    if (profile.certificateFileName != null) ...[
                      const SizedBox(height: 10),
                      _SummaryRow(
                        label: 'Certificate',
                        value: '✓ ${profile.certificateFileName}',
                        valueColor: AppColors.success,
                      ),
                    ],
                  ],
                ),
              ),

              const Spacer(),

              // Primary CTA: Go to Dashboard
              PrimaryButton(
                label: 'GO TO DASHBOARD',
                icon: Icons.arrow_forward_rounded,
                onTap: () => _navigateToDashboard(context),
              ),
              const SizedBox(height: 12),
              const Center(
                child: Text(
                  'Full dashboard preview active during review period',
                  style: TextStyle(color: Colors.white38, fontSize: 11),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white60, fontSize: 13),
        ),
        Flexible(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: valueColor ?? Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
