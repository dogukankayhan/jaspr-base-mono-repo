import '../phone/country_phone.dart';
import 'validator_rule.dart';
import 'rules/required_validator.dart';
import 'rules/min_length_validator.dart';
import 'rules/max_length_validator.dart';
import 'rules/email_validator.dart';
import 'rules/pattern_validator.dart';
import 'rules/range_validator.dart';
import 'rules/min_validator.dart';
import 'rules/max_validator.dart';
import 'rules/equals_validator.dart';
import 'rules/custom_validator.dart';
import 'rules/phone_validator.dart';
import 'rules/iban_validator.dart';
import 'rules/age_validator.dart';
import 'rules/date_validator.dart';
import 'rules/url_validator.dart';

/// Static factory for all built-in validators.
///
/// Each method takes optional [message] parameter (i18n):
/// ```dart
/// Validators.required(message: t.validation.required)
/// Validators.email(message: t.validation.email)
/// ```
abstract final class Validators {
  /// Value must not be null, empty string, or empty iterable.
  static Validator<T> required<T>({String? message}) =>
      RequiredValidator<T>(message);

  /// String must have at least [length] characters.
  static Validator<String> minLength(int length, {String? message}) =>
      MinLengthValidator(length, message);

  /// String must have at most [length] characters.
  static Validator<String> maxLength(int length, {String? message}) =>
      MaxLengthValidator(length, message);

  /// Must be a valid email address.
  static Validator<String> email({String? message}) => EmailValidator(message);

  /// String must match the given regex [pattern].
  static Validator<String> pattern(String pattern, {String? message}) =>
      PatternValidator(pattern, message);

  /// Number must be between [min] and [max] (inclusive).
  static Validator<num> range(num min, num max, {String? message}) =>
      RangeValidator(min, max, message);

  /// Number must be at least [value].
  static Validator<num> min(num value, {String? message}) =>
      MinValidator(value, message);

  /// Number must be at most [value].
  static Validator<num> max(num value, {String? message}) =>
      MaxValidator(value, message);

  /// Value must equal the result of [compareValue] at call time.
  static Validator<T> equals<T>(T Function() compareValue, {String? message}) =>
      EqualsValidator<T>(compareValue, message);

  /// Custom validation with a lambda.
  static Validator<T> custom<T>(String? Function(T? value) validate) =>
      CustomValidator<T>(validate);

  /// Phone number shaped like [country] expects — Türkiye (10 digits
  /// starting with 5) by default. Accepts formatted or raw digit string.
  static Validator<String> phone({
    CountryPhone country = CountryPhones.defaultCountry,
    String? message,
  }) => PhoneValidator(
    digits: country.digitCount,
    mobilePrefixes: country.mobilePrefixes,
    message: message,
  );

  /// Turkish IBAN: TR + 24 digits.
  /// Accepts formatted "TR00 0000 …" or raw string.
  static Validator<String> iban({String? message}) => IbanValidator(message);

  /// Non-blocking age check: warns when parsed integer < [minAge].
  /// Returns null for empty/non-numeric values (pair with Validators.required separately).
  static Validator<String> ageWarning({int minAge = 18, String? message}) =>
      AgeValidator(minAge: minAge, message: message);

  /// Date format DD.MM.YYYY with real calendar validation.
  static Validator<String> date({String? message}) => DateValidator(message);

  /// URL format starting with http:// or https://.
  static Validator<String> url({String? message}) => UrlValidator(message);
}
