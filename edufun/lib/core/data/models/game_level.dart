import 'dart:convert';

/// مرحلة داخل لعبة، كما تصل من `GET /levels/?game_code=&child_id=`.
///
/// [config] إعدادات المرحلة (صعوبة/عدد جولات/نطاق أرقام) تُقرأ في شاشات الألعاب
/// لتوليد محتوى مناسب لكل مرحلة. [unlocked] و[completed] حالة الطفل الحالية.
class GameLevel {
  final int levelNumber;
  final String titleAr;
  final int starsReward;
  final Map<String, dynamic> config;
  final bool completed;
  final bool unlocked;
  final int starsEarned;

  const GameLevel({
    required this.levelNumber,
    required this.titleAr,
    required this.starsReward,
    required this.config,
    required this.completed,
    required this.unlocked,
    required this.starsEarned,
  });

  /// قراءة قيمة صحيحة من الإعدادات مع قيمة افتراضية عند غيابها.
  int cfgInt(String key, int fallback) {
    final v = config[key];
    if (v == null) return fallback;
    if (v is int) return v;
    return int.tryParse('$v') ?? fallback;
  }

  static Map<String, dynamic> _parseConfig(dynamic raw) {
    if (raw == null) return const {};
    if (raw is Map) return Map<String, dynamic>.from(raw);
    if (raw is String && raw.trim().isNotEmpty) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is Map) return Map<String, dynamic>.from(decoded);
      } catch (_) {}
    }
    return const {};
  }

  factory GameLevel.fromJson(Map<String, dynamic> j) => GameLevel(
        levelNumber: int.tryParse('${j['level_number']}') ?? 1,
        titleAr: (j['title_ar'] ?? '').toString(),
        starsReward: int.tryParse('${j['stars_reward']}') ?? 20,
        config: _parseConfig(j['config']),
        completed: (j['completed'] == 1 ||
            j['completed'] == true ||
            j['completed'] == '1'),
        unlocked: (j['unlocked'] == 1 ||
            j['unlocked'] == true ||
            j['unlocked'] == '1'),
        starsEarned: int.tryParse('${j['stars_earned']}') ?? 0,
      );

  /// مرحلة افتراضية تُبنى محلياً عند انقطاع الاتصال بالسيرفر.
  factory GameLevel.offline(int number, {required bool completed, required bool unlocked}) =>
      GameLevel(
        levelNumber: number,
        titleAr: 'المستوى $number',
        starsReward: 20,
        config: const {},
        completed: completed,
        unlocked: unlocked,
        starsEarned: completed ? 20 : 0,
      );
}

/// نتيجة جلب مراحل لعبة: حالة فتح العمر + قائمة المراحل.
class GameLevelsResult {
  final bool ageUnlocked;
  final List<GameLevel> levels;
  const GameLevelsResult({required this.ageUnlocked, required this.levels});
}
