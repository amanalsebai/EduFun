import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/custom_app_bar.dart';
import '../../core/widgets/custom_drawer.dart';
import 'data/flashcards_data.dart';
import 'widgets/flip_card.dart';

class FlashcardsScreen8to9 extends StatefulWidget {
  const FlashcardsScreen8to9({super.key});

  @override
  State<FlashcardsScreen8to9> createState() => _FlashcardsScreen8to9State();
}

class _FlashcardsScreen8to9State extends State<FlashcardsScreen8to9> {
  // التصنيف الافتراضي المختار هو "جداول الضرب"
  String _selectedCategory = "multiplication";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const CustomDrawer(currentIndex: 2),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const CustomAppBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(left: 24, right: 24, top: 24, bottom: 40),
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
          "استعد لمغامرة تعليمية مشوقة في الفضاء الواسع",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.onSurfaceVariant),
        ),
      ],
    );
  }

  // بناء قسم الـ Bento العلوي التفاعلي (الأقسام)
  Widget _buildCategoriesBento() {
    return SizedBox(
      height: 250,
      child: Row(
        children: [
          // البطاقة الكبيرة (جداول الضرب)
          Expanded(
            flex: 3,
            child: GestureDetector(
              onTap: () => setState(() => _selectedCategory = "multiplication"),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: _selectedCategory == "multiplication" ? AppColors.primaryContainer : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: _selectedCategory == "multiplication" ? Border.all(color: AppColors.primary, width: 3) : null,
                  boxShadow: [
                    BoxShadow(color: AppColors.primary.withOpacity(0.2), blurRadius: 15, offset: const Offset(0, 10))
                  ],
                ),
                child: Stack(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Icon(
                          Icons.calculate_rounded,
                          color: _selectedCategory == "multiplication" ? AppColors.onPrimaryContainer : AppColors.primary,
                          size: 40,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "جداول الضرب",
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                color: _selectedCategory == "multiplication" ? AppColors.onPrimaryContainer : AppColors.primary,
                              ),
                            ),
                            const Text("رحلة الأرقام السريعة", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black45)),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                          child: Text(
                            "تحديد القسم",
                            style: TextStyle(
                              color: _selectedCategory == "multiplication" ? AppColors.primary : AppColors.onSurfaceVariant,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Positioned(
                      bottom: 0, left: 0,
                      child: Opacity(
                        opacity: 0.15,
                        child: Icon(Icons.functions_rounded, size: 100, color: AppColors.primary),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // البطاقتان الصغيرتان على اليسار
          Expanded(
            flex: 2,
            child: Column(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedCategory = "division"),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: _selectedCategory == "division" ? AppColors.secondaryContainer : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: _selectedCategory == "division" ? Border.all(color: AppColors.secondary, width: 3) : null,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.view_quilt_rounded, color: _selectedCategory == "division" ? AppColors.onSecondaryContainer : AppColors.secondary, size: 30),
                          const SizedBox(height: 8),
                          Text("أساسيات القسمة", style: TextStyle(fontWeight: FontWeight.w900, color: _selectedCategory == "division" ? AppColors.onSecondaryContainer : AppColors.onSurfaceVariant, fontSize: 13)),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedCategory = "grammar"),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: _selectedCategory == "grammar" ? AppColors.tertiaryContainer : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: _selectedCategory == "grammar" ? Border.all(color: AppColors.tertiary, width: 3) : null,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.auto_stories_rounded, color: _selectedCategory == "grammar" ? AppColors.onTertiaryContainer : AppColors.tertiary, size: 30),
                          const SizedBox(height: 8),
                          Text("أمثلة للإعراب", style: TextStyle(fontWeight: FontWeight.w900, color: _selectedCategory == "grammar" ? AppColors.onTertiaryContainer : AppColors.onSurfaceVariant, fontSize: 13)),
                        ],
                      ),
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

  // ألوان البطاقات تتناوب حسب ترتيب البطاقة في الشبكة
  static const List<Color> _cardColors = [AppColors.primaryContainer, AppColors.secondaryContainer, AppColors.tertiaryContainer, AppColors.outlineVariant];

  // بناء شبكة الكروت التفاعلية — المحتوى من data/flashcards_data.dart
  Widget _buildFlashcardsGrid() {
    final cards = _selectedCategory == "multiplication"
        ? multiplicationCards8to9
        : (_selectedCategory == "division" ? divisionCards8to9 : grammarCards8to9);
    // بطاقات جداول الضرب أطول لتتسع للجدول الكامل على ظهرها
    final aspectRatio = _selectedCategory == "multiplication" ? 0.55 : 0.8;
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 20,
      crossAxisSpacing: 20,
      childAspectRatio: aspectRatio,
      children: [
        for (int i = 0; i < cards.length; i++)
          FlashcardFlip(
            frontIcon: cards[i].icon,
            frontTitle: cards[i].title,
            frontSubtitle: cards[i].subtitle,
            backTitle: cards[i].backTitle,
            backSubtitle: cards[i].backSubtitle,
            backLines: cards[i].backLines,
            themeColor: _cardColors[i % _cardColors.length],
          ),
      ],
    );
  }
}