import 'package:flutter/material.dart';
import 'package:pocket_puja/core/theme/app_theme.dart';
import 'package:pocket_puja/core/widgets/glass.dart';
import 'package:pocket_puja/shared/auth/auth_footer_link.dart';
import 'package:pocket_puja/shared/auth/otp_verification_screen.dart';
import 'package:pocket_puja/shared/registration/name_screen.dart';

/// Screen 1: App Entry & Login Screen (BLOCK 5)
///
/// This is the very first screen shown when the app opens for a returning user
/// with no active session. One screen, shared by both Customer and Poojari —
/// the SAME mobile number field for everyone, no role toggle, no "which app"
/// question anywhere on this screen.
///
/// Layout:
/// 1. App branding header (logo/name, gold theme, matching every other screen)
/// 2. Single input: Mobile Number (with 1-tap prototype demo pills for easy testing)
/// 3. PrimaryButton: "Send OTP" -> routes to OTPVerificationScreen
/// 4. Footer hyperlink: "Don't have an account? Register" -> routes to NameScreen
class MobileNumberScreen extends StatefulWidget {
  final Function(String mobile)? onSendOTP;
  final bool isLoading;
  final String? error;

  const MobileNumberScreen({
    super.key,
    this.onSendOTP,
    this.isLoading = false,
    this.error,
  });

  @override
  State<MobileNumberScreen> createState() => _MobileNumberScreenState();
}

class _MobileNumberScreenState extends State<MobileNumberScreen> {
  final _mobileController = TextEditingController();
  bool _teluguSelected = true;
  String? _validationError;

  @override
  void dispose() {
    _mobileController.dispose();
    super.dispose();
  }

  void _fillCustomerDemo() {
    setState(() {
      _mobileController.text = '9876543210';
      _validationError = null;
    });
  }

  void _fillPoojariDemo() {
    setState(() {
      _mobileController.text = '9988776655';
      _validationError = null;
    });
  }

  void _handleSendOTP() {
    final rawNumber = _mobileController.text.trim().replaceAll(RegExp(r'\D'), '');
    if (rawNumber.length != 10) {
      setState(() {
        _validationError = 'Please enter a valid 10-digit mobile number';
      });
      return;
    }

    setState(() => _validationError = null);
    final fullMobile = '+91$rawNumber';

    if (widget.onSendOTP != null) {
      widget.onSendOTP!(fullMobile);
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => OTPVerificationScreen(mobile: fullMobile),
        ),
      );
    }
  }

  void _navigateToRegister() {
    final rawNumber = _mobileController.text.trim().replaceAll(RegExp(r'\D'), '');
    final mobileToSend = rawNumber.length == 10 ? '+91$rawNumber' : '';
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => NameScreen(mobile: mobileToSend),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayError = widget.error ?? _validationError;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: AppGradients.auth),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // App Emblem & Title
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary.withValues(alpha: 0.15),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.4),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          blurRadius: 24,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text('🪔', style: TextStyle(fontSize: 34)),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Pocket Puja',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          color: AppColors.primary,
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          shadows: AppTheme.goldGlow,
                        ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Sacred digital sanctuary for Vedic rituals',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Main Glass Login Card
                  GlassPanel(
                    padding: const EdgeInsets.all(24),
                    borderRadius: 24,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Language Selection Row
                        Row(
                          children: [
                            Expanded(
                              child: _LanguageOption(
                                label: 'తెలుగు',
                                subLabel: 'TELUGU',
                                selected: _teluguSelected,
                                onTap: () => setState(() => _teluguSelected = true),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _LanguageOption(
                                label: 'English',
                                subLabel: 'ENGLISH',
                                selected: !_teluguSelected,
                                onTap: () => setState(() => _teluguSelected = false),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Prototype Quick Demo Accounts Helper
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: AppColors.primary.withValues(alpha: 0.35),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.touch_app_rounded, size: 14, color: AppColors.primary),
                                  SizedBox(width: 6),
                                  Text(
                                    'PROTOTYPE QUICK LOGINS (OTP: 123456)',
                                    style: TextStyle(
                                      color: AppColors.primaryFixed,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.6,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: _fillCustomerDemo,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 8),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(alpha: 0.08),
                                          borderRadius: BorderRadius.circular(10),
                                          border: Border.all(color: Colors.white24),
                                        ),
                                        child: const Column(
                                          children: [
                                            Text(
                                              '👤 Customer Login',
                                              style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
                                            ),
                                            SizedBox(height: 2),
                                            Text(
                                              '9876543210',
                                              style: TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.w800),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: _fillPoojariDemo,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 8),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(alpha: 0.08),
                                          borderRadius: BorderRadius.circular(10),
                                          border: Border.all(color: Colors.white24),
                                        ),
                                        child: const Column(
                                          children: [
                                            Text(
                                              '🪔 Poojari Login',
                                              style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
                                            ),
                                            SizedBox(height: 2),
                                            Text(
                                              '9988776655',
                                              style: TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.w800),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 22),

                        // Section Label
                        const Text(
                          'MOBILE NUMBER',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.1,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Single Mobile Number Input Field
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.06),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: displayError != null
                                  ? AppColors.error
                                  : AppColors.primary.withValues(alpha: 0.35),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Text(
                                '+91',
                                style: TextStyle(
                                  color: AppColors.primaryFixed,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Container(width: 1, height: 20, color: Colors.white24),
                              const SizedBox(width: 10),
                              Expanded(
                                child: TextField(
                                  controller: _mobileController,
                                  keyboardType: TextInputType.phone,
                                  maxLength: 10,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 1.1,
                                  ),
                                  decoration: const InputDecoration(
                                    hintText: 'Enter 10-digit number',
                                    hintStyle: TextStyle(color: Colors.white38),
                                    counterText: '',
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.symmetric(vertical: 12),
                                  ),
                                  onSubmitted: (_) => _handleSendOTP(),
                                ),
                              ),
                            ],
                          ),
                        ),

                        if (displayError != null) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.error_outline_rounded, size: 14, color: AppColors.error),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  displayError,
                                  style: const TextStyle(color: AppColors.error, fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                        ],

                        const SizedBox(height: 24),

                        // Primary Button: SEND OTP
                        PrimaryButton(
                          label: 'SEND OTP',
                          icon: Icons.arrow_forward_rounded,
                          isLoading: widget.isLoading,
                          onTap: _handleSendOTP,
                        ),

                        const SizedBox(height: 20),

                        // BLOCK 5 Footer Hyperlink: "Don't have an account? Register"
                        AuthFooterLink.register(
                          onTap: _navigateToRegister,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                  const Text(
                    'By continuing, you agree to our Terms of Service\nand Sacred Sanctuary Privacy Policy',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white38, fontSize: 11, height: 1.4),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LanguageOption extends StatelessWidget {
  final String label;
  final String subLabel;
  final bool selected;
  final VoidCallback onTap;

  const _LanguageOption({
    required this.label,
    required this.subLabel,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary.withValues(alpha: 0.18) : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColors.primary : Colors.white12,
            width: selected ? 1.5 : 1.0,
          ),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                color: selected ? AppColors.primary : Colors.white70,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subLabel,
              style: TextStyle(
                color: selected ? AppColors.primary.withValues(alpha: 0.75) : Colors.white38,
                fontSize: 9,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
