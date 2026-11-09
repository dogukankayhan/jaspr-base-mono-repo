part of '../pokemon_detail_screen.dart';

class PokemonStatsTab extends StatefulWidget {
  final Pokemon pokemon;

  const PokemonStatsTab({super.key, required this.pokemon});

  @override
  State<PokemonStatsTab> createState() => _PokemonStatsTabState();
}

class _PokemonStatsTabState extends State<PokemonStatsTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final stats = widget.pokemon.stats;
    final t = context.translations.pokemon.detail.stats;
    final statsList = [
      (t.hp, stats.hp),
      (t.attack, stats.attack),
      (t.defense, stats.defense),
      (t.spAttack, stats.specialAttack),
      (t.spDefense, stats.specialDefense),
      (t.speed, stats.speed),
    ];

    final primaryColor = PokemonUtils.getTypeColor(
      widget.pokemon.types.first.type.name,
    );

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
              Text(
                t.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              ...statsList.map(
                (stat) => _buildStatRow(stat.$1, stat.$2, primaryColor),
              ),
              const SizedBox(height: 32),
              _buildTotalStats(
                context,
                statsList.fold(0, (sum, item) => sum + item.$2),
              ),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildStatRow(String label, int value, Color color) {
    final percentage = (value / 255).clamp(0.0, 1.0);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(label, style: const TextStyle(color: Colors.grey)),
          ),
          SizedBox(
            width: 35,
            child: Text(
              value.toString(),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              height: 8,
              decoration: BoxDecoration(
                color: color.withAlpha(25),
                borderRadius: BorderRadius.circular(10),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: percentage,
                child: Container(
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalStats(BuildContext context, int total) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.withAlpha(12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            context.translations.pokemon.detail.stats.total,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(
            total.toString(),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ],
      ),
    );
  }
}
