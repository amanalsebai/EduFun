import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ScoreManager {
  static const String _keyStars = 'global_stars';

  // ✅ مُخطِر حيّ بعدد النجوم: يبدأ من 0 للطفل الجديد
  static final ValueNotifier<int> starsNotifier = ValueNotifier<int>(0);

  // قراءة النجوم الكلية (الافتراضي 0 للطفل الجديد)
  static Future<int> getStars() async {
    final prefs = await SharedPreferences.getInstance();
    final stars = prefs.getInt(_keyStars) ?? 0; // ✅ تبدأ من 0
    // مزامنة المُخطِر مع القيمة المحفوظة
    starsNotifier.value = stars;
    return stars;
  }

  // زيادة وحفظ النجوم الكلية في الجوال
  static Future<int> addStars(int count) async {
    final prefs = await SharedPreferences.getInstance();
    int currentStars = prefs.getInt(_keyStars) ?? 0;
    int updatedStars = currentStars + count;
    await prefs.setInt(_keyStars, updatedStars);
    // ✅ تحديث المُخطِر ليرى الشريط العلوي وكل المستمعين القيمة الجديدة لحظياً
    starsNotifier.value = updatedStars;
    return updatedStars;
  }
}