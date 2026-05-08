import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';
import '../services/local_storage_service.dart';
import '../models/daily_summary.dart';
import 'login_page.dart';
import 'search_page.dart';
import 'progress_page.dart';
import 'more_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DateTime _selectedDate = DateTime.now();
  DailySummary? _dailySummary;
  bool _isLoading = true;
  int _bottomNavIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  String get _dateKey =>
      '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}';

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    final cached = await LocalStorageService.getDailySummary(_dateKey);
    if (cached != null && mounted) {
      setState(() {
        _dailySummary = cached;
        _isLoading = false;
      });
    }

    try {
      final data = await ApiService.getDailySummary(_dateKey);
      await LocalStorageService.saveDailySummary(data);
      if (mounted) {
        setState(() {
          _dailySummary = data;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (cached == null && mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _previousDay() {
    setState(
        () => _selectedDate = _selectedDate.subtract(const Duration(days: 1)));
    _loadData();
  }

  void _nextDay() {
    setState(
        () => _selectedDate = _selectedDate.add(const Duration(days: 1)));
    _loadData();
  }

  void _navigateToLogin() {
    ApiService.logout();
    LocalStorageService.clear();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  Future<void> _addFood(String mealType) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => SearchPage(initialMealType: mealType),
      ),
    );
    if (result == true) _loadData();
  }

  String _formatDate(DateTime date) {
    final today = DateTime.now();
    if (date.year == today.year &&
        date.month == today.month &&
        date.day == today.day) {
      return 'Today';
    }
    final yesterday = today.subtract(const Duration(days: 1));
    if (date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day) {
      return 'Yesterday';
    }
    final tomorrow = today.add(const Duration(days: 1));
    if (date.year == tomorrow.year &&
        date.month == tomorrow.month &&
        date.day == tomorrow.day) {
      return 'Tomorrow';
    }
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _bottomNavIndex,
        children: [
          _DiaryPage(
            selectedDate: _selectedDate,
            dateKey: _dateKey,
            formatDate: _formatDate,
            isLoading: _isLoading,
            dailySummary: _dailySummary,
            onPreviousDay: _previousDay,
            onNextDay: _nextDay,
            onLogout: _navigateToLogin,
            onAddFood: _addFood,
            onRefresh: _loadData,
          ),
          const SearchPage(),
          const ProgressPage(),
          MorePage(
            onLogout: () {
              ApiService.logout();
              LocalStorageService.clear();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
                (route) => false,
              );
            },
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _bottomNavIndex,
        onTap: (index) => setState(() => _bottomNavIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Diary'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart), label: 'Progress'),
          BottomNavigationBarItem(icon: Icon(Icons.more_horiz), label: 'More'),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────
// Diary Tab
// ──────────────────────────────────────────────

class _DiaryPage extends StatelessWidget {
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

  const _DiaryPage({
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
            Text(formatDate(selectedDate),
                style: const TextStyle(fontSize: 16)),
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
              message:
                  ApiService.isConnected ? 'Connected' : 'Disconnected',
              child: Icon(
                Icons.circle,
                size: 12,
                color: ApiService.isConnected
                    ? AppColors.successGreen
                    : AppColors.errorRed,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: onLogout,
          ),
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
                        _CalorieRingCard(summary: dailySummary!),
                        const SizedBox(height: 16),
                        _MacroBreakdownCard(summary: dailySummary!),
                        const SizedBox(height: 16),
                        ...dailySummary!.meals.map(
                          (m) => _MealCard(
                            name: m.name,
                            calories: m.calories,
                            items: m.items,
                            onAdd: () => onAddFood(m.name),
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

// ──────────────────────────────────────────────
// Calorie Ring
// ──────────────────────────────────────────────

class _CalorieRingCard extends StatelessWidget {
  final DailySummary summary;

  const _CalorieRingCard({required this.summary});

  @override
  Widget build(BuildContext context) {
    final consumed = summary.totalCalories.toDouble();
    final goal = summary.calorieGoal.toDouble();
    final progress = goal > 0 ? consumed / goal : 0.0;
    final remaining = goal - consumed;

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        child: Column(
          children: [
            SizedBox(
              width: 180,
              height: 180,
              child: CustomPaint(
                painter: _RingPainter(
                  progress: progress.clamp(0.0, 1.0),
                  color: AppColors.calorieColor,
                  backgroundColor: AppColors.surfaceBg,
                  strokeWidth: 16,
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${consumed.toInt()}',
                        style: Theme.of(context)
                            .textTheme
                            .headlineLarge
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textWhite,
                            ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'consumed',
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: AppColors.textGray),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${remaining.toInt()} cal left',
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(
                              color: AppColors.primaryBlue,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color backgroundColor;
  final double strokeWidth;

  _RingPainter({
    required this.progress,
    required this.color,
    required this.backgroundColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final bgPaint = Paint()
      ..color = backgroundColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, bgPaint);

    final progressPaint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      2 * pi * progress.clamp(0.0, 1.0),
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

// ──────────────────────────────────────────────
// Macro Breakdown
// ──────────────────────────────────────────────

class _MacroBreakdownCard extends StatelessWidget {
  final DailySummary summary;

  const _MacroBreakdownCard({required this.summary});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Macronutrients',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textWhite,
                  ),
            ),
            const SizedBox(height: 16),
            _MacroRow(
              label: 'Carbs',
              consumed: summary.totalCarbs,
              goal: _macroGoal(0.50),
              color: AppColors.carbColor,
              unit: 'g',
            ),
            const SizedBox(height: 12),
            _MacroRow(
              label: 'Protein',
              consumed: summary.totalProtein,
              goal: _macroGoal(0.25),
              color: AppColors.proteinColor,
              unit: 'g',
            ),
            const SizedBox(height: 12),
            _MacroRow(
              label: 'Fat',
              consumed: summary.totalFat,
              goal: _macroGoal(0.25),
              color: AppColors.fatColor,
              unit: 'g',
            ),
          ],
        ),
      ),
    );
  }

  double _macroGoal(double fraction) {
    return (summary.calorieGoal * fraction) / 4;
  }
}

class _MacroRow extends StatelessWidget {
  final String label;
  final double consumed;
  final double goal;
  final Color color;
  final String unit;

  const _MacroRow({
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
                  decoration:
                      BoxDecoration(color: color, shape: BoxShape.circle),
                ),
                const SizedBox(width: 8),
                Text(label,
                    style: const TextStyle(color: AppColors.textGray)),
              ],
            ),
            Text(
              '${consumed.toStringAsFixed(1)}$unit / ${goal.toInt()}$unit',
              style: const TextStyle(color: AppColors.textGray),
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

// ──────────────────────────────────────────────
// Meal Card
// ──────────────────────────────────────────────

class _MealCard extends StatelessWidget {
  final String name;
  final int calories;
  final List<FoodItem> items;
  final VoidCallback onAdd;

  const _MealCard({
    required this.name,
    required this.calories,
    required this.items,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textWhite,
                      ),
                ),
                Row(
                  children: [
                    Text(
                      '$calories',
                      style: TextStyle(
                        color: calories > 0
                            ? AppColors.primaryBlue
                            : AppColors.textDarkGray,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      'cal',
                      style: TextStyle(
                          color: AppColors.textDarkGray, fontSize: 12),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: onAdd,
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlue,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(Icons.add,
                            size: 20, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (items.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  'No foods recorded',
                  style: TextStyle(
                      color: AppColors.textDarkGray, fontSize: 13),
                ),
              )
            else
              ...items.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        item.name,
                        style: const TextStyle(
                            color: AppColors.textGray, fontSize: 14),
                      ),
                      Text(
                        '${item.calories} cal',
                        style: const TextStyle(
                            color: AppColors.textDarkGray, fontSize: 14),
                      ),
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
