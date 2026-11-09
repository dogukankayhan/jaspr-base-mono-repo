// dart format off
// ignore_for_file: type=lint

// GENERATED FILE, DO NOT MODIFY
// Generated with jaspr_builder

import 'package:jaspr/server.dart';
import 'package:flutter_base_kit_web_ssr_demo/components/pokemon_card.dart'
    as _pokemon_card;
import 'package:flutter_base_kit_web_ssr_demo/islands/favorite_button.dart'
    as _favorite_button;
import 'package:flutter_base_kit_web_ssr_demo/islands/favorites_island.dart'
    as _favorites_island;
import 'package:flutter_base_kit_web_ssr_demo/islands/pokemon_home_island.dart'
    as _pokemon_home_island;
import 'package:flutter_base_kit_web_ssr_demo/pages/detail_server_page.dart'
    as _detail_server_page;
import 'package:flutter_base_kit_web_ssr_demo/app.dart' as _app;

/// Default [ServerOptions] for use with your Jaspr project.
///
/// Use this to initialize Jaspr **before** calling [runApp].
///
/// Example:
/// ```dart
/// import 'main.server.options.dart';
///
/// void main() {
///   Jaspr.initializeApp(
///     options: defaultServerOptions,
///   );
///
///   runApp(...);
/// }
/// ```
ServerOptions get defaultServerOptions => ServerOptions(
  clientId: 'main.client.dart.js',
  clients: {
    _favorite_button.FavoriteButton:
        ClientTarget<_favorite_button.FavoriteButton>(
          'favorite_button',
          params: __favorite_buttonFavoriteButton,
        ),
    _favorites_island.FavoritesIsland:
        ClientTarget<_favorites_island.FavoritesIsland>('favorites_island'),
    _pokemon_home_island.PokemonHomeIsland:
        ClientTarget<_pokemon_home_island.PokemonHomeIsland>(
          'pokemon_home_island',
          params: __pokemon_home_islandPokemonHomeIsland,
        ),
  },
  styles: () => [
    ..._app.App.styles,
    ..._pokemon_card.PokemonCard.styles,
    ..._favorite_button.FavoriteButton.styles,
    ..._favorites_island.FavoritesIsland.styles,
    ..._pokemon_home_island.PokemonHomeIsland.styles,
    ..._detail_server_page.DetailServerPage.styles,
  ],
);

Map<String, Object?> __favorite_buttonFavoriteButton(
  _favorite_button.FavoriteButton c,
) => {'pokemonId': c.pokemonId};
Map<String, Object?> __pokemon_home_islandPokemonHomeIsland(
  _pokemon_home_island.PokemonHomeIsland c,
) => {'seed': c.seed.toJson()};
