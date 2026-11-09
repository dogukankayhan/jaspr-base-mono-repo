import 'package:kit_core/utils/validator/field_validator.dart';
import 'package:kit_core/utils/validator/form_validator.dart';
import 'package:kit_core/utils/validator/validators.dart';
import 'package:test/test.dart';

void main() {
  group('RequiredValidator', () {
    final v = FieldValidator<String>([Validators.required()]);

    test('null fails', () => expect(v.validate(null), isNotNull));
    test('empty string fails', () => expect(v.validate(''), isNotNull));
    test('whitespace-only fails', () => expect(v.validate('   '), isNotNull));
    test('valid string passes', () => expect(v.validate('hello'), isNull));
    test(
      'isValid returns false for null',
      () => expect(v.isValid(null), false),
    );
    test(
      'isValid returns true for valid',
      () => expect(v.isValid('hello'), true),
    );
  });

  group('EmailValidator', () {
    final v = FieldValidator<String>([Validators.email()]);

    test('valid emails pass', () {
      for (final email in ['a@b.com', 'user+tag@domain.co.uk']) {
        expect(v.validate(email), isNull, reason: '$email should be valid');
      }
    });

    test('invalid emails fail', () {
      for (final email in ['notanemail', '@nodomain', 'no@']) {
        expect(
          v.validate(email),
          isNotNull,
          reason: '$email should be invalid',
        );
      }
    });
  });

  group('MinLengthValidator', () {
    final v = FieldValidator<String>([Validators.minLength(6)]);

    test('too short fails', () => expect(v.validate('abc'), isNotNull));
    test('exact length passes', () => expect(v.validate('abcdef'), isNull));
    test('longer passes', () => expect(v.validate('abcdefgh'), isNull));
  });

  group('MaxLengthValidator', () {
    final v = FieldValidator<String>([Validators.maxLength(5)]);

    test('too long fails', () => expect(v.validate('toolong'), isNotNull));
    test('exact length passes', () => expect(v.validate('12345'), isNull));
    test('shorter passes', () => expect(v.validate('abc'), isNull));
  });

  group('PatternValidator', () {
    final v = FieldValidator<String>([
      Validators.pattern(r'[A-Z]', message: 'Needs uppercase'),
    ]);

    test('no uppercase fails', () => expect(v.validate('alllower'), isNotNull));
    test('has uppercase passes', () => expect(v.validate('hasUpper'), isNull));
    test(
      'custom message returned',
      () => expect(v.validate('lower'), equals('Needs uppercase')),
    );
  });

  group('EqualsValidator', () {
    String expected = 'secret';
    final v = FieldValidator<String>([
      Validators.equals(() => expected, message: 'Must match'),
    ]);

    test(
      'non-matching value fails',
      () => expect(v.validate('other'), isNotNull),
    );
    test('matching value passes', () => expect(v.validate('secret'), isNull));
    test(
      'custom message returned',
      () => expect(v.validate('wrong'), equals('Must match')),
    );
  });

  group('CustomValidator', () {
    final v = FieldValidator<String>([
      Validators.custom(
        (value) => value == 'forbidden' ? 'Forbidden value' : null,
      ),
    ]);

    test(
      'forbidden value fails with message',
      () => expect(v.validate('forbidden'), equals('Forbidden value')),
    );
    test('allowed value passes', () => expect(v.validate('ok'), isNull));
  });

  group('Chained validators — first error wins', () {
    final v = FieldValidator<String>([
      Validators.required(),
      Validators.email(),
      Validators.maxLength(50),
    ]);

    test('null fails required', () => expect(v.validate(null), isNotNull));
    test(
      'non-email fails email',
      () => expect(v.validate('notanemail'), isNotNull),
    );
    test(
      'valid short email passes all',
      () => expect(v.validate('user@example.com'), isNull),
    );
    test('valid but too-long email fails maxLength', () {
      expect(
        v.validate('averylongemailaddressthatexceedsfiftychars@example.com'),
        isNotNull,
      );
    });
  });

  group('validateAll — collects all errors', () {
    final v = FieldValidator<String>([
      Validators.minLength(8),
      Validators.pattern(r'[A-Z]', message: 'Needs uppercase'),
      Validators.pattern(r'[0-9]', message: 'Needs a digit'),
    ]);

    test('weak password collects all 3 errors', () {
      final result = v.validateAll('abc');
      expect(result.isValid, false);
      expect(result.errors.length, 3);
    });

    test('strong password has no errors', () {
      final result = v.validateAll('StrongPass1');
      expect(result.isValid, true);
      expect(result.errors, isEmpty);
    });
  });

  group('FieldValidator.and — extends with more rules', () {
    final base = FieldValidator<String>([Validators.required()]);
    final extended = base.and([Validators.email()]);

    test(
      'null fails required in base',
      () => expect(extended.validate(null), isNotNull),
    );
    test(
      'non-email fails email added via and',
      () => expect(extended.validate('notanemail'), isNotNull),
    );
    test(
      'valid email passes both',
      () => expect(extended.validate('a@b.com'), isNull),
    );
  });

  group('FormValidator', () {
    String email = '';
    String password = '';

    final emailValidator = FieldValidator<String>([
      Validators.required(),
      Validators.email(),
    ]);
    final passwordValidator = FieldValidator<String>([
      Validators.required(),
      Validators.minLength(8),
    ]);

    FormValidator form() => FormValidator({
      'email': () => emailValidator.validate(email),
      'password': () => passwordValidator.validate(password),
    });

    test('isValid false when fields are empty', () {
      email = '';
      password = '';
      expect(form().isValid, false);
    });

    test('isValid true when all fields valid', () {
      email = 'user@example.com';
      password = 'SecurePass';
      expect(form().isValid, true);
    });

    test('errorFor returns message for invalid field', () {
      email = 'bademail';
      password = 'SecurePass';
      expect(form().errorFor('email'), isNotNull);
      expect(form().errorFor('password'), isNull);
    });

    test('activeErrors only contains failing fields', () {
      email = '';
      password = 'SecurePass';
      final errors = form().activeErrors;
      expect(errors.containsKey('email'), true);
      expect(errors.containsKey('password'), false);
    });

    test('errors map returns all fields', () {
      email = 'a@b.com';
      password = 'ok';
      final errors = form().errors;
      expect(errors.containsKey('email'), true);
      expect(errors.containsKey('password'), true);
      expect(errors['email'], isNull);
      expect(errors['password'], isNotNull);
    });
  });
}
