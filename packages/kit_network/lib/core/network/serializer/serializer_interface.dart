typedef FromJson<T> = T Function(Map<String, dynamic> json);

abstract class Serializer {
  T decode<T>(Object? source, FromJson<T> fromJson);
  List<T> decodeList<T>(Object? source, FromJson<T> fromJson);
}
