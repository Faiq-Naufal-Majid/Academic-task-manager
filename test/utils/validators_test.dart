import 'package:flutter_test/flutter_test.dart';
import 'package:project_responsi/utils/validators.dart';

void main() {
  group('Validators & Sanitization Tests (Pertemuan 6)', () {
    test('isValidEmail memvalidasi format email mahasiswa dengan benar', () {
      expect(Validators.isValidEmail('mhs@students.amikom.ac.id'), isTrue);
      expect(Validators.isValidEmail('budi.raharjo@mail.com'), isTrue);
      expect(Validators.isValidEmail('invalid-email'), isFalse);
      expect(Validators.isValidEmail('user@domain'), isFalse);
    });

    test('sanitize membersihkan karakter berbahaya untuk mencegah XSS', () {
      const dangerousInput = '<script>alert("hacked")</script>';
      final sanitized = Validators.sanitize(dangerousInput);
      expect(sanitized, isNot(contains('<')));
      expect(sanitized, isNot(contains('>')));
      expect(sanitized, isNot(contains('"')));
      expect(sanitized, contains('&lt;script&gt;'));
    });

    test('validateNim memvalidasi format nomor induk mahasiswa', () {
      expect(Validators.validateNim('22.11.4820'), isNull); // Valid
      expect(Validators.validateNim('22114820'), isNull); // Valid
      expect(Validators.validateNim('123'), contains('8-12 digit'));
      expect(Validators.validateNim('abc.11.4820'), contains('8-12 digit'));
    });

    test('validatePassword menguji kriteria panjang, kapital, dan angka', () {
      expect(Validators.validatePassword('Password123'), isNull); // Valid
      expect(Validators.validatePassword('pass'), contains('minimal 8 karakter'));
      expect(Validators.validatePassword('password123'), contains('huruf kapital'));
      expect(Validators.validatePassword('PasswordAbc'), contains('angka'));
    });

    test('calculatePasswordStrength mengembalikan skor kekuatan yang akurat', () {
      expect(Validators.calculatePasswordStrength(''), equals(0.0));
      expect(Validators.calculatePasswordStrength('weak'), lessThan(0.4));
      expect(Validators.calculatePasswordStrength('MediumPass123'), greaterThanOrEqualTo(0.6));
    });
  });
}
