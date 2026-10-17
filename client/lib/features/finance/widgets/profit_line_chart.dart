import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:phone/core/constants/app_colors.dart';
import 'package:phone/core/constants/app_radius.dart';
import 'package:phone/core/constants/app_spacing.dart';
import 'package:phone/core/extensions/string_extension.dart';
import 'package:phone/core/providers/language_provider.dart';
import 'package:phone/features/finance/widgets/month_axis_label.dart';
import 'package:phone/generated/models/payment_metric_response.dart';

const double _chartHeight = 380;
const double _chartPaddingTop = AppSpacing.xl + 2;
const double _barWidth = 2.5;
const double _dotRadius = 5;
const double _dotStrokeWidth = 2;
const double _zeroThreshold = 0.001;
const double _paddingRatio = 0.25;
const double _fallbackPadding = 10;
const double _monthLabelReservedSize = 36;

LineChartBarData _buildBarData(List<FlSpot> spots, double zeroStop) =>
    LineChartBarData(
      spots: spots,
      barWidth: _barWidth,
      isStrokeCapRound: true,
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: const [
          AppColors.chartProfit,
          AppColors.chartProfit,
          AppColors.chartLoss,
          AppColors.chartLoss,
        ],
        stops: [0, zeroStop, zeroStop, 1],
      ),
      dotData: FlDotData(
        getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
          radius: _dotRadius,
          color: Colors.white,
          strokeColor: spot.y < 0 ? AppColors.chartLoss : AppColors.chartProfit,
          strokeWidth: _dotStrokeWidth,
        ),
      ),
      belowBarData: BarAreaData(
        show: true,
        applyCutOffY: true,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.chartProfit.withValues(alpha: 0.2),
            AppColors.chartProfit.withValues(alpha: 0),
            AppColors.chartProfit.withValues(alpha: 0),
          ],
          stops: [0, zeroStop, 1],
        ),
      ),
      aboveBarData: BarAreaData(
        show: true,
        applyCutOffY: true,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.chartLoss.withValues(alpha: 0),
            AppColors.chartLoss.withValues(alpha: 0),
            AppColors.chartLoss.withValues(alpha: 0.2),
          ],
          stops: [0, zeroStop, 1],
        ),
      ),
    );

LineTouchData _buildTouchData() => LineTouchData(
  handleBuiltInTouches: false,
  touchTooltipData: LineTouchTooltipData(
    fitInsideVertically: true,
    tooltipBorderRadius: AppRadius.lgAll,
    tooltipBorder: const BorderSide(color: Colors.white),
    getTooltipColor: (spot) =>
        spot.y >= 0 ? AppColors.chartProfitTooltip : AppColors.chartLossTooltip,
    tooltipPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
    getTooltipItems: (touchedSpots) => touchedSpots
        .map(
          (spot) => spot.y.abs() < _zeroThreshold
              ? null
              : LineTooltipItem(
                  NumberFormat.compact().format(spot.y).toUpperCase(),
                  TextStyle(
                    color: spot.y >= 0
                        ? AppColors.chartProfitText
                        : AppColors.chartLossText,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
        )
        .toList(),
  ),
);

String? _monthLabelFor(
  double value,
  List<PaymentMetricResponse> data,
  String? locale,
) {
  final index = value.toInt();
  if (value % 1 != 0 || index < 0 || index >= data.length) return null;

  return DateFormat(
    'MMM',
    locale,
  ).format(data[index].date).replaceAll('.', '').capitalized;
}

class ProfitLineChart extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    if (data.isEmpty) return const SizedBox.shrink();

    final locale = ref.watch(
      languageProvider.select((s) => s.value?.languageTag),
    );

    final spots = [
      for (final (index, metric) in data.indexed)
        FlSpot(index.toDouble(), metric.total.toDouble()),
    ];

    final minY = spots.map((spot) => spot.y).reduce((a, b) => a < b ? a : b);
    final maxY = spots.map((spot) => spot.y).reduce((a, b) => a > b ? a : b);

    final rangeY = (maxY - minY).abs();
    final paddingY = rangeY == 0 ? _fallbackPadding : rangeY * _paddingRatio;

    final calculatedMinY = minY < 0 ? minY - paddingY : -paddingY;
    final calculatedMaxY = maxY > 0 ? maxY + paddingY : paddingY;

    final spotRange = maxY - minY;
    final zeroStop = spotRange == 0 ? 0.5 : (maxY / spotRange).clamp(0.0, 1.0);

    final barData = _buildBarData(spots, zeroStop);

    final tooltipIndicators = [
      for (final spot in spots)
        ShowingTooltipIndicators([LineBarSpot(barData, 0, spot)]),
    ];

    return Container(
      height: _chartHeight,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        _chartPaddingTop,
        AppSpacing.lg,
        AppSpacing.lg,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.lgAll,
      ),
      child: LineChart(
        LineChartData(
          minX: -0.2,
          maxX: (data.length - 1) + 0.2,
          minY: calculatedMinY,
          maxY: calculatedMaxY,
          showingTooltipIndicators: tooltipIndicators,
          gridData: FlGridData(
            drawVerticalLine: false,
            getDrawingHorizontalLine: (value) => FlLine(
              color: Colors.black.withValues(
                alpha: value.abs() < _zeroThreshold ? 0.1 : 0.04,
              ),
              strokeWidth: 1,
            ),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(),
            rightTitles: const AxisTitles(),
            leftTitles: const AxisTitles(),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: _monthLabelReservedSize,
                interval: 1,
                getTitlesWidget: (value, meta) => MonthAxisLabel(
                  meta: meta,
                  label: _monthLabelFor(value, data, locale),
                ),
              ),
            ),
          ),
          lineBarsData: [barData],
          lineTouchData: _buildTouchData(),
        ),
      ),
    );
  }
}
