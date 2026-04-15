import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      primaryColor: AppColors.primary,

      // إعداد الخطوط (تأكد من إضافة الخطوط في pubspec.yaml لاحقاً)
      // fontFamily: 'NotoSansArabic',

      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        primaryContainer: AppColors.primaryContainer,
        secondary: AppColors.secondary,
        secondaryContainer: AppColors.secondaryContainer,
        tertiary: AppColors.tertiary,
        tertiaryContainer: AppColors.tertiaryContainer,
        background: AppColors.background,
        surface: AppColors.surface,
        error: AppColors.error,
      ),

      textTheme: const TextTheme(
        displayLarge: TextStyle(color: AppColors.onBackground, fontWeight: FontWeight.w900),
        bodyLarge: TextStyle(color: AppColors.onSurface, fontWeight: FontWeight.bold),
        bodyMedium: TextStyle(color: AppColors.onSurfaceVariant),
      ),
    );
  }
}