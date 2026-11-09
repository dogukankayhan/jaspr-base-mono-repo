class PokemonBrief {
  final String name;
  final String url;

  const PokemonBrief({required this.name, required this.url});

  /// The id at the end of the resource URL (`…/pokemon/6/` → 6), or null if
  /// the URL has an unexpected shape.
  int? get id {
    final segments = url.split('/').where((s) => s.isNotEmpty);
    return segments.isEmpty ? null : int.tryParse(segments.last);
  }
}
