import 'package:flutter/material.dart';
import 'package:pocket_puja/app.dart';
import 'package:pocket_puja/core/services/session_service.dart';
import 'package:pocket_puja/core/theme/app_theme.dart';
import 'package:pocket_puja/core/widgets/glass.dart';
import 'package:pocket_puja/shared/auth/auth_footer_link.dart';
import 'package:pocket_puja/shared/auth/mobile_number_screen.dart';
import 'package:pocket_puja/shared/registration/customer/customer_registration_form.dart';
import 'package:pocket_puja/shared/registration/poojari/poojari_registration_form.dart';

/// Available registration roles
enum Role { customer, poojari }

/// Screen 4: Role Picker Screen
/// Brand-new user picking which kind of account to create:
/// Mobile + OTP -> Name -> Role Picker (this screen) -> role-specific form
class RolePickerScreen extends StatefulWidget {
  final String mobile;
  final String fullName;

  const RolePickerScreen({
    super.key,
    required this.mobile,
    required this.fullName,
  });

  @override
  State<RolePickerScreen> createState() => _RolePickerScreenState();
}

class _RolePickerScreenState extends State<RolePickerScreen> {
  Role? _selectedRole;

  void _handleContinue() {
    // Defensive guard
    if (_selectedRole == null) return;

    if (_selectedRole == Role.customer) {
      // Persist chosen role into session
      SessionService.instance.switchRole(AppRole.customer);

      // Route to Customer registration continuation using pushReplacement
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => CustomerRegistrationForm(
            mobile: widget.mobile,
            fullName: widget.fullName,
          ),
        ),
      );
    } else if (_selectedRole == Role.poojari) {
      // Persist chosen role into session
      SessionService.instance.switchRole(AppRole.poojari);

      // Route to Poojari registration form using pushReplacement
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => PoojariRegistrationForm(
            mobile: widget.mobile,
            fullName: widget.fullName,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GlassScaffold(
      showAppBar: false,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Bar & Back Button
              IconButton(
                onPressed: () => Navigator.of(context).maybePop(),
                icon: const Icon(
                  Icons.arrow_back_ios_new,
                  color: AppColors.primary,
                  size: 20,
                ),
                padding: EdgeInsets.zero,
                alignment: Alignment.centerLeft,
              ),
              const SizedBox(height: 16),

              // Step Pill
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                    ),
                    child: const Text(
                      'STEP 2 OF 2',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.1,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    '• Account Type',
                    style: TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Header: Create Account & How will you use the app?
              Text(
                'Create Account',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: AppColors.primary,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      shadows: AppTheme.goldGlow,
                    ),
              ),
              const SizedBox(height: 6),
              const Text(
                'How will you use the app?',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 32),

              // Card A — Customer (Devotee / Folded hands icon)
              _RoleCard(
                icon: Icons.self_improvement,
                title: 'Customer',
                subtext: 'Book Poojaris for your rituals',
                isSelected: _selectedRole == Role.customer,
                onTap: () {
                  setState(() => _selectedRole = Role.customer);
                },
              ),

              const SizedBox(height: 18),

              // Card B — Poojari (temple_hindu icon)
              _RoleCard(
                icon: Icons.temple_hindu,
                title: 'Poojari',
                subtext: 'Perform poojas and earn on your schedule',
                isSelected: _selectedRole == Role.poojari,
                onTap: () {
                  setState(() => _selectedRole = Role.poojari);
                },
              ),

              const Spacer(),

              // Continue Button (disabled until a card is selected)
              PrimaryButton(
                label: 'CONTINUE',
                icon: Icons.arrow_forward_rounded,
                enabled: _selectedRole != null,
                onTap: _selectedRole != null ? _handleContinue : null,
              ),

              const SizedBox(height: 18),

              AuthFooterLink.login(
                onTap: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const MobileNumberScreen()),
                  );
                },
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}

/// Shared internal widget for both Customer and Poojari selectable cards.
/// Provides identical layout, typography, state transitions, and gold glow border styling.
class _RoleCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtext;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleCard({
    required this.icon,
    required this.title,
    required this.subtext,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = isSelected
        ? AppColors.primary
        : Colors.white.withValues(alpha: 0.15);
    final tintColor = isSelected
        ? AppColors.primary
        : Colors.white;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.25),
                  blurRadius: 18,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: GlassPanel(
        borderRadius: 24,
        padding: const EdgeInsets.all(20),
        tint: tintColor,
        borderColor: borderColor,
        onTap: onTap,
        child: Stack(
          children: [
            Row(
              children: [
                // Icon Avatar
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected
                        ? AppColors.primary.withValues(alpha: 0.2)
                        : Colors.white.withValues(alpha: 0.06),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : Colors.white.withValues(alpha: 0.18),
                      width: 1.5,
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      icon,
                      size: 28,
                      color: isSelected
                          ? AppColors.primary
                          : Colors.white.withValues(alpha: 0.65),
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // Title & Subtext
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : Colors.white.withValues(alpha: 0.7),
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          shadows: isSelected ? AppTheme.goldGlow : null,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtext,
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white.withValues(alpha: 0.85)
                              : Colors.white.withValues(alpha: 0.55),
                          fontSize: 13,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 28),
              ],
            ),

            // Checkmark Badge (top-right, visible when selected)
            Positioned(
              top: 0,
              right: 0,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: isSelected ? 1.0 : 0.0,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.check,
                      size: 15,
                      color: AppColors.onPrimary,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
