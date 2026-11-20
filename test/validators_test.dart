import 'package:flutter_test/flutter_test.dart';
import 'package:seek/core/utils/validators.dart';

void main() {
  group('email', () {
    test('rejects empty', () => expect(Validators.email(''), isNotNull));
    test('rejects missing @', () => expect(Validators.email('budi.mail.com'), isNotNull));
    test('accepts a valid email', () => expect(Validators.email('budi@mail.com'), isNull));
  });

  group('phone', () {
    test('accepts 08 format', () => expect(Validators.phone('08123456789'), isNull));
    test('accepts +62 format', () => expect(Validators.phone('+6281234567890'), isNull));
    test('rejects too short', () => expect(Validators.phone('12345'), isNotNull));
  });

  group('password', () {
    test('rejects too short', () => expect(Validators.password('Ab1'), isNotNull));
    test('rejects no uppercase', () => expect(Validators.password('abcdefg1'), isNotNull));
    test('rejects no number', () => expect(Validators.password('Abcdefgh'), isNotNull));
    test('accepts a strong password', () => expect(Validators.password('Abcdefg1'), isNull));
    test('srength of empty is 0', () => expect(Validators.passwordStrength(''), 0));
    test('strength of strong is 4', () => expect(Validators.passwordStrength('Abcdefg1'), 4));
  });

  group('confirm password', () {
    test('matches', () => expect(Validators.confirmPassword('Abcdefg1', 'Abcdefg1'), isNull));
    test('does not match', () => expect(Validators.confirmPassword('x', 'Abcdefg1'), isNotNull));
  });
}