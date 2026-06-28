import '../../network/api_client.dart';
import '../models/game.dart';

/// يجلب كتالوج الألعاب لعمر معيّن من المسار `GET /games/?min_age=`.
///
/// في حال فشل الاتصال أو ردّ غير متوقّع يُرجع قائمة فارغة، فيعتمد عليه
/// المتصل (شاشات الأعمار) للسقوط على البطاقات الثابتة البديلة (offline fallback).
class GameRepository {
  Future<List<Game>> getByAge(int age) async {
    final r = await ApiClient.get('/games/', query: {'min_age': '$age'});
    if (!r.success || r.data is! List) return const [];
    return (r.data as List)
        .map((e) => Game.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
