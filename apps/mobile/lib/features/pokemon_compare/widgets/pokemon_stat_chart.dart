part of '../view/compare_screen.dart';

const List<Color> kCompareColors = [
  Color(0xFFE8702A), // orange
  Color(0xFF3B82F6), // blue
  Color(0xFF22C55E), // green
  Color(0xFFA855F7), // purple
  Color(0xFFEF4444), // red
];

const _kCardBg = Color(0xFF1C1B2E);
const _kGridLine = Color(0x33FFFFFF);
const _kAxisLabel = Color(0x99FFFFFF);
const _kAxisLabelStyle = TextStyle(color: _kAxisLabel, fontSize: 10);

const _statLabels = ['HP', 'ATK', 'DEF', 'SP.A', 'SP.D', 'SPD'];

class PokemonStatChart extends StatelessWidget {
  const PokemonStatChart({super.key, required this.pokemons});

  final List<Pokemon> pokemons;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _kCardBg,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.fromLTRB(12, 20, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Legend(pokemons: pokemons),
          const SizedBox(height: 16),
          SizedBox(height: 200, child: LineChart(_buildChartData())),
        ],
      ),
    );
  }

  LineChartData _buildChartData() {
    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: 50,
        getDrawingHorizontalLine: (_) =>
            const FlLine(color: _kGridLine, strokeWidth: 1, dashArray: [5, 5]),
      ),
      titlesData: FlTitlesData(
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 32,
            interval: 50,
            getTitlesWidget: (value, _) =>
                Text(value.toInt().toString(), style: _kAxisLabelStyle),
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 24,
            getTitlesWidget: (value, _) {
              final index = value.toInt();
              if (index < 0 || index >= _statLabels.length) {
                return const SizedBox.shrink();
              }
              return Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(_statLabels[index], style: _kAxisLabelStyle),
              );
            },
          ),
        ),
      ),
      borderData: FlBorderData(show: false),
      minX: 0,
      maxX: 5,
      minY: 0,
      maxY: 255,
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          getTooltipColor: (_) => const Color(0xFF2D2B42),
          getTooltipItems: (spots) => spots.map((spot) {
            final label = _statLabels[spot.x.toInt()];
            final color = kCompareColors[spot.barIndex % kCompareColors.length];
            return LineTooltipItem(
              '$label: ${spot.y.toInt()}',
              TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            );
          }).toList(),
        ),
      ),
      lineBarsData: [
        for (var i = 0; i < pokemons.length; i++)
          _buildLine(
            _spotsFrom(pokemons[i]),
            kCompareColors[i % kCompareColors.length],
          ),
      ],
    );
  }

  List<FlSpot> _spotsFrom(Pokemon p) => [
    FlSpot(0, p.stats.hp.toDouble()),
    FlSpot(1, p.stats.attack.toDouble()),
    FlSpot(2, p.stats.defense.toDouble()),
    FlSpot(3, p.stats.specialAttack.toDouble()),
    FlSpot(4, p.stats.specialDefense.toDouble()),
    FlSpot(5, p.stats.speed.toDouble()),
  ];

  LineChartBarData _buildLine(List<FlSpot> spots, Color color) {
    return LineChartBarData(
      spots: spots,
      isCurved: false,
      color: color,
      barWidth: 2,
      dotData: FlDotData(
        getDotPainter: (_, _, _, _) => FlDotCirclePainter(
          radius: 4,
          color: color,
          strokeColor: Colors.white,
          strokeWidth: 1.5,
        ),
      ),
      belowBarData: BarAreaData(
        show: true,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [color.withAlpha(60), color.withAlpha(0)],
        ),
      ),
    );
  }
}

// ─── Legend ──────────────────────────────────────────────────────────────────

class _Legend extends StatelessWidget {
  const _Legend({required this.pokemons});

  final List<Pokemon> pokemons;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 6,
      children: [
        for (var i = 0; i < pokemons.length; i++)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _LegendDot(color: kCompareColors[i % kCompareColors.length]),
              const SizedBox(width: 5),
              Text(
                pokemons[i].name.toUpperCase(),
                style: context.textStyle.paragraph12Bold.copyWith(
                  color: kCompareColors[i % kCompareColors.length],
                ),
              ),
            ],
          ),
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
