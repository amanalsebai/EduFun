import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/custom_app_bar.dart';
import '../../core/widgets/custom_bottom_nav.dart';
import 'widgets/flip_card.dart';

class FlashcardsDashboard extends StatelessWidget {
  const FlashcardsDashboard({super.key});

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
                const CustomAppBar(score: 125),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(left: 24, right: 24, top: 24, bottom: 120),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeroHeader(),
                        const SizedBox(height: 30),
                        _buildCategoriesBento(),
                        const SizedBox(height: 40),
                        _buildSuggestedCardsHeader(),
                        const SizedBox(height: 20),
                        _buildFlashcardsGrid(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // شريط التنقل السفلي
          const Positioned(
            bottom: 0, left: 0, right: 0,
            child: CustomBottomNav(currentIndex: 2), // الاندكس 2 يعني قسم البطاقات
          ),
        ],
      ),
    );
  }

  Widget _buildHeroHeader() {
    return const Column(
      children: [
        Text(
          "اختر بطاقة لتبدأ التعلم!",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: AppColors.onBackground, height: 1.2),
        ),
        SizedBox(height: 8),
        Text(
          "استعد لمغامرة تعليمية مشوقة!",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.onSurfaceVariant),
        ),
      ],
    );
  }

  // تصميم الـ Bento (العنصر الكبير على اليمين، والاثنين الصغار على اليسار)
  Widget _buildCategoriesBento() {
    return SizedBox(
      height: 250,
      child: Row(
        children: [
          // العنصر الكبير (جداول الضرب)
          Expanded(
            flex: 3,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: AppColors.primaryContainer.withOpacity(0.4), blurRadius: 15, offset: const Offset(0, 10))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Icon(Icons.calculate_rounded, color: AppColors.onPrimaryContainer, size: 40),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("جداول الضرب", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.onPrimaryContainer)),
                      Text("رحلة الأرقام", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black45)),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                    child: const Text("ابدأ الآن", style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w900)),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 16),
          // العناصر الصغيرة
          Expanded(
            flex: 2,
            child: Column(
              children: [
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(color: AppColors.secondaryContainer, borderRadius: BorderRadius.circular(20)),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.view_quilt_rounded, color: AppColors.onSecondaryContainer, size: 30),
                        SizedBox(height: 8),
                        Text("القسمة", style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.onSecondaryContainer)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(color: AppColors.tertiaryContainer, borderRadius: BorderRadius.circular(20)),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.auto_stories_rounded, color: AppColors.onTertiaryContainer, size: 30),
                        SizedBox(height: 8),
                        Text("الإعراب", style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.onTertiaryContainer)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSuggestedCardsHeader() {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text("البطاقات المقترحة لك", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.onBackground)),
        Icon(Icons.more_horiz, color: AppColors.onSurfaceVariant),
      ],
    );
  }

  // شبكة البطاقات التي تستخدم ويدجت FlipCard
  Widget _buildFlashcardsGrid() {
    return GridView.count(
      crossAxisCount: 2, // كرتين في كل صف
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 20,
      crossAxisSpacing: 20,
      childAspectRatio: 0.8, // نسبة الطول للعرض لتكون البطاقة مستطيلة للأعلى
      children: const [
        FlashcardFlip(
          frontIcon: "✖️",
          frontTitle: "٩ × ٨ = ؟",
          backTitle: "٧٢",
          backSubtitle: "عمل رائع! بطل الضرب",
          themeColor: AppColors.primaryContainer,
        ),
        FlashcardFlip(
          frontIcon: "➗",
          frontTitle: "٤٥ ÷ ٥ = ؟",
          backTitle: "٩",
          backSubtitle: "أحسنت التقسيم!",
          themeColor: AppColors.secondaryContainer,
        ),
        FlashcardFlip(
          frontIcon: "📖",
          frontSubtitle: "موقع كلمة (العلمُ)",
          frontTitle: "إعراب العلمُ؟",
          backTitle: "مبتدأ مرفوع",
          backSubtitle: "يا لك من نحوي ذكي!",
          themeColor: AppColors.tertiaryContainer,
        ),
        FlashcardFlip(
          frontIcon: "🚀",
          frontTitle: "١٢ × ١٢ = ؟",
          backTitle: "١٤٤",
          backSubtitle: "انطلاق صاروخي!",
          themeColor: AppColors.outlineVariant,
        ),
      ],
    );
  }
}