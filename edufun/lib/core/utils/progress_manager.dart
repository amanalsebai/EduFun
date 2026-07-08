import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/models/game_level.dart';
import '../data/repositories/child_repository.dart';
import '../data/repositories/level_repository.dart';
import '../data/repositories/progress_repository.dart';
import '../data/repositories/unlock_repository.dart';
import '../network/session.dart';
import 'score_manager.dart';

/// مدير تقدّم الطفل: يتتبّع الألعاب التي أنهها الطفل، ويفتح المستوى التالي
/// تلقائياً عند إكمال كل ألعاب المستوى.
///
/// **نفس الواجهة الأصلية** (لا تتغيّر أي شاشة)، لكن التقدّم يُسجَّل على السيرفر
/// عبر `/progress/` مع الاحتفاظ بالكاش المحلي بديلاً عند انقطاع الاتصال.
class ProgressManager {
  // معرّفات ألعاب كل مستوى (عمر) — مطابقة لجدول games في القاعدة.
  static const Map<int, List<String>> gamesByAge = {
    6: ['word_game', 'color_matching', 'addition_game'],
    7: ['sentence_game', 'ar_en_matching', 'advanced_math'],
    8: ['english_spelling', 'math_adventure', 'grammar_matching'],
    9: ['crossmath', 'error_hunter', 'question_builder'],
  };

  /// يُطلق إشعاراً عند فوز الطفل بلعبة جديدة، لتحديث الشاشات فوراً.
  static final ValueNotifier<int> progressTick = ValueNotifier<int>(0);

  /// النجوم الممنوحة عند إكمال أي لعبة (تطابق `addStars(50)` في كل شاشات الألعاب).
  static const int defaultStarsPerGame = 50;

  /// عدد المراحل الافتراضي لكل لعبة عند العمل دون اتصال (يطابق الـ seed).
  static const int defaultLevelsPerGame = 3;

  /// النجوم الممنوحة عند إكمال مرحلة واحدة (يطابق `stars_reward` في الـ seed).
  static const int defaultStarsPerLevel = 20;

  static String _key(String gameId) => 'game_done_$gameId';
  static String _levelKey(String gameId, int level) => 'level_done_${gameId}_$level';

  /// تسجيل فوز الطفل بلعبة. تُستدعى عند الفوز داخل كل لعبة.
  ///
  /// **هذه هي نقطة الحقيقة الوحيدة للسكور**: سواء عبر السيرفر أو محلياً،
  /// هي مَن يضبط [ScoreManager.starsNotifier] بالقيمة النهائية الصحيحة —
  /// فلا تعتمد الشاشات على أي تحديث تفاعلي (optimistic) منفصل.
  ///
  /// - عند الاتصال: ترسل `POST /progress/` وتُحدِّث النجوم بالقيمة الموثوقة.
  /// - عند الانقطاع: تسجّل محلياً (الكاش) وتزيد النجوم محلياً.
  static Future<void> markGameCompleted(String gameId,
      {int stars = defaultStarsPerGame}) async {
    final prefs = await SharedPreferences.getInstance();
    final already = prefs.getBool(_key(gameId)) == true;

    // أعد قراءة الكاش المحلي للنجوم كقاعدة انطلاق (موثوقة بلا تضاعف).
    await ScoreManager.loadCachedIntoNotifier();

    if (already) {
      // لُعبَت من قبل: لا زيادة. صحّح المُخطِّر بقيمة السيرفر إن توفّرت.
      await ScoreManager.ensureChild();
      if (Session.isOnline) {
        final child =
            await ChildRepository().getById(Session.currentChildId);
        if (child != null) {
          await ScoreManager.syncFromServer(child.totalStars);
        }
      } else {
        // أعد الكاش فقط (بدون مضاعفة).
        await ScoreManager.loadCachedIntoNotifier();
      }
      progressTick.value++;
      return;
    }

    await ScoreManager.ensureChild();
    if (Session.isOnline) {
      final total = await ProgressRepository().markCompleted(
        Session.currentChildId,
        gameId,
        stars: stars,
      );
      if (total != null) {
        // نجاح: ثبّت محلياً + القيمة الموثوقة للنجوم.
        await prefs.setBool(_key(gameId), true);
        await ScoreManager.syncFromServer(total);
        progressTick.value++;
        return;
      }
      // فشل الطلب رغم الاتصال المبدئي → تعامل كوضع محلي.
    }

    // وضع محلي (offline): سجّل الكاش وأضف النجوم محلياً (مرة واحدة فقط).
    await prefs.setBool(_key(gameId), true);
    await ScoreManager.addStars(stars);
    progressTick.value++;
  }

  /// هل أُكملت اللعبة؟ (يقرأ الكاش المحلي السريع؛ يُزامَن عبر [syncFromServer]).
  static Future<bool> isGameCompleted(String gameId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_key(gameId)) ?? false;
  }

  /// يزامن الكاش المحلي مع السيرفر (يُستدعى عند بدء التطبيق/دخول شاشات الألعاب).
  /// يدمج: كل ما هو مكتمل على السيرفر يُعلَّم مكتمل محلياً.
  static Future<void> syncFromServer() async {
    await ScoreManager.ensureChild();
    if (!Session.isOnline) return;
    final list = await ProgressRepository().getAll(Session.currentChildId);
    if (list.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    for (final p in list) {
      if (p.completed) {
        await prefs.setBool(_key(p.gameCode), true);
      }
    }
    // خذ فرصة لتحديث النجوم أيضاً
    final child = await ChildRepository().getById(Session.currentChildId);
    if (child != null) {
      await ScoreManager.syncFromServer(child.totalStars);
    }
    progressTick.value++;
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

  /// هل أنهى الطفل كل ألعاب مستواه؟ (شرط فتح المستوى التالي).
  static Future<bool> isAgeCompleted(int age) async {
    final games = gamesByAge[age] ?? const [];
    if (games.isEmpty) return false;
    final done = await completedCountForAge(age);
    return done >= games.length;
  }

  /// المستوى التالي المتاح (أو null إذا كان في أعلى مستوى).
  static int? nextAgeIfUnlocked(int age) {
    if (!gamesByAge.containsKey(age + 1)) return null;
    return age + 1;
  }

  // ===================================================================
  //  نظام المراحل (Levels) — مرتبط بالباك إند مع بديل محلي عند الانقطاع
  // ===================================================================

  /// نقطة الفوز الموحّدة لكل شاشات الألعاب.
  /// - إن مُرِّرت [level] ← نسجّل إكمال تلك المرحلة تحديداً.
  /// - وإلا ← نسجّل إكمال اللعبة كاملة (توافق مع النداء القديم).
  static Future<void> recordWin(String gameId, {GameLevel? level}) async {
    if (level != null) {
      await markLevelCompleted(gameId, level.levelNumber, stars: level.starsReward);
    } else {
      await markGameCompleted(gameId);
    }
  }

  /// تسجيل إكمال مرحلة محددة.
  /// - عند الاتصال: `POST /levels/` (يزيد النجوم بالفرق ويضبط ملخّص اللعبة تلقائياً).
  /// - عند الانقطاع: يسجّل محلياً؛ وعندما تكتمل كل مراحل اللعبة يضع أيضاً مفتاح
  ///   `game_done_<game>` ويضيف النجوم محلياً (مرة واحدة).
  static Future<void> markLevelCompleted(String gameId, int levelNumber,
      {int stars = defaultStarsPerLevel}) async {
    final prefs = await SharedPreferences.getInstance();
    final levelKey = _levelKey(gameId, levelNumber);
    final alreadyLevel = prefs.getBool(levelKey) == true;

    await ScoreManager.loadCachedIntoNotifier();
    await ScoreManager.ensureChild();

    if (Session.isOnline) {
      final res = await LevelRepository()
          .complete(Session.currentChildId, gameId, levelNumber, stars: stars);
      if (res != null) {
        await prefs.setBool(levelKey, true);
        if (res.gameCompleted) await prefs.setBool(_key(gameId), true);
        if (res.totalStars != null) {
          await ScoreManager.syncFromServer(res.totalStars!);
        }
        progressTick.value++;
        return;
      }
      // فشل رغم الاتصال المبدئي → تعامل كوضع محلي.
    }

    // وضع محلي: سجّل المرحلة وأضف نجومها مرة واحدة.
    if (!alreadyLevel) {
      await prefs.setBool(levelKey, true);
      await ScoreManager.addStars(stars);
    }
    // إذا اكتملت كل المراحل محلياً علّم اللعبة مكتملة (لملخّص فتح الأعمار).
    if (_allLevelsDoneLocally(prefs, gameId)) {
      await prefs.setBool(_key(gameId), true);
    }
    progressTick.value++;
  }

  /// هل أُكملت هذه المرحلة محلياً؟ (للبديل عند انقطاع الاتصال).
  static Future<bool> isLevelCompletedLocal(String gameId, int levelNumber) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_levelKey(gameId, levelNumber)) ?? false;
  }

  static bool _allLevelsDoneLocally(SharedPreferences prefs, String gameId) {
    for (int i = 1; i <= defaultLevelsPerGame; i++) {
      if (prefs.getBool(_levelKey(gameId, i)) != true) return false;
    }
    return true;
  }

  /// هل المستوى العمري التالي مفتوح؟ (السيرفر هو الحكم، مع بديل محلي).
  static Future<bool> isNextAgeUnlocked(int age) async {
    final next = nextAgeIfUnlocked(age);
    if (next == null) return false;
    await ScoreManager.ensureChild();
    if (Session.isOnline) {
      final status = await UnlockRepository().getStatus(Session.currentChildId);
      if (status != null) return status.isUnlocked(next);
    }
    // بديل محلي: العمر التالي يُفتح عند إكمال كل ألعاب العمر الحالي.
    return isAgeCompleted(age);
  }

  /// مسح كل التقدّم المحلي (يُستدعى عند تسجيل طفل جديد فعلياً على هذا الجهاز).
  static Future<void> clearLocalProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs
        .getKeys()
        .where((k) =>
            k.startsWith('game_done_') ||
            k.startsWith('level_done_') ||
            k == 'global_stars')
        .toList();
    for (final k in keys) {
      await prefs.remove(k);
    }
    ScoreManager.starsNotifier.value = 0;
    progressTick.value++;
  }
}
