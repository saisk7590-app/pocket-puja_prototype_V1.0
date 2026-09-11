import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/otp_verify_screen.dart';
import 'screens/shell/app_shell.dart';
import 'services/audio_controller.dart';

void main() {
  runApp(const PocketPujaApp());
}

/// UI-only prototype — no backend, no persistence, no real auth.
/// All "network" calls below are mocked with a short delay so the
/// loading states in the UI still make sense. All content comes from
/// the /data folder (mock data), not a database.
class PocketPujaApp extends StatefulWidget {
  const PocketPujaApp({super.key});
  @override
  State<PocketPujaApp> createState() => _PocketPujaAppState();
}

class _PocketPujaAppState extends State<PocketPujaApp> {
  final _navigatorKey = GlobalKey<NavigatorState>();
  final AudioController _audioController = AudioController();
  bool _isLoading = false;
  String? _error;
  String _mobile = '';

  Future<void> _handleSendOTP(String mobile) async {
    setState(() {
      _mobile = mobile;
      _isLoading = true;
      _error = null;
    });
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    setState(() => _isLoading = false);
    _navigatorKey.currentState!.push(
      MaterialPageRoute(builder: (_) => _buildOtpScreen()),
    );
  }

  Future<void> _handleVerifyOTP(String otp) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    if (otp.length == 6) {
      setState(() => _isLoading = false);
      _navigatorKey.currentState!.pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => AppShell(onLogout: _handleLogout)),
        (route) => false,
      );
    } else {
      setState(() {
        _isLoading = false;
        _error = 'Invalid OTP. Please try again.';
      });
    }
  }

  void _handleLogout() {
    setState(() {
      _mobile = '';
      _error = null;
    });
    _navigatorKey.currentState!.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => _buildLoginScreen()),
      (route) => false,
    );
  }

  Widget _buildLoginScreen() => LoginScreen(
    isLoading: _isLoading,
    error: _error,
    onSendOTP: _handleSendOTP,
  );
  Widget _buildOtpScreen() => OTPVerifyScreen(
    mobile: _mobile,
    isLoading: _isLoading,
    error: _error,
    onVerify: _handleVerifyOTP,
    onResend: () => _handleSendOTP(_mobile),
  );

  @override
  Widget build(BuildContext context) {
    return AudioControllerScope(
      controller: _audioController,
      child: MaterialApp(
        title: 'Pocket Puja',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.theme,
        navigatorKey: _navigatorKey,
        home: _buildLoginScreen(),
      ),
    );
  }
}
