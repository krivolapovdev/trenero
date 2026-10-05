import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:phone/core/extensions/string_extension.dart';
import 'package:phone/generated/models/payment_metric_response.dart';

class ProfitLineChart extends StatelessWidget {
  final List<PaymentMetricResponse> data;
  final int selectedIndex;
  final ValueChanged<int> onIndexChanged;

  const new({
    super.key,
    required this.data,
    required this.selectedIndex,
    required this.onIndexChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return const SizedBox.shrink();

    const greenColor = Color(0xFF66a57a);
    const redColor = Color(0xFFEB5757);

    const darkGreenText = Color(0xFF2D6A4F);
    const darkRedText = Color(0xFF9E2A2B);

    final spots = data.asMap().entries.map((entry) {
      final index = entry.key;
      final value = entry.value.total.toDouble();
      return FlSpot(index.toDouble(), value);
    }).toList();

    final minY = spots.map((s) => s.y).reduce((a, b) => a < b ? a : b);
    final maxY = spots.map((s) => s.y).reduce((a, b) => a > b ? a : b);

    final rangeY = (maxY - minY).abs();
    final paddingY = rangeY == 0 ? 10.0 : rangeY * 0.25;

    final calculatedMinY = minY < 0 ? minY - paddingY : -paddingY;
    final calculatedMaxY = maxY > 0 ? maxY + paddingY : paddingY;

    final spotRange = maxY - minY;
    final zeroStop = spotRange == 0 ? 0.5 : (maxY / spotRange).clamp(0.0, 1.0);

    final showingTooltipIndicators = spots
        .asMap()
        .entries
        .map(
          (entry) => ShowingTooltipIndicators([
            LineBarSpot(
              LineChartBarData(
                spots: spots,
                isCurved: false,
                barWidth: 2.5,
                isStrokeCapRound: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: const [greenColor, greenColor, redColor, redColor],
                  stops: [0.0, zeroStop, zeroStop, 1.0],
                ),
                dotData: FlDotData(
                  show: true,
                  getDotPainter: (spot, percent, barData, index) =>
                      FlDotCirclePainter(
                        radius: 5,
                        color: Colors.white,
                        strokeColor: spot.y < 0 ? redColor : greenColor,
                        strokeWidth: 2,
                      ),
                ),
                belowBarData: BarAreaData(
                  show: true,
                  cutOffY: 0,
                  applyCutOffY: true,
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      greenColor.withValues(alpha: 0.2),
                      greenColor.withValues(alpha: 0.0),
                      greenColor.withValues(alpha: 0.0),
                    ],
                    stops: [0.0, zeroStop, 1.0],
                  ),
                ),
                aboveBarData: BarAreaData(
                  show: true,
                  cutOffY: 0,
                  applyCutOffY: true,
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      redColor.withValues(alpha: 0.0),
                      redColor.withValues(alpha: 0.0),
                      redColor.withValues(alpha: 0.2),
                    ],
                    stops: [0.0, zeroStop, 1.0],
                  ),
                ),
              ),
              0,
              entry.value,
            ),
          ]),
        )
        .toList();

    return Container(
      height: 380,
      padding: const EdgeInsets.fromLTRB(16, 22, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: LineChart(
        LineChartData(
          minX: -0.2,
          maxX: (data.length - 1) + 0.2,
          minY: calculatedMinY,
          maxY: calculatedMaxY,
          showingTooltipIndicators: showingTooltipIndicators,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            drawHorizontalLine: true,
            getDrawingHorizontalLine: (value) => FlLine(
              color: Colors.black.withValues(
                alpha: value.abs() < 0.001 ? 0.1 : 0.04,
              ),
              strokeWidth: 1,
            ),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            show: true,
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 36,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (value % 1 != 0 || index < 0 || index >= data.length) {
                    return const SizedBox.shrink();
                  }

                  final itemDate = data[index].date;
                  final rawLabel = DateFormat('MMM', 'ru').format(itemDate);
                  final label = rawLabel.replaceAll('.', '').capitalized;

                  return SideTitleWidget(
                    meta: meta,
                    space: 12,
                    child: Text(
                      label,
                      style: TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                  );
                },
              ),
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: false,
              barWidth: 2.5,
              isStrokeCapRound: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: const [greenColor, greenColor, redColor, redColor],
                stops: [0.0, zeroStop, zeroStop, 1.0],
              ),
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) =>
                    FlDotCirclePainter(
                      radius: 5,
                      color: Colors.white,
                      strokeColor: spot.y < 0 ? redColor : greenColor,
                      strokeWidth: 2,
                    ),
              ),
              belowBarData: BarAreaData(
                show: true,
                cutOffY: 0,
                applyCutOffY: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    greenColor.withValues(alpha: 0.2),
                    greenColor.withValues(alpha: 0.0),
                    greenColor.withValues(alpha: 0.0),
                  ],
                  stops: [0.0, zeroStop, 1.0],
                ),
              ),
              aboveBarData: BarAreaData(
                show: true,
                cutOffY: 0,
                applyCutOffY: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    redColor.withValues(alpha: 0.0),
                    redColor.withValues(alpha: 0.0),
                    redColor.withValues(alpha: 0.2),
                  ],
                  stops: [0.0, zeroStop, 1.0],
                ),
              ),
            ),
          ],
          lineTouchData: LineTouchData(
            enabled: true,
            handleBuiltInTouches: false,
            touchTooltipData: LineTouchTooltipData(
              fitInsideVertically: true,
              tooltipBorderRadius: BorderRadius.all(Radius.circular(16)),
              tooltipBorder: BorderSide(color: Colors.white, width: 1),
              getTooltipColor: (spot) =>
                  spot.y >= 0 ? Color(0xffedf4ef) : Color(0xfffdebeb),
              tooltipPadding: const EdgeInsets.symmetric(
                horizontal: 6,
                vertical: 4,
              ),
              getTooltipItems: (List<LineBarSpot> touchedSpots) =>
                  touchedSpots.map((spot) {
                    if (spot.y.abs() < 0.001) {
                      return null;
                    }

                    return LineTooltipItem(
                      NumberFormat.compact().format(spot.y).toUpperCase(),
                      TextStyle(
                        color: spot.y >= 0 ? darkGreenText : darkRedText,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    );
                  }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}
