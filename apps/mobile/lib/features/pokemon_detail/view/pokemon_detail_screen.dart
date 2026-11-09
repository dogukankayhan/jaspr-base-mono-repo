import 'package:app_shared/domain/entity/evolution_chain_entity.dart';
import 'package:app_shared/domain/entity/pokemon_entity.dart';
import 'package:app_shared/domain/entity/pokemon_move_entity.dart';
import 'package:app_shared/domain/entity/pokemon_species_entity.dart';
import 'package:app_shared/features/pokemon_detail/bloc/detail_bloc.dart';
import 'package:app_shared/features/pokemon_detail/bloc/detail_state.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_base_kit/core/localization/localization_extension.dart';
import 'package:flutter_base_kit/features/pokemon_evolution_simulator/evolution_simulator_navigator.dart';
import 'package:flutter_kit_core/base_bloc/base_bloc_view.dart';

import '../../../../core/utils/pokemon_utils.dart';
import '../navigator/pokemon_detail_navigator.dart';

part 'widgets/pokemon_about_tab.dart';
part 'widgets/pokemon_evolution_tab.dart';
part 'widgets/pokemon_moves_tab.dart';
part 'widgets/pokemon_stats_tab.dart';

class PokemonDetailScreen extends StatefulWidget {
  final int pokemonId;
  final Pokemon? pokemon;
  final String? activeKey;

  const PokemonDetailScreen({
    super.key,
    required this.pokemonId,
    this.pokemon,
    this.activeKey,
  });

  @override
  State<PokemonDetailScreen> createState() => _PokemonDetailScreenState();
}

