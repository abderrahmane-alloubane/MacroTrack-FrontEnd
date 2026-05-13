import 'dart:async';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/local_storage_service.dart';
import '../models/daily_summary.dart';
import '../widgets/diary_page.dart';
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
  Timer? _connectionTimer;

  @override
  void initState() {
    super.initState();
    _loadData();
    _connectionTimer = Timer.periodic(
      const Duration(
        minutes: 1,
      ), // to change when building app since 1 minute is too short
      (_) async {
        await ApiService.checkConnection();
        if (mounted) setState(() {});
      },
    );
  }

  @override
  void dispose() {
    _connectionTimer?.cancel();
    super.dispose();
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
      if (mounted) {
        setState(() {
          if (cached == null) _dailySummary = null;
          _isLoading = false;
        });
      }
    }
  }

  void _previousDay() {
    setState(
      () => _selectedDate = _selectedDate.subtract(const Duration(days: 1)),
    );
    _loadData();
  }

  void _nextDay() {
    setState(() => _selectedDate = _selectedDate.add(const Duration(days: 1)));
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
      MaterialPageRoute(builder: (_) => SearchPage(initialMealType: mealType)),
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
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _bottomNavIndex,
        children: [
          DiaryPage(
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
            icon: Icon(Icons.bar_chart),
            label: 'Progress',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.more_horiz), label: 'More'),
        ],
      ),
    );
  }
}
