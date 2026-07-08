import 'package:shared_preferences/shared_preferences.dart';

import 'api_client.dart';
import '../data/repositories/child_repository.dart';

/// إدارة هوية الطفل الحالي على هذا الجهاز.
///
/// التطبيق الأصلي لا يملك شاشة «اختيار طفل» (مستخدم واحد محلي)، لذا عند أول
/// اتصال بالسيرفر نُضمّن وجود سجلّ طفل على الخادم ونحفظ معرّفه محلياً ليُستخدم
/// في كل الطلبات اللاحقة. إذا كان السيرفر متوقّفاً نعمل في «وضع محلي» (id = 0).
class Session {
  static const _kChildId = 'server_child_id';

  static int _childId = 0;
  static int get currentChildId => _childId;

  /// تحميل المعرّف المحفوظ (سريع، دون اتصال).
  static Future<int> loadCachedChildId() async {
    final p = await SharedPreferences.getInstance();
    _childId = p.getInt(_kChildId) ?? 0;
    return _childId;
  }

  static Future<void> _saveChildId(int id) async {
    _childId = id;
    final p = await SharedPreferences.getInstance();
    await p.setInt(_kChildId, id);
  }

  /// يمسح كل مفاتيح التقدّم/النجوم المحلية (لطفل جديد يبدأ من الصفر).
  static Future<void> _clearLocalProgress() async {
    final p = await SharedPreferences.getInstance();
    final keys = p
        .getKeys()
        .where((k) =>
            k.startsWith('game_done_') ||
            k.startsWith('level_done_') ||
            k == 'global_stars')
        .toList();
    for (final k in keys) {
      await p.remove(k);
    }
  }

  /// يضمن وجود طفل حقيقي على السيرفر للاستخدام في الطلبات.
  ///
  /// - لو المعرّف محفوظ مسبقاً ← نعيد使用ـه.
  /// - وإلا نقرأ كل الأطفال فإذا وُجد أحدهم نأخذ الأول.
  /// - وإن لم يوجد نُنشئ طفلاً افتراضياً (اسم الطفل المحفوظ محلياً + العمر المحفوظ).
  /// - عند فشل الاتصال نعيد 0 ونعمل في «الوضع المحلي» دون انهيار.
  /// يُنشئ **طفلاً جديداً** على السيرفر ويجعله الطفل الحالي على هذا الجهاز.
  ///
  /// تُستدعى من شاشة التسجيل (إدخال الاسم) في الـ onboarding. على عكس
  /// [ensureChild] هذه الدالة تُنشئ سجلاً جديداً دائماً ولا تتبنّى طفلاً موجوداً.
  /// تحفظ الاسم والعمر محلياً أيضاً ليُستخدما كبديل عند انقطاع السيرفر.
  ///
  /// تعيد معرّف الطفل الجديد، أو 0 إذا تعذّر الوصول للسيرفر (وضع محلي).
  static Future<int> registerNewChild(String name, int age) async {
    final p = await SharedPreferences.getInstance();
    await p.setString('child_name', name);
    await p.setInt('child_age', age);

    final repo = ChildRepository();

    // نموذج «طفل واحد لكل جهاز»: إن سبق التسجيل على هذا الجهاز نُحدّث نفس السجل
    // بدل إنشاء سجلّ مكرّر في كل تشغيل؛ وإلا نُنشئ سجلاً جديداً (أول تسجيل فعلي).
    final existingId = await loadCachedChildId();
    if (existingId != 0) {
      final ok = await repo.update(existingId, name: name, age: age);
      if (ok) return _childId; // _childId مضبوط من loadCachedChildId
      // السجل المحفوظ لم يعد موجوداً على السيرفر ← نُنشئ من جديد بالأسفل.
    }

    final created = await repo.create(name, age);
    if (created != null) {
      // طفل جديد فعلاً على هذا الجهاز ← ابدأ من الصفر: امسح أي تقدّم/نجوم محلية
      // متبقّية من طفل سابق (المفاتيح game_done_*, level_done_*, global_stars).
      await _clearLocalProgress();
      await _saveChildId(created.id);
      return _childId;
    }

    // السيرفر غير متاح ← وضع محلي (يُعاد المحاولة لاحقاً عبر ensureChild)
    return 0;
  }

  static Future<int> ensureChild() async {
    if (await loadCachedChildId() != 0) return _childId;

    // لا نتبنّى طفلاً موجوداً على السيرفر؛ نُنشئ من الاسم/العمر المحفوظَين محلياً
    // (نتيجة التسجيل في الـ onboarding) حتى لا تختلط بيانات أجهزة مختلفة.
    final p = await SharedPreferences.getInstance();
    final name = p.getString('child_name') ?? 'بطلنا الصغير';
    final age = p.getInt('child_age') ?? 6;

    return registerNewChild(name, age);
  }

  /// هل نحن متّصلون فعلياً بطفل على السيرفر؟
  static bool get isOnline => _childId > 0;

  /// اختبار سريع للاتصال (يستخدمه الـ FAB أحياناً).
  static Future<bool> testConnection() => ApiClient.ping();
}
