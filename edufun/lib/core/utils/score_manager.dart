import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/repositories/child_repository.dart';
import '../network/session.dart';

/// مدير النجوم الكلّية للطفل.
///
/// **نفس الواجهة الأصلية** (لا تتغيّر أي شاشة)، لكن «مصدر الحقيقة» أصبح السيرفر:
/// - عند الاتصال: نقرأ `children.total_stars` من `/children/?id=`.
/// - عند انقطاع الاتصال: نقرأ من الكاش المحلي (ليبقى التطبيق يعمل دون اتصال).
///
/// الزيادة الفعلية على السيرفر تتمّ عبر `ProgressManager.markGameCompleted`
/// (الذي يستدعي `/progress/` ويزيد النجوم بالفرق فقط لمنع التضخّم عند الإعادة).
/// دالة [addStars] هنا تُحدِّث الكاش والمُخطِر بشكل تفاعلي (optimistic) فقط،
/// ثم تُصحَّح القيمة من السيرفر عند النداء التالي.
class ScoreManager {
  static const String _keyStars = 'global_stars'; // كاش محلي

  /// مُخطِر حيّ بعدد النجوم.
  static final ValueNotifier<int> starsNotifier = ValueNotifier<int>(0);

  /// معرّف الطفل الحالي على السيرفر (0 = وضع محلي).
  static int get currentChildId => Session.currentChildId;

  /// يضمن وجود طفل على السيرفر ويُهيّئ معرّفه. آمن استدعاؤه عدة مرات.
  static Future<int> ensureChild() => Session.ensureChild();

  /// يحمّل قيمة النجوم المخزّنة محلياً إلى المُخطِر فوراً (عرض سريع بلا وميض).
  /// يُستدعى عند بناء شاشة فيها شريط العلوي قبل المزامنة مع السيرفر.
  static Future<void> loadCachedIntoNotifier() async {
    final prefs = await SharedPreferences.getInstance();
    starsNotifier.value = prefs.getInt(_keyStars) ?? 0;
  }

  /// قراءة النجوم الكلّية (السيرفر أولاً، ثم الكاش المحلي بديلاً).
  static Future<int> getStars() async {
    await ensureChild();
    if (Session.isOnline) {
      final child = await ChildRepository().getById(Session.currentChildId);
      if (child != null) {
        starsNotifier.value = child.totalStars;
        await _cache(child.totalStars);
        return child.totalStars;
      }
    }
    // وضع البديل المحلي
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getInt(_keyStars) ?? 0;
    starsNotifier.value = cached;
    return cached;
  }

  /// زيادة تفاعلية (optimistic) للنجوم محلياً + تحديث المُخطِر فوراً.
  /// الزيادة الحقيقية على السيرفر تتمّ عند تسجيل اللعبة (انظر ProgressManager).
  static Future<int> addStars(int count) async {
    final prefs = await SharedPreferences.getInstance();
    int current = prefs.getInt(_keyStars) ?? 0;
    int updated = current + count;
    await prefs.setInt(_keyStars, updated);
    starsNotifier.value = updated;
    return updated;
  }

  /// يُستدعى من ProgressManager لتثبيت القيمة الموثوقة القادمة من السيرفر.
  static Future<void> syncFromServer(int totalStars) async {
    starsNotifier.value = totalStars;
    await _cache(totalStars);
  }

  static Future<void> _cache(int v) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyStars, v);
  }
}
