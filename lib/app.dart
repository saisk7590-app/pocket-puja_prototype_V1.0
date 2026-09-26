import 'package:flutter/material.dart';
import 'package:pocket_puja/core/services/audio_controller.dart';
import 'package:pocket_puja/core/services/poojari_controller.dart';
import 'package:pocket_puja/core/services/session_service.dart';
import 'package:pocket_puja/core/theme/app_theme.dart';
import 'package:pocket_puja/customer/shell/app_shell.dart';
import 'package:pocket_puja/poojari/shell/poojari_shell.dart';
import 'package:pocket_puja/shared/auth/mobile_number_screen.dart';
import 'package:pocket_puja/shared/auth/otp_verification_screen.dart';

/// Available application roles
enum AppRole { customer, poojari }

/// Root application widget supporting dynamic switching between Customer and Poojari apps.
class PocketPujaApp extends StatefulWidget {
  final AppRole initialRole;

  const PocketPujaApp({
    super.key,
    this.initialRole = AppRole.customer,
  });

  @override
  State<PocketPujaApp> createState() => _PocketPujaAppState();
}

class _PocketPujaAppState extends State<PocketPujaApp> {
  final _navigatorKey = GlobalKey<NavigatorState>();
  final AudioController _audioController = AudioController();
  final PoojariController _poojariController = PoojariController();
  final SessionService _sessionService = SessionService.instance;

  bool _isLoading = false;
  String? _error;
  String _mobile = '';

  @override
  void initState() {
    super.initState();
    _sessionService.addListener(_onSessionChanged);
  }

  @override
  void dispose() {
    _sessionService.removeListener(_onSessionChanged);
    super.dispose();
  }

  void _onSessionChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  void _switchRole(AppRole newRole) {
    _sessionService.switchRole(newRole);
    if (_sessionService.isLoggedIn) {
      _navigatorKey.currentState?.pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => _buildHomeScreen()),
        (route) => false,
      );
    }
  }


  Future<void> _handleSendOTP(String mobile) async {
    setState(() {
      _mobile = mobile;
      _isLoading = true;
      _error = null;
    });

    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;

    setState(() => _isLoading = false);

    _navigatorKey.currentState!.push(
      MaterialPageRoute(
        builder: (_) => OTPVerificationScreen(
          mobile: _mobile,
          onExistingUserSuccess: (user) {
            _navigatorKey.currentState!.pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => _buildHomeScreen()),
              (route) => false,
            );
          },
        ),
      ),
    );
  }

  void _handleLogout() {
    _sessionService.logout();
    setState(() {
      _mobile = '';
      _error = null;
    });
    _navigatorKey.currentState!.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => _buildLoginScreen()),
      (route) => false,
    );
  }

  Widget _buildHomeScreen() {
    final role = _sessionService.currentRole;
    if (role == AppRole.poojari) {
      return PoojariShell(
        onLogout: _handleLogout,
        onSwitchToCustomer: () => _switchRole(AppRole.customer),
      );
    } else {
      return AppShell(
        onLogout: _handleLogout,
      );
    }
  }

  Widget _buildLoginScreen() {
    return MobileNumberScreen(
      isLoading: _isLoading,
      error: _error,
      onSendOTP: _handleSendOTP,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SessionScope(
      sessionService: _sessionService,
      child: AudioControllerScope(
        controller: _audioController,
        child: PoojariControllerScope(
          controller: _poojariController,
          child: MaterialApp(
            title: 'Pocket Puja',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.theme,
            navigatorKey: _navigatorKey,
            home: _sessionService.isLoggedIn ? _buildHomeScreen() : _buildLoginScreen(),
          ),
        ),
      ),
    );
  }
}
