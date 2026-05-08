import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color primaryBlue = Color(0xFF2196F3);
  static const Color darkBlue = Color(0xFF1565C0);
  static const Color accentBlue = Color(0xFF42A5F5);
  static const Color scaffoldBg = Color(0xFF121212);
  static const Color cardBg = Color(0xFF1E1E1E);
  static const Color surfaceBg = Color(0xFF2A2A2A);
  static const Color textWhite = Color(0xFFFFFFFF);
  static const Color textGray = Color(0xFFB0B0B0);
  static const Color textDarkGray = Color(0xFF757575);
  static const Color dividerColor = Color(0xFF333333);
  static const Color errorRed = Color(0xFFEF5350);
  static const Color successGreen = Color(0xFF66BB6A);

  static const Color carbColor = Color(0xFF4CAF50);
  static const Color proteinColor = Color(0xFFE53935);
  static const Color fatColor = Color(0xFFFFC107);
  static const Color calorieColor = Color(0xFF2196F3);
}

class AppTheme {
  AppTheme._();

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.scaffoldBg,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryBlue,
        secondary: AppColors.accentBlue,
        surface: AppColors.cardBg,
        error: AppColors.errorRed,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.cardBg,
        foregroundColor: AppColors.textWhite,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: const CardThemeData(
        color: AppColors.cardBg,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceBg,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.dividerColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primaryBlue, width: 2),
        ),
        labelStyle: const TextStyle(color: AppColors.textDarkGray),
        prefixIconColor: AppColors.textDarkGray,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlue,
          foregroundColor: AppColors.textWhite,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryBlue,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.dividerColor,
        thickness: 1,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.cardBg,
        selectedItemColor: AppColors.primaryBlue,
        unselectedItemColor: AppColors.textDarkGray,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
    );
  }
}
