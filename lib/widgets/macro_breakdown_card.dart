import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/daily_summary.dart';
import '../services/api_service.dart';

class MacroBreakdownCard extends StatelessWidget {
  final DailySummary summary;

  const MacroBreakdownCard({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    final carbsGoal = _macroGoal(ApiService.carbsRatio / 100, 4);
    final proteinGoal = _macroGoal(ApiService.proteinRatio / 100, 4);
    final fatGoal = _macroGoal(ApiService.fatRatio / 100, 9);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Macronutriments',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textWhite,
              ),
            ),
            const SizedBox(height: 16),
            MacroRow(
              label: 'Glucides',
              consumed: summary.totalCarbs,
              goal: carbsGoal,
              color: AppColors.carbColor,
              unit: 'g',
            ),
            const SizedBox(height: 12),
            MacroRow(
              label: 'Protéines',
              consumed: summary.totalProtein,
              goal: proteinGoal,
              color: AppColors.proteinColor,
              unit: 'g',
            ),
            const SizedBox(height: 12),
            MacroRow(
              label: 'Lipides',
              consumed: summary.totalFat,
              goal: fatGoal,
              color: AppColors.fatColor,
              unit: 'g',
            ),
          ],
        ),
      ),
    );
  }

  double _macroGoal(double fraction, int calPerGram) {
    return (ApiService.dailyCalorieGoal * fraction) / calPerGram;
  }
}

class MacroRow extends StatelessWidget {
  final String label;
  final double consumed;
  final double goal;
  final Color color;
  final String unit;

  const MacroRow({
    super.key,
    required this.label,
    required this.consumed,
    required this.goal,
    required this.color,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    final progress = goal > 0 ? (consumed / goal).clamp(0.0, 1.0) : 0.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(label, style: TextStyle(color: AppColors.textGray)),
            ],
          ),
          Text(
            '${consumed.toStringAsFixed(1)}$unit / ${goal.toInt()}$unit',
            style: TextStyle(color: AppColors.textGray),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: AppColors.surfaceBg,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
          ),
        ),
      ],
    );
  }
}
