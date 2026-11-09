import 'package:app_shared/domain/constants/pokemon_types.dart';
import 'package:app_shared/domain/entity/pokemon_entity.dart';
import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:kit_core/utils/extensions/string_ext.dart';
import 'package:kit_design_tokens/kit_design_tokens.dart';

/// Pokémon card used by the home list and the favorites page — shared, so it
/// is a standalone component rather than `part of` either page (Pattern 9).
///
/// [onToggleFavorite] is null while the page is rendered on the server (the
/// button is inert HTML until the island hydrates).
class PokemonCard extends StatelessComponent {
  const PokemonCard({
    required this.pokemon,
    required this.isFavorite,
    required this.onToggleFavorite,
    super.key,
  });

  final Pokemon pokemon;
  final bool isFavorite;
  final void Function()? onToggleFavorite;

  @override
  Component build(BuildContext context) {
    final p = pokemon;
    final artwork =
        p.sprites.other?.officialArtwork?.frontDefault ??
        p.sprites.frontDefault;
    final mainType = p.types.isEmpty ? 'normal' : p.types.first.type.name;

    return article(
      classes: 'card',
      styles: Styles(
        raw: {'--card-color': cssHex(PokemonTypes.colorOf(mainType))},
      ),
      [
        // A plain link: in multi-page mode the server renders the detail page.
        a(href: '/pokemon/${p.id}', classes: 'card-link', [
          if (artwork != null)
            img(
              src: artwork,
              alt: p.name,
              loading: MediaLoading.lazy,
              // Intrinsic size of PokeAPI's official artwork — reserves the
              // space before the image loads (no layout shift / CLS).
              width: 475,
              height: 475,
              attributes: const {'decoding': 'async'},
            ),
          span(classes: 'card-id', [
            Component.text('#${p.id.toString().padLeft(3, '0')}'),
          ]),
          // h2: cards sit directly under the page's h1 (no skipped level).
          h2([Component.text(p.name.capitalize)]),
        ]),
        // Sibling of the link, not inside it: no nested interactive content.
        button(
          classes: isFavorite ? 'fav is-fav' : 'fav',
          attributes: {
            'type': 'button',
            'aria-pressed': '$isFavorite',
            'aria-label': isFavorite
                ? 'Remove ${p.name} from favorites'
                : 'Add ${p.name} to favorites',
          },
          onClick: onToggleFavorite,
          [Component.text(isFavorite ? '★' : '☆')],
        ),
      ],
    );
  }

  @css
  static List<StyleRule> get styles => [
    css('.grid').styles(
      raw: {
        'display': 'grid',
        'grid-template-columns': 'repeat(auto-fill, minmax(170px, 1fr))',
        'gap': '16px',
      },
    ),
    css('.card').styles(
      raw: {
        'position': 'relative',
        'border-radius': '20px',
        'background':
            'color-mix(in srgb, var(--card-color, var(--kit-gray-20)) 22%, white)',
      },
    ),
    css('.card-link').styles(
      raw: {
        'display': 'grid',
        'gap': '4px',
        'padding': '12px',
        'color': 'inherit',
        'text-decoration': 'none',
      },
    ),
    css('.card-link img').styles(
      raw: {
        'width': '100%',
        'height': 'auto',
        'aspect-ratio': '1',
        'object-fit': 'contain',
      },
    ),
    css('.card-link h2').styles(raw: {'margin': '0', 'font-size': '1.15rem'}),
    css(
      '.card-id',
    ).styles(raw: {'font-size': '0.8rem', 'color': 'var(--kit-gray-50)'}),
    css('.fav').styles(
      raw: {
        'position': 'absolute',
        'top': '8px',
        'right': '8px',
        'width': '36px',
        'height': '36px',
        'border': 'none',
        'border-radius': '50%',
        'background': 'rgba(255,255,255,.85)',
        'font-size': '1.2rem',
        'cursor': 'pointer',
      },
    ),
    css('.fav.is-fav').styles(raw: {'color': 'var(--kit-gold)'}),
  ];
}
