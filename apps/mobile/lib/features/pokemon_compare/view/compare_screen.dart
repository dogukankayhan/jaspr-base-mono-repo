import 'package:app_shared/domain/entity/pokemon_entity.dart';
import 'package:app_shared/features/pokemon_compare/bloc/compare_bloc.dart';
import 'package:app_shared/features/pokemon_compare/bloc/compare_event.dart';
import 'package:app_shared/features/pokemon_compare/bloc/compare_state.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_base_kit/core/utils/pokemon_utils.dart';
import 'package:flutter_kit_core/base_bloc/base_bloc_view.dart';
import 'package:flutter_kit_ui/extensions/context_ext.dart';
import 'package:flutter_kit_ui/typography/app_text_style.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

part '../widgets/pokemon_stat_chart.dart';

class CompareScreen extends StatelessWidget {
  const CompareScreen({super.key, required this.pokemons});

  final List<Pokemon> pokemons;

  @override
  Widget build(BuildContext context) {
    return BaseBlocView<CompareBloc, CompareState>(
      create: () => CompareBloc(pokemons: pokemons),
      loadingOverlay: const SizedBox.shrink(),
      builder: (context, state, bloc) => Scaffold(
        appBar: AppBar(
          title: Text('Karşılaştır', style: context.textStyle.title18Bold),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _PokemonHeaderRow(state: state, bloc: bloc),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children: [
                    PokemonStatChart(pokemons: state.pokemons),
                    const SizedBox(height: 16),
                    _StatGrid(pokemons: state.pokemons),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Header Row ──────────────────────────────────────────────────────────────

class _PokemonHeaderRow extends StatelessWidget {
  const _PokemonHeaderRow({required this.state, required this.bloc});

  final CompareState state;
  final CompareBloc bloc;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 148,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        clipBehavior: Clip.none,
        itemCount: state.pokemons.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, i) => _PokemonHeaderCard(
          pokemon: state.pokemons[i],
          color: kCompareColors[i % kCompareColors.length],
          canRemove: state.pokemons.length > 1,
          onRemove: () => bloc.add(ComparePokemonRemoved(state.pokemons[i].id)),
        ),
      ),
    );
  }
}

class _PokemonHeaderCard extends StatelessWidget {
  const _PokemonHeaderCard({
    required this.pokemon,
    required this.color,
    required this.canRemove,
    required this.onRemove,
  });

  final Pokemon pokemon;
  final Color color;
  final bool canRemove;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 110,
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 10),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withAlpha(80), width: 1.5),
      ),
      child: Stack(
        alignment: AlignmentGeometry.center,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _AnimatedPokemonSprite(pokemon: pokemon, size: 60.w),
              const SizedBox(height: 2),
              Text(
                '#${pokemon.id.toString().padLeft(3, '0')}',
                style: context.textStyle.paragraph12Regular.copyWith(
                  color: context.appColors.textFieldUnFocusText,
                ),
              ),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  pokemon.name.toUpperCase(),
                  style: context.textStyle.paragraph12Bold.copyWith(
                    color: color,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                ),
              ),
            ],
          ),
          if (canRemove)
            Positioned(
              top: 0,
              right: 0,
              child: GestureDetector(
                onTap: onRemove,
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: color.withAlpha(180),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close_rounded,
                    size: 12,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Stat Grid ───────────────────────────────────────────────────────────────

class _StatGrid extends StatelessWidget {
  const _StatGrid({required this.pokemons});

  final List<Pokemon> pokemons;

  static const _kStatRows = [
    ('HP', _StatField.hp),
    ('Attack', _StatField.attack),
    ('Defense', _StatField.defense),
    ('Sp. Attack', _StatField.spAttack),
    ('Sp. Defense', _StatField.spDefense),
    ('Speed', _StatField.speed),
    ('Total', _StatField.total),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Column(
        children: [
          ..._kStatRows.asMap().entries.map((entry) {
            final isTotal = entry.value.$2 == _StatField.total;
            return Column(
              children: [
                if (isTotal) const Divider(height: 16),
                _StatRow(
                  label: entry.value.$1,
                  field: entry.value.$2,
                  pokemons: pokemons,
                  isTotal: isTotal,
                ),
              ],
            );
          }),
        ],
      ),
    );
  }
}

enum _StatField { hp, attack, defense, spAttack, spDefense, speed, total }

class _StatRow extends StatelessWidget {
  const _StatRow({
    required this.label,
    required this.field,
    required this.pokemons,
    this.isTotal = false,
  });

  final String label;
  final _StatField field;
  final List<Pokemon> pokemons;
  final bool isTotal;

  int _value(Pokemon p) => switch (field) {
    _StatField.hp => p.stats.hp,
    _StatField.attack => p.stats.attack,
    _StatField.defense => p.stats.defense,
    _StatField.spAttack => p.stats.specialAttack,
    _StatField.spDefense => p.stats.specialDefense,
    _StatField.speed => p.stats.speed,
    _StatField.total =>
      p.stats.hp +
          p.stats.attack +
          p.stats.defense +
          p.stats.specialAttack +
          p.stats.specialDefense +
          p.stats.speed,
  };

  @override
  Widget build(BuildContext context) {
    final maxVal = isTotal ? 720.0 : 255.0;
    final values = pokemons.map(_value).toList();
    final best = values.reduce((a, b) => a > b ? a : b);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          SizedBox(
            width: 78,
            child: Text(
              label,
              style:
                  (isTotal
                          ? context.textStyle.paragraph12Bold
                          : context.textStyle.paragraph12Regular)
                      .copyWith(color: context.appColors.textFieldUnFocusText),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < pokemons.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 3),
                    child: _MiniStatBar(
                      value: values[i],
                      maxValue: maxVal,
                      color: kCompareColors[i % kCompareColors.length],
                      isBest: values[i] == best && pokemons.length > 1,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniStatBar extends StatelessWidget {
  const _MiniStatBar({
    required this.value,
    required this.maxValue,
    required this.color,
    required this.isBest,
  });

  final int value;
  final double maxValue;
  final Color color;
  final bool isBest;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: value / maxValue,
              backgroundColor: color.withAlpha(25),
              valueColor: AlwaysStoppedAnimation(
                isBest ? color : color.withAlpha(160),
              ),
              minHeight: 6,
            ),
          ),
        ),
        const SizedBox(width: 6),
        SizedBox(
          width: 28,
          child: Text(
            value.toString(),
            textAlign: TextAlign.end,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isBest ? FontWeight.w700 : FontWeight.w400,
              color: isBest ? color : color.withAlpha(180),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Animated Sprite ─────────────────────────────────────────────────────────

class _AnimatedPokemonSprite extends StatelessWidget {
  const _AnimatedPokemonSprite({required this.pokemon, required this.size});

  final Pokemon pokemon;
  final double size;

  @override
  Widget build(BuildContext context) {
    final animUrl = PokemonUtils.animatedSpriteUrl(pokemon.id);
    final fallbackUrl =
        pokemon.sprites.other?.officialArtwork?.frontDefault ??
        pokemon.sprites.frontDefault;

    if (animUrl != null) {
      return Image.network(
        animUrl,
        width: size,
        height: size,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.none,
        errorBuilder: (_, _, _) => _fallback(fallbackUrl, size),
      );
    }
    return _fallback(fallbackUrl, size);
  }

  static Widget _fallback(String? url, double size) {
    if (url == null) {
      return Icon(Icons.catching_pokemon, size: size * 0.7);
    }
    return Image.network(
      url,
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (_, _, _) => Icon(Icons.catching_pokemon, size: size * 0.7),
    );
  }
}
