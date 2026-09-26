import 'package:flutter/material.dart';
import 'package:pocket_puja/core/theme/app_theme.dart';
import 'package:pocket_puja/core/widgets/glass.dart';
import 'package:pocket_puja/shared/auth/auth_footer_link.dart';
import 'package:pocket_puja/shared/auth/mobile_number_screen.dart';
import 'package:pocket_puja/shared/registration/role_picker_screen.dart';

/// Screen 3: Name Screen
/// Single field: Full Name, PrimaryButton "Continue"
class NameScreen extends StatefulWidget {
  final String mobile;

  const NameScreen({
    super.key,
    required this.mobile,
  });

  @override
  State<NameScreen> createState() => _NameScreenState();
}

class _NameScreenState extends State<NameScreen> {
  final _nameController = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _handleContinue() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _error = 'Please enter your full name');
      return;
    }
    if (name.length < 2) {
      setState(() => _error = 'Name must be at least 2 characters');
      return;
    }

    setState(() => _error = null);

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => RolePickerScreen(
          mobile: widget.mobile,
          fullName: name,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GlassScaffold(
      showAppBar: false,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back Button
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

              // Progress Indicator
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
                      'STEP 1 OF 2',
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
                    '• Basic Profile',
                    style: TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Headline
              Text(
                'What is your name?',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: AppColors.primary,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      shadows: AppTheme.goldGlow,
                    ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Please enter your full name as you would like it to appear on Pocket Puja rituals & bookings.',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 32),

              // Form Glass Card
              GlassPanel(
                padding: const EdgeInsets.all(24),
                borderRadius: 24,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'FULL NAME',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: Colors.white70,
                            fontSize: 11,
                            letterSpacing: 1.2,
                          ),
                    ),
                    const SizedBox(height: 12),

                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _error != null
                              ? AppColors.error.withValues(alpha: 0.6)
                              : AppColors.primary.withValues(alpha: 0.3),
                          width: 1.2,
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.person_outline_rounded,
                            color: AppColors.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: _nameController,
                              textCapitalization: TextCapitalization.words,
                              autofocus: true,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                              decoration: const InputDecoration(
                                hintText: 'e.g. Sai Kiran Sharma',
                                hintStyle: TextStyle(color: Colors.white38),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(vertical: 12),
                              ),
                              onSubmitted: (_) => _handleContinue(),
                            ),
                          ),
                        ],
                      ),
                    ),

                    if (_error != null) ...[
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Icon(
                            Icons.error_outline_rounded,
                            size: 14,
                            color: AppColors.error,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _error!,
                            style: const TextStyle(
                              color: AppColors.error,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],

                    const SizedBox(height: 28),

                    // Continue PrimaryButton
                    PrimaryButton(
                      label: 'CONTINUE',
                      icon: Icons.arrow_forward_rounded,
                      onTap: _handleContinue,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
              Center(
                child: Column(
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.phone_android_rounded, size: 14, color: Colors.white38),
                        const SizedBox(width: 6),
                        Text(
                          'Registered mobile: ${widget.mobile}',
                          style: const TextStyle(color: Colors.white38, fontSize: 12),
                        ),
                      ],
                    ),
                    AuthFooterLink.login(
                      onTap: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (_) => const MobileNumberScreen()),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
