import 'package:app_shared/domain/constants/pokemon_types.dart';
import 'package:app_shared/domain/entity/pokemon_entity.dart';
import 'package:app_shared/features/pokemon_home/bloc/pokemon_home_bloc.dart';
import 'package:app_shared/features/pokemon_home/bloc/pokemon_home_state.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_base_kit/core/localization/localization_extension.dart';
import 'package:flutter_base_kit/core/utils/pokemon_utils.dart';
import 'package:flutter_base_kit/features/pokemon_compare/compare_navigator.dart';
import 'package:flutter_base_kit/features/pokemon_detail/navigator/pokemon_detail_navigator.dart';
import 'package:flutter_kit_core/base_bloc/base_bloc_view.dart';
import 'package:flutter_kit_ui/colors/app_brand_colors.dart';
import 'package:flutter_kit_ui/extensions/context_ext.dart';
import 'package:flutter_kit_ui/typography/app_text_style.dart';

import '../widgets/pokemon_card.dart';

class PokemonHomeScreen extends StatelessWidget {
  const PokemonHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseBlocView<PokemonHomeBloc, PokemonHomeState>(
      create: () => PokemonHomeBloc.create()..add(PokemonHomeStarted()),
      loadingOverlay: const SizedBox.shrink(),
      builder: (context, state, bloc) =>
          _PokemonHomeView(state: state, bloc: bloc),
    );
  }
}

/// Owns the UI-only controllers the shared bloc must not hold (it also runs
/// on the web): scroll position and search field text.
class _PokemonHomeView extends StatefulWidget {
  const _PokemonHomeView({required this.state, required this.bloc});

  final PokemonHomeState state;
  final PokemonHomeBloc bloc;

  @override
  State<_PokemonHomeView> createState() => _PokemonHomeViewState();
}

class _PokemonHomeViewState extends State<_PokemonHomeView> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();

  PokemonHomeState get state => widget.state;
  PokemonHomeBloc get bloc => widget.bloc;

  @override
  void didUpdateWidget(_PokemonHomeView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (state.resultsVersion != oldWidget.state.resultsVersion) {
      // New result set (search / filter / clear) → back to the top.
      if (_scrollController.hasClients) _scrollController.jumpTo(0);
      // A type filter replaced the search → reflect that in the field.
      if (state.searchQuery == null && _searchController.text.isNotEmpty) {
        _searchController.clear();
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: context.translations.pokemon.searchHint,
            border: InputBorder.none,
            prefixIcon: const Icon(Icons.search),
            suffixIcon: ValueListenableBuilder<TextEditingValue>(
              valueListenable: _searchController,
              builder: (context, value, _) => value.text.isEmpty
                  ? const SizedBox.shrink()
                  : IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        bloc.add(PokemonHomeSearchQueryChanged(''));
                      },
                    ),
            ),
          ),
          onChanged: (query) => bloc.add(PokemonHomeSearchQueryChanged(query)),
          onSubmitted: (query) => bloc.add(PokemonHomeSearch(query)),
        ),
        actions: [
          IconButton(
            tooltip: state.isCompareMode ? 'Çıkış' : 'Karşılaştır',
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                state.isCompareMode
                    ? Icons.close
                    : Icons.compare_arrows_rounded,
                key: ValueKey(state.isCompareMode),
              ),
            ),
            onPressed: () => bloc.add(PokemonHomeCompareModeToggled()),
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              _TypeFilterChips(bloc: bloc, state: state),
              Expanded(
                child: _PokemonGrid(
                  state: state,
                  bloc: bloc,
                  scrollController: _scrollController,
                ),
              ),
            ],
          ),
          _ComparePanel(state: state, bloc: bloc),
        ],
      ),
    );
  }
}

// ─── Type Filter ─────────────────────────────────────────────────────────────

class _TypeFilterChips extends StatelessWidget {
  const _TypeFilterChips({required this.bloc, required this.state});

  final PokemonHomeBloc bloc;
  final PokemonHomeState state;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: PokemonTypes.filterable.length,
        itemBuilder: (context, index) {
          final type = PokemonTypes.filterable[index];
          final isSelected = state.selectedType == type;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(
                type.toUpperCase(),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : null,
                ),
              ),
              selected: isSelected,
              onSelected: (_) => bloc.add(PokemonHomeFilterByType(type)),
              selectedColor: PokemonUtils.getTypeColor(type),
              checkmarkColor: Colors.white,
            ),
          );
        },
      ),
    );
  }
}

// ─── Pokemon Grid ─────────────────────────────────────────────────────────────

class _PokemonGrid extends StatelessWidget {
  const _PokemonGrid({
    required this.state,
    required this.bloc,
    required this.scrollController,
  });

  final PokemonHomeState state;
  final PokemonHomeBloc bloc;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    if (state.isLoading && state.items.isEmpty) {
      return const Center(child: CircularProgressIndicator.adaptive());
    }

