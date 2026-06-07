import 'package:shared_preferences/shared_preferences.dart';

class ScoreManager {
  static const String _keyStars = 'global_stars';

  // قراءة النجوم الكلية (الافتراضي 0 للطفل الجديد)
  static Future<int> getStars() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyStars) ?? 0; // ✅ تبدأ من 0
  }

  // زيادة وحفظ النجوم الكلية في الجوال
  static Future<int> addStars(int count) async {
    final prefs = await SharedPreferences.getInstance();
    int currentStars = prefs.getInt(_keyStars) ?? 0;
    int updatedStars = currentStars + count;
    await prefs.setInt(_keyStars, updatedStars);
    return updatedStars;
  }
}