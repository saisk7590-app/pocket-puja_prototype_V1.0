import 'package:flutter/material.dart';
import 'package:pocket_puja/core/theme/app_theme.dart';
import 'package:pocket_puja/core/widgets/glass.dart';

/// Screen 1: Mobile Number Input
/// Shared by Customer and Poojari — no role question here.
class MobileNumberScreen extends StatefulWidget {
  final Function(String mobile) onSendOTP;
  final bool isLoading;
  final String? error;

  const MobileNumberScreen({
    super.key,
    required this.onSendOTP,
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

  void _handleSubmit() {
    final rawNumber = _mobileController.text.trim().replaceAll(RegExp(r'\D'), '');
    if (rawNumber.length != 10) {
      setState(() {
        _validationError = 'Please enter a valid 10-digit mobile number';
      });
      return;
    }
    setState(() => _validationError = null);
    final fullMobile = '+91$rawNumber';
    widget.onSendOTP(fullMobile);
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
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
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
                        color: AppColors.primary.withValues(alpha: 0.35),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.25),
                          blurRadius: 24,
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        '🪔',
                        style: TextStyle(fontSize: 34),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Pocket Puja',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          color: AppColors.primary,
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          shadows: AppTheme.goldGlow,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Digital sanctuary for your daily rituals',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                  ),
                  const SizedBox(height: 32),

                  // Mobile Input Glass Card
                  GlassPanel(
                    padding: const EdgeInsets.all(24),
                    borderRadius: 24,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'SELECT PREFERRED LANGUAGE',
                          textAlign: TextAlign.center,
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
                              child: _LanguageOption(
                                label: 'తెలుగు',
                                subLabel: 'TELUGU',
                                selected: _teluguSelected,
                                onTap: () => setState(() => _teluguSelected = true),
                              ),
                            ),
                            const SizedBox(width: 12),
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
                        const SizedBox(height: 28),

                        Text(
                          'ENTER MOBILE NUMBER',
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                color: Colors.white70,
                                fontSize: 12,
                                letterSpacing: 1.1,
                              ),
                        ),
                        const SizedBox(height: 12),

                        // Mobile Input Row
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.06),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: displayError != null
                                  ? AppColors.error.withValues(alpha: 0.6)
                                  : AppColors.primary.withValues(alpha: 0.3),
                              width: 1.2,
                            ),
                          ),
                          child: Row(
                            children: [
                              Text(
                                '+91',
                                style: TextStyle(
                                  color: AppColors.primaryFixed,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Container(
                                width: 1,
                                height: 24,
                                color: Colors.white24,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextField(
                                  controller: _mobileController,
                                  keyboardType: TextInputType.phone,
                                  maxLength: 10,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 1.2,
                                  ),
                                  decoration: const InputDecoration(
                                    hintText: 'Enter 10-digit number',
                                    hintStyle: TextStyle(color: Colors.white38),
                                    counterText: '',
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.symmetric(vertical: 12),
                                  ),
                                  onSubmitted: (_) => _handleSubmit(),
                                ),
                              ),
                            ],
                          ),
                        ),

                        if (displayError != null) ...[
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              const Icon(
                                Icons.error_outline_rounded,
                                size: 14,
                                color: AppColors.error,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  displayError,
                                  style: const TextStyle(
                                    color: AppColors.error,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],

                        const SizedBox(height: 24),

                        // Send OTP CTA
                        PrimaryButton(
                          label: 'SEND OTP',
                          icon: Icons.arrow_forward_rounded,
                          isLoading: widget.isLoading,
                          onTap: _handleSubmit,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                  Text(
                    'By continuing, you agree to our Terms of Service\nand Sacred Sanctuary Privacy Policy',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white38,
                          height: 1.4,
                        ),
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
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withValues(alpha: 0.18)
              : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? AppColors.primary : Colors.white12,
            width: selected ? 1.5 : 1.0,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    blurRadius: 10,
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                color: selected ? AppColors.primary : Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subLabel,
              style: TextStyle(
                color: selected
                    ? AppColors.primary.withValues(alpha: 0.8)
                    : Colors.white54,
                fontSize: 10,
                letterSpacing: 1,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
