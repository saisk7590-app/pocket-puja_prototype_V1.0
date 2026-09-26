import 'package:flutter/material.dart';
import 'package:pocket_puja/core/models/user_account.dart';
import 'package:pocket_puja/core/services/session_service.dart';
import 'package:pocket_puja/core/theme/app_theme.dart';
import 'package:pocket_puja/core/widgets/glass.dart';
import 'package:pocket_puja/customer/shell/app_shell.dart';
import 'package:pocket_puja/shared/auth/auth_footer_link.dart';
import 'package:pocket_puja/shared/auth/mobile_number_screen.dart';

/// Customer / Devotee Registration Form
/// Collects details matching the inner customer profile (Name, City, DOB, Rashi, Gothram)
/// and routes straight to Customer Dashboard (AppShell).
class CustomerRegistrationForm extends StatefulWidget {
  final String mobile;
  final String fullName;

  const CustomerRegistrationForm({
    super.key,
    required this.mobile,
    required this.fullName,
  });

  @override
  State<CustomerRegistrationForm> createState() => _CustomerRegistrationFormState();
}

class _CustomerRegistrationFormState extends State<CustomerRegistrationForm> {
  late final TextEditingController _nameController;
  final _cityController = TextEditingController(text: 'Hyderabad');
  final _gothramController = TextEditingController(text: 'Kashyapa (కాశ్యప)');
  String _selectedDob = '15 Aug 1995';
  String _selectedRashi = 'Simha (సింహ)';
  bool _isSubmitting = false;
  String? _errorMessage;

  final List<String> _rashiOptions = const [
    'Simha (సింహ)',
    'Mesha (మేషం)',
    'Vrishabha (వృషభం)',
    'Mithuna (మిథునం)',
    'Karka (కర్కాటకం)',
    'Kanya (కన్య)',
    'Tula (తుల)',
    'Vrischika (వృశ్చికం)',
    'Dhanu (ధనుస్సు)',
    'Makara (మకరం)',
    'Kumbha (కుంభం)',
    'Meena (మీనం)',
  ];

