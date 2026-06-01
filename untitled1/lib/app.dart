import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'features/onboarding/splash_screen.dart';

// يمكنك تغيير الشاشة الرئيسية هنا لتجربة الصفحات المختلفة مباشرة
 //import 'features/onboarding/age_selection_screen.dart';
// import 'features/dashboard/dashboard_screen.dart';
// import 'features/games/language/word_game_screen.dart';
// import 'features/games/language/sentence_game_screen.dart';
// import 'features/games/language/punctuation_screen.dart';
 //import 'features/flashcards/flashcards_dashboard.dart';

class SmartGamesApp extends StatelessWidget {
  SmartGamesApp({super.key}) {
    // TODO: implement SmartGamesApp
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Play & Learn - ألعاب ذكية',
      theme: AppTheme.lightTheme,

      // دعم اللغة العربية افتراضياً
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child!,
        );
      },

      // نقطة الانطلاق الافتراضية للتطبيق هي شاشة التحميل (Splash)
      // والتي ستقوم تلقائياً بتوجيه المستخدم للشاشات التالية.
      home: const SplashScreen(),

      // --- ملاحظة للمطور ---
      // إذا أردت اختبار شاشة معينة مباشرة، يمكنك إزالة التعليق
      // عن أحد الأسطر التالية وتبديله مكان SplashScreen
      // home: const AgeSelectionScreen(),
      // home: const DashboardScreen(),
      // home: const WordGameScreen(),
      // home: const SentenceGameScreen(),
      // home: const PunctuationScreen(),
      // home: const FlashcardsDashboard(),
    );
  }
}