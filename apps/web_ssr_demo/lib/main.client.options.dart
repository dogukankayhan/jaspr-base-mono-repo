// dart format off
// ignore_for_file: type=lint

// GENERATED FILE, DO NOT MODIFY
// Generated with jaspr_builder

import 'package:jaspr/client.dart';

import 'package:flutter_base_kit_web_ssr_demo/codec/home_seed.dart'
    as _home_seed;
import 'package:flutter_base_kit_web_ssr_demo/islands/favorite_button.dart'
    deferred as _favorite_button;
import 'package:flutter_base_kit_web_ssr_demo/islands/favorites_island.dart'
    deferred as _favorites_island;
import 'package:flutter_base_kit_web_ssr_demo/islands/pokemon_home_island.dart'
    deferred as _pokemon_home_island;

/// Default [ClientOptions] for use with your Jaspr project.
///
/// Use this to initialize Jaspr **before** calling [runApp].
///
/// Example:
/// ```dart
/// import 'main.client.options.dart';
///
/// void main() {
///   Jaspr.initializeApp(
///     options: defaultClientOptions,
///   );
///
///   runApp(...);
/// }
/// ```
ClientOptions get defaultClientOptions => ClientOptions(
  clients: {
    'favorite_button': ClientLoader(
      (p) => _favorite_button.FavoriteButton(pokemonId: p['pokemonId'] as int),
      loader: _favorite_button.loadLibrary,
    ),
    'favorites_island': ClientLoader(
      (p) => _favorites_island.FavoritesIsland(),
      loader: _favorites_island.loadLibrary,
    ),
    'pokemon_home_island': ClientLoader(
      (p) => _pokemon_home_island.PokemonHomeIsland(
        seed: _home_seed.HomeSeed.fromJson(p['seed'] as Map<String, Object?>),
      ),
      loader: _pokemon_home_island.loadLibrary,
    ),
  },
);
