import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_puja/core/models/user_account.dart';
import 'package:pocket_puja/core/services/session_service.dart';
import 'package:pocket_puja/app.dart';

void main() {
  group('BLOCK 5 Auth Routing & Session Tests', () {
    final s = SessionService.instance;

    test('1. Customer credential 9876543210 resolves to Customer role and destination', () {
      final dest = s.authenticateAndResolveRoute('9876543210');
      final account = s.lookupAccountByMobile('9876543210');

      expect(dest, equals(AuthRouteDestination.customerHome));
      expect(account, isNotNull);
      expect(account!.role, equals(AppRole.customer));
      expect(account.isCustomer, isTrue);
      expect(account.isPoojari, isFalse);
      expect(s.currentRole, equals(AppRole.customer));
    });

    test('2. Poojari credential 9988776655 resolves to Poojari role and dashboard destination', () {
      final dest = s.authenticateAndResolveRoute('9988776655');
      final account = s.lookupAccountByMobile('9988776655');

      expect(dest, equals(AuthRouteDestination.poojariDashboard));
      expect(account, isNotNull);
      expect(account!.role, equals(AppRole.poojari));
      expect(account.isPoojari, isTrue);
      expect(account.isCustomer, isFalse);
      expect(s.currentRole, equals(AppRole.poojari));
      expect(account.poojariStatus, equals(PoojariVerificationStatus.verified));
    });

    test('3. Brand new unregistered mobile routes to Registration NameScreen', () {
      final dest = s.authenticateAndResolveRoute('9111222333');
      final account = s.lookupAccountByMobile('9111222333');

      expect(account, isNull);
      expect(dest, equals(AuthRouteDestination.registrationName));
    });

    test('4. Normalization handles spaces, hyphens, and +91 prefix seamlessly', () {
      expect(s.lookupAccountByMobile('+91 99887 76655'), isNotNull);
      expect(s.lookupAccountByMobile('9988776655'), isNotNull);
      expect(s.lookupAccountByMobile('+919988776655'), isNotNull);
      expect(s.lookupAccountByMobile('+91-98765-43210'), isNotNull);
    });
  });
}
