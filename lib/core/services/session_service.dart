import 'package:flutter/material.dart';
import 'package:pocket_puja/app.dart';
import 'package:pocket_puja/core/models/user_account.dart';

/// Destination resolution result after OTP verification
enum AuthRouteDestination {
  customerHome,
  poojariDashboard,
  registrationName,
}

/// Central session and authentication state manager for Pocket Puja.
/// Supports both Customer and Poojari roles, registration, returning user login,
/// and Poojari verification status updates.
class SessionService extends ChangeNotifier {
  static final SessionService _instance = SessionService._internal();
  factory SessionService() => _instance;
  static SessionService get instance => _instance;

  SessionService._internal() {
    _initPreseededAccounts();
  }

  final Map<String, UserAccount> _registeredAccounts = {};
  UserAccount? _currentUser;
  bool _isLoggedIn = false;

  UserAccount? get currentUser => _currentUser;
  bool get isLoggedIn => _isLoggedIn && _currentUser != null;
  AppRole get currentRole => _currentUser?.role ?? AppRole.customer;
  PoojariVerificationStatus get poojariStatus =>
      _currentUser?.poojariStatus ?? PoojariVerificationStatus.underReview;

  void _initPreseededAccounts() {
    // Standard mock existing customer account (Sai Kiran)
    const existingCustomerMobile = '+919876543210';
    _registeredAccounts[_normalizeMobile(existingCustomerMobile)] = const UserAccount(
      mobile: existingCustomerMobile,
      fullName: 'Sai Kiran Sharma',
      role: AppRole.customer,
    );

    // Standard mock existing poojari account (Shri Venkata Ramana)
    const existingPoojariMobile = '+919988776655';
    _registeredAccounts[_normalizeMobile(existingPoojariMobile)] = const UserAccount(
      mobile: existingPoojariMobile,
      fullName: 'Shri Venkata Ramana',
      role: AppRole.poojari,
      poojariStatus: PoojariVerificationStatus.verified,
      poojariProfile: PoojariProfile(
        city: 'Hyderabad',
        serviceRadius: '15km',
        experienceYears: 14,
        trainingLineage: 'Trained under Sri Sitarama Shastri, Kanchi Kamakoti Peetham',
        specializations: ['Satyanarayana Vratam', 'Gruhapravesham', 'Ganesha Pooja'],
        languages: ['Telugu', 'Sanskrit', 'English'],
        certificateFileName: 'vedic_pravesha_certificate.pdf',
      ),
    );

    // Additional mock under-review poojari account for verification testing
    const underReviewPoojariMobile = '+919123456780';
    _registeredAccounts[_normalizeMobile(underReviewPoojariMobile)] = const UserAccount(
      mobile: underReviewPoojariMobile,
      fullName: 'Shri Raghava Acharya',
      role: AppRole.poojari,
      poojariStatus: PoojariVerificationStatus.underReview,
      poojariProfile: PoojariProfile(
        city: 'Vijayawada',
        serviceRadius: '10km',
        experienceYears: 8,
        trainingLineage: 'Trained under Sri Ramanuja Sampradaya',
        specializations: ['Gruhapravesham', 'Satyanarayana Vratam'],
        languages: ['Telugu', 'Sanskrit'],
        certificateFileName: 'veda_pathashala_degree.pdf',
      ),
    );
  }

  static String _normalizeMobile(String mobile) {
    String clean = mobile.replaceAll(RegExp(r'[\s\-()]'), '');
    if (!clean.startsWith('+91') && clean.length == 10) {
      clean = '+91$clean';
    }
    return clean;
  }

  /// Checks if a mobile number is already registered
  bool isExistingUser(String mobile) {
    final norm = _normalizeMobile(mobile);
    return _registeredAccounts.containsKey(norm);
  }

  /// Fetches an existing user account if registered
  UserAccount? getUserByMobile(String mobile) {
    final norm = _normalizeMobile(mobile);
    return _registeredAccounts[norm];
  }

  /// Single branch point after OTP success (BLOCK 2 Login Routing Logic):
  /// - Existing account with role == 'customer' -> sets session & returns [customerHome]
  /// - Existing account with role == 'poojari'  -> sets session & returns [poojariDashboard]
  /// - New number                             -> returns [registrationName]
  AuthRouteDestination authenticateAndResolveRoute(String mobile) {
    final norm = _normalizeMobile(mobile);
    final existingUser = _registeredAccounts[norm];

    if (existingUser != null) {
      _currentUser = existingUser;
      _isLoggedIn = true;
      notifyListeners();

      if (existingUser.role == AppRole.poojari) {
        return AuthRouteDestination.poojariDashboard;
      } else {
        return AuthRouteDestination.customerHome;
      }
    }

    return AuthRouteDestination.registrationName;
  }

  /// Log in an existing user with mobile
  UserAccount? loginWithMobile(String mobile) {
    final norm = _normalizeMobile(mobile);
    final user = _registeredAccounts[norm];
    if (user != null) {
      _currentUser = user;
      _isLoggedIn = true;
      notifyListeners();
      return user;
    }
    return null;
  }

  /// Register a new Customer account
  UserAccount registerCustomer({
    required String mobile,
    required String fullName,
  }) {
    final norm = _normalizeMobile(mobile);
    final user = UserAccount(
      mobile: norm,
      fullName: fullName.trim(),
      role: AppRole.customer,
    );
    _registeredAccounts[norm] = user;
    _currentUser = user;
    _isLoggedIn = true;
    notifyListeners();
    return user;
  }

  /// Register a new Poojari account with 'under_review' status
  UserAccount registerPoojari({
    required String mobile,
    required String fullName,
    required PoojariProfile profile,
  }) {
    final norm = _normalizeMobile(mobile);
    final user = UserAccount(
      mobile: norm,
      fullName: fullName.trim(),
      role: AppRole.poojari,
      poojariStatus: PoojariVerificationStatus.underReview,
      poojariProfile: profile,
    );
    _registeredAccounts[norm] = user;
    _currentUser = user;
    _isLoggedIn = true;
    notifyListeners();
    return user;
  }

  /// Update current Poojari verification status
  void updatePoojariStatus(PoojariVerificationStatus status) {
    if (_currentUser != null && _currentUser!.isPoojari) {
      final updated = _currentUser!.copyWith(poojariStatus: status);
      _registeredAccounts[_normalizeMobile(updated.mobile)] = updated;
      _currentUser = updated;
      notifyListeners();
    }
  }

  /// Switch active role (e.g. for testing / dual preview)
  void switchRole(AppRole newRole) {
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(role: newRole);
      _registeredAccounts[_normalizeMobile(_currentUser!.mobile)] = _currentUser!;
      notifyListeners();
    }
  }

  /// Log out and clear current user session
  void logout() {
    _currentUser = null;
    _isLoggedIn = false;
    notifyListeners();
  }
}

/// Inherited scope widget for [SessionService]
class SessionScope extends InheritedNotifier<SessionService> {
  const SessionScope({
    super.key,
    required SessionService sessionService,
    required super.child,
  }) : super(notifier: sessionService);

  static SessionService of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<SessionScope>();
    assert(scope != null, 'No SessionScope found in context');
    return scope!.notifier!;
  }

  static SessionService? maybeOf(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<SessionScope>();
    return scope?.notifier;
  }
}
