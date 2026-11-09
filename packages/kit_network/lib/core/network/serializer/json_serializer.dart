import 'dart:convert';
import 'serializer_interface.dart';

class JsonSerializer implements Serializer {
  const JsonSerializer();

  @override
  T decode<T>(Object? source, FromJson<T> fromJson) {
    if (source == null) {
      throw ArgumentError('Source is null for decode<T>()');
    }
    final map = source is Map<String, dynamic>
        ? source
        : (source is String
              ? jsonDecode(source) as Map<String, dynamic>
              : null);

    if (map == null) {
      throw ArgumentError(
        'Unsupported source type for decode<T> : ${source.runtimeType}',
      );
    }
    return fromJson(map);
  }

  @override
  List<T> decodeList<T>(Object? source, FromJson<T> fromJson) {
    if (source == null) return const [];
    final list = source is List
        ? source
        : (source is String ? (jsonDecode(source) as List) : null);

    if (list == null) {
      throw ArgumentError(
        'Unsupported source type for decodeList<T> : ${source.runtimeType}',
      );
    }
    return list
        .map<T>((e) => fromJson((e as Map).cast<String, dynamic>()))
        .toList();
  }
}
