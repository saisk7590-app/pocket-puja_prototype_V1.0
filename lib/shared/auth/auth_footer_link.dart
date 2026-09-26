import 'package:flutter/material.dart';
import 'package:pocket_puja/core/theme/app_theme.dart';
import 'package:pocket_puja/shared/auth/mobile_number_screen.dart';
import 'package:pocket_puja/shared/registration/name_screen.dart';

/// Reusable footer link component for switching between Auth (Login) and Registration.
/// Used across:
/// 1. lib/shared/auth/mobile_number_screen.dart ("Don't have an account? Register")
/// 2. lib/shared/registration/name_screen.dart ("Already have an account? Login")
/// 3. lib/shared/registration/role_picker_screen.dart ("Already have an account? Login")
/// 4. lib/shared/registration/poojari/poojari_registration_form.dart ("Already have an account? Login")
/// 5. lib/shared/registration/customer/customer_registration_form.dart ("Already have an account? Login")
class AuthFooterLink extends StatelessWidget {
  final String promptText;
  final String actionText;
  final VoidCallback? onTap;

  const AuthFooterLink({
    super.key,
    required this.promptText,
    required this.actionText,
    this.onTap,
  });

  /// Factory helper for "Don't have an account? Register" link
  factory AuthFooterLink.register({Key? key, VoidCallback? onTap}) {
    return AuthFooterLink(
      key: key,
      promptText: "Don't have an account? ",
      actionText: "Register",
      onTap: onTap,
    );
  }

  /// Factory helper for "Already have an account? Login" link
  factory AuthFooterLink.login({Key? key, VoidCallback? onTap}) {
    return AuthFooterLink(
      key: key,
      promptText: "Already have an account? ",
      actionText: "Login",
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            promptText,
            style: const TextStyle(
              color: Colors.white60,
              fontSize: 13,
            ),
          ),
          GestureDetector(
            onTap: onTap ??
                () {
                  if (actionText.toLowerCase().contains('register')) {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const NameScreen(mobile: '')),
                    );
                  } else {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => const MobileNumberScreen()),
                    );
                  }
                },
            child: Text(
              actionText,
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w800,
                fontSize: 13,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
