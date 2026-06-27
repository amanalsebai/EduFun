/// سؤال تقييم مبدئي قادم من السيرفر — يقابل جدول `assessment_questions`.
///
/// يحوّل أعمدة الخيارات (option_a..option_d) إلى قائمة [options] مع تجاهل الفارغ،
/// ويضبط [correctIndex] ضمن المدى الصالح.
class AssessmentQuestionModel {
  final int id;
  final int age;
  final String category; // math / language / logic
  final String question;
  final List<String> options;
  final int correctIndex;

  AssessmentQuestionModel({
    required this.id,
    required this.age,
    required this.category,
    required this.question,
    required this.options,
    required this.correctIndex,
  });

  factory AssessmentQuestionModel.fromJson(Map<String, dynamic> j) {
    final options = <String>[];
    for (final key in ['option_a', 'option_b', 'option_c', 'option_d']) {
      final v = (j[key] ?? '').toString();
      if (v.trim().isNotEmpty) options.add(v);
    }
    var correct = int.tryParse('${j['correct_index']}') ?? 0;
    if (options.isEmpty) {
      correct = 0;
    } else if (correct < 0 || correct >= options.length) {
      correct = 0;
    }
    return AssessmentQuestionModel(
      id: int.tryParse('${j['id']}') ?? 0,
      age: int.tryParse('${j['age']}') ?? 0,
      category: (j['category'] ?? '').toString(),
      question: (j['question'] ?? '').toString(),
      options: options,
      correctIndex: correct,
    );
  }
}
