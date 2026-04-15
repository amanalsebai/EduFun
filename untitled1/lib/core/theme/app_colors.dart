import 'package:flutter/material.dart';

class AppColors {
  // ألوان الخلفيات والأسطح
  static const Color background = Color(0xFFE4FFCD);
  static const Color surface = Color(0xFFE4FFCD);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFCEFFAC);
  static const Color surfaceContainer = Color(0xFFA5FF6F);
  static const Color surfaceContainerHigh = Color(0xFF80FF2C);

  // الألوان الأساسية (Primary - الأحمر الوردي والذهبي حسب الشاشة)
  static const Color primary = Color(0xFF9C3756); // أُخذ من شاشات التعليم
  static const Color onPrimary = Color(0xFFFFEFF0);
  static const Color primaryContainer = Color(0xFFFF85A4); // أو الأصفر في بعض الشاشات
  static const Color onPrimaryContainer = Color(0xFF5D0227);

  // الألوان الثانوية (Secondary - الأزرق)
  static const Color secondary = Color(0xFF00618F);
  static const Color onSecondary = Color(0xFFEAF4FF);
  static const Color secondaryContainer = Color(0xFFA7D7FF);
  static const Color onSecondaryContainer = Color(0xFF004C71);

  // الألوان الثلاثية (Tertiary - الأصفر/الذهبي)
  static const Color tertiary = Color(0xFF6D5A00);
  static const Color onTertiary = Color(0xFFFFF2CE);
  static const Color tertiaryContainer = Color(0xFFFFE170);
  static const Color onTertiaryContainer = Color(0xFF615000);

  // ألوان النصوص
  static const Color onBackground = Color(0xFF143600);
  static const Color onSurface = Color(0xFF143600);
  static const Color onSurfaceVariant = Color(0xFF2C6900);

  // ألوان الأخطاء والنجاح (Outline)
  static const Color error = Color(0xFFB31B25);
  static const Color outline = Color(0xFF3B8700);
  static const Color outlineVariant = Color(0xFF59C400);
}