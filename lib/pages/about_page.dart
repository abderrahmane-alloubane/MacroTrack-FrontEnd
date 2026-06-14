import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('À propos')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.restaurant_menu, size: 80, color: AppColors.primaryBlue),
              const SizedBox(height: 24),
              Text('MacroTrack',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold, color: AppColors.textWhite)),
              const SizedBox(height: 8),
              Text('v0.1.0',
                style: TextStyle(color: AppColors.textGray, fontSize: 18)),
              const SizedBox(height: 24),
              Text(
                'Suivez votre apport quotidien en macronutriments.\n'
                'Recherchez des aliments, enregistrez vos repas\n'
                'et surveillez vos progrès avec des graphiques.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textGray, fontSize: 14, height: 1.5),
              ),
              const SizedBox(height: 32),
              Text('Construit avec Flutter & Spring Boot',
                style: TextStyle(color: AppColors.textDarkGray, fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }
}
