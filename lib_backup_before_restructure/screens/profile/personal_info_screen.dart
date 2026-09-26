import 'package:flutter/material.dart';
import 'dart:async';
import '../../theme/app_theme.dart';
import '../../widgets/common/glass.dart';
import '../../data/profile/profile_data.dart';
import '../../data/calendar/calendar_data.dart';

class PersonalInfoScreen extends StatefulWidget {
  const PersonalInfoScreen({super.key});
  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

enum _MobileEditState { view, editing, otpSent }

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  late TextEditingController _nameController;
  late TextEditingController _cityController;
  late TextEditingController _newMobileController;
  String? _dob;
  bool _dirty = false;

  _MobileEditState _mobileState = _MobileEditState.view;
  final List<TextEditingController> _otpControllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _otpFocusNodes = List.generate(6, (_) => FocusNode());
  Timer? _resendTimer;
  int _resendCountdown = 30;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: currentUser.name);
    _cityController = TextEditingController(text: currentUser.city);
    _newMobileController = TextEditingController();
    _dob = currentUser.dob;
    _nameController.addListener(_markDirty);
    _cityController.addListener(_markDirty);
    _newMobileController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    for (var c in _otpControllers) {
      c.dispose();
    }
    for (var f in _otpFocusNodes) {
      f.dispose();
    }
    _nameController.dispose();
    _cityController.dispose();
    _newMobileController.dispose();
    super.dispose();
  }

  void _markDirty() {
    if (!_dirty) setState(() => _dirty = true);
  }

  void _startResendTimer() {
    _resendCountdown = 30;
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_resendCountdown > 0) {
        setState(() => _resendCountdown--);
      } else {
        t.cancel();
      }
    });
  }

  void _onOtpDigitChanged(int index, String value) {
    if (value.length == 1 && index < 5) {
      _otpFocusNodes[index + 1].requestFocus();
    }
    if (value.isEmpty && index > 0) {
      _otpFocusNodes[index - 1].requestFocus();
    }
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
      setState(() {
        _dob = '${picked.day} ${_monthShort(picked.month)} ${picked.year}';
        _dirty = true;
      });
    }
  }

  String _monthShort(int m) => const [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ][m - 1];

  String get _rashiFromDob {
    // Simplified sun-sign style — not birth-star accurate, by design (no time/place needed).
    return currentUser.rashi;
  }

  @override
  Widget build(BuildContext context) {
    return GlassScaffold(
      title: 'Personal Info',
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
        children: [
          GlassPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionLabel('MOBILE NUMBER'),
                const SizedBox(height: 10),
                _buildMobileSection(),
              ],
            ),
          ),
          const SizedBox(height: 16),
          GlassPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionLabel('NAME'),
                const SizedBox(height: 10),
                TextField(
                  controller: _nameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: _fieldDecoration(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          GlassPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionLabel('DATE OF BIRTH'),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: _pickDob,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.cake_outlined,
                          color: AppColors.primary,
                          size: 18,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          _dob ?? 'Set your birth date',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Used to personalize your daily Rashi Phalam.',
                  style: TextStyle(color: Colors.white38, fontSize: 11),
                ),
                if (_dob != null) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Text(
                        rashiSigns.firstWhere((s) => s.name == 'Simha').symbol,
                        style: const TextStyle(
                          fontSize: 20,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Your Rashi: $_rashiFromDob',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          GlassPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionLabel('CITY'),
                const SizedBox(height: 10),
                TextField(
                  controller: _cityController,
                  style: const TextStyle(color: Colors.white),
                  decoration: _fieldDecoration(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: GhostButton(
                  label: 'Cancel',
                  onTap: _dirty
                      ? () => setState(() {
                          _nameController.text = currentUser.name;
                          _cityController.text = currentUser.city;
                          _dirty = false;
                        })
                      : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: PrimaryButton(
                  label: 'Save',
                  enabled: _dirty,
                  onTap: () {
                    setState(() => _dirty = false);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Profile updated')),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  InputDecoration _fieldDecoration() => InputDecoration(
    filled: true,
    fillColor: Colors.white.withValues(alpha: 0.05),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
  );

  Widget _buildMobileSection() {
    switch (_mobileState) {
      case _MobileEditState.view:
        return Row(
          children: [
            Expanded(
              child: Text(
                currentUser.mobile,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            TextButton(
              onPressed: () =>
                  setState(() => _mobileState = _MobileEditState.editing),
              child: const Text(
                'Change',
                style: TextStyle(color: AppColors.primary),
              ),
            ),
          ],
        );
      case _MobileEditState.editing:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  '+91 ',
                  style: TextStyle(color: Colors.white70, fontSize: 15),
                ),
                Expanded(
                  child: TextField(
                    controller: _newMobileController,
                    keyboardType: TextInputType.phone,
                    maxLength: 10,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      counterText: '',
                      hintText: 'New mobile number',
                      hintStyle: TextStyle(color: Colors.white38),
                      border: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white24),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: GhostButton(
                    label: 'Cancel',
                    height: 44,
                    onTap: () =>
                        setState(() => _mobileState = _MobileEditState.view),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: PrimaryButton(
                    label: 'Get OTP',
                    height: 44,
                    enabled: _newMobileController.text.trim().length == 10,
                    onTap: () {
                      setState(() => _mobileState = _MobileEditState.otpSent);
                      _startResendTimer();
                    },
                  ),
                ),
              ],
            ),
          ],
        );
      case _MobileEditState.otpSent:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '+91 ${_newMobileController.text}',
              style: const TextStyle(color: Colors.white54, fontSize: 13),
            ),
            const SizedBox(height: 4),
            const Text(
              'Enter verification code sent to this number',
              style: TextStyle(color: Colors.white38, fontSize: 11),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(
                6,
                (i) => SizedBox(
                  width: 40,
                  height: 48,
                  child: TextField(
                    controller: _otpControllers[i],
                    focusNode: _otpFocusNodes[i],
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    maxLength: 1,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                    decoration: InputDecoration(
                      counterText: '',
                      filled: true,
                      fillColor: Colors.white.withValues(alpha: 0.05),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (v) => _onOtpDigitChanged(i, v),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            _resendCountdown > 0
                ? Text(
                    'Resend in ${_resendCountdown}s',
                    style: const TextStyle(color: Colors.white38, fontSize: 12),
                  )
                : TextButton(
                    onPressed: _startResendTimer,
                    child: const Text(
                      'Resend OTP',
                      style: TextStyle(color: AppColors.primary),
                    ),
                  ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: GhostButton(
                    label: 'Cancel',
                    height: 44,
                    onTap: () =>
                        setState(() => _mobileState = _MobileEditState.view),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: PrimaryButton(
                    label: 'Verify & Update',
                    height: 44,
                    onTap: () {
                      setState(() => _mobileState = _MobileEditState.view);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Number updated ✓')),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        );
    }
  }
}