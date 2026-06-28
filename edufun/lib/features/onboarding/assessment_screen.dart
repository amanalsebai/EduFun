import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/data/models/scores.dart';
import '../../core/data/repositories/question_repository.dart';
import '../../core/data/repositories/scores_repository.dart';
import '../../core/network/session.dart';
import '../../core/theme/app_colors.dart';

// استيراد جميع عوالم الألعاب للتوجيه الصحيح
import '../dashboard/main_layout_screen.dart';      // ألعاب 6 سنوات
import '../games/age_7_games_screen.dart';          // ألعاب 7 سنوات
import '../games/age_8_games_screen.dart';     // ألعاب 8 سنوات
import '../games/age_9_games_screen.dart';          // ألعاب 9 سنوات الجديدة!

class AssessmentQuestion {
  final String question;
  final List<String> options;
  final int correctAnswerIndex;
  final String category;

  AssessmentQuestion({
    required this.question,
    required this.options,
    required this.correctAnswerIndex,
    required this.category,
  });
}

class AssessmentScreen extends StatefulWidget {
  final int childAge;
  const AssessmentScreen({super.key, required this.childAge});

  @override
  State<AssessmentScreen> createState() => _AssessmentScreenState();
}

class _AssessmentScreenState extends State<AssessmentScreen> {
  int _currentIndex = 0;
  Map<String, int> scores = {'math': 0, 'language': 0, 'logic': 0};
  late List<AssessmentQuestion> _questions;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    // نُجهّز الأسئلة المحلية أولاً (بديل مضمون) ثم نحاول جلبها من السيرفر.
    _loadQuestionsForAge();
    _loadQuestionsFromServer();
  }

  /// يجلب أسئلة التقييم من السيرفر حسب العمر. عند النجاح يستبدل الأسئلة المحلية،
  /// وعند الفشل/عدم وجود بيانات يبقى على النسخة المحلية.
  Future<void> _loadQuestionsFromServer() async {
    final remote = await QuestionRepository().getByAge(widget.childAge);
    if (remote.isNotEmpty) {
      _questions = remote
          .map((q) => AssessmentQuestion(
                question: q.question,
                options: q.options,
                correctAnswerIndex: q.correctIndex,
                category: q.category,
              ))
          .toList();
    }
    if (mounted) setState(() => _loading = false);
  }

  void _loadQuestionsForAge() {
    switch (widget.childAge) {
      case 6:
        _questions = [
          AssessmentQuestion(question: "ما هو الحرف الذي تبدأ به كلمة 'تفاحة'؟", options: ["ت", "ب", "س", "أ"], correctAnswerIndex: 0, category: "language"),
          AssessmentQuestion(question: "إذا كان معك تفاحتين، وأعطاك والدك تفاحة، كم يصبح المجموع؟", options: ["2", "3", "4", "5"], correctAnswerIndex: 1, category: "math"),
          AssessmentQuestion(question: "أي من هذه الحيوانات يطير في السماء؟", options: ["القطة", "السمكة", "العصفور", "الكلب"], correctAnswerIndex: 2, category: "logic"),
        ];
        break;
      case 7:
        _questions = [
          AssessmentQuestion(question: "رتب الحروف التالية لتكوين كلمة مفيدة: (م، ز، و)", options: ["زمو", "موز", "وزم", "زوم"], correctAnswerIndex: 1, category: "language"),
          AssessmentQuestion(question: "كم ناتج: ٥ + ٤ = ؟", options: ["٨", "٩", "١٠", "٧"], correctAnswerIndex: 1, category: "math"),
          AssessmentQuestion(question: "القطة بالنسبة للمواء، كالكلب بالنسبة للـ...", options: ["زئير", "صهيل", "نباح", "تغريد"], correctAnswerIndex: 2, category: "logic"),
        ];
        break;
      case 8:
        _questions = [
          AssessmentQuestion(question: "ما هو مرادف كلمة 'سعيد'؟", options: ["حزين", "مسرور", "غاضب", "خائف"], correctAnswerIndex: 1, category: "language"),
          AssessmentQuestion(question: "كم ناتج: ١٥ - ٧ = ؟", options: ["٦", "٨", "٩", "٧"], correctAnswerIndex: 1, category: "math"),
          AssessmentQuestion(question: "ما هو الشكل الذي له ٤ أضلاع متساوية؟", options: ["الدائرة", "المثلث", "المستطيل", "المربع"], correctAnswerIndex: 3, category: "logic"),
        ];
        break;
      case 9:
        _questions = [
          AssessmentQuestion(question: "أين نضع الفاصلة (،)؟", options: ["نهاية الجملة", "للتعجب", "بين الجمل المتتابعة", "للسؤال"], correctAnswerIndex: 2, category: "language"),
          AssessmentQuestion(question: "كم ناتج: ٨ × ٧ = ؟", options: ["٥٤", "٥٦", "٦٤", "٤٨"], correctAnswerIndex: 1, category: "math"),
          AssessmentQuestion(question: "إذا كان اليوم الثلاثاء، فماذا سيكون بعد ٣ أيام؟", options: ["الخميس", "الجمعة", "السبت", "الأحد"], correctAnswerIndex: 1, category: "logic"),
        ];
        break;
      default:
        _questions = [
          AssessmentQuestion(question: "1+1=?", options: ["1", "2", "3", "4"], correctAnswerIndex: 1, category: "math"),
        ];
    }
  }

  void _answerQuestion(int selectedIndex) {
    if (selectedIndex == _questions[_currentIndex].correctAnswerIndex) {
      String category = _questions[_currentIndex].category;
      scores[category] = (scores[category] ?? 0) + 1;
    }

    if (_currentIndex < _questions.length - 1) {
      setState(() {
        _currentIndex++;
      });
    } else {
      _finishAssessment();
    }
  }

  void _finishAssessment() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('score_math', scores['math'] ?? 0);
    await prefs.setInt('score_language', scores['language'] ?? 0);
    await prefs.setInt('score_logic', scores['logic'] ?? 0);
    await prefs.setInt('child_age', widget.childAge);

    // إرسال النتيجة للسيرفر (يكتب جدول assessments ويُزامن child_scores).
    // يعمل بصمت: إن فشل الاتصال تبقى النتيجة محفوظة محلياً (وضع البديل).
    await Session.ensureChild();
    if (Session.isOnline) {
      await ScoresRepository().saveAssessment(
        Session.currentChildId,
        Scores(
          math: scores['math'] ?? 0,
          language: scores['language'] ?? 0,
          logic: scores['logic'] ?? 0,
        ),
      );
    }

    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: AppColors.primary),
            const SizedBox(height: 20),
            const Text(
              "نقوم بتجهيز عالمك الخاص... 🚀",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      Navigator.of(context).pop();

      Widget nextScreen;

      // ✅ تم تصحيح التوجيه البرمجي بدقة شديدة هنا بناءً على عمر الطفل
      // التوجيه الصحيح بناءً على تقسيمك الدقيق والجديد للأعمار:
      switch (widget.childAge) {
        case 6:
          nextScreen = const MainLayoutScreen(); // عالم ألعاب 6 سنوات (موز، ألوان، جمع)
          break;
        case 7:
          nextScreen = const Age7GamesScreen(); // عالم ألعاب 7 سنوات (جمل، إنجليزي، طرح)
          break;
        case 8:
          nextScreen = const Age8GamesScreen(); // عالم ألعاب 8 سنوات (ترقيم، ضرب وقسمة، إعراب)
          break;
        case 9:
          nextScreen = const Age9GamesScreen(); // عالم ألعاب 9 سنوات (كروس ماث، أخطاء، سؤال إنجليزي)
          break;
        default:
          nextScreen = const MainLayoutScreen();
      }

      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => nextScreen));
    });
  }

  @override
  Widget build(BuildContext context) {
    // نعرض مؤشّر تحميل ريثما نحاول جلب الأسئلة من السيرفر (لمنع تبدّلها أثناء الحل).
    if (_loading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    final currentQuestion = _questions[_currentIndex];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              LinearProgressIndicator(
                value: (_currentIndex + 1) / _questions.length,
                backgroundColor: AppColors.surfaceContainerHigh,
                color: AppColors.primary,
                minHeight: 12,
                borderRadius: BorderRadius.circular(10),
              ),
              const SizedBox(height: 24),

              const Row(
                children: [
                  Icon(Icons.psychology, size: 50, color: AppColors.secondary),
                  SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      "مهمة اكتشاف القدرات!",
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.onBackground),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // ✅ تمرير المحتوى لمنع الـ Overflow عندما يكون السؤال أو الخيارات طويلة
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10))],
                        ),
                        child: Text(
                          currentQuestion.question,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.primary, height: 1.4),
                        ),
                      ),
                      const SizedBox(height: 32),

                      ...List.generate(currentQuestion.options.length, (index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: ElevatedButton(
                            onPressed: () => _answerQuestion(index),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: AppColors.onBackground,
                              elevation: 4,
                              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            child: Text(
                              currentQuestion.options[index],
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}