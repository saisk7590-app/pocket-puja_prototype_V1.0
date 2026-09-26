import 'package:flutter/material.dart';
import 'package:pocket_puja/core/theme/app_theme.dart';
import 'package:pocket_puja/core/widgets/glass.dart';
import 'package:pocket_puja/shared/registration/customer/customer_registration_form.dart';
import 'package:pocket_puja/shared/registration/poojari/poojari_registration_form.dart';

/// Screen 4: Role Picker Screen
/// Two large tappable cards: "Customer" / "Poojari"
/// - Customer -> routes to CustomerRegistrationForm
/// - Poojari  -> routes to PoojariRegistrationForm
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
  String? _selectedRole;

  void _selectCustomer() {
    setState(() => _selectedRole = 'customer');

    // Route into Customer Registration details form
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CustomerRegistrationForm(
          mobile: widget.mobile,
          fullName: widget.fullName,
        ),
      ),
    );
  }

  void _selectPoojari() {
    setState(() => _selectedRole = 'poojari');

    // Continue to Poojari Registration Form
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PoojariRegistrationForm(
          mobile: widget.mobile,
          fullName: widget.fullName,
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
                    '• Choose Account Type',
                    style: TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Headline & Welcome
              Text(
                'Namaste, ${widget.fullName.split(" ").first}!',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: AppColors.primary,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      shadows: AppTheme.goldGlow,
                    ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Select how you wish to participate in the Pocket Puja spiritual ecosystem:',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 28),

              // Card 1: Customer / Devotee
              _RoleCard(
                iconEmoji: '👤',
                title: 'Customer / Devotee',
                teluguTitle: 'భక్తుడు',
                subtitle:
                    'Book certified Vedic poojaris for home & temple rituals, stream daily stotrams, and receive door-delivered samagri.',
                features: const [
                  'Instant Pandit Booking',
                  'Daily Panchangam & Audio',
                  'Pure Samagri Store',
                ],
                isSelected: _selectedRole == 'customer',
                onTap: _selectCustomer,
              ),

              const SizedBox(height: 20),

              // Card 2: Vedic Poojari / Priest
              _RoleCard(
                iconEmoji: '🪔',
                title: 'Vedic Poojari / Priest',
                teluguTitle: 'పురోహితుడు',
                subtitle:
                    'Join our verified network of Vedic scholars. Receive devotee puja requests, manage auspicious muhurthams, and earn dakshina.',
                features: const [
                  'Verified Scholar Credentials',
                  'Schedule & Muhurtham Mgmt',
                  'Guaranteed Dakshina Payouts',
                ],
                isSelected: _selectedRole == 'poojari',
                onTap: _selectPoojari,
              ),

              const SizedBox(height: 28),

              // Hyperlink to Sign In
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Already have an account? ',
                      style: TextStyle(color: Colors.white60, fontSize: 13),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
                      },
                      child: const Text(
                        'Sign In',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final String iconEmoji;
  final String title;
  final String teluguTitle;
  final String subtitle;
  final List<String> features;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleCard({
    required this.iconEmoji,
    required this.title,
    required this.teluguTitle,
    required this.subtitle,
    required this.features,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GlassPanelGold(
      padding: const EdgeInsets.all(22),
      borderRadius: 24,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withValues(alpha: 0.18),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.4),
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: Text(
                    iconEmoji,
                    style: const TextStyle(fontSize: 26),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            teluguTitle,
                            style: TextStyle(
                              color: AppColors.primaryFixed,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Features Chips
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: features.map((f) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.07),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.12),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.check_circle_rounded,
                      size: 13,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      f,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          // CTA Strip
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Register as ${title.split("/").first.trim()}',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_rounded,
                  color: AppColors.primary,
                  size: 16,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
