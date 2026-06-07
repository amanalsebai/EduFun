import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/custom_app_bar.dart';
import '../../core/widgets/custom_drawer.dart';

// استيراد ألعاب عمر 8 سنوات
import 'language/english_spelling_screen.dart'; // مكتشف الكلمات (إنجليزي)
import 'math/math_adventure_screen.dart';        // الضرب والقسمة (رياضيات)
import 'language/grammar_matching_screen.dart';  // توصيل الإعراب (قواعد)
import 'widgets/next_level_unlock_card.dart';    // ✅ بطاقة فتح المستوى التالي
import 'age_9_games_screen.dart';                // ✅ ألعاب المستوى التالي (٩ سنوات)


class Age8GamesScreen extends StatelessWidget {
  const Age8GamesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const CustomDrawer(),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // ✅ تم إزالة الـ score ليعمل تلقائياً
            const CustomAppBar(showBackButton: false),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    _buildWelcomeHero(),
                    const SizedBox(height: 30),
                    _buildGamesGrid(context),
                    const SizedBox(height: 24),
                    // ✅ يفتح ألعاب المستوى التالي عند إنهاء كل ألعاب هذا المستوى
                    NextLevelUnlockCard(
                      age: 8,
                      onGoToNextLevel: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const Age9GamesScreen()),
                      ),
                    ),
                    const SizedBox(height: 40),
                    _buildProgressSection(),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeHero() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.4),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: -30, right: -30,
            child: Container(width: 150, height: 150, decoration: BoxDecoration(color: AppColors.tertiaryContainer.withOpacity(0.3), shape: BoxShape.circle)),
          ),
          Positioned(
            bottom: -30, left: -30,
            child: Container(width: 150, height: 150, decoration: BoxDecoration(color: AppColors.secondaryContainer.withOpacity(0.3), shape: BoxShape.circle)),
          ),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "مرحباً بك يا بطل!\nاختر تحدي اليوم",
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: AppColors.primary, height: 1.2),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "استعد لرحلة مليئة بالذكاء والمرح في عالم المعرفة!",
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.onSurfaceVariant.withOpacity(0.8)),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // ✅ مجسّم البطل بأيقونة ثابتة بدل صورة الشبكة المؤقتة
              Container(
                width: 100, height: 100,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.6),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                ),
                child: const Center(child: Text("🧠", style: TextStyle(fontSize: 50))),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGamesGrid(BuildContext context) {
    // ✅ الألعاب تحت بعضها (عمود واحد) ببطاقات أفقية تتجنّب الـ overflow
    return Column(
      children: [
        _buildGameCard(
          title: "مكتشف الكلمات", category: "لغة إنجليزية",
          bgColor: AppColors.primaryContainer, textColor: AppColors.onPrimaryContainer, shadowColor: AppColors.primary,
          icon: Icons.abc_rounded,
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const EnglishSpellingScreen())),
        ),
        const SizedBox(height: 16),
        _buildGameCard(
          title: "الضرب والقسمة", category: "رياضيات",
          bgColor: AppColors.secondaryContainer, textColor: AppColors.onSecondaryContainer, shadowColor: AppColors.secondaryDim,
          icon: Icons.calculate_rounded,
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const MathAdventureScreen())),
        ),
        const SizedBox(height: 16),
        _buildGameCard(
          title: "توصيل الإعراب", category: "قواعد عربية",
          bgColor: AppColors.tertiaryContainer, textColor: AppColors.onTertiaryContainer, shadowColor: AppColors.tertiaryDim,
          icon: Icons.account_tree_rounded,
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const GrammarMatchingScreen())),
        ),
      ],
    );
  }

  Widget _buildGameCard({required String title, required String category, required Color bgColor, required Color textColor, required Color shadowColor, required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(24),
          border: Border(bottom: BorderSide(color: shadowColor, width: 6)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))],
        ),
        child: Row(
          children: [
            Container(
              width: 60, height: 60,
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.3), borderRadius: BorderRadius.circular(18)),
              child: Icon(icon, size: 32, color: textColor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: textColor)),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.3), borderRadius: BorderRadius.circular(15)),
                    child: Text(category, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: textColor)),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.arrow_forward_ios_rounded, size: 18, color: textColor.withOpacity(0.5)),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.8), borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("مستوى التقدم", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.primary)),
              Row(
                children: [
                  Text("المستوى 5", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.secondary)),
                  SizedBox(width: 4),
                  Icon(Icons.military_tech_rounded, color: AppColors.secondary),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            height: 24,
            width: double.infinity,
            decoration: BoxDecoration(color: AppColors.surfaceContainer, borderRadius: BorderRadius.circular(12)),
            child: FractionallySizedBox(
              alignment: Alignment.centerRight,
              widthFactor: 0.75,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.tertiary,
                  borderRadius: BorderRadius.circular(12),
                  image: const DecorationImage(image: NetworkImage("https://www.transparenttextures.com/patterns/diagonal-stripes.png"), fit: BoxFit.none, repeat: ImageRepeat.repeat, opacity: 0.2),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text("بقي لك 50 نجمة للوصول للمستوى 6!", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.onSurfaceVariant)),
        ],
      ),
    );
  }
}