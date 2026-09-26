import 'package:flutter/material.dart';
import 'package:pocket_puja/core/services/audio_controller.dart';
import 'package:pocket_puja/core/services/session_service.dart';
import 'package:pocket_puja/core/theme/app_theme.dart';
import 'package:pocket_puja/core/widgets/poojari_mode_badge.dart';
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
  final SessionService _sessionService = SessionService.instance;

  late AppRole _currentRole;
  bool _isLoading = false;
  String? _error;
  String _mobile = '';

  @override
  void initState() {
    super.initState();
    _currentRole = widget.initialRole;
    _sessionService.addListener(_onSessionChanged);
  }

  @override
  void dispose() {
    _sessionService.removeListener(_onSessionChanged);
    super.dispose();
  }

  void _onSessionChanged() {
    if (mounted) {
      setState(() {
        if (_sessionService.currentUser != null) {
          _currentRole = _sessionService.currentRole;
        }
      });
    }
  }

  void _switchRole(AppRole newRole) {
    setState(() {
      _currentRole = newRole;
    });
    _sessionService.switchRole(newRole);

    if (_sessionService.isLoggedIn) {
      _navigatorKey.currentState?.pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => _buildHomeScreen()),
        (route) => false,
      );
    }
  }

  void _toggleRole() {
    _switchRole(_currentRole == AppRole.customer ? AppRole.poojari : AppRole.customer);
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
            setState(() {
              _currentRole = user.role;
            });
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
    if (_currentRole == AppRole.poojari) {
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
    return Stack(
      children: [
        MobileNumberScreen(
          isLoading: _isLoading,
          error: _error,
          onSendOTP: _handleSendOTP,
        ),
        Positioned(
          top: 48,
          right: 20,
          child: SafeArea(
            child: PoojariModeBadge(
              isPoojari: _currentRole == AppRole.poojari,
              onToggle: _toggleRole,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SessionScope(
      sessionService: _sessionService,
      child: AudioControllerScope(
        controller: _audioController,
        child: MaterialApp(
          title: 'Pocket Puja',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.theme,
          navigatorKey: _navigatorKey,
          home: _sessionService.isLoggedIn ? _buildHomeScreen() : _buildLoginScreen(),
        ),
      ),
    );
  }
}
