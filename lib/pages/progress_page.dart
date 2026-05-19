import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../models/daily_summary.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../util/extensions/color_extensions.dart';
import '../widgets/indicator.dart';

class ProgressPage extends StatefulWidget {
  const ProgressPage({super.key});

  @override
  State<ProgressPage> createState() => _ProgressPageState();
}

class _ProgressPageState extends State<ProgressPage> {
  List<DailySummary>? _weeklyData;
  bool _isLoading = true;
  String? _error;

  int barTouchedIndex = -1;
  int pieTouchedIndex = -1;

  final Color barColor = Colors.white;
  final Color touchedBarColor = AppColors.successGreen;
  final Color barBackgroundColor =
      Colors.white.darken().withValues(alpha: 0.3);

  @override
  void initState() {
    super.initState();
    _loadWeeklyData();
  }

  Future<void> _loadWeeklyData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final data = await ApiService.getWeeklySummaries();
      if (mounted) {
        setState(() {
          _weeklyData = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  double get _maxY {
    if (_weeklyData == null || _weeklyData!.isEmpty) return 2500;
    final maxCal = _weeklyData!
        .map((d) => d.totalCalories.toDouble())
        .reduce((a, b) => a > b ? a : b);
    final goal = _weeklyData!.first.calorieGoal.toDouble();
    return (maxCal > goal ? maxCal : goal) * 1.2;
  }

  // ──────────────────────────────────────────────
  // Macro totals for pie chart
  // ──────────────────────────────────────────────

  Map<String, double> get _macroTotals {
    if (_weeklyData == null || _weeklyData!.isEmpty) {
      return {'carbs': 0, 'protein': 0, 'fat': 0};
    }
    double carbs = 0, protein = 0, fat = 0;
    for (final d in _weeklyData!) {
      carbs += d.totalCarbs;
      protein += d.totalProtein;
      fat += d.totalFat;
    }
    return {'carbs': carbs, 'protein': protein, 'fat': fat};
  }

  double get _totalMacroCalories {
    final m = _macroTotals;
    return m['carbs']! * 4 + m['protein']! * 4 + m['fat']! * 9;
  }

  // ──────────────────────────────────────────────
  // Build
  // ──────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Weekly Progress')),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Failed to load data',
                style: TextStyle(color: AppColors.errorRed)),
            const SizedBox(height: 8),
            ElevatedButton(
                onPressed: _loadWeeklyData, child: const Text('Retry')),
          ],
        ),
      );
    }
    return _buildContent();
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildBarChartSection(),
          const SizedBox(height: 24),
          _buildDivider(),
          const SizedBox(height: 16),
          _buildLineChartSection(),
          const SizedBox(height: 24),
          _buildDivider(),
          const SizedBox(height: 16),
          _buildPieChartSection(),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(color: AppColors.dividerColor.withValues(alpha: 0.5));
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  // ──────────────────────────────────────────────
  // Bar Chart
  // ──────────────────────────────────────────────

  Widget _buildBarChartSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _sectionTitle('Weekly Caloric Intake'),
        const SizedBox(height: 16),
        SizedBox(
          height: 280,
          child: BarChart(mainBarData()),
        ),
      ],
    );
  }

  BarChartGroupData makeGroupData(
    int x,
    double y, {
    bool isTouched = false,
    Color? barColor,
    double width = 22,
    List<int> showTooltips = const [],
  }) {
    barColor ??= this.barColor;
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: isTouched ? y + 1 : y,
          color: isTouched ? touchedBarColor : barColor,
          width: width,
          borderSide: isTouched
              ? BorderSide(color: touchedBarColor.darken(80))
              : const BorderSide(color: Colors.white, width: 0),
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            toY: _maxY,
            color: barBackgroundColor,
          ),
        ),
      ],
      showingTooltipIndicators: showTooltips,
    );
  }

  List<BarChartGroupData> showingGroups() {
    if (_weeklyData == null || _weeklyData!.isEmpty) {
      return List.generate(
          7, (i) => makeGroupData(i, 0, isTouched: i == barTouchedIndex));
    }
    return List.generate(7, (i) {
      final val = i < _weeklyData!.length
          ? _weeklyData![i].totalCalories.toDouble()
          : 0.0;
      return makeGroupData(i, val, isTouched: i == barTouchedIndex);
    });
  }

  BarChartData mainBarData() {
    return BarChartData(
      barTouchData: BarTouchData(
        enabled: true,
        touchTooltipData: BarTouchTooltipData(
          getTooltipColor: (_) => Colors.blueGrey,
          tooltipHorizontalAlignment: FLHorizontalAlignment.right,
          tooltipMargin: -10,
          getTooltipItem: (group, groupIndex, rod, rodIndex) {
            final weekDay = switch (group.x) {
              0 => 'Monday',
              1 => 'Tuesday',
              2 => 'Wednesday',
              3 => 'Thursday',
              4 => 'Friday',
              5 => 'Saturday',
              6 => 'Sunday',
              _ => '',
            };
            final value = rod.toY - 1;
            final displayValue = value >= 1000
                ? '${(value / 1000).toStringAsFixed(1)}k'
                : value.toInt().toString();
            return BarTooltipItem(
              '$weekDay\n',
              const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
              children: [
                TextSpan(
                  text: '$displayValue kcal',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            );
          },
        ),
        touchCallback: (FlTouchEvent event, barTouchResponse) {
          setState(() {
            if (!event.isInterestedForInteractions ||
                barTouchResponse == null ||
                barTouchResponse.spot == null) {
              barTouchedIndex = -1;
              return;
            }
            barTouchedIndex = barTouchResponse.spot!.touchedBarGroupIndex;
          });
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
            getTitlesWidget: barBottomTitles,
            reservedSize: 38,
          ),
        ),
        leftTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
      ),
      borderData: FlBorderData(show: false),
      barGroups: showingGroups(),
      gridData: const FlGridData(show: false),
    );
  }

  Widget barBottomTitles(double value, TitleMeta meta) {
    const style = TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.bold,
      fontSize: 14,
    );
    String text = switch (value.toInt()) {
      0 => 'M',
      1 => 'T',
      2 => 'W',
      3 => 'T',
      4 => 'F',
      5 => 'S',
      6 => 'S',
      _ => '',
    };
    return SideTitleWidget(
      meta: meta,
      space: 16,
      child: Text(text, style: style),
    );
  }

  // ──────────────────────────────────────────────
  // Line Chart — 3 curves: protein, fats, carbs
  // ──────────────────────────────────────────────

  List<List<double>> get _weeklyMacroData {
    if (_weeklyData == null || _weeklyData!.isEmpty) {
      return List.generate(7, (_) => [0, 0, 0]);
    }
    return _weeklyData!.map((d) => [
      d.totalProtein,
      d.totalFat,
      d.totalCarbs,
    ]).toList();
  }

  double get _lineMaxY {
    double maxVal = 0;
    for (final day in _weeklyMacroData) {
      for (final v in day) {
        if (v > maxVal) maxVal = v;
      }
    }
    return maxVal < 1 ? 300 : maxVal * 1.3;
  }

  Widget _buildLineChartSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _sectionTitle('Macro Trends'),
        const SizedBox(height: 16),
        SizedBox(
          height: 250,
          child: LineChart(
            lineData(),
            duration: const Duration(milliseconds: 250),
          ),
        ),
        const SizedBox(height: 12),
        _macroLegend(),
      ],
    );
  }

  Widget _macroLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _legendDot(AppColors.carbColor, 'Carbs'),
        const SizedBox(width: 20),
        _legendDot(AppColors.proteinColor, 'Protein'),
        const SizedBox(width: 20),
        _legendDot(AppColors.fatColor, 'Fats'),
      ],
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(
          color: color, borderRadius: BorderRadius.circular(2),
        )),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(
          color: AppColors.textGray, fontSize: 12,
        )),
      ],
    );
  }

  LineChartData lineData() {
    final data = _weeklyMacroData;
    final carbsSpots = List.generate(7, (i) => FlSpot(i.toDouble(), data[i][2]));
    final proteinSpots = List.generate(7, (i) => FlSpot(i.toDouble(), data[i][0]));
    final fatsSpots = List.generate(7, (i) => FlSpot(i.toDouble(), data[i][1]));

    final macroColors = [AppColors.carbColor, AppColors.proteinColor, AppColors.fatColor];
    final macroNames = ['Carbs', 'Protein', 'Fats'];

    return LineChartData(
      lineTouchData: LineTouchData(
        handleBuiltInTouches: true,
        touchTooltipData: LineTouchTooltipData(
          getTooltipColor: (_) => Colors.blueGrey.withValues(alpha: 0.8),
          getTooltipItems: (touchedSpots) {
            return touchedSpots.map((spot) {
              return LineTooltipItem(
                '${macroNames[spot.barIndex]}: ${spot.y.toInt()}g',
                TextStyle(
                  color: macroColors[spot.barIndex],
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              );
            }).toList();
          },
        ),
      ),
      gridData: const FlGridData(show: false),
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
            getTitlesWidget: lineBottomTitles,
            reservedSize: 32,
            interval: 1,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 40,
            interval: 50,
            getTitlesWidget: lineLeftTitles,
          ),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border(
          bottom: BorderSide(
              color: AppColors.successGreen.withValues(alpha: 0.2), width: 2),
          left: const BorderSide(color: Colors.transparent),
          right: const BorderSide(color: Colors.transparent),
          top: const BorderSide(color: Colors.transparent),
        ),
      ),
      minX: 0,
      maxX: 6,
      minY: 0,
      maxY: _lineMaxY,
      lineBarsData: [
        LineChartBarData(
          isCurved: true,
          color: AppColors.carbColor,
          barWidth: 4,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(show: false),
          spots: carbsSpots,
        ),
        LineChartBarData(
          isCurved: true,
          color: AppColors.proteinColor,
          barWidth: 4,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(show: false),
          spots: proteinSpots,
        ),
        LineChartBarData(
          isCurved: true,
          color: AppColors.fatColor,
          barWidth: 4,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(show: false),
          spots: fatsSpots,
        ),
      ],
    );
  }

  Widget lineBottomTitles(double value, TitleMeta meta) {
    const style = TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.bold,
      fontSize: 13,
    );
    String text = switch (value.toInt()) {
      0 => 'M',
      1 => 'T',
      2 => 'W',
      3 => 'T',
      4 => 'F',
      5 => 'S',
      6 => 'S',
      _ => '',
    };
    return SideTitleWidget(
      meta: meta,
      space: 8,
      child: Text(text, style: style),
    );
  }

  Widget lineLeftTitles(double value, TitleMeta meta) {
    if (value == 0) return const SizedBox.shrink();
    return SideTitleWidget(
      meta: meta,
      space: 4,
      child: Text(
        value.toInt().toString(),
        style: const TextStyle(
          color: AppColors.textDarkGray,
          fontSize: 11,
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────
  // Pie Chart
  // ──────────────────────────────────────────────

  Widget _buildPieChartSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _sectionTitle('Macro Distribution'),
        const SizedBox(height: 16),
        _buildPieChart(),
      ],
    );
  }

  Widget _buildPieChart() {
    final macros = _macroTotals;
    final total = _totalMacroCalories;
    final hasData = total > 0;

    final carbsCal = macros['carbs']! * 4;
    final proteinCal = macros['protein']! * 4;
    final fatCal = macros['fat']! * 9;

    final carbsPct =
        hasData ? (carbsCal / total * 100).toStringAsFixed(0) : '0';
    final proteinPct =
        hasData ? (proteinCal / total * 100).toStringAsFixed(0) : '0';
    final fatPct =
        hasData ? (fatCal / total * 100).toStringAsFixed(0) : '0';

    return SizedBox(
      height: 200,
      child: Row(
        children: [
          Expanded(
            child: PieChart(
              PieChartData(
                pieTouchData: PieTouchData(
                  touchCallback: (FlTouchEvent event, pieTouchResponse) {
                    setState(() {
                      if (!event.isInterestedForInteractions ||
                          pieTouchResponse == null ||
                          pieTouchResponse.touchedSection == null) {
                        pieTouchedIndex = -1;
                        return;
                      }
                      pieTouchedIndex = pieTouchResponse
                          .touchedSection!.touchedSectionIndex;
                    });
                  },
                ),
                borderData: FlBorderData(show: false),
                sectionsSpace: 2,
                centerSpaceRadius: 35,
                sections: [
                  PieChartSectionData(
                    color: AppColors.carbColor,
                    value: hasData ? carbsCal : 1,
                    title: hasData ? '$carbsPct%' : '',
                    radius: pieTouchedIndex == 0 ? 55 : 45,
                    titleStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  PieChartSectionData(
                    color: AppColors.proteinColor,
                    value: hasData ? proteinCal : 1,
                    title: hasData ? '$proteinPct%' : '',
                    radius: pieTouchedIndex == 1 ? 55 : 45,
                    titleStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  PieChartSectionData(
                    color: AppColors.fatColor,
                    value: hasData ? fatCal : 1,
                    title: hasData ? '$fatPct%' : '',
                    radius: pieTouchedIndex == 2 ? 55 : 45,
                    titleStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 16),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Indicator(
                color: AppColors.carbColor,
                text: 'Carbs $carbsPct%',
                isSquare: true,
              ),
              const SizedBox(height: 8),
              Indicator(
                color: AppColors.proteinColor,
                text: 'Protein $proteinPct%',
                isSquare: true,
              ),
              const SizedBox(height: 8),
              Indicator(
                color: AppColors.fatColor,
                text: 'Fat $fatPct%',
                isSquare: true,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
