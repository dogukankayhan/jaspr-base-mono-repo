part of '../pokemon_home_page.dart';

/// Search field. Keystrokes are debounced by the bloc; Enter searches now.
class _HomeSearchBar extends StatelessComponent {
  const _HomeSearchBar({
    required this.text,
    required this.onChanged,
    required this.onSubmitted,
    required this.onClear,
  });

  final String text;
  final void Function(String value) onChanged;
  final void Function() onSubmitted;
  final void Function() onClear;

  @override
  Component build(BuildContext context) {
    return div(classes: 'search', [
      input<String>(
        type: InputType.search,
        value: text,
        classes: 'search-input',
        attributes: const {
          'placeholder': 'Search Pokémon by name…',
          'aria-label': 'Search Pokémon',
          'autocomplete': 'off',
          'spellcheck': 'false',
        },
        onInput: onChanged,
        events: {
          'keydown': (event) {
            if ((event as web.KeyboardEvent).key == 'Enter') onSubmitted();
          },
        },
      ),
      if (text.isNotEmpty)
        button(
          classes: 'search-clear',
          attributes: const {'aria-label': 'Clear search', 'type': 'button'},
          onClick: onClear,
          [Component.text('✕')],
        ),
    ]);
  }

  static List<StyleRule> get styles => [
    css('.search').styles(raw: {'position': 'relative'}),
    css('.search-input').styles(
      raw: {
        'width': '100%',
        'box-sizing': 'border-box',
        'padding': '12px 44px 12px 16px',
        'font-size': '1rem',
        'border': '2px solid var(--kit-gray-20)',
        'border-radius': '999px',
        'outline': 'none',
        'background': 'white',
      },
    ),
    css(
      '.search-input:focus',
    ).styles(raw: {'border-color': 'var(--kit-primary)'}),
    // Hide the browser's own clear button — we render a consistent one.
    css(
      '.search-input::-webkit-search-cancel-button',
    ).styles(raw: {'-webkit-appearance': 'none'}),
    css('.search-clear').styles(
      raw: {
        'position': 'absolute',
        'right': '8px',
        'top': '50%',
        'transform': 'translateY(-50%)',
        'width': '32px',
        'height': '32px',
        'border': 'none',
        'border-radius': '50%',
        'background': 'var(--kit-gray-10)',
        'cursor': 'pointer',
      },
    ),
  ];
}
