import 'dart:ui';

import 'package:app_shared/domain/entity/evolution_chain_entity.dart';
import 'package:app_shared/domain/entity/pokemon_entity.dart';
import 'package:app_shared/features/pokemon_evolution_simulator/bloc/evolution_simulator_bloc.dart';
import 'package:app_shared/features/pokemon_evolution_simulator/bloc/evolution_simulator_event.dart';
import 'package:app_shared/features/pokemon_evolution_simulator/bloc/evolution_simulator_state.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_base_kit/core/utils/pokemon_utils.dart';
import 'package:flutter_kit_core/base_bloc/base_bloc_view.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class EvolutionSimulatorScreen extends StatelessWidget {
  final EvolutionChain chain;
  final int initialPokemonId;

  const EvolutionSimulatorScreen({
    super.key,
    required this.chain,
    required this.initialPokemonId,
  });

  @override
  Widget build(BuildContext context) {
    return BaseBlocView<EvolutionSimulatorBloc, EvolutionSimulatorState>(
      create: () => EvolutionSimulatorBloc.create(),
      onInit: (bloc) => bloc.add(
        EvolutionSimulatorStarted(
          chain: chain,
          initialPokemonId: initialPokemonId,
        ),
      ),
      loadingOverlay: const SizedBox.shrink(),
      builder: (context, state, bloc) {
        if (state.isLoading) {
          return const Scaffold(
            backgroundColor: Color(0xFF121212),
            body: Center(
              child: SpinKitDoubleBounce(color: Color(0xFF3B82F6), size: 80.0),
            ),
          );
        }

        if (state.errorMessage != null) {
          return Scaffold(
            backgroundColor: const Color(0xFF121212),
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: const BackButton(color: Colors.white),
            ),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.redAccent,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      state.errorMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3B82F6),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                      onPressed: () => bloc.add(
                        EvolutionSimulatorStarted(
                          chain: chain,
                          initialPokemonId: initialPokemonId,
                        ),
                      ),
                      child: const Text(
                        'Tekrar Dene',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        final currentPokemon = state.currentPokemon;
        if (currentPokemon == null) {
          return const Scaffold(
            backgroundColor: Color(0xFF121212),
            body: Center(
              child: SpinKitDoubleBounce(color: Color(0xFF3B82F6), size: 80.0),
            ),
          );
        }

        final primaryType = currentPokemon.types.first.type.name;
        final typeColor = PokemonUtils.getTypeColor(primaryType);

        return Scaffold(
          backgroundColor: const Color(0xFF0F0F12),
          body: Stack(
            children: [
              // 1. Dynamic background gradient based on Pokemon type
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      typeColor.withValues(alpha: 0.35),
                      const Color(0xFF0F0F12),
                    ],
                  ),
                ),
              ),

              // 2. Main Scrollable Content
              SafeArea(
                top: false,
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    SliverAppBar(
                      pinned: true,
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      scrolledUnderElevation: 0,
                      leading: IconButton(
                        icon: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Colors.white,
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      title: const Text(
                        'EVRİM SİMÜLATÖRÜ',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                          letterSpacing: 1.5,
                        ),
                      ),
                      centerTitle: true,
                      flexibleSpace: ClipRect(
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            color: const Color(
                              0xFF0F0F12,
                            ).withValues(alpha: 0.5),
                          ),
                        ),
                      ),
                    ),

                    // Pokemon Sprite / Banner
                    SliverToBoxAdapter(
                      child: _buildPokemonBanner(currentPokemon, typeColor),
                    ),

                    // Evolution Chain Map (Visualizer)
                    SliverToBoxAdapter(
                      child: _buildEvolutionChainSection(state, bloc),
                    ),

                    // Evolve Button CTA Section (Trigger evolution if level matches)
                    if (state.unlockedEvolutions.isNotEmpty)
                      SliverToBoxAdapter(
                        child: _buildEvolveCTASection(state, bloc, typeColor),
                      ),

                    // Level Slider & Stats Cards
                    SliverToBoxAdapter(
                      child: _buildStatsSimulationSection(
                        context,
                        state,
                        bloc,
                        typeColor,
                      ),
                    ),

                    const SliverToBoxAdapter(child: SizedBox(height: 32)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ─── Pokemon Sprite / Banner ───────────────────────────────────────────────
  Widget _buildPokemonBanner(Pokemon pokemon, Color themeColor) {
    final animUrl = PokemonUtils.animatedSpriteUrl(pokemon.id);
    final fallbackUrl =
        pokemon.sprites.other?.officialArtwork?.frontDefault ??
        pokemon.sprites.frontDefault;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        children: [
          // Sprite Container
          Container(
            height: 180,
            width: 180,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: themeColor.withValues(alpha: 0.3),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              transitionBuilder: (child, animation) => ScaleTransition(
                scale: animation,
                child: FadeTransition(opacity: animation, child: child),
              ),
              child: animUrl != null
                  ? Image.network(
                      animUrl,
                      key: ValueKey('anim-${pokemon.id}'),
                      height: 140,
                      width: 140,
                      fit: BoxFit.contain,
                      filterQuality: FilterQuality.none,
                      errorBuilder: (context, error, stackTrace) =>
                          _fallbackImage(fallbackUrl, pokemon.id),
                    )
                  : _fallbackImage(fallbackUrl, pokemon.id),
            ),
          ),
          const SizedBox(height: 12),
          // ID & Name
          Text(
            '#${pokemon.id.toString().padLeft(3, '0')}',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            PokemonUtils.capitalize(pokemon.name),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 8),
          // Types Row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: pokemon.types.map((type) {
              final typeName = type.type.name;
              final tColor = PokemonUtils.getTypeColor(typeName);
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 4.0),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: tColor.withValues(alpha: 0.25),
                  border: Border.all(
                    color: tColor.withValues(alpha: 0.5),
                    width: 1.0,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  PokemonUtils.capitalize(typeName),
                  style: TextStyle(
                    color: tColor,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _fallbackImage(String? url, int id) {
    if (url == null) {
      return Icon(
        Icons.catching_pokemon,
        size: 100,
        color: Colors.white.withValues(alpha: 0.5),
        key: ValueKey('fallback-$id'),
      );
    }
    return CachedNetworkImage(
      imageUrl: url,
      key: ValueKey('artwork-$id'),
      height: 140,
      width: 140,
      fit: BoxFit.contain,
    );
  }

  // ─── Evolution Chain Map ───────────────────────────────────────────────────
  Widget _buildEvolutionChainSection(
    EvolutionSimulatorState state,
    EvolutionSimulatorBloc bloc,
  ) {
    if (state.chain == null) return const SizedBox.shrink();

    final allPaths = state.chain!.allPaths;
    // Show only paths that contain the current pokemon; fall back to all paths
    final displayPaths = allPaths
        .where((p) => p.any((n) => n.speciesId == state.currentPokemonId))
        .toList();
    final paths = displayPaths.isEmpty ? allPaths : displayPaths;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
          child: Text(
            'EVRİM ŞEMASI',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ),
        for (final path in paths)
          SizedBox(
            height: 120,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              clipBehavior: Clip.none,
              itemCount: path.length,
              separatorBuilder: (_, index) {
                final nextNode = path[index + 1];
                String req = 'Lvl ?';
                if (nextNode.triggerName == 'level-up' &&
                    nextNode.minLevel != null) {
                  req = 'Lvl ${nextNode.minLevel}';
                } else if (nextNode.itemName != null) {
                  req = PokemonUtils.capitalize(
                    nextNode.itemName!.replaceAll('-', ' '),
                  );
                } else if (nextNode.triggerName == 'trade') {
                  req = 'Trade';
                }

                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      req,
                      style: const TextStyle(
                        color: Colors.white38,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Icon(
                      Icons.arrow_forward_rounded,
                      color: Colors.white24,
                      size: 20,
                    ),
                  ],
                );
              },
              itemBuilder: (context, index) {
                final node = path[index];
                final isCurrent = node.speciesId == state.currentPokemonId;
                final nodePokemon = state.pokemons[node.speciesId];

                return GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    bloc.add(EvolutionSimulatorPokemonSelected(node.speciesId));
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        width: 68,
                        height: 68,
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF1E1E24),
                          border: Border.all(
                            color: isCurrent
                                ? const Color(0xFF3B82F6)
                                : Colors.white10,
                            width: isCurrent ? 2.5 : 1.0,
                          ),
                          boxShadow: isCurrent
                              ? [
                                  BoxShadow(
                                    color: const Color(
                                      0xFF3B82F6,
                                    ).withValues(alpha: 0.3),
                                    blurRadius: 12,
                                    spreadRadius: 2,
                                  ),
                                ]
                              : null,
                        ),
                        child: Container(
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFF141417),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: nodePokemon != null
                              ? CachedNetworkImage(
                                  imageUrl:
                                      nodePokemon.sprites.frontDefault ?? '',
                                  fit: BoxFit.contain,
                                  errorWidget: (context, url, error) =>
                                      const Icon(
                                        Icons.catching_pokemon,
                                        color: Colors.grey,
                                      ),
                                )
                              : Image.network(
                                  'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/$kDefaultPokemonSpriteId.png',
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(
                                        Icons.catching_pokemon,
                                        color: Colors.grey,
                                      ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        PokemonUtils.capitalize(node.speciesName),
                        style: TextStyle(
                          color: isCurrent ? Colors.white : Colors.white38,
                          fontSize: 10,
                          fontWeight: isCurrent
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        const SizedBox(height: 16),
      ],
    );
  }

  // Fallback ID when details are loading
  static const int kDefaultPokemonSpriteId = 25; // Pikachu

  // ─── Evolve CTA Section ───────────────────────────────────────────────────
  Widget _buildEvolveCTASection(
    EvolutionSimulatorState state,
    EvolutionSimulatorBloc bloc,
    Color themeColor,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: state.unlockedEvolutions.map((node) {
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF10B981).withValues(alpha: 0.25),
                  blurRadius: 16,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Material(
              color: const Color(0xFF10B981),
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  HapticFeedback.heavyImpact();
                  bloc.add(
                    EvolutionSimulatorEvolve(targetSpeciesId: node.speciesId),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 14.0,
                    horizontal: 16.0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.auto_awesome_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'EVRİMLEŞTİR: ${node.speciesName.toUpperCase()}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ─── Level Slider & Stats Cards ───────────────────────────────────────────
  Widget _buildStatsSimulationSection(
    BuildContext context,
    EvolutionSimulatorState state,
    EvolutionSimulatorBloc bloc,
    Color themeColor,
  ) {
    final currentPokemon = state.currentPokemon!;
    final stats = currentPokemon.stats;

    // Stat calculators (Official formula)
    int calculateHP(int base, int level) {
      const int iv = 31; // Perfect IVs
      const int ev = 0;
      return (((2 * base + iv + (ev ~/ 4)) * level) ~/ 100) + level + 10;
    }

    int calculateOtherStat(int base, int level) {
      const int iv = 31; // Perfect IVs
      const int ev = 0;
      const double nature = 1.0; // Neutral Nature
      return (((((2 * base + iv + (ev ~/ 4)) * level) ~/ 100) + 5) * nature)
          .toInt();
    }

    final simulatedHP = calculateHP(stats.hp, state.currentLevel);
    final simulatedAtk = calculateOtherStat(stats.attack, state.currentLevel);
    final simulatedDef = calculateOtherStat(stats.defense, state.currentLevel);
    final simulatedSpAtk = calculateOtherStat(
      stats.specialAttack,
      state.currentLevel,
    );
    final simulatedSpDef = calculateOtherStat(
      stats.specialDefense,
      state.currentLevel,
    );
    final simulatedSpeed = calculateOtherStat(stats.speed, state.currentLevel);

    final simulatedTotal =
        simulatedHP +
        simulatedAtk +
        simulatedDef +
        simulatedSpAtk +
        simulatedSpDef +
        simulatedSpeed;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.08),
                width: 1.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Level Header row
                Row(
                  children: [
                    const Text(
                      'SİMÜLASYON SEVİYESİ',
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: themeColor.withValues(alpha: 0.15),
                        border: Border.all(
                          color: themeColor.withValues(alpha: 0.4),
                          width: 1.0,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Lvl ${state.currentLevel}',
                        style: TextStyle(
                          color: themeColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Slider control
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: themeColor,
                    inactiveTrackColor: Colors.white12,
                    thumbColor: Colors.white,
                    overlayColor: themeColor.withValues(alpha: 0.2),
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 10,
                    ),
                    trackHeight: 6,
                  ),
                  child: Slider(
                    value: state.currentLevel.toDouble(),
                    min: 1,
                    max: 100,
                    divisions: 99,
                    onChanged: (val) {
                      bloc.add(EvolutionSimulatorLevelChanged(val.toInt()));
                    },
                  ),
                ),
                const SizedBox(height: 24),

                // Stats Section Header
                const Row(
                  children: [
                    Text(
                      'SİMÜLE STATLAR (IV: 31 | EV: 0)',
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    Spacer(),
                    Text(
                      'DEĞER',
                      style: TextStyle(
                        color: Colors.white30,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const Divider(color: Colors.white10, height: 16),

                // Stat bar widgets
                _buildStatProgressRow(
                  'HP (Sağlık)',
                  simulatedHP,
                  stats.hp,
                  500,
                  themeColor,
                ),
                _buildStatProgressRow(
                  'Attack (Saldırı)',
                  simulatedAtk,
                  stats.attack,
                  400,
                  themeColor,
                ),
                _buildStatProgressRow(
                  'Defense (Savunma)',
                  simulatedDef,
                  stats.defense,
                  400,
                  themeColor,
                ),
                _buildStatProgressRow(
                  'Sp. Attack (Öz. Sal.)',
                  simulatedSpAtk,
                  stats.specialAttack,
                  400,
                  themeColor,
                ),
                _buildStatProgressRow(
                  'Sp. Defense (Öz. Sav.)',
                  simulatedSpDef,
                  stats.specialDefense,
                  400,
                  themeColor,
                ),
                _buildStatProgressRow(
                  'Speed (Hız)',
                  simulatedSpeed,
                  stats.speed,
                  400,
                  themeColor,
                ),

                const Divider(color: Colors.white10, height: 24),
                // Total stat row
                Row(
                  children: [
                    const Text(
                      'Total (Toplam Güç)',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      simulatedTotal.toString(),
                      style: TextStyle(
                        color: themeColor,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatProgressRow(
    String label,
    int value,
    int base,
    double maxPossible,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text(
                label,
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
              const SizedBox(width: 6),
              Text(
                '(Taban: $base)',
                style: const TextStyle(color: Colors.white30, fontSize: 10),
              ),
              const Spacer(),
              Text(
                value.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: value / maxPossible,
              backgroundColor: Colors.white10,
              valueColor: AlwaysStoppedAnimation(color),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }
}
