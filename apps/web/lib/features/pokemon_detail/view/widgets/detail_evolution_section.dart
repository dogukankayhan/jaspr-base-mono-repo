part of '../pokemon_detail_page.dart';

/// Evolution chain as linked steps. Screen-private (Pattern 9).
class _DetailEvolutionSection extends StatelessComponent {
  const _DetailEvolutionSection({
    required this.chain,
    required this.isLoading,
    required this.currentId,
  });

  final EvolutionChain? chain;
  final bool isLoading;
  final int currentId;

  @override
  Component build(BuildContext context) {
    final chain = this.chain;

    return section([
      h2([Component.text('Evolution')]),
      if (isLoading)
        p([Component.text('Loading…')])
      else if (chain == null)
        p([Component.text('No evolution data.')])
      else
        for (final path in chain.allPaths)
          div(classes: 'evo-path', [
            for (final (i, node) in path.indexed) ...[
              if (i > 0) span(classes: 'evo-arrow', [Component.text('→')]),
              if (node.speciesId == currentId)
                span(classes: 'evo-step is-current', [
                  Component.text(node.speciesName.capitalize),
                ])
              else
                PokemonDetailNavigator.link(
                  id: node.speciesId,
                  classes: 'evo-step',
                  child: Component.text(node.speciesName.capitalize),
                ),
            ],
          ]),
    ]);
  }

  /// Collected by [PokemonDetailPage.styles] — jaspr_builder can't reach
  /// private classes directly.
  static List<StyleRule> get styles => [
    css('.evo-path').styles(
      raw: {
        'display': 'flex',
        'flex-wrap': 'wrap',
        'align-items': 'center',
        'gap': '8px',
      },
    ),
    css('.evo-step').styles(
      raw: {
        'padding': '6px 14px',
        'border-radius': '999px',
        'background': 'var(--kit-secondary-10)',
        'text-decoration': 'none',
      },
    ),
    css('.evo-step.is-current').styles(
      raw: {
        'background': 'var(--kit-primary)',
        'color': 'var(--kit-onPrimary)',
      },
    ),
    css('.evo-arrow').styles(raw: {'color': 'var(--kit-gray-40)'}),
  ];
}
