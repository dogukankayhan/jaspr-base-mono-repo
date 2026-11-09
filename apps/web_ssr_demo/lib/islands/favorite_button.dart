import 'dart:async';

import 'package:app_shared/domain/repository/favorites_repository.dart';
import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:kit_network/core/di/locator.dart';

/// The only interactive part of the detail page.
///
/// Favorites are per-visitor (stored in this browser), so the server can't
/// know them: it renders "☆ Add to favorites", and the browser corrects it
/// right after hydration from the shared FavoritesRepository.
@client
class FavoriteButton extends StatefulComponent {
  const FavoriteButton({required this.pokemonId, super.key});

  final int pokemonId;

  @override
  State<FavoriteButton> createState() => _FavoriteButtonState();

  @css
  static List<StyleRule> get styles => [
    css('.fav-btn').styles(
      raw: {
        'padding': '8px 16px',
        'border': '2px solid var(--kit-gold)',
        'border-radius': '999px',
        'background': 'transparent',
        'font-weight': '600',
        'cursor': 'pointer',
      },
    ),
    css('.fav-btn.is-fav').styles(raw: {'background': 'var(--kit-gold)'}),
  ];
}

class _FavoriteButtonState extends State<FavoriteButton> {
  bool _isFavorite = false;
  StreamSubscription<Set<int>>? _sub;

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) return; // server: no per-user data
    final repo = getIt<FavoritesRepository>();
    _sub = repo.favoriteIdsStream.listen((ids) {
      if (mounted) {
        setState(() => _isFavorite = ids.contains(component.pokemonId));
      }
    });
    repo.isFavorite(component.pokemonId).then((v) {
      if (mounted) setState(() => _isFavorite = v);
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Component build(BuildContext context) {
    return button(
      classes: _isFavorite ? 'fav-btn is-fav' : 'fav-btn',
      attributes: const {'type': 'button'},
      onClick: () =>
          getIt<FavoritesRepository>().toggleFavorite(component.pokemonId),
      [Component.text(_isFavorite ? '★ Favorite' : '☆ Add to favorites')],
    );
  }
}
