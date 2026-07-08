import '../../network/api_client.dart';
import '../models/game_content_item.dart';

/// يجلب محتوى الألعاب النصية من `GET /game_items/` (قابل للتعديل من لوحة admin).
class ContentRepository {
  /// عناصر محتوى لعبة عند مستوى محدّد. قائمة فارغة عند الفشل/الانقطاع
  /// (فتعود الشاشة إلى محتواها المدمج offline).
  Future<List<GameContentItem>> getItems(String gameCode, int levelNumber) async {
    final r = await ApiClient.get('/game_items/', query: {
      'game_code': gameCode,
      'level_number': '$levelNumber',
    });
    if (!r.success || r.data is! List) return const [];
    return (r.data as List)
        .map((e) => GameContentItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
