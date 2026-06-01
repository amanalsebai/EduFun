import 'package:shared_preferences/shared_preferences.dart';

class ScoreManager {
  static const String _keyStars = 'global_stars';

  // 1. قراءة عدد النجوم الحالي المخزن في الهاتف (الافتراضي 100 نجمة كبداية)
  static Future<int> getStars() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyStars) ?? 100;
  }

  // 2. زيادة عدد النجوم (مثلاً إضافة 50 نجمة عند الفوز) وحفظها
  static Future<int> addStars(int count) async {
    final prefs = await SharedPreferences.getInstance();
    int currentStars = prefs.getInt(_keyStars) ?? 100;
    int updatedStars = currentStars + count;
    await prefs.setInt(_keyStars, updatedStars);
    return updatedStars;
  }
}