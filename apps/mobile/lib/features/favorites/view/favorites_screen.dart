import 'package:app_shared/features/pokemon_favorites/bloc/pokemon_favorites_bloc.dart';
import 'package:app_shared/features/pokemon_favorites/bloc/pokemon_favorites_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_kit_core/base_bloc/base_bloc_view.dart';
import 'package:flutter_kit_ui/extensions/context_ext.dart';
import 'package:flutter_kit_ui/typography/app_text_style.dart';

import '../../../core/localization/localization_extension.dart';
import '../../pokemon_favorites/view/favorites_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseBlocView<PokemonFavoritesBloc, PokemonFavoritesState>(
      create: () => PokemonFavoritesBloc.create(),
      loadingOverlay: const SizedBox.shrink(),
      builder: (context, pokemonState, pokemonBloc) {
        return Scaffold(
          backgroundColor: context.appColors.background,
          appBar: AppBar(
            title: Text(
              context.translations.favorites.title,
              style: context.textStyle.title18Bold,
            ),
            automaticallyImplyLeading: false,
            actions: [
              if (pokemonState.favorites.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  tooltip: context.translations.favorites.clearTooltip,
                  onPressed: () => _showClearAllDialog(context, pokemonBloc),
                ),
            ],
          ),
          body: PokemonFavoritesTab(state: pokemonState, bloc: pokemonBloc),
        );
      },
    );
  }

  Future<void> _showClearAllDialog(
    BuildContext context,
    PokemonFavoritesBloc bloc,
  ) {
    final t = context.translations;
    return showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t.favorites.clearTitle),
        content: Text(t.favorites.clearConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(t.common.cancel),
          ),
          TextButton(
            onPressed: () {
              bloc.add(PokemonFavoritesClearAll());
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(t.favorites.clearSuccess),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(t.favorites.clearButton),
          ),
        ],
      ),
    );
  }
}
