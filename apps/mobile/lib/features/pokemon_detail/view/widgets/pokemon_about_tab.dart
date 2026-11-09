part of '../pokemon_detail_screen.dart';

class PokemonAboutTab extends StatefulWidget {
  final Pokemon pokemon;
  final PokemonSpecies? species;

  const PokemonAboutTab({super.key, required this.pokemon, this.species});

  @override
  State<PokemonAboutTab> createState() => _PokemonAboutTabState();
}

class _PokemonAboutTabState extends State<PokemonAboutTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
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
              if (widget.species != null) ...[
                Text(
                  widget.species!.description,
                  style: const TextStyle(height: 1.5, fontSize: 16),
                ),
                const SizedBox(height: 24),
              ],
              _buildInfoSection(context),
              const SizedBox(height: 24),
              _buildBreedingSection(context),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoSection(BuildContext context) {
    final t = context.translations.pokemon.detail.about;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(12),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildRow(
            t.species,
            widget.species?.genus ?? context.translations.common.unknown,
          ),
          _buildRow(
            t.height,
            '${(widget.pokemon.height / 10).toStringAsFixed(1)} m',
          ),
          _buildRow(
            t.weight,
            '${(widget.pokemon.weight / 10).toStringAsFixed(1)} kg',
          ),
          _buildRow(
            t.abilities,
            widget.pokemon.abilities
                .map((e) => PokemonUtils.capitalize(e.ability.name))
                .join(', '),
          ),
          if (widget.species?.habitat != null)
            _buildRow(
              t.habitat,
              PokemonUtils.capitalize(widget.species!.habitat!),
            ),
        ],
      ),
    );
  }

  Widget _buildBreedingSection(BuildContext context) {
    if (widget.species == null) return const SizedBox.shrink();
    final t = context.translations.pokemon.detail.about;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.translations.pokemon.detail.about.breeding,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        _buildRow(
          t.eggGroups,
          widget.species!.eggGroups
              .map((e) => PokemonUtils.capitalize(e))
              .join(', '),
        ),
        if (!widget.species!.isGenderless)
          _buildRow(
            t.gender,
            '',
            customValue: Row(
              children: [
                const Icon(Icons.male, color: Colors.blue, size: 18),
                Text(' ${widget.species!.malePercentage.toStringAsFixed(1)}%'),
                const SizedBox(width: 16),
                const Icon(Icons.female, color: Colors.pink, size: 18),
                Text(
                  ' ${widget.species!.femalePercentage.toStringAsFixed(1)}%',
                ),
              ],
            ),
          ),
        if (widget.species!.isGenderless) _buildRow(t.gender, t.genderless),
      ],
    );
  }

  Widget _buildRow(String label, String value, {Widget? customValue}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child:
                customValue ??
                Text(
                  value,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
          ),
        ],
      ),
    );
  }
}