class _PokemonDetailScreenState extends State<PokemonDetailScreen> {
  bool _isTransitionComplete = false;
  Animation<double>? _routeAnimation;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final route = ModalRoute.of(context);
      if (route?.animation != null) {
        _routeAnimation = route!.animation;
        if (_routeAnimation!.isCompleted) {
          setState(() => _isTransitionComplete = true);
        } else {
          _routeAnimation!.addStatusListener(_onAnimationStatusChanged);
        }
      } else {
        setState(() => _isTransitionComplete = true);
      }
    });
  }

  void _onAnimationStatusChanged(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      _routeAnimation?.removeStatusListener(_onAnimationStatusChanged);
      if (mounted) {
        setState(() => _isTransitionComplete = true);
      }
    }
  }

  @override
  void dispose() {
    _routeAnimation?.removeStatusListener(_onAnimationStatusChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String key = widget.activeKey ?? 'pokemon_detail_${widget.pokemonId}';

    return BaseBlocView<DetailBloc, DetailState>(
      activeKey: key,
      onInit: (bloc) => bloc.add(DetailLoad(widget.pokemonId)),
      create: () => DetailBloc.create(initialPokemon: widget.pokemon),
      builder: (context, state, bloc) {
        if (state.pokemon == null && state.errorMessage == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (state.errorMessage != null && state.pokemon == null) {
          return Scaffold(
            appBar: AppBar(
              title: Text(context.translations.pokemon.detail.error),
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(state.errorMessage!, textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => bloc.add(DetailLoad(widget.pokemonId)),
                    child: Text(context.translations.common.retry),
                  ),
                ],
              ),
            ),
          );
        }

        final pokemon = state.pokemon!;
        final primaryColor = PokemonUtils.getTypeColor(
          pokemon.types.first.type.name,
        );

        return DefaultTabController(
          length: 4,
          child: Scaffold(
            body: NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) => [
                SliverOverlapAbsorber(
                  handle: NestedScrollView.sliverOverlapAbsorberHandleFor(
                    context,
                  ),
                  sliver: SliverAppBar(
                    expandedHeight: 400,
                    pinned: true,
                    backgroundColor: primaryColor,
                    elevation: 0,
                    leading: const BackButton(color: Colors.white),
                    actions: [
                      IconButton(
                        icon: Icon(
                          state.isFavorite
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: Colors.white,
                        ),
                        onPressed: () => bloc.add(DetailToggleFavorite()),
                      ),
                    ],
                    flexibleSpace: LayoutBuilder(
                      builder: (context, constraints) {
                        final top = constraints.biggest.height;
                        final collapsedHeight =
                            MediaQuery.of(context).padding.top +
                            kToolbarHeight +
                            48;
                        final isCollapsed = top <= collapsedHeight;

                        return FlexibleSpaceBar(
                          centerTitle: true,
                          titlePadding: const EdgeInsets.only(bottom: 56),
                          title: isCollapsed
                              ? Text(
                                  PokemonUtils.capitalize(pokemon.name),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                )
                              : null,
                          background: Stack(
                            children: [
                              Positioned(
                                right: -50,
                                bottom: 0,
                                child: Icon(
                                  Icons.catching_pokemon,
                                  size: 200,
                                  color: Colors.white.withAlpha(40),
                                ),
                              ),
                              SafeArea(
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                    left: 24,
                                    right: 24,
                                    top: 40,
                                    bottom: 8,
                                  ),
                                  child: Opacity(
                                    opacity:
                                        (top - collapsedHeight) /
                                                (320 - collapsedHeight) >
                                            0.5
                                        ? 1
                                        : 0,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              PokemonUtils.capitalize(
                                                pokemon.name,
                                              ),
                                              style: const TextStyle(
                                                fontSize: 32,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                bottom: 6,
                                              ),
                                              child: Text(
                                                '#${pokemon.id.toString().padLeft(3, '0')}',
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white.withAlpha(
                                                    180,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Wrap(
                                          spacing: 8,
                                          children: pokemon.types
                                              .map(
                                                (t) =>
                                                    _buildTypeTag(t.type.name),
                                              )
                                              .toList(),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 0,
                                right: 0,
                                bottom: 80,
                                child: Opacity(
                                  opacity:
                                      (top - collapsedHeight) /
                                              (320 - collapsedHeight) >
                                          0.2
                                      ? 1
                                      : 0,
                                  child: Hero(
                                    tag: 'pokemon-${pokemon.id}',
                                    child: CachedNetworkImage(
                                      imageUrl:
                                          pokemon
                                              .sprites
                                              .other
                                              ?.officialArtwork
                                              ?.frontDefault ??
                                          pokemon.sprites.frontDefault ??
                                          '',
                                      height: 200,
                                      fit: BoxFit.contain,
                                      memCacheHeight: 450,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    bottom: PreferredSize(
                      preferredSize: const Size.fromHeight(48),
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(32),
                            topRight: Radius.circular(32),
                          ),
                        ),
                        child: Builder(
                          builder: (context) {
                            final t = context.translations.pokemon.detail.tabs;
                            return TabBar(
                              labelColor: Colors.black,
                              unselectedLabelColor: Colors.grey,
                              indicatorColor: primaryColor,
                              indicatorWeight: 3,
                              tabs: [
                                Tab(text: t.about),
                                Tab(text: t.stats),
                                Tab(text: t.evolution),
                                Tab(text: t.moves),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ],
              body: _isTransitionComplete
                  ? TabBarView(
                      children: [
                        PokemonAboutTab(
                          key: const PageStorageKey('about'),
                          pokemon: pokemon,
                          species: state.species,
                        ),
                        PokemonStatsTab(
                          key: const PageStorageKey('stats'),
                          pokemon: pokemon,
                        ),
                        PokemonEvolutionTab(
                          key: const PageStorageKey('evolution'),
                          chain: state.evolutionChain,
                          isLoading: state.isEvolutionLoading,
                          currentPokemonId: pokemon.id,
                        ),
                        PokemonMovesTab(
                          key: const PageStorageKey('moves'),
                          pokemon: pokemon,
                        ),
                      ],
                    )
                  : const Center(child: CircularProgressIndicator.adaptive()),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTypeTag(String typeName) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(60),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        PokemonUtils.capitalize(typeName),
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
