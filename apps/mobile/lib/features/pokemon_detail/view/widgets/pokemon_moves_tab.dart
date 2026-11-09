part of '../pokemon_detail_screen.dart';

class PokemonMovesTab extends StatefulWidget {
  final Pokemon pokemon;

  const PokemonMovesTab({super.key, required this.pokemon});

  @override
  State<PokemonMovesTab> createState() => _PokemonMovesTabState();
}

class _PokemonMovesTabState extends State<PokemonMovesTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  late final List<PokemonMove> _sortedMoves = _buildSortedMoves();

  List<PokemonMove> _buildSortedMoves() {
    final moves = List<PokemonMove>.from(widget.pokemon.moves);
    moves.sort((a, b) {
      final detailA = _getBestDetail(a.versionGroupDetails);
      final detailB = _getBestDetail(b.versionGroupDetails);
      final isLevelUpA = detailA.moveLearnMethod.name == 'level-up';
      final isLevelUpB = detailB.moveLearnMethod.name == 'level-up';
      if (isLevelUpA && !isLevelUpB) return -1;
      if (!isLevelUpA && isLevelUpB) return 1;
      if (isLevelUpA && isLevelUpB) {
        final lvlCompare = detailA.levelLearnedAt.compareTo(
          detailB.levelLearnedAt,
        );
        if (lvlCompare != 0) return lvlCompare;
      }
      return a.move.name.compareTo(b.move.name);
    });
    return moves;
  }

  static const _versionPriorities = [
    'scarlet-violet',
    'legends-arceus',
    'brilliant-diamond-shining-pearl',
    'sword-shield',
    'lets-go-pikachu-lets-go-eevee',
    'ultra-sun-ultra-moon',
    'sun-moon',
    'omega-ruby-alpha-sapphire',
    'x-y',
    'black-2-white-2',
    'black-white',
    'heartgold-soulsilver',
    'platinum',
    'diamond-pearl',
    'emerald',
    'firered-leafgreen',
    'ruby-sapphire',
    'crystal',
    'gold-silver',
    'yellow',
    'red-blue',
  ];

  VersionGroupDetail _getBestDetail(List<VersionGroupDetail> details) {
    if (details.isEmpty) {
      return const VersionGroupDetail(
        levelLearnedAt: 0,
        moveLearnMethod: MoveLearnMethod(name: 'unknown', url: ''),
        versionGroup: VersionGroup(name: 'unknown', url: ''),
      );
    }

    VersionGroupDetail? bestDetail;
    int bestPriority = -1;

    for (final detail in details) {
      final idx = _versionPriorities.indexOf(detail.versionGroup.name);
      final priority = idx == -1 ? _versionPriorities.length : idx;

      if (bestDetail == null || priority < bestPriority) {
        bestDetail = detail;
        bestPriority = priority;
      } else if (priority == bestPriority) {
        if (detail.moveLearnMethod.name == 'level-up' &&
            bestDetail.moveLearnMethod.name != 'level-up') {
          bestDetail = detail;
        }
      }
    }

    return bestDetail!;
  }

  // Returns (bgColor, borderColor, textColor) for a learn method badge.
  // Add a new case here when a new learn method is introduced.
  ({Color bg, Color border, Color text}) _learnMethodStyle(String method) {
    final base = switch (method) {
      'level-up' => Colors.blue,
      'machine' => Colors.purple,
      'egg' => Colors.amber,
      'tutor' => Colors.teal,
      _ => Colors.grey,
    };
    final isGrey = base == Colors.grey;
    return (
      bg: base.withValues(alpha: 0.15),
      border: base.withValues(alpha: 0.4),
      text: isGrey ? Colors.grey : Color.lerp(base, Colors.white, 0.4)!,
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return CustomScrollView(
      key: const PageStorageKey('moves'),
      physics: const ClampingScrollPhysics(),
      slivers: [
        SliverOverlapInjector(
          handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
        ),
        SliverPadding(
          padding: const EdgeInsets.all(24),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final move = _sortedMoves[index];
              final bestDetail = _getBestDetail(move.versionGroupDetails);
              final method = bestDetail.moveLearnMethod.name;

              return Column(
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      PokemonUtils.capitalize(
                        move.move.name.replaceAll('-', ' '),
                      ),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    trailing: Builder(
                      builder: (context) {
                        final style = _learnMethodStyle(method);
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: style.bg,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: style.border, width: 1.0),
                          ),
                          child: Text(
                            method == 'level-up'
                                ? 'LV. ${bestDetail.levelLearnedAt}'
                                : method == 'machine'
                                ? 'TM'
                                : method.toUpperCase(),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: style.text,
                            ),
                          ),
                        );
                      },
                    ),
                    subtitle: Text(
                      context.translations.pokemon.detail.moves.learnMethod(
                        method: method.replaceAll('-', ' '),
                      ),
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ),
                  if (index < _sortedMoves.length - 1) const Divider(),
                ],
              );
            }, childCount: _sortedMoves.length),
          ),
        ),
      ],
    );
  }
}
