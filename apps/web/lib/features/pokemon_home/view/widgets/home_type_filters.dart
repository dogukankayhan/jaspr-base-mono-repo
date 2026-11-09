part of '../pokemon_home_page.dart';

/// Type quick-filters from the shared catalog. Clicking the active one clears it.
class _HomeTypeFilters extends StatelessComponent {
  const _HomeTypeFilters({
    required this.selectedType,
    required this.onSelected,
  });

  final String? selectedType;
  final void Function(String type) onSelected;

  @override
  Component build(BuildContext context) {
    return div(
      classes: 'type-filters',
      attributes: const {'role': 'group', 'aria-label': 'Filter by type'},
      [
        for (final type in PokemonTypes.filterable)
          button(
            classes: type == selectedType ? 'type-chip is-active' : 'type-chip',
            styles: Styles(
              raw: {'--chip-color': cssHex(PokemonTypes.colorOf(type))},
            ),
            attributes: {
              'type': 'button',
              'aria-pressed': '${type == selectedType}',
            },
            onClick: () => onSelected(type),
            [Component.text(type.capitalize)],
          ),
      ],
    );
  }

  static List<StyleRule> get styles => [
    css('.type-filters').styles(
      raw: {
        'display': 'flex',
        'gap': '8px',
        'overflow-x': 'auto',
        'padding-bottom': '4px',
      },
    ),
    css('.type-chip').styles(
      raw: {
        'flex': '0 0 auto',
        'padding': '6px 14px',
        'border': '2px solid var(--chip-color)',
        'border-radius': '999px',
        'background': 'white',
        'color': 'var(--kit-textBlack)',
        'font-weight': '600',
        'cursor': 'pointer',
      },
    ),
    css(
      '.type-chip.is-active',
    ).styles(raw: {'background': 'var(--chip-color)', 'color': 'white'}),
  ];
}
