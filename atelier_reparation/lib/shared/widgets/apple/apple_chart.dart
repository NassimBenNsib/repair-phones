import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../core/design/apple_tokens.dart';

/// Mini-courbe (sparkline) sans axes, pour accompagner une statistique.
class Sparkline extends StatelessWidget {
  const Sparkline({
    super.key,
    required this.values,
    required this.color,
    this.height = 40,
  });

  final List<double> values;
  final Color color;
  final double height;

  @override
  Widget build(BuildContext context) {
    final spots = [
      for (var i = 0; i < values.length; i++) FlSpot(i.toDouble(), values[i]),
    ];

    return SizedBox(
      height: height,
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineTouchData: const LineTouchData(enabled: false),
          minY: values.isEmpty ? 0 : null,
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              curveSmoothness: 0.35,
              color: color,
              barWidth: 2.5,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    color.withValues(alpha: 0.25),
                    color.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Histogramme d'activité thématisé (barres arrondies aux couleurs du système).
class AppleBarChart extends StatelessWidget {
  const AppleBarChart({
    super.key,
    required this.values,
    required this.labels,
    required this.color,
    this.height = 180,
  });

  final List<double> values;
  final List<String> labels;
  final Color color;
  final double height;

  @override
  Widget build(BuildContext context) {
    final colors = context.appleColors;
    final maxValue =
        values.isEmpty ? 1.0 : values.reduce((a, b) => a > b ? a : b);

    return SizedBox(
      height: height,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxValue == 0 ? 1 : maxValue * 1.2,
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          barTouchData: BarTouchData(enabled: false),
          titlesData: FlTitlesData(
            show: true,
            leftTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 24,
                getTitlesWidget: (value, meta) {
                  final i = value.toInt();
                  if (i < 0 || i >= labels.length) return const SizedBox();
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      labels[i],
                      style: AppleTypography.caption2
                          .copyWith(color: colors.secondaryLabel),
                    ),
                  );
                },
              ),
            ),
          ),
          barGroups: [
            for (var i = 0; i < values.length; i++)
              BarChartGroupData(
                x: i,
                barRods: [
                  BarChartRodData(
                    toY: values[i],
                    width: 14,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(6),
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [color.withValues(alpha: 0.6), color],
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

/// Courbe d'aire lissée avec libellés en abscisse — tendance sur une période.
/// Anime le tracé sauf en mode « réduire les animations ».
class AppleLineChart extends StatelessWidget {
  const AppleLineChart({
    super.key,
    required this.values,
    required this.labels,
    required this.color,
    this.height = 200,
  });

  final List<double> values;
  final List<String> labels;
  final Color color;
  final double height;

  @override
  Widget build(BuildContext context) {
    final colors = context.appleColors;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final maxV = values.isEmpty ? 1.0 : values.reduce((a, b) => a > b ? a : b);
    // Affiche ~6 libellés au plus pour éviter l'encombrement.
    final step = (values.length / 6).ceil().clamp(1, 999);

    return SizedBox(
      height: height,
      child: LineChart(
        duration: reduceMotion ? Duration.zero : const Duration(milliseconds: 450),
        LineChartData(
          minY: 0,
          maxY: maxV == 0 ? 1 : maxV * 1.2,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: (maxV == 0 ? 1 : maxV) / 3,
            getDrawingHorizontalLine: (_) =>
                FlLine(color: colors.separator, strokeWidth: 0.5),
          ),
          borderData: FlBorderData(show: false),
          lineTouchData: const LineTouchData(enabled: false),
          titlesData: FlTitlesData(
            leftTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 22,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  final i = value.toInt();
                  if (i < 0 || i >= labels.length || i % step != 0) {
                    return const SizedBox();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(labels[i],
                        style: AppleTypography.caption2
                            .copyWith(color: colors.secondaryLabel)),
                  );
                },
              ),
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: [
                for (var i = 0; i < values.length; i++)
                  FlSpot(i.toDouble(), values[i]),
              ],
              isCurved: true,
              curveSmoothness: 0.32,
              color: color,
              barWidth: 2.5,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    color.withValues(alpha: 0.28),
                    color.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Segment d'un [AppleDonutChart].
typedef DonutSegment = ({String label, double value, Color color});

/// Anneau (donut) + total central + légende colorée. Idéal pour une
/// répartition (statuts de réparation). Réduit-motion : pas d'animation.
class AppleDonutChart extends StatelessWidget {
  const AppleDonutChart({
    super.key,
    required this.segments,
    required this.centerValue,
    this.centerLabel,
    this.height = 180,
  });

  final List<DonutSegment> segments;
  final String centerValue;
  final String? centerLabel;
  final double height;

  @override
  Widget build(BuildContext context) {
    final colors = context.appleColors;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final total = segments.fold<double>(0, (s, e) => s + e.value);

    return SizedBox(
      height: height,
      child: Row(
        children: [
          SizedBox(
            width: height,
            height: height,
            child: Stack(
              alignment: Alignment.center,
              children: [
                PieChart(
                  duration:
                      reduceMotion ? Duration.zero : const Duration(milliseconds: 400),
                  PieChartData(
                    sectionsSpace: 2,
                    centerSpaceRadius: height * 0.28,
                    startDegreeOffset: -90,
                    pieTouchData: PieTouchData(enabled: false),
                    sections: total == 0
                        ? [
                            PieChartSectionData(
                                value: 1,
                                color: colors.fill,
                                radius: height * 0.16,
                                showTitle: false),
                          ]
                        : [
                            for (final s in segments)
                              if (s.value > 0)
                                PieChartSectionData(
                                  value: s.value,
                                  color: s.color,
                                  radius: height * 0.16,
                                  showTitle: false,
                                ),
                          ],
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(centerValue,
                        style: AppleTypography.title2
                            .copyWith(color: colors.label)),
                    if (centerLabel != null)
                      Text(centerLabel!,
                          style: AppleTypography.caption1
                              .copyWith(color: colors.secondaryLabel)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final s in segments)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                              color: s.color, shape: BoxShape.circle),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(s.label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppleTypography.subheadline
                                  .copyWith(color: colors.secondaryLabel)),
                        ),
                        Text('${s.value.toInt()}',
                            style: AppleTypography.subheadline.copyWith(
                                color: colors.label,
                                fontWeight: FontWeight.w600)),
                      ],
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