  final List<String> _gothramPresets = const [
    'Kashyapa (కాశ్యప)',
    'Bharadwaja (భరద్వాజ)',
    'Kaushika (కౌశిక)',
    'Harithasa (హరితస)',
    'Vashishta (వశిష్ట)',
    'Srivatsa (శ్రీవత్స)',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.fullName);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _cityController.dispose();
    _gothramController.dispose();
    super.dispose();
  }

  Future<void> _pickDob() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(1995, 8, 15),
      firstDate: DateTime(1930),
      lastDate: DateTime.now(),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppColors.primary,
            onPrimary: AppColors.onPrimary,
            surface: AppColors.surfaceContainerHigh,
          ),
        ),
        child: child!,
      ),
    );

    if (picked != null) {
      final months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      setState(() {
        _selectedDob = '${picked.day} ${months[picked.month - 1]} ${picked.year}';
      });
    }
  }

  void _quickFillDemoDevotee() {
    setState(() {
      _nameController.text = 'Sai Kiran';
      _cityController.text = 'Hyderabad';
      _selectedDob = '15 Aug 1995';
      _selectedRashi = 'Simha (సింహ)';
      _gothramController.text = 'Kashyapa (కాశ్యప)';
      _errorMessage = null;
    });
  }

  void _handleSubmit() {
    final name = _nameController.text.trim().isEmpty ? 'Sai Kiran' : _nameController.text.trim();
    final city = _cityController.text.trim().isEmpty ? 'Hyderabad' : _cityController.text.trim();

    setState(() {
      _errorMessage = null;
      _isSubmitting = true;
    });

    final customerProfile = CustomerProfile(
      city: city,
      dob: _selectedDob,
      rashi: _selectedRashi,
      gothram: _gothramController.text.trim().isEmpty
          ? 'Kashyapa (కాశ్యప)'
          : _gothramController.text.trim(),
    );

    // Register customer account in session with profile
    SessionService.instance.registerCustomer(
      mobile: widget.mobile,
      fullName: name,
      profile: customerProfile,
    );

    // Direct routing to Customer Dashboard (AppShell)
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
              // Top Bar & Back Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
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
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.35)),
                    ),
                    child: const Text(
                      '👤 DEVOTEE PROFILE',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.1,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Title
              Text(
                'Complete Devotee Profile',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: AppColors.primary,
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      shadows: AppTheme.goldGlow,
                    ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Add your spiritual details for personalized daily panchangam and auspicious muhurthams.',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),

              // Prototype Quick Fill Banner
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.35)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.touch_app_rounded, size: 18, color: AppColors.primary),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'PROTOTYPE QUICK FILL',
                            style: TextStyle(
                              color: AppColors.primaryFixed,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.8,
                            ),
                          ),
                          Text(
                            'Tap to autofill demo Devotee profile',
                            style: TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: _quickFillDemoDevotee,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.onPrimary,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Autofill', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              if (_errorMessage != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: AppColors.errorContainer.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.error.withValues(alpha: 0.6)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(
                            color: AppColors.error,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // 1. Full Name
              GlassPanel(
                padding: const EdgeInsets.all(20),
                borderRadius: 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'FULL NAME',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: Colors.white70,
                            fontSize: 11,
                            letterSpacing: 1.1,
                          ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.person_outline_rounded, color: AppColors.primary, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: _nameController,
                              style: const TextStyle(color: Colors.white, fontSize: 15),
                              decoration: const InputDecoration(
                                hintText: 'Your Full Name',
                                hintStyle: TextStyle(color: Colors.white38),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // 2. City
              GlassPanel(
                padding: const EdgeInsets.all(20),
                borderRadius: 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'RESIDENTIAL CITY',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: Colors.white70,
                            fontSize: 11,
                            letterSpacing: 1.1,
                          ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.location_city_rounded, color: AppColors.primary, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: _cityController,
                              style: const TextStyle(color: Colors.white, fontSize: 15),
                              decoration: const InputDecoration(
                                hintText: 'e.g. Hyderabad, Vijayawada',
                                hintStyle: TextStyle(color: Colors.white38),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // 3. Date of Birth
              GlassPanel(
                padding: const EdgeInsets.all(20),
                borderRadius: 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'DATE OF BIRTH',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: Colors.white70,
                            fontSize: 11,
                            letterSpacing: 1.1,
                          ),
                    ),
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: _pickDob,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.cake_outlined, color: AppColors.primary, size: 20),
                                const SizedBox(width: 10),
                                Text(
                                  _selectedDob,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const Icon(Icons.calendar_month_rounded, color: AppColors.primary, size: 18),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // 4. Rashi (Zodiac)
              GlassPanel(
                padding: const EdgeInsets.all(20),
                borderRadius: 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'RASHI (ZODIAC SIGN)',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: Colors.white70,
                            fontSize: 11,
                            letterSpacing: 1.1,
                          ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Used for customized auspicious tithi & horoscopes',
                      style: TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 8,
                      runSpacing: 10,
                      children: _rashiOptions.map((rashi) {
                        final isSelected = _selectedRashi == rashi;
                        return ChoiceChip(
                          label: Text(rashi),
                          selected: isSelected,
                          onSelected: (val) {
                            if (val) setState(() => _selectedRashi = rashi);
                          },
                          backgroundColor: Colors.white.withValues(alpha: 0.05),
                          selectedColor: AppColors.primary.withValues(alpha: 0.25),
                          labelStyle: TextStyle(
                            color: isSelected ? AppColors.primary : Colors.white70,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            fontSize: 12,
                          ),
                          side: BorderSide(
                            color: isSelected ? AppColors.primary : Colors.white12,
                            width: isSelected ? 1.4 : 1.0,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // 5. Gothram
              GlassPanel(
                padding: const EdgeInsets.all(20),
                borderRadius: 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'GOTHRAM (గోత్రం)',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: Colors.white70,
                            fontSize: 11,
                            letterSpacing: 1.1,
                          ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.temple_hindu_outlined, color: AppColors.primary, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: _gothramController,
                              style: const TextStyle(color: Colors.white, fontSize: 15),
                              decoration: const InputDecoration(
                                hintText: 'e.g. Kashyapa, Bharadwaja',
                                hintStyle: TextStyle(color: Colors.white38),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: _gothramPresets.map((g) {
                        return GestureDetector(
                          onTap: () => setState(() => _gothramController.text = g),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.white12),
                            ),
                            child: Text(
                              g,
                              style: const TextStyle(color: Colors.white60, fontSize: 11),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Submit Primary Button
              PrimaryButton(
                label: 'COMPLETE REGISTRATION & ENTER',
                icon: Icons.arrow_forward_rounded,
                isLoading: _isSubmitting,
                onTap: _handleSubmit,
              ),

              const SizedBox(height: 20),

              // Hyperlink to Login Screen
              AuthFooterLink.login(
                onTap: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const MobileNumberScreen()),
                  );
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
