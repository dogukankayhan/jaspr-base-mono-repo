/// URLs shared by the server pages and the browser islands (no server-only
/// imports here — this file is compiled for both).
library;

/// URL of a home result set: `/`, `/?type=fire`, `/?q=pika`, `&page=N`.
/// A type filter wins over a search (as in the bloc).
String homeLocation({String? query, String? type, int page = 1}) {
  final q = query?.trim();
  final params = <String, String>{
    'type': ?type,
    if (type == null && q != null && q.isNotEmpty) 'q': q,
    if (page > 1) 'page': '$page',
  };
  return Uri(
    path: '/',
    queryParameters: params.isEmpty ? null : params,
  ).toString();
}

String detailLocation(int id) => '/pokemon/$id';
