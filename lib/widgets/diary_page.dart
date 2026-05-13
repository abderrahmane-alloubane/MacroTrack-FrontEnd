import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';
import '../models/daily_summary.dart';
import 'calorie_ring_card.dart';
import 'macro_breakdown_card.dart';
import 'meal_card.dart';

class DiaryPage extends StatelessWidget {
  final DateTime selectedDate;
  final String dateKey;
  final String Function(DateTime) formatDate;
  final bool isLoading;
  final DailySummary? dailySummary;
  final VoidCallback onPreviousDay;
  final VoidCallback onNextDay;
  final VoidCallback onLogout;
  final void Function(String mealType) onAddFood;
  final Future<void> Function() onRefresh;

  const DiaryPage({
    super.key,
    required this.selectedDate,
    required this.dateKey,
    required this.formatDate,
    required this.isLoading,
    required this.dailySummary,
    required this.onPreviousDay,
    required this.onNextDay,
    required this.onLogout,
    required this.onAddFood,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: onPreviousDay,
            ),
            Text(
              formatDate(selectedDate),
              style: const TextStyle(fontSize: 16),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: onNextDay,
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: Tooltip(
              message: ApiService.isConnected ? 'Connected' : 'Disconnected',
              child: Icon(
                Icons.circle,
                size: 12,
                color: ApiService.isConnected
                    ? AppColors.successGreen
                    : AppColors.errorRed,
              ),
            ),
          ),
          IconButton(icon: const Icon(Icons.logout), onPressed: onLogout),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: onRefresh,
              child: dailySummary != null
                  ? ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        CalorieRingCard(summary: dailySummary!),
                        const SizedBox(height: 16),
                        MacroBreakdownCard(summary: dailySummary!),
                        const SizedBox(height: 16),
                        ...dailySummary!.meals.map(
                          (m) => MealCard(
                            name: m.name,
                            calories: m.calories,
                            items: m.items,
                            onAdd: () => onAddFood(m.name),
                            onRefresh: onRefresh,
                            dateKey: dateKey,
                          ),
                        ),
                      ],
                    )
                  : const Center(
                      child: Text(
                        'Could not load data.\nPull down to retry.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.textGray),
                      ),
                    ),
            ),
    );
  }
}
