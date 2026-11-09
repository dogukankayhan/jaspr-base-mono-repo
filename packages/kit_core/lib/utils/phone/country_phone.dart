import 'country_phone_data.dart';
import 'phone_mask.dart';

/// Phone-number metadata for one country: dial code, national number mask and
/// display name.
///
/// Ported from the iOS app's `Country` table so both platforms format and
/// validate the same way — see the header of [countryPhoneData].
class CountryPhone {
  const CountryPhone({
    required this.isoCode,
    required this.dialCode,
    required this.pattern,
    required this.nameTr,
    required this.nameEn,
    this.trunkPrefix,
    this.mobilePrefixes = const [],
    this.isDialCodePrimary = false,
  });

  /// ISO 3166-1 alpha-2, e.g. `TR`.
  final String isoCode;

  /// Country calling code with its leading `+`, e.g. `+90`.
  final String dialCode;

  /// National number mask, `#` marking a digit slot — e.g. `### ### ## ##`.
  final String pattern;

  final String nameTr;
  final String nameEn;

  /// Prefix dialled domestically that must be dropped before the number goes
  /// on the wire (the `0` in `0555…`). Null where we could not confirm one.
  final String? trunkPrefix;

  /// Leading digits a mobile number has to start with. Empty = no constraint.
  final List<String> mobilePrefixes;

  /// Whether this country wins when several share a [dialCode] (24 countries
  /// share `+1`) and a pasted number has to resolve to exactly one of them.
  final bool isDialCodePrimary;

  /// How many digits the national number holds, derived from [pattern].
  int get digitCount => '#'.allMatches(pattern).length;

  /// 🇹🇷 — composed from [isoCode] with Unicode regional indicator symbols,
  /// which is why no flag assets ship with the app.
  String get flagEmoji {
    const base = 0x1F1E6; // 🇦
    const a = 0x41; // 'A'
    return String.fromCharCodes([
      base + (isoCode.codeUnitAt(0) - a),
      base + (isoCode.codeUnitAt(1) - a),
    ]);
  }

  String localizedName(String languageCode) =>
      languageCode == 'tr' ? nameTr : nameEn;

  /// Placeholder showing the shape the field expects — `5XX XXX XX XX` for
  /// Türkiye, where the only mobile prefix fills the first slot.
  String get hint {
    final masked = pattern.replaceAll('#', 'X');
    if (mobilePrefixes.length != 1) return masked;
    return masked.replaceFirst('X', mobilePrefixes.single);
  }

  /// Formats raw [input] against [pattern]: `5551234567` → `555 123 45 67`.
  String format(String input) =>
      maskPhoneDigits(nationalDigits(input), pattern);

  /// Strips separators, the [trunkPrefix] and a leading [dialCode] off [input],
  /// leaving the bare national digits — and never more than [digitCount].
  String nationalDigits(String input) {
    var digits = input.replaceAll(RegExp(r'\D'), '');

    // A pasted "+90 555…" / "0090555…" still carries the country code.
    final code = dialCode.substring(1);
    if (digits.length > code.length && digits.startsWith(code)) {
      digits = digits.substring(code.length);
    }

    final trunk = trunkPrefix;
    if (trunk != null && digits.startsWith(trunk)) {
      digits = digits.substring(trunk.length);
    }

    return digits.length > digitCount
        ? digits.substring(0, digitCount)
        : digits;
  }

  /// `+905551234567` — what the API is given.
  String toE164(String input) => '$dialCode${nationalDigits(input)}';

  /// `+90 555 123 45 67` — what a human is shown.
  String formatE164(String input) => '$dialCode ${format(input)}';
}

/// Lookup and parsing over the [countryPhoneData] table.
abstract final class CountryPhones {
  static const List<CountryPhone> all = countryPhoneData;

  /// Where every phone field starts — see [defaultCountryPhone].
  static const CountryPhone defaultCountry = defaultCountryPhone;

  static final Map<String, CountryPhone> _byIso = {
    for (final country in all) country.isoCode: country,
  };

  /// One country per dial code — the [CountryPhone.isDialCodePrimary] entry
  /// wins wherever several share one.
  static final Map<String, CountryPhone> _byDialCode = () {
    final map = <String, CountryPhone>{};
    for (final country in all) {
      if (!map.containsKey(country.dialCode) || country.isDialCodePrimary) {
        map[country.dialCode] = country;
      }
    }
    return map;
  }();

  /// Longest first, so `+90` never shadows `+905`-style longer codes.
  static final List<String> _dialCodesByLength = _byDialCode.keys.toList()
    ..sort((a, b) => b.length.compareTo(a.length));

  static CountryPhone? byIso(String isoCode) => _byIso[isoCode.toUpperCase()];

  /// Splits a pasted international number into its country and national part.
  ///
  /// Returns null when [raw] carries no recognisable country code, which is
  /// the common case — a user typing a local number keeps the country they
  /// already picked.
  static (CountryPhone, String)? parse(String raw) {
    final trimmed = raw.trim();
    final isInternational = trimmed.startsWith('+') || trimmed.startsWith('00');
    if (!isInternational) return null;

    var digits = trimmed.replaceAll(RegExp(r'\D'), '');
    if (trimmed.startsWith('00')) digits = digits.substring(2);
    if (digits.isEmpty) return null;

    for (final dialCode in _dialCodesByLength) {
      final code = dialCode.substring(1);
      if (digits.length <= code.length || !digits.startsWith(code)) continue;
      final country = _byDialCode[dialCode]!;
      return (country, country.nationalDigits(digits.substring(code.length)));
    }
    return null;
  }
}
