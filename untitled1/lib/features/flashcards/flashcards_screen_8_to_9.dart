import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/custom_app_bar.dart';
import '../../core/widgets/custom_drawer.dart';
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
                        child: Image.network(
                          "https://lh3.googleusercontent.com/aida-public/AB6AXuDbyB07hDRgz9IgrmdeBD0VuLa29sVWUEiqX8zEkQt9Em4u5gBnxLS0Te26B2z62kPW5d9QDGYW2FPbiVhrqeTI4TQNSXB8ps_R490gMjqZiQ5wbDk3bR28SNvVp6G1wb4Tkr5gAZXM9RV6uvY4lFisE4FaTcMPm6KwZ5kC_kMuzbN3npG8SkJvTMR0rzypFVB4qXWNGV8_xacRntXi-Ap0ibdO9Et4BH6GjkovclKjjr_L3DApT7pJaSTBhBD7ME5XByvlOeyY0WKy",
                          width: 100, height: 100,
                        ),
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

  // بناء شبكة الكروت التفاعلية (أصلحنا دالة الاقواس بالكامل هنا)
  Widget _buildFlashcardsGrid() {
    if (_selectedCategory == "multiplication") {
      return GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        mainAxisSpacing: 20,
        crossAxisSpacing: 20,
        childAspectRatio: 0.8,
        children: [
          FlashcardFlip(
            frontIcon: "✖️",
            frontTitle: "٩ × ٨ = ؟",
            backTitle: "٧٢",
            backSubtitle: "عمل رائع! بطل الضرب",
            themeColor: AppColors.primaryContainer,
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
    } else if (_selectedCategory == "division") {
      return GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        mainAxisSpacing: 20,
        crossAxisSpacing: 20,
        childAspectRatio: 0.8,
        children: [
          FlashcardFlip(
            frontIcon: "➗",
            frontTitle: "٤٥ ÷ ٥ = ؟",
            backTitle: "٩",
            backSubtitle: "أحسنت القسمة يا بطل!",
            themeColor: AppColors.secondaryContainer,
          ),
          FlashcardFlip(
            frontIcon: "➗",
            frontTitle: "٣٦ ÷ ٦ = ؟",
            backTitle: "٦",
            backSubtitle: "مذهل وممتاز!",
            themeColor: AppColors.outlineVariant,
          ),
        ],
      );
    } else {
      return GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        mainAxisSpacing: 20,
        crossAxisSpacing: 20,
        childAspectRatio: 0.8,
        children: [
          FlashcardFlip(
            frontIcon: "📖",
            frontSubtitle: "موقع كلمة (العلمُ)",
            frontTitle: "إعراب العلمُ؟",
            backTitle: "مبتدأ مرفوع بالضمة",
            backSubtitle: "يا لك من نحوي ذكي!",
            themeColor: AppColors.tertiaryContainer,
          ),
          FlashcardFlip(
            frontIcon: "📖",
            frontSubtitle: "موقع كلمة (التفاحةَ)",
            frontTitle: "إعراب التفاحةَ؟",
            backTitle: "مفعول به منصوب",
            backSubtitle: "ممتاز وعبقري نحو!",
            themeColor: AppColors.outlineVariant,
          ),
        ],
      );
    }
  }
}