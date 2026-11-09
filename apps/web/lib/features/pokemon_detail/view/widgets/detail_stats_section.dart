part of '../pokemon_detail_page.dart';

/// Base stats as horizontal bars. Screen-private (Pattern 9).
class _DetailStatsSection extends StatelessComponent {
  const _DetailStatsSection({required this.pokemon});

  final Pokemon pokemon;

  /// The highest base stat any Pokémon has — used to scale the bars.
  static const _maxStat = 255;

  @override
  Component build(BuildContext context) {
    final s = pokemon.stats;
    final rows = [
      ('HP', s.hp),
      ('Attack', s.attack),
      ('Defense', s.defense),
      ('Sp. Atk', s.specialAttack),
      ('Sp. Def', s.specialDefense),
      ('Speed', s.speed),
    ];

    return section([
      h2([Component.text('Base stats')]),
      div(classes: 'stats', [
        for (final (label, value) in rows) ...[
          span(classes: 'stats-label', [Component.text(label)]),
          span(classes: 'stats-value', [Component.text('$value')]),
          div(classes: 'stats-track', [
            div(
              classes: 'stats-bar',
              styles: Styles(
                raw: {'width': '${(value / _maxStat * 100).clamp(0, 100)}%'},
              ),
              [],
            ),
          ]),
        ],
      ]),
    ]);
  }

  /// Collected by [PokemonDetailPage.styles] — jaspr_builder can't reach
  /// private classes directly.
  static List<StyleRule> get styles => [
    css('.stats').styles(
      raw: {
        'display': 'grid',
        'grid-template-columns': '80px 40px 1fr',
        'gap': '8px 12px',
        'align-items': 'center',
      },
    ),
    css('.stats-label').styles(raw: {'color': 'var(--kit-gray-50)'}),
    css(
      '.stats-value',
    ).styles(raw: {'font-weight': '700', 'text-align': 'right'}),
    css('.stats-track').styles(
      raw: {
        'height': '8px',
        'border-radius': '4px',
        'background': 'var(--kit-gray-10)',
      },
    ),
    css('.stats-bar').styles(
      raw: {
        'height': '100%',
        'border-radius': '4px',
        'background': 'var(--kit-primary)',
      },
    ),
  ];
}