    if (state.errorMessage != null && state.items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              state.errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => bloc.add(PokemonHomeStarted()),
              child: Text(context.translations.common.retry),
            ),
          ],
        ),
      );
    }

    final double screenWidth = MediaQuery.sizeOf(context).width;
    // On smaller devices (e.g. iPhone SE with width <= 360), adjust aspect ratio to be slightly taller (e.g. 0.68)
    // to give text content and padding enough vertical room to avoid overlap/overflow.
    final double childAspectRatio = screenWidth <= 360 ? 0.68 : 0.75;

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollUpdateNotification) {
          final m = notification.metrics;
          bloc.add(
            PokemonHomeScrollPositionChanged(m.pixels, m.maxScrollExtent),
          );
        }
        return false;
      },
      child: RefreshIndicator(
        onRefresh: () async {
          bloc.add(PokemonHomeRefresh());
          await Future.delayed(const Duration(milliseconds: 500));
        },
        child: GridView.builder(
          controller: scrollController,
          // Extra bottom padding when compare panel is visible
          padding: EdgeInsets.fromLTRB(
            16,
            16,
            16,
            state.isCompareMode ? 96 : 16,
          ),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: childAspectRatio,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: state.hasMore
              ? state.items.length + 2
              : state.items.length,
          itemBuilder: (context, index) {
            if (index >= state.items.length) {
              return const Center(child: CircularProgressIndicator.adaptive());
            }
            final pokemon = state.items[index];
            final isSelected = state.isSelectedForCompare(pokemon.id);
            final canSelect = state.compareSelection.length < 5 || isSelected;

            return PokemonCard(
              key: ValueKey(pokemon.id),
              pokemon: pokemon,
              isFavorite: state.favoriteIds.contains(pokemon.id),
              isCompareMode: state.isCompareMode,
              isSelectedForCompare: isSelected,
              onTap: () => PokemonDetailNavigator.show(
                context,
                pokemonId: pokemon.id,
                pokemon: pokemon,
              ),
              onFavoriteToggle: () =>
                  bloc.add(PokemonHomeToggleFavorite(pokemon.id)),
              onCompareTap: canSelect
                  ? () => bloc.add(PokemonHomeCompareSelectionToggled(pokemon))
                  : null,
            );
          },
        ),
      ),
    );
  }
}

// ─── Compare Bottom Panel ─────────────────────────────────────────────────────

class _ComparePanel extends StatelessWidget {
  const _ComparePanel({required this.state, required this.bloc});

  final PokemonHomeState state;
  final PokemonHomeBloc bloc;

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeInOutCubic,
      bottom: state.isCompareMode ? 0 : -100,
      left: 0,
      right: 0,
      child: _ComparePanelContent(state: state, bloc: bloc),
    );
  }
}

class _ComparePanelContent extends StatelessWidget {
  const _ComparePanelContent({required this.state, required this.bloc});

  final PokemonHomeState state;
  final PokemonHomeBloc bloc;

  @override
  Widget build(BuildContext context) {
    final sel = state.compareSelection;
    final canCompare = sel.length > 1;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
        border: Border(
          top: BorderSide(color: Theme.of(context).dividerColor, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          for (var i = 0; i < 5; i++) ...[
            if (i > 0) const SizedBox(width: 4),
            _SlotAvatar(
              pokemon: i < sel.length ? sel[i] : null,
              label: '${i + 1}',
            ),
          ],
          const Spacer(),
          FilledButton(
            onPressed: canCompare
                ? () => CompareNavigator.show(context, pokemons: sel)
                : null,
            style: FilledButton.styleFrom(
              backgroundColor: AppBrandColors.primary,
              disabledBackgroundColor: context.appColors.disabledButtonBg,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: Text(
              'Karşılaştır',
              style: context.textStyle.paragraph14Bold.copyWith(
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SlotAvatar extends StatelessWidget {
  const _SlotAvatar({required this.pokemon, required this.label});

  final Pokemon? pokemon;
  final String label;

  @override
  Widget build(BuildContext context) {
    if (pokemon == null) {
      return Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Theme.of(context).dividerColor, width: 1.5),
        ),
        child: Center(
          child: Text(
            label,
            style: context.textStyle.paragraph12Bold.copyWith(
              color: context.appColors.textFieldUnFocusText,
            ),
          ),
        ),
      );
    }

    final imageUrl =
        pokemon!.sprites.other?.officialArtwork?.frontDefault ??
        pokemon!.sprites.frontDefault ??
        '';

    return Container(
      width: 44,
      height: 44,
      decoration: const BoxDecoration(shape: BoxShape.circle),
      clipBehavior: Clip.antiAlias,
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.contain,
        errorWidget: (_, _, _) => const Icon(Icons.catching_pokemon),
      ),
    );
  }
}
