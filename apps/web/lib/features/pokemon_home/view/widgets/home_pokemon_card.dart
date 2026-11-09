part of '../pokemon_home_page.dart';

/// One Pokémon in the grid. The favorite button is a *sibling* of the link
/// (not inside it): interactive content inside `<a>` is invalid HTML and its
/// click would also navigate.
class _HomePokemonCard extends StatelessComponent {
  const _HomePokemonCard({
    required this.pokemon,
    required this.isFavorite,
    required this.onToggleFavorite,
    super.key,
  });

  final Pokemon pokemon;
  final bool isFavorite;
  final void Function() onToggleFavorite;

  @override
  Component build(BuildContext context) {
    final artwork =
        pokemon.sprites.other?.officialArtwork?.frontDefault ??
        pokemon.sprites.frontDefault;
    final mainType = pokemon.types.isEmpty
        ? 'normal'
        : pokemon.types.first.type.name;

    return article(
      classes: 'poke-card',
      styles: Styles(
        raw: {'--card-color': cssHex(PokemonTypes.colorOf(mainType))},
      ),
      [
        PokemonDetailNavigator.link(
          id: pokemon.id,
          classes: 'poke-card-link',
          child: div(classes: 'poke-card-body', [
            if (artwork != null)
              img(src: artwork, alt: pokemon.name, loading: MediaLoading.lazy),
            span(classes: 'poke-card-id', [
              Component.text('#${pokemon.id.toString().padLeft(3, '0')}'),
            ]),
            h3(classes: 'poke-card-name', [
              Component.text(pokemon.name.capitalize),
            ]),
            div(classes: 'poke-card-types', [
              for (final t in pokemon.types)
                span(
                  classes: 'poke-card-type',
                  styles: Styles(
                    raw: {
                      'background': cssHex(PokemonTypes.colorOf(t.type.name)),
                    },
                  ),
                  [Component.text(t.type.name)],
                ),
            ]),
          ]),
        ),
        button(
          classes: isFavorite ? 'poke-fav is-fav' : 'poke-fav',
          attributes: {
            'type': 'button',
            'aria-pressed': '$isFavorite',
            'aria-label': isFavorite
                ? 'Remove ${pokemon.name} from favorites'
                : 'Add ${pokemon.name} to favorites',
          },
          onClick: onToggleFavorite,
          [Component.text(isFavorite ? '★' : '☆')],
        ),
      ],
    );
  }

  static List<StyleRule> get styles => [
    css('.poke-card').styles(
      raw: {
        'position': 'relative',
        'border-radius': '20px',
        'background':
            'color-mix(in srgb, var(--card-color, var(--kit-gray-20)) 22%, white)',
        'transition': 'transform .15s ease, box-shadow .15s ease',
      },
    ),
    css('.poke-card:hover').styles(
      raw: {
        'transform': 'translateY(-3px)',
        'box-shadow': '0 8px 20px rgba(0,0,0,.08)',
      },
    ),
    css('.poke-card.is-skeleton').styles(
      raw: {
        'aspect-ratio': '3 / 4',
        'background': 'var(--kit-gray-10)',
        'animation': 'kit-pulse 1.2s ease-in-out infinite',
      },
    ),
    css.keyframes('kit-pulse', {
      '50%': const Styles(raw: {'opacity': '0.5'}),
    }),
    css('.poke-card-link').styles(
      raw: {'display': 'block', 'color': 'inherit', 'text-decoration': 'none'},
    ),
    css('.poke-card-link:focus-visible').styles(
      raw: {'outline': '3px solid var(--kit-primary)', 'border-radius': '20px'},
    ),
    css(
      '.poke-card-body',
    ).styles(raw: {'display': 'grid', 'gap': '4px', 'padding': '12px'}),
    css('.poke-card-body img').styles(
      raw: {'width': '100%', 'aspect-ratio': '1', 'object-fit': 'contain'},
    ),
    css(
      '.poke-card-id',
    ).styles(raw: {'font-size': '0.8rem', 'color': 'var(--kit-gray-50)'}),
    css('.poke-card-name').styles(raw: {'margin': '0', 'font-size': '1.05rem'}),
    css(
      '.poke-card-types',
    ).styles(raw: {'display': 'flex', 'gap': '6px', 'flex-wrap': 'wrap'}),
    css('.poke-card-type').styles(
      raw: {
        'padding': '2px 10px',
        'border-radius': '999px',
        'color': 'white',
        'font-size': '0.75rem',
        'text-transform': 'capitalize',
      },
    ),
    css('.poke-fav').styles(
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
        'color': 'var(--kit-gray-50)',
      },
    ),
    css('.poke-fav.is-fav').styles(raw: {'color': 'var(--kit-gold)'}),
  ];
}
