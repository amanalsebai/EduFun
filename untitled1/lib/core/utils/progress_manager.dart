import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// مدير تقدّم الطفل: يتتبّع الألعاب التي أنهاها الطفل وفاز بها،
/// وعندما يُكمل كل ألعاب مستواه يفتح له ألعاب المستوى التالي تلقائياً.
class ProgressManager {
  // معرّفات ألعاب كل مستوى (عمر). الترتيب لا يهم، المهم العدد والمعرّفات.
  static const Map<int, List<String>> gamesByAge = {
    6: ['word_game', 'color_matching', 'addition_game'],
    7: ['sentence_game', 'ar_en_matching', 'advanced_math'],
    8: ['english_spelling', 'math_adventure', 'grammar_matching'],
    9: ['crossmath', 'error_hunter', 'question_builder'],
  };

  // مُخطِر يُطلق إشعاراً عند فوز الطفل بلعبة جديدة، لتحديث شاشات الألعاب فوراً
  static final ValueNotifier<int> progressTick = ValueNotifier<int>(0);

  static String _key(String gameId) => 'game_done_$gameId';

  /// تسجيل فوز الطفل بلعبة (إنهاء كل مراحلها). تُستدعى عند الفوز داخل كل لعبة.
  static Future<void> markGameCompleted(String gameId) async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_key(gameId)) != true) {
      await prefs.setBool(_key(gameId), true);
      // إشعار الشاشات المستمعة بأن التقدّم تغيّر
      progressTick.value++;
    }
  }

  static Future<bool> isGameCompleted(String gameId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_key(gameId)) ?? false;
  }

  /// عدد الألعاب المُنجزة ضمن مستوى عمري معيّن.
  static Future<int> completedCountForAge(int age) async {
    final prefs = await SharedPreferences.getInstance();
    final games = gamesByAge[age] ?? const [];
    int count = 0;
    for (final g in games) {
      if (prefs.getBool(_key(g)) ?? false) count++;
    }
    return count;
  }

  /// هل أنهى الطفل كل ألعاب مستواه؟ (شرط فتح المستوى التالي)
  static Future<bool> isAgeCompleted(int age) async {
    final games = gamesByAge[age] ?? const [];
    if (games.isEmpty) return false;
    final done = await completedCountForAge(age);
    return done >= games.length;
  }

  /// المستوى التالي المتاح (أو null إذا كان الطفل في أعلى مستوى أو لم يُكمل مستواه).
  static int? nextAgeIfUnlocked(int age) {
    if (!gamesByAge.containsKey(age + 1)) return null;
    return age + 1;
  }
}
