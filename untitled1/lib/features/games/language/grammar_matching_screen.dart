import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/widgets/custom_bottom_nav.dart';

class GrammarMatchingScreen extends StatelessWidget {
  const GrammarMatchingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                const CustomAppBar(score: 300),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(left: 24, right: 24, top: 20, bottom: 120),
                    child: Column(
                      children: [
                        _buildHeader(),
                        const SizedBox(height: 30),
                        _buildMatchingBoard(context),
                        const SizedBox(height: 40),
                        _buildCheckAnswerButton(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: CustomBottomNav(currentIndex: 1),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.tertiaryContainer,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            "تحدي القواعد",
            style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.onTertiaryContainer),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          "وصّل الكلمة بإعرابها الصحيح!",
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: AppColors.onBackground),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "الجملة:",
              style: TextStyle(fontSize: 18, color: AppColors.onSurfaceVariant),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                "أكل الولدُ التفاحةَ",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMatchingBoard(BuildContext context) {
    // نستخدم الـ LayoutBuilder للحصول على أبعاد اللوحة لرسم الخطوط
    return LayoutBuilder(
      builder: (context, constraints) {
        return SizedBox(
          height: 350, // ارتفاع ثابت للوحة
          child: Stack(
            children: [
              // يمكنك هنا إضافة CustomPainter لرسم الخطوط المنقطة بشكل تفاعلي
              // حالياً سنتركها شكلية كما في الكود التالي

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // العمود الأيسر (الإعراب)
                  const Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _GrammarTermCard(term: "فعل ماضٍ"),
                        _GrammarTermCard(term: "فاعل مرفوع"),
                        _GrammarTermCard(term: "مفعول به منصوب"),
                      ],
                    ),
                  ),

                  // مساحة فارغة في المنتصف للخطوط
                  const SizedBox(width: 40),

                  // العمود الأيمن (الكلمات)
                  const Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _WordCard(word: "أكل"),
                        _WordCard(word: "الولدُ"),
                        _WordCard(word: "التفاحةَ"),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCheckAnswerButton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: AppColors.primaryContainer,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            offset: const Offset(0, 8),
            blurRadius: 0,
          )
        ],
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "تحقق من الإجابة",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.onPrimaryContainer),
          ),
          SizedBox(width: 8),
          Icon(Icons.check_circle, color: AppColors.onPrimaryContainer),
        ],
      ),
    );
  }
}

// ويدجت الكلمة (الجهة اليمنى)
class _WordCard extends StatelessWidget {
  final String word;
  const _WordCard({required this.word});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primaryContainer,
          width: 3,
          style: BorderStyle.solid,
        ),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Text(
            word,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: AppColors.primary),
          ),
          // النقطة التي يخرج منها خط التوصيل
          Positioned(
            left: -11, // لتكون على يسار البطاقة
            child: Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 4),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ويدجت الإعراب (الجهة اليسرى)
class _GrammarTermCard extends StatelessWidget {
  final String term;
  const _GrammarTermCard({required this.term});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: AppColors.secondaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Text(
            term,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.onSecondaryContainer),
          ),
          // النقطة التي يصل إليها خط التوصيل
          Positioned(
            right: -11, // لتكون على يمين البطاقة
            child: Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: AppColors.secondaryContainer,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 4),
              ),
            ),
          ),
        ],
      ),
    );
  }
}