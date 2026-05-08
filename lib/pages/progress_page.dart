import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ProgressPage extends StatelessWidget {
  const ProgressPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Progress')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.bar_chart, size: 64, color: AppColors.textDarkGray),
            const SizedBox(height: 16),
            const Text(
              'Progress Coming Soon',
              style: TextStyle(
                  color: AppColors.textGray,
                  fontSize: 18,
                  fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            const Text(
              'Weekly and monthly charts will appear here',
              style: TextStyle(color: AppColors.textDarkGray, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
