import 'package:kit_core/utils/extensions/string_ext.dart';
import 'package:test/test.dart';

void main() {
  group('normalizedForSearch', () {
    test('folds Turkish diacritics to ASCII and lowercases', () {
      expect('İstanbul'.normalizedForSearch, 'istanbul');
      expect('Çanakkale'.normalizedForSearch, 'canakkale');
      expect('Ağrı Dağı'.normalizedForSearch, 'agri dagi');
      expect('Şırnak'.normalizedForSearch, 'sirnak');
      expect('Ürgüp'.normalizedForSearch, 'urgup');
      expect('Ördek Gölü'.normalizedForSearch, 'ordek golu');
    });

    test('matches regardless of the original casing', () {
      final query = 'istanbul';
      expect('İSTANBUL'.normalizedForSearch, query);
      expect('istanbul'.normalizedForSearch, query);
    });

    test('leaves plain ASCII untouched other than casing', () {
      expect('Hello World'.normalizedForSearch, 'hello world');
    });
  });
}
