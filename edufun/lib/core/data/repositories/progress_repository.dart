import '../../network/api_client.dart';
import '../models/game_progress.dart';

class ProgressRepository {
  /// كل تقدّم الطفل. يعيد قائمة فارغة عند الفشل.
  Future<List<GameProgress>> getAll(int childId) async {
    final r =
        await ApiClient.get('/progress/', query: {'child_id': '$childId'});
    if (!r.success || r.data is! List) return [];
    return (r.data as List)
        .map((e) => GameProgress.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// تسجيل إكمال لعبة. يعيد مجموع النجوم الجديد (total_stars) أو null عند الفشل.
  /// [stars] = النجوم المكتسبة من هذه اللعبة (مثلاً 50).
  Future<int?> markCompleted(int childId, String gameCode,
      {int stars = 0}) async {
    final r = await ApiClient.post('/progress/', {
      'child_id': childId,
      'game_code': gameCode,
      'stars': stars,
    });
    if (!r.success || r.data is! Map) return null;
    final data = r.data as Map<String, dynamic>;
    if (data['total_stars'] != null) {
      return int.tryParse('${data['total_stars']}');
    }
    return null;
  }
}
