import '../../network/api_client.dart';

/// حالة فتح الأعمار لطفل (نقطة الحقيقة لفتح المستوى التالي على السيرفر).
class UnlockStatus {
  final int baseAge;
  final int totalStars;

  /// لكل عمر: هل هو مفتوح؟ وكم لعبة أُنجزت من إجماليها.
  final Map<int, AgeUnlock> ages;

  const UnlockStatus({
    required this.baseAge,
    required this.totalStars,
    required this.ages,
  });

  bool isUnlocked(int age) => ages[age]?.unlocked ?? (age <= baseAge);
  bool isCompleted(int age) => ages[age]?.completed ?? false;
}

class AgeUnlock {
  final int gamesDone;
  final int gamesTotal;
  final bool completed;
  final bool unlocked;
  const AgeUnlock({
    required this.gamesDone,
    required this.gamesTotal,
    required this.completed,
    required this.unlocked,
  });
}

class UnlockRepository {
  /// يجلب حالة فتح الأعمار من `GET /unlocks/?child_id=`. null عند الفشل.
  Future<UnlockStatus?> getStatus(int childId) async {
    final r = await ApiClient.get('/unlocks/', query: {'child_id': '$childId'});
    if (!r.success || r.data is! Map) return null;
    final data = r.data as Map<String, dynamic>;
    final agesRaw = (data['ages'] is Map) ? data['ages'] as Map : const {};
    final ages = <int, AgeUnlock>{};
    agesRaw.forEach((k, v) {
      final age = int.tryParse('$k');
      if (age == null || v is! Map) return;
      ages[age] = AgeUnlock(
        gamesDone: int.tryParse('${v['games_done']}') ?? 0,
        gamesTotal: int.tryParse('${v['games_total']}') ?? 0,
        completed: v['completed'] == true,
        unlocked: v['unlocked'] == true,
      );
    });
    return UnlockStatus(
      baseAge: int.tryParse('${data['base_age']}') ?? 6,
      totalStars: int.tryParse('${data['total_stars']}') ?? 0,
      ages: ages,
    );
  }
}
