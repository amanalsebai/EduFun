import '../../network/api_client.dart';
import '../models/scores.dart';

class ScoresRepository {
  /// قراءة درجات الطفل. يعيد أصفاراً عند الفشل (يُعامل كـ "لا توجد بيانات").
  Future<Scores> get(int childId) async {
    final r = await ApiClient.get('/scores/', query: {'child_id': '$childId'});
    if (!r.success || r.data is! Map) return const Scores();
    return Scores.fromJson(r.data as Map<String, dynamic>);
  }

  /// تحديث الدرجات الثلاث. يعيد true عند النجاح فقط.
  Future<bool> update(int childId, Scores scores) async {
    final r = await ApiClient.put('/scores/',
        query: {'child_id': '$childId'}, body: scores.toJson());
    return r.success;
  }

  /// حفظ نتيجة تقييم مبدئي كامل (يكتب جدول assessments ويُزامن scores).
  Future<bool> saveAssessment(int childId, Scores scores) async {
    final r = await ApiClient.post('/assessment/', {
      'child_id': childId,
      'math_score': scores.math,
      'language_score': scores.language,
      'logic_score': scores.logic,
    });
    return r.success;
  }
}
