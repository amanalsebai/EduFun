import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ScoreManager {
  static const String _keyStars = 'global_stars';

  // ✅ مُخطِر حيّ بعدد النجوم: أي شاشة تستمع له تتحدث فوراً عند تغيّر النقاط
  static final ValueNotifier<int> starsNotifier = ValueNotifier<int>(100);

  // 1. قراءة عدد النجوم الحالي المخزن في الهاتف (الافتراضي 100 نجمة كبداية)
  static Future<int> getStars() async {
    final prefs = await SharedPreferences.getInstance();
    final stars = prefs.getInt(_keyStars) ?? 100;
    // مزامنة المُخطِر مع القيمة المحفوظة
    starsNotifier.value = stars;
    return stars;
  }

  // 2. زيادة عدد النجوم (مثلاً إضافة 50 نجمة عند الفوز) وحفظها
  static Future<int> addStars(int count) async {
    final prefs = await SharedPreferences.getInstance();
    int currentStars = prefs.getInt(_keyStars) ?? 100;
    int updatedStars = currentStars + count;
    await prefs.setInt(_keyStars, updatedStars);
    // ✅ تحديث المُخطِر ليرى الشريط العلوي وكل المستمعين القيمة الجديدة لحظياً
    starsNotifier.value = updatedStars;
    return updatedStars;
  }
}
