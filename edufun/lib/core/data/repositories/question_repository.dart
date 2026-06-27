import '../../network/api_client.dart';
import '../models/assessment_question.dart';

/// قراءة أسئلة التقييم المبدئي من السيرفر حسب العمر. تعيد قائمة فارغة عند
/// فشل الاتصال لتستخدم الشاشة الأسئلة المحلية البديلة.
class QuestionRepository {
  Future<List<AssessmentQuestionModel>> getByAge(int age) async {
    final r = await ApiClient.get('/questions/', query: {'age': '$age'});
    if (!r.success || r.data is! List) return [];
    return (r.data as List)
        .map((e) => AssessmentQuestionModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
