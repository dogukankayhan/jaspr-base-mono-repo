import 'package:app_shared/domain/entity/pokemon_ability_entity.dart';
import 'package:app_shared/domain/entity/pokemon_entity.dart';
import 'package:app_shared/domain/entity/pokemon_sprites_entity.dart';
import 'package:app_shared/domain/entity/pokemon_stats_entity.dart';
import 'package:app_shared/domain/entity/pokemon_type_entity.dart';
import 'package:app_shared/features/pokemon_home/bloc/pokemon_home_state.dart';
import 'package:jaspr/jaspr.dart';

/// The first page the server rendered, handed to the browser so the
/// `PokemonHomeBloc` there starts from it (no refetch, no empty flash).
///
/// Jaspr serializes `@client` component parameters into the page; `@encoder`
/// / `@decoder` teach it how to do that for this type.
///
/// Only the fields the list view needs travel (id, name, types, artwork) —
/// the full entity (stats, moves…) would just bloat the HTML. Detail pages
/// load the complete Pokémon themselves.
class HomeSeed {
  const HomeSeed({
    required this.items,
    required this.hasMore,
    required this.nextOffset,
    this.startPage = 1,
    this.query,
    this.type,
  });

  final List<Pokemon> items;
  final bool hasMore;
  final int nextOffset;

  /// Which server page (`?page=N`) the items start at — for the
  /// "previous page" link.
  final int startPage;
  final String? query;
  final String? type;

  /// The bloc state this seed represents.
  PokemonHomeState toState() => PokemonHomeState(
    items: items,
    hasMore: hasMore,
    nextOffset: nextOffset,
    searchQuery: query,
    selectedType: type,
  );

  @encoder
  Map<String, Object?> toJson() => {
    'items': [for (final p in items) _encodePokemon(p)],
    'hasMore': hasMore,
    'nextOffset': nextOffset,
    'startPage': startPage,
    'query': query,
    'type': type,
  };

  @decoder
  static HomeSeed fromJson(Map<String, Object?> json) => HomeSeed(
    items: [
      for (final p in (json['items'] as List? ?? const []))
        _decodePokemon((p as Map).cast<String, Object?>()),
    ],
    hasMore: json['hasMore'] as bool? ?? false,
    nextOffset: json['nextOffset'] as int? ?? 0,
    startPage: json['startPage'] as int? ?? 1,
    query: json['query'] as String?,
    type: json['type'] as String?,
  );

  static Map<String, Object?> _encodePokemon(Pokemon p) => {
    'id': p.id,
    'name': p.name,
    'types': [for (final t in p.types) t.type.name],
    'artwork': p.sprites.other?.officialArtwork?.frontDefault,
    'sprite': p.sprites.frontDefault,
  };

  static Pokemon _decodePokemon(Map<String, Object?> j) => Pokemon(
    id: j['id'] as int? ?? 0,
    name: j['name'] as String? ?? '',
    height: 0,
    weight: 0,
    types: [
      for (final (i, name) in (j['types'] as List? ?? const []).indexed)
        PokemonType(
          slot: i + 1,
          type: TypeInfo(name: name as String, url: ''),
        ),
    ],
    abilities: const <PokemonAbility>[],
    stats: const PokemonStats(
      hp: 0,
      attack: 0,
      defense: 0,
      specialAttack: 0,
      specialDefense: 0,
      speed: 0,
    ),
    sprites: PokemonSprites(
      frontDefault: j['sprite'] as String?,
      other: PokemonOtherSprites(
        officialArtwork: OfficialArtwork(frontDefault: j['artwork'] as String?),
      ),
    ),
    speciesName: j['name'] as String? ?? '',
    speciesUrl: '',
  );
}
