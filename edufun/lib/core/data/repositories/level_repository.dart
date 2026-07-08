import '../../network/api_client.dart';
import '../models/game_level.dart';

class LevelRepository {
  /// مراحل لعبة مع حالة الطفل (مفتوحة/مكتملة). قائمة فارغة عند الفشل.
  Future<GameLevelsResult> getLevels(String gameCode, int childId) async {
    final r = await ApiClient.get('/levels/', query: {
      'game_code': gameCode,
      'child_id': '$childId',
    });
    if (!r.success || r.data is! Map) {
      return const GameLevelsResult(ageUnlocked: true, levels: []);
    }
    final data = r.data as Map<String, dynamic>;
    final rawLevels = (data['levels'] is List) ? data['levels'] as List : const [];
    return GameLevelsResult(
      ageUnlocked: data['age_unlocked'] == true,
      levels: rawLevels
          .map((e) => GameLevel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  /// إكمال مرحلة. يعيد (total_stars, game_completed) أو null عند الفشل/القفل.
  Future<LevelCompletion?> complete(
    int childId,
    String gameCode,
    int levelNumber, {
    int stars = 0,
  }) async {
    final r = await ApiClient.post('/levels/', {
      'child_id': childId,
      'game_code': gameCode,
      'level_number': levelNumber,
      'stars': stars,
    });
    if (!r.success || r.data is! Map) return null;
    final data = r.data as Map<String, dynamic>;
    return LevelCompletion(
      totalStars: int.tryParse('${data['total_stars']}'),
      gameCompleted: data['game_completed'] == true,
    );
  }
}

class LevelCompletion {
  final int? totalStars;
  final bool gameCompleted;
  const LevelCompletion({required this.totalStars, required this.gameCompleted});
}
