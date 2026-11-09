part of '../pokemon_detail_screen.dart';

class PokemonEvolutionTab extends StatefulWidget {
  final EvolutionChain? chain;
  final bool isLoading;
  final int? currentPokemonId;

  const PokemonEvolutionTab({
    super.key,
    this.chain,
    this.isLoading = false,
    this.currentPokemonId,
  });

  @override
  State<PokemonEvolutionTab> createState() => _PokemonEvolutionTabState();
}

class _PokemonEvolutionTabState extends State<PokemonEvolutionTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (widget.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (widget.chain == null) {
      return Center(
        child: Text(
          context.translations.pokemon.detail.evolution.noData,
          style: const TextStyle(color: Colors.grey),
        ),
      );
    }

    final paths = widget.chain!.allPaths;

    return CustomScrollView(
      physics: const ClampingScrollPhysics(),
      slivers: [
        SliverOverlapInjector(
          handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
        ),
        SliverPadding(
          padding: const EdgeInsets.all(24),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    context.translations.pokemon.detail.evolution.chainTitle,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton.icon(
                    style: TextButton.styleFrom(
                      foregroundColor: Theme.of(context).primaryColor,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    icon: const Icon(Icons.analytics_outlined, size: 18),
                    label: Text(
                      context
                          .translations
                          .pokemon
                          .detail
                          .evolution
                          .simulatorButton,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      EvolutionSimulatorNavigator.show(
                        context,
                        chain: widget.chain!,
                        initialPokemonId: widget.currentPokemonId ?? 1,
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ...paths.map((path) => _buildEvolutionPath(context, path)),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildEvolutionPath(BuildContext context, List<EvolutionNode> path) {
    if (path.length <= 1) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.grey.withAlpha(10),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Text(
          'Bu Pokémon evrimleşmez.',
          textAlign: TextAlign.center,
          style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
        ),
      );
    }

    final List<Widget> children = [];
    for (int i = 0; i < path.length; i++) {
      children.add(_buildEvolutionNode(context, path[i]));
      if (i < path.length - 1) {
        children.add(
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ),
        );
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.withAlpha(40)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: children,
        ),
      ),
    );
  }

  Widget _buildEvolutionNode(BuildContext context, EvolutionNode node) {
    return InkWell(
      onTap: () {
        PokemonDetailNavigator.show(context, pokemonId: node.speciesId);
      },
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.grey.withAlpha(20),
              shape: BoxShape.circle,
            ),
            child: CachedNetworkImage(
              imageUrl:
                  'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/${node.speciesId}.png',
              memCacheWidth: 160,
              memCacheHeight: 160,
              placeholder: (context, url) =>
                  const Icon(Icons.catching_pokemon, color: Colors.grey),
              errorWidget: (context, url, e) => const Icon(Icons.error),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            PokemonUtils.capitalize(node.speciesName),
            style: const TextStyle(
              fontWeight: FontWeight.normal,
              fontSize: 12,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
