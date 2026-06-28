import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/data/repositories/scores_repository.dart';
import '../../core/network/session.dart';
import '../../core/theme/app_colors.dart';

class ParentPortalScreen extends StatefulWidget {
  const ParentPortalScreen({super.key});

  @override
  State<ParentPortalScreen> createState() => _ParentPortalScreenState();
}

class _ParentPortalScreenState extends State<ParentPortalScreen> {
  int mathScore = 0;
  int languageScore = 0;
  int logicScore = 0;
  int childAge = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadScores();
  }

  // قراءة النتائج: السيرفر أولاً (حيّة)، ثم الكاش المحلي بديلاً.
  Future<void> _loadScores() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      int math = 0, language = 0, logic = 0, age = 0;

      // جرّب السيرفر
      await Session.ensureChild();
      bool serverUsed = false;
      if (Session.isOnline) {
        final s = await ScoresRepository().get(Session.currentChildId);
        if (s.math != 0 || s.language != 0 || s.logic != 0) {
          math = s.math;
          language = s.language;
          logic = s.logic;
          serverUsed = true;
          // خزّن نسخة محلية (cache) للعمل دون اتصال
          await prefs.setInt('score_math', math);
          await prefs.setInt('score_language', language);
          await prefs.setInt('score_logic', logic);
        }
      }

      // بديل محلي
      if (!serverUsed) {
        math = prefs.getInt('score_math') ?? 0;
        language = prefs.getInt('score_language') ?? 0;
        logic = prefs.getInt('score_logic') ?? 0;
      }
      age = prefs.getInt('child_age') ?? 0;

      if (!mounted) return;
      setState(() {
        mathScore = math;
        languageScore = language;
        logicScore = logic;
        childAge = age;
        isLoading = false;
      });
    } catch (e) {
      // في حال حدث خطأ في القراءة، نوقف التحميل لكي لا يعلق التطبيق
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
    }
  }

  // النظام الذكي لتقديم التوصيات
  String _getRecommendation() {
    int lowestScore = mathScore;
    String weakestSubject = 'math';

    if (languageScore < lowestScore) {
      lowestScore = languageScore;
      weakestSubject = 'language';
    }
    if (logicScore < lowestScore) {
      lowestScore = logicScore;
      weakestSubject = 'logic';
    }

    // إذا كانت كل الدرجات عالية
    if (mathScore > 0 && languageScore > 0 && logicScore > 0) {
      return "مستوى طفلك متوازن ورائع في جميع الأقسام! دعه يستمر باللعب ليطور مهاراته أكثر.";
    }

    // إذا كانت كلها أصفار (لم يقم بالاختبار بعد)
    if (mathScore == 0 && languageScore == 0 && logicScore == 0) {
      return "لم يقم طفلك بإنهاء التقييم المبدئي بعد. دعه يجرب اختبار 'مهمة اكتشاف القدرات' لنتمكن من تحليل مستواه.";
    }

    switch (weakestSubject) {
      case 'math':
        return "لاحظنا أن طفلك يواجه تحدياً بسيطاً في الأرقام. ننصح بتشجيعه على لعب 'الرياضيات الممتعة' وتدريبه على عد الأشياء في المنزل.";
      case 'language':
        return "طفلك يحتاج لبعض الدعم في الحروف واللغة. ننصح بالتركيز على لعبة 'ترتيب الكلمات' وقراءة قصة قصيرة له قبل النوم.";
      case 'logic':
        return "مهارات المنطق تحتاج لتطوير. الألعاب التي تعتمد على التركيز والمطابقة ستساعده كثيراً في تقوية قوة الملاحظة لديه.";
      default:
        return "دع طفلك يستكشف الألعاب، التعلم باللعب هو أفضل طريقة!";
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLowest,
      appBar: AppBar(
        backgroundColor: AppColors.tertiaryContainer,
        elevation: 0,
        title: const Text(
            "بوابة الآباء",
            style: TextStyle(color: AppColors.onTertiaryContainer, fontWeight: FontWeight.w900)
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: AppColors.onTertiaryContainer),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "تقرير الأداء الأسبوعي",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: AppColors.onBackground),
            ),
            const SizedBox(height: 8),
            Text(
              childAge > 0 ? "العمر المسجل: $childAge سنوات" : "العمر غير مسجل بعد",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.onSurfaceVariant),
            ),

            const SizedBox(height: 40),

            const Text("نتائج التقييم المبدئي:", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
            const SizedBox(height: 20),

            // درجات المواد
            _buildScoreBar("الرياضيات", mathScore, AppColors.secondary),
            const SizedBox(height: 20),
            _buildScoreBar("اللغة العربية", languageScore, AppColors.tertiary),
            const SizedBox(height: 20),
            _buildScoreBar("المنطق والملاحظة", logicScore, AppColors.outlineVariant),

            const SizedBox(height: 40),

            // مربع النصائح الذكية
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primaryContainer.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.primaryContainer, width: 2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.lightbulb_rounded, color: AppColors.primary, size: 30),
                      SizedBox(width: 8),
                      Text("توصيات النظام الذكي:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.primary)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _getRecommendation(),
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.onBackground, height: 1.5),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreBar(String title, int score, Color color) {
    // 0 = يحتاج تدريب (20%) ، 1 = ممتاز (100%)
    double percentage = score >= 1 ? 1.0 : 0.2;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Text(
                score >= 1 ? "ممتاز" : "يحتاج تدريب",
                style: TextStyle(fontWeight: FontWeight.w900, color: color)
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 14,
          decoration: BoxDecoration(color: AppColors.surfaceContainerHigh.withOpacity(0.5), borderRadius: BorderRadius.circular(10)),
          child: FractionallySizedBox(
            alignment: Alignment.centerRight,
            widthFactor: percentage,
            child: Container(decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(10))),
          ),
        ),
      ],
    );
  }
}