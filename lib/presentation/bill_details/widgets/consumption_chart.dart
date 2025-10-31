import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class ConsumptionChart extends StatefulWidget {
  final List<Map<String, dynamic>> consumptionData;

  const ConsumptionChart({
    Key? key,
    required this.consumptionData,
  }) : super(key: key);

  @override
  State<ConsumptionChart> createState() => _ConsumptionChartState();
}

class _ConsumptionChartState extends State<ConsumptionChart> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : AppTheme.cardLight,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppTheme.getElevationShadow(isLight: !isDark, elevation: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Water Consumption Trend',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppTheme.textPrimaryDark
                      : AppTheme.textPrimaryLight,
                ),
          ),
          SizedBox(height: 1.h),
          Text(
            'Last 6 months usage pattern',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isDark
                      ? AppTheme.textSecondaryDark
                      : AppTheme.textSecondaryLight,
                ),
          ),
          SizedBox(height: 3.h),
          SizedBox(
            height: 30.h,
            child: Semantics(
              label:
                  "Water consumption chart showing usage trends over the last 6 months",
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 5,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: (isDark
                                ? AppTheme.dividerDark
                                : AppTheme.dividerLight)
                            .withValues(alpha: 0.5),
                        strokeWidth: 1,
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        interval: 1,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          if (value.toInt() >= 0 &&
                              value.toInt() < widget.consumptionData.length) {
                            return SideTitleWidget(
                              axisSide: meta.axisSide,
                              child: Text(
                                widget.consumptionData[value.toInt()]["month"]
                                    as String,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: isDark
                                          ? AppTheme.textSecondaryDark
                                          : AppTheme.textSecondaryLight,
                                    ),
                              ),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 5,
                        reservedSize: 42,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          return SideTitleWidget(
                            axisSide: meta.axisSide,
                            child: Text(
                              '${value.toInt()}m³',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: isDark
                                        ? AppTheme.textSecondaryDark
                                        : AppTheme.textSecondaryLight,
                                  ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(
                      color: (isDark
                              ? AppTheme.dividerDark
                              : AppTheme.dividerLight)
                          .withValues(alpha: 0.3),
                    ),
                  ),
                  minX: 0,
                  maxX: (widget.consumptionData.length - 1).toDouble(),
                  minY: 0,
                  maxY: _getMaxConsumption() + 5,
                  lineBarsData: [
                    LineChartBarData(
                      spots: _getSpots(),
                      isCurved: true,
                      gradient: LinearGradient(
                        colors: [
                          isDark ? AppTheme.primaryDark : AppTheme.primaryLight,
                          (isDark
                                  ? AppTheme.primaryDark
                                  : AppTheme.primaryLight)
                              .withValues(alpha: 0.7),
                        ],
                      ),
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: touchedIndex == index ? 6 : 4,
                            color: isDark
                                ? AppTheme.primaryDark
                                : AppTheme.primaryLight,
                            strokeWidth: 2,
                            strokeColor:
                                isDark ? AppTheme.cardDark : AppTheme.cardLight,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [
                            (isDark
                                    ? AppTheme.primaryDark
                                    : AppTheme.primaryLight)
                                .withValues(alpha: 0.2),
                            (isDark
                                    ? AppTheme.primaryDark
                                    : AppTheme.primaryLight)
                                .withValues(alpha: 0.05),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ],
                  lineTouchData: LineTouchData(
                    enabled: true,
                    touchCallback:
                        (FlTouchEvent event, LineTouchResponse? touchResponse) {
                      setState(() {
                        if (touchResponse != null &&
                            touchResponse.lineBarSpots != null) {
                          touchedIndex =
                              touchResponse.lineBarSpots!.first.spotIndex;
                        } else {
                          touchedIndex = -1;
                        }
                      });
                    },
                    getTouchedSpotIndicator:
                        (LineChartBarData barData, List<int> spotIndexes) {
                      return spotIndexes.map((spotIndex) {
                        return TouchedSpotIndicatorData(
                          FlLine(
                            color: isDark
                                ? AppTheme.primaryDark
                                : AppTheme.primaryLight,
                            strokeWidth: 2,
                            dashArray: [5, 5],
                          ),
                          FlDotData(
                            getDotPainter: (spot, percent, barData, index) =>
                                FlDotCirclePainter(
                              radius: 8,
                              color: isDark
                                  ? AppTheme.primaryDark
                                  : AppTheme.primaryLight,
                              strokeWidth: 2,
                              strokeColor: isDark
                                  ? AppTheme.cardDark
                                  : AppTheme.cardLight,
                            ),
                          ),
                        );
                      }).toList();
                    },
                    touchTooltipData: LineTouchTooltipData(
                      tooltipBgColor: 
                          isDark ? AppTheme.cardDark : AppTheme.cardLight,
                      getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                        return touchedBarSpots.map((barSpot) {
                          final flSpot = barSpot;
                          final dataPoint =
                              widget.consumptionData[flSpot.x.toInt()];
                          return LineTooltipItem(
                            '${dataPoint["month"]}\n${flSpot.y.toInt()}m³',
                            TextStyle(
                              color: isDark
                                  ? AppTheme.textPrimaryDark
                                  : AppTheme.textPrimaryLight,
                              fontWeight: FontWeight.bold,
                              fontSize: 12.sp,
                            ),
                          );
                        }).toList();
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 2.h),
          _buildChartLegend(context, isDark),
        ],
      ),
    );
  }

  List<FlSpot> _getSpots() {
    return widget.consumptionData.asMap().entries.map((entry) {
      return FlSpot(
        entry.key.toDouble(),
        (entry.value["consumption"] as int).toDouble(),
      );
    }).toList();
  }

  double _getMaxConsumption() {
    return widget.consumptionData
        .map((data) => (data["consumption"] as int).toDouble())
        .reduce((a, b) => a > b ? a : b);
  }

  Widget _buildChartLegend(BuildContext context, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 4.w,
          height: 2.h,
          decoration: BoxDecoration(
            color: isDark ? AppTheme.primaryDark : AppTheme.primaryLight,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        SizedBox(width: 2.w),
        Text(
          'Monthly Consumption (m³)',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: isDark
                    ? AppTheme.textSecondaryDark
                    : AppTheme.textSecondaryLight,
              ),
        ),
      ],
    );
  }
}