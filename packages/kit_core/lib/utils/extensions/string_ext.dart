/// Dart's case mapping is locale-independent, so the Turkish dotted/dotless i
/// pair has to be mapped by hand: 'i'.toUpperCase() gives 'I' instead of 'İ',
/// and 'İ'.toLowerCase() gives 'i' plus a combining dot.
const _upperTr = {'i': 'İ', 'ı': 'I'};
const _lowerTr = {'I': 'ı', 'İ': 'i'};

final _letter = RegExp(r'\p{L}', unicode: true);

extension NullableStringExt on String? {
  bool get isNotEmpty => this != null && this!.isNotEmpty;
  bool get isEmpty => this == null || this!.isEmpty;
}

extension StringExt on String {
  /// "hello world" → "Hello world"
  String get capitalize =>
      isEmpty ? this : this[0].toUpperCase() + substring(1).toLowerCase();

  /// "hello world" → "Hello World"
  String get titleCase =>
      split(' ').where((e) => e.isNotEmpty).map((e) => e.capitalize).join(' ');

  /// "hello-world" / "hello_world" → "Hello world"
  String get humanize => replaceAll(RegExp(r'[-_]'), ' ').capitalize;

  /// Turkish-aware [titleCase] that keeps the original spacing:
  /// "YILMAZ" / "yılmaz" → "Yılmaz", "IŞIK" → "Işık", "inan" → "İnan".
  ///
  /// Prefer this for names in a Turkish locale — [titleCase] renders "İNAN" as
  /// "Inan" and "IŞIK" as "işık". Every non-letter (space, hyphen, apostrophe)
  /// is kept as is and starts a new word, so the result has the same length as
  /// the input and this is safe to run on text the user is still typing.
  String get titleCaseTr {
    final out = StringBuffer();
    var atWordStart = true;
    for (final char in split('')) {
      if (!_letter.hasMatch(char)) {
        out.write(char);
        atWordStart = true;
        continue;
      }
      out.write(
        atWordStart
            ? _upperTr[char] ?? char.toUpperCase()
            : _lowerTr[char] ?? char.toLowerCase(),
      );
      atWordStart = false;
    }
    return out.toString();
  }

  /// Turkish-aware uppercase: "ışık" → "IŞIK", "inan" → "İNAN".
  ///
  /// [toUpperCase] maps 'i' to 'I', dropping the dot the Turkish alphabet
  /// keeps — use this wherever uppercased Turkish text is shown to a member.
  String get upperCaseTr =>
      split('').map((c) => _upperTr[c] ?? c.toUpperCase()).join();

  /// Turkish-aware lowercase: "IŞIK" → "ışık", "İNAN" → "inan".
  ///
  /// [toLowerCase] maps both 'I' and 'İ' to 'i', collapsing a distinction the
  /// Turkish alphabet draws — the two are different letters that sort apart.
  String get lowerCaseTr =>
      split('').map((c) => _lowerTr[c] ?? c.toLowerCase()).join();

  /// "John Doe" → "JD" (avatar initials)
  String get initials => trim()
      .split(' ')
      .where((e) => e.isNotEmpty)
      .map((e) => e[0].toUpperCase())
      .join();

  /// Truncates with ellipsis. "Hello World" truncate(7) → "Hello W…"
  String truncate(int maxLength) =>
      length <= maxLength ? this : '${substring(0, maxLength)}…';

  bool get isEmail => RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(this);

  bool get isNumeric => double.tryParse(this) != null;

  bool get isUrl =>
      Uri.tryParse(this)?.hasAbsolutePath == true && startsWith('http');

  static const Map<String, String> _turkishDiacritics = {
    'ç': 'c',
    'Ç': 'C',
    'ğ': 'g',
    'Ğ': 'G',
    'ı': 'i',
    'İ': 'I',
    'ö': 'o',
    'Ö': 'O',
    'ş': 's',
    'Ş': 'S',
    'ü': 'u',
    'Ü': 'U',
  };

  /// Lowercased with Turkish diacritics folded to their ASCII equivalent, so
  /// e.g. "İstanbul" and "istanbul" match the same search query.
  String get normalizedForSearch {
    final buffer = StringBuffer();
    for (final char in split('')) {
      buffer.write(_turkishDiacritics[char] ?? char);
    }
    return buffer.toString().toLowerCase();
  }
}
