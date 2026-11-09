import '../validator_rule.dart';

/// Validates a URL that must begin with http:// or https://.
class UrlValidator extends Validator<String> {
  const UrlValidator([super.message]);

  static final _regex = RegExp(
    r'^https?://([\w-]+(\.[\w-]+)+)([\w.,@?^=%&:/~+#\-_]*[\w@?^=%&/~+#\-_])?$',
    caseSensitive: false,
  );

  @override
  String? validate(String? value) {
    if (value == null || value.isEmpty) return null;
    if (!_regex.hasMatch(value)) {
      return resolveMessage('Geçerli bir URL giriniz');
    }
    return null;
  }
}
