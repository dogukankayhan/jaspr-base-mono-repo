import 'package:app_shared/features/pokemon_favorites/bloc/pokemon_favorites_bloc.dart';
import 'package:app_shared/features/pokemon_favorites/bloc/pokemon_favorites_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_base_kit/core/localization/localization_extension.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../pokemon_home/widgets/pokemon_card.dart';
import '../navigator/favorites_navigator.dart';

class PokemonFavoritesTab extends StatelessWidget {
  const PokemonFavoritesTab({
    super.key,
    required this.state,
    required this.bloc,
  });

  final PokemonFavoritesState state;
  final PokemonFavoritesBloc bloc;

  @override
  Widget build(BuildContext context) {
    if (state.isLoading && state.favorites.isEmpty) {
      return const Center(child: CircularProgressIndicator.adaptive());
    }

    if (state.errorMessage != null && state.favorites.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            SizedBox(height: 16.h),
            Text(
              state.errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16.h),
            ElevatedButton(
              onPressed: () => bloc.add(PokemonFavoritesLoad()),
              child: Text(context.translations.common.retry),
            ),
          ],
        ),
      );
    }

    if (state.favorites.isEmpty) {
      return _EmptyView();
    }

    return RefreshIndicator(
      onRefresh: () async {
        bloc.add(PokemonFavoritesRefresh());
        await Future.delayed(const Duration(milliseconds: 500));
      },
      child: GridView.builder(
        padding: EdgeInsets.all(16.w),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.75,
          crossAxisSpacing: 16.w,
          mainAxisSpacing: 16.h,
        ),
        itemCount: state.favorites.length,
        itemBuilder: (context, index) {
          final pokemon = state.favorites[index];
          return Dismissible(
            key: Key('pokemon-${pokemon.id}'),
            direction: DismissDirection.endToStart,
            background: Container(
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(16.r),
              ),
              alignment: Alignment.centerRight,
              padding: EdgeInsets.only(right: 20.w),
              child: Icon(Icons.delete, color: Colors.white, size: 32.w),
            ),
            confirmDismiss: (_) => _showRemoveDialog(context, pokemon.name),
            onDismissed: (_) {
              bloc.add(PokemonFavoritesRemove(pokemon.id));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    context.translations.favorites.removeSuccess(
                      name: pokemon.name,
                    ),
                  ),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            child: PokemonCard(
              pokemon: pokemon,
              isFavorite: true,
              onFavoriteToggle: () =>
                  bloc.add(PokemonFavoritesRemove(pokemon.id)),
              onTap: () =>
                  PokemonFavoritesNavigator.showDetail(context, pokemon),
            ),
          );
        },
      ),
    );
  }

  Future<bool?> _showRemoveDialog(BuildContext context, String pokemonName) {
    final t = context.translations;
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t.favorites.removeTitle),
        content: Text(t.favorites.removeConfirm(name: pokemonName)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(t.common.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(t.favorites.removeButton),
          ),
        ],
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final t = context.translations;
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.favorite_border,
            size: 64.w,
            color: cs.onSurface.withValues(alpha: 0.25),
          ),
          SizedBox(height: 16.h),
          Text(
            t.favorites.emptyPokemon,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: cs.onSurface.withValues(alpha: 0.5),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            t.favorites.emptyPokemonHint,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: cs.onSurface.withValues(alpha: 0.35),
            ),
          ),
        ],
      ),
    );
  }
}
