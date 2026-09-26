import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pocket_puja/core/models/user_account.dart';
import 'package:pocket_puja/core/services/session_service.dart';
import 'package:pocket_puja/core/theme/app_theme.dart';
import 'package:pocket_puja/core/widgets/glass.dart';
import 'package:pocket_puja/customer/shell/app_shell.dart';
import 'package:pocket_puja/poojari/shell/poojari_shell.dart';
import 'package:pocket_puja/shared/registration/name_screen.dart';

/// Screen 2: OTP Verification
/// Validates 6-digit OTP, checks if account exists:
/// - Existing account -> skips to main app flow (BLOCK 2 Login routing):
///     * Customer -> lib/customer/shell/ (Customer Home)
///     * Poojari  -> lib/poojari/shell/ (Poojari Dashboard)
/// - New number -> continues to Step 3 (NameScreen)
class OTPVerificationScreen extends StatefulWidget {
  final String mobile;
  final Function(String otp)? onVerify;
  final VoidCallback? onResend;
  final ValueChanged<UserAccount>? onExistingUserSuccess;
  final ValueChanged<String>? onNewUserSuccess;
  final bool isLoading;
  final String? error;

  const OTPVerificationScreen({
    super.key,
    required this.mobile,
    this.onVerify,
    this.onResend,
    this.onExistingUserSuccess,
    this.onNewUserSuccess,
    this.isLoading = false,
    this.error,
  });

  @override
  State<OTPVerificationScreen> createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  final List<TextEditingController> _controllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  Timer? _timer;
  int _countdown = 30;
  bool _internalLoading = false;
  String? _internalError;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    _countdown = 30;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      if (_countdown > 0) {
        setState(() => _countdown--);
      } else {
        t.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var c in _controllers) {
      c.dispose();
    }
    for (var f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  String get _currentOtp => _controllers.map((c) => c.text).join();

  void _onOTPChanged(int index, String value) {
    if (value.length == 1 && index < 5) {
      _focusNodes[index + 1].requestFocus();
    }
    if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }

    if (_currentOtp.length == 6) {
      _handleVerify();
    }
  }

  Future<void> _handleVerify() async {
    final otp = _currentOtp;
    if (otp.length != 6) {
      setState(() => _internalError = 'Please enter all 6 digits of the OTP');
      return;
    }

    setState(() {
      _internalLoading = true;
      _internalError = null;
    });

    // If custom external verify callback is provided, invoke it
    if (widget.onVerify != null) {
      widget.onVerify!(otp);
      return;
    }

    // Default built-in verification and login resolution flow:
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;

    final session = SessionService.instance;
    final destination = session.authenticateAndResolveRoute(widget.mobile);

    setState(() => _internalLoading = false);

    switch (destination) {
      case AuthRouteDestination.customerHome:
      case AuthRouteDestination.poojariDashboard:
        final user = session.currentUser;
        if (widget.onExistingUserSuccess != null && user != null) {
          widget.onExistingUserSuccess!(user);
        } else {
          // Route straight to Customer Home or Poojari Dashboard
          if (destination == AuthRouteDestination.customerHome) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (_) => AppShell(
                  onLogout: () {
                    session.logout();
                    Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
                  },
                ),
              ),
              (route) => false,
            );
          } else {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (_) => PoojariShell(
                  onLogout: () {
                    session.logout();
                    Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
                  },
                ),
              ),
              (route) => false,
            );
          }
        }
        break;

      case AuthRouteDestination.registrationName:
        // New Number -> Proceed to Step 3: NameScreen
        if (widget.onNewUserSuccess != null) {
          widget.onNewUserSuccess!(widget.mobile);
        } else {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => NameScreen(mobile: widget.mobile),
            ),
          );
        }
        break;
    }
  }

  void _handleResend() {
    if (widget.onResend != null) {
      widget.onResend!();
    }
    _startCountdown();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('New verification code sent to ${widget.mobile}'),
        backgroundColor: AppColors.surfaceContainerHigh,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final masked = widget.mobile.length >= 6
        ? widget.mobile.replaceRange(4, widget.mobile.length - 2, '****')
        : widget.mobile;

    final displayError = widget.error ?? _internalError;
    final isLoading = widget.isLoading || _internalLoading;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: AppGradients.auth),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              children: [
                // Top App Bar row
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(
                      Icons.arrow_back_ios_new,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Icon & Title
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary.withValues(alpha: 0.15),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.35),
                      width: 1.5,
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.mark_email_read_outlined,
                      color: AppColors.primary,
                      size: 28,
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'Verify OTP',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        color: AppColors.primary,
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        shadows: AppTheme.goldGlow,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Enter the 6-digit code sent to $masked',
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 32),

                // OTP Card
                GlassPanel(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
                  borderRadius: 24,
                  child: Column(
                    children: [
                      Text(
                        'ENTER VERIFICATION CODE',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: Colors.white60,
                              fontSize: 11,
                              letterSpacing: 1.2,
                            ),
                      ),
                      const SizedBox(height: 24),

                      // 6 Pin Boxes
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(
                          6,
                          (i) => SizedBox(
                            width: 44,
                            height: 56,
                            child: TextField(
                              controller: _controllers[i],
                              focusNode: _focusNodes[i],
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              maxLength: 1,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primary,
                              ),
                              decoration: InputDecoration(
                                counterText: '',
                                filled: true,
                                fillColor: Colors.white.withValues(alpha: 0.06),
                                contentPadding: EdgeInsets.zero,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: BorderSide(
                                    color: Colors.white.withValues(alpha: 0.15),
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: BorderSide(
                                    color: Colors.white.withValues(alpha: 0.18),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: const BorderSide(
                                    color: AppColors.primary,
                                    width: 2,
                                  ),
                                ),
                              ),
                              onChanged: (v) => _onOTPChanged(i, v),
                            ),
                          ),
                        ),
                      ),

                      if (displayError != null) ...[
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.error_outline_rounded,
                              size: 15,
                              color: AppColors.error,
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                displayError,
                                style: const TextStyle(
                                  color: AppColors.error,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],

                      const SizedBox(height: 24),

                      // Resend Timer Row
                      _countdown > 0
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.timer_outlined,
                                  size: 16,
                                  color: Colors.white54,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Resend code in ${_countdown}s',
                                  style: const TextStyle(
                                    color: Colors.white54,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            )
                          : TextButton.icon(
                              onPressed: _handleResend,
                              icon: const Icon(
                                Icons.refresh_rounded,
                                color: AppColors.primary,
                                size: 18,
                              ),
                              label: const Text(
                                'Resend OTP',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 14,
                                ),
                              ),
                            ),

                      const SizedBox(height: 24),

                      // Verify PrimaryButton
                      PrimaryButton(
                        label: 'VERIFY & CONTINUE',
                        icon: Icons.check_circle_outline_rounded,
                        isLoading: isLoading,
                        onTap: _handleVerify,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
