import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/custom_app_bar.dart';
import '../../core/widgets/custom_drawer.dart';
import 'widgets/flip_card.dart';

class FlashcardsScreen6to7 extends StatefulWidget {
  const FlashcardsScreen6to7({super.key});
  @override
  State<FlashcardsScreen6to7> createState() => _FlashcardsScreen6to7State();
}

class _FlashcardsScreen6to7State extends State<FlashcardsScreen6to7> {
  String _selectedCategory = "even_odd";

  // 🟢 ميزة جديدة: قائمة بيانات مضاعفات الأعداد كاملة من 2 إلى 10
  final List<Map<String, String>> _multiplesData = [
    {"q": "مضاعفات العدد 2؟", "a": "2, 4, 6, 8, 10", "sub": "نزيد 2 في كل مرة! 🎈"},
    {"q": "مضاعفات العدد 3؟", "a": "3, 6, 9, 12, 15", "sub": "نزيد 3 في كل مرة! 🎈"},
    {"q": "مضاعفات العدد 4؟", "a": "4, 8, 12, 16, 20", "sub": "نزيد 4 في كل مرة! 🎈"},
    {"q": "مضاعفات العدد 5؟", "a": "5, 10, 15, 20, 25", "sub": "نزيد 5 في كل مرة! 🎈"},
    {"q": "مضاعفات العدد 6؟", "a": "6, 12, 18, 24, 30", "sub": "نزيد 6 في كل مرة! 🎈"},
    {"q": "مضاعفات العدد 7؟", "a": "7, 14, 21, 28, 35", "sub": "نزيد 7 في كل مرة! 🎈"},
    {"q": "مضاعفات العدد 8؟", "a": "8, 16, 24, 32, 40", "sub": "نزيد 8 في كل مرة! 🎈"},
    {"q": "مضاعفات العدد 9؟", "a": "9, 18, 27, 36, 45", "sub": "نزيد 9 في كل مرة! 🎈"},
    {"q": "مضاعفات العدد 10؟", "a": "10, 20, 30, 40, 50", "sub": "الجدول الأسهل! نزيد 10 دائمًا."},
  ];

  // 🟢 ميزة جديدة: كروت المقارنة مع أمثلة عملية توضيحية للأطفال
  final List<Map<String, String>> _compareData = [
    {"q": "علامة الأكبر من؟", "a": " [ > ] ", "sub": "تفتح فمها دائماً للعدد الكبير!\nمثال: 5 > 3"},
    {"q": "علامة الأصغر من؟", "a": " [ < ] ", "sub": "تشير دائماً للعدد الصغير!\nمثال: 2 < 7"},
    {"q": "علامة اليساوي؟", "a": " [ = ] ", "sub": "تُستعمل عندما تتساوى الأعداد!\nمثال: 4 = 4"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      drawer: const CustomDrawer(currentIndex: 2),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const CustomAppBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    _buildHeroHeader(),
                    const SizedBox(height: 30),
                    _buildCategoriesBento(),
                    const SizedBox(height: 40),
                    _buildSuggestedCardsHeader(),
                    const SizedBox(height: 20),
                    _buildFlashcardsGrid(), // استدعاء دالة بناء الكروت المصححة
                    const SizedBox(height: 50),
                    _buildPlayroomDecor(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroHeader() => const Column(children: [Text("اختر بطاقة لتبدأ التعلم!", textAlign: TextAlign.center, style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: AppColors.onBackground, height: 1.2)), SizedBox(height: 8), Text("تعلم الأرقام والمقارنات بطريقة ممتعة وسهلة!", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.onSurfaceVariant))]);

  Widget _buildCategoriesBento() => SizedBox(height: 250, child: Row(children: [Expanded(flex: 2, child: GestureDetector(onTap: () => setState(() => _selectedCategory = "even_odd"), child: Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: _selectedCategory == "even_odd" ? AppColors.surfaceContainer : Colors.white, borderRadius: BorderRadius.circular(20), border: _selectedCategory == "even_odd" ? Border.all(color: AppColors.outlineVariant, width: 3) : null, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]), child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text("الأعداد الزوجية والفردية", style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.onSurface, height: 1.2)), SizedBox(height: 8), Text("تعلم الفرق بين الأرقام بطريقة ممتعة!", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.onSurfaceVariant, fontSize: 12)), Spacer(), Icon(Icons.numbers_rounded, color: AppColors.outline, size: 40)])))), const SizedBox(width: 16), Expanded(flex: 1, child: Column(children: [_buildSmallCategory("multiples", Icons.calculate_rounded, "مضاعفات\nالأعداد", AppColors.secondaryContainer, AppColors.onSecondaryContainer), const SizedBox(height: 16), _buildSmallCategory("compare", Icons.unfold_more_rounded, "الأكبر\nوالأصغر", AppColors.tertiaryContainer, AppColors.onTertiaryContainer)]))]));
  Widget _buildSmallCategory(String categoryId, IconData icon, String title, Color bgColor, Color iconColor) { bool isSelected = _selectedCategory == categoryId; return Expanded(child: GestureDetector(onTap: () => setState(() => _selectedCategory = categoryId), child: Container(width: double.infinity, decoration: BoxDecoration(color: isSelected ? bgColor : Colors.white, borderRadius: BorderRadius.circular(20), border: isSelected ? Border.all(color: iconColor, width: 3) : null), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icon, color: isSelected ? iconColor : AppColors.onSurfaceVariant, size: 36), const SizedBox(height: 8), Text(title, textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w900, color: isSelected ? iconColor : AppColors.onSurfaceVariant, fontSize: 14))])))); }
  Widget _buildSuggestedCardsHeader() => const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text("البطاقات المقترحة لك", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.onBackground)), Icon(Icons.more_horiz, color: AppColors.onSurfaceVariant)]);

  // ✅ تم تحويل هذه الدالة لتصبح دالة نظامية (Block Method) مصلحة للأقواس وتعمل ديناميكياً 100%
  Widget _buildFlashcardsGrid() {
    if (_selectedCategory == "even_odd") {
      return  GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        mainAxisSpacing: 20,
        crossAxisSpacing: 20,
        childAspectRatio: 0.8,
        children: [
          FlashcardFlip(frontIcon: "❓", frontTitle: "ما هو العدد الزوجي؟", backTitle: "يقبل القسمة على 2", backSubtitle: "مثل: 2, 4, 6, 8", themeColor: AppColors.primaryContainer),
          FlashcardFlip(frontIcon: "❓", frontTitle: "ما هو العدد الفردي؟", backTitle: "لا يقبل القسمة على 2", backSubtitle: "مثل: 1, 3, 5, 7", themeColor: AppColors.secondaryContainer),
        ],
      );
    } else if (_selectedCategory == "multiples") {
      // توليد الكروت من القائمة الشاملة من 2 لـ 10 ديناميكياً
      return GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 20,
        crossAxisSpacing: 20,
        childAspectRatio: 0.8,
        children: _multiplesData.map((data) => FlashcardFlip(
          frontIcon: "🔢",
          frontTitle: data["q"]!,
          backTitle: data["a"]!,
          backSubtitle: data["sub"]!,
          themeColor: AppColors.secondaryContainer,
        )).toList(),
      );
    } else {
      // توليد كروت المقارنة مع الأمثلة الجديدة
      return GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 20,
        crossAxisSpacing: 20,
        childAspectRatio: 0.8,
        children: _compareData.map((data) => FlashcardFlip(
          frontIcon: "↔️",
          frontTitle: data["q"]!,
          backTitle: data["a"]!,
          backSubtitle: data["sub"]!,
          themeColor: AppColors.tertiaryContainer,
        )).toList(),
      );
    }
  }

  Widget _buildProgressBubbles() => Row(mainAxisAlignment: MainAxisAlignment.center, children: [_buildBubble(color: const Color(0xFF67E100), child: const Icon(Icons.check, color: Colors.white, size: 20)), _buildBubble(color: const Color(0xFFFFE170), size: 40, child: const Text("1", style: TextStyle(color: Color(0xFF615000), fontWeight: FontWeight.w900, fontSize: 20))), _buildBubble(color: AppColors.surfaceContainerHigh), _buildBubble(color: AppColors.surfaceContainerHigh), _buildBubble(color: AppColors.surfaceContainerHigh)]);
  Widget _buildBubble({required Color color, double size = 30, Widget? child}) => Container(margin: const EdgeInsets.symmetric(horizontal: 4), width: size, height: size, decoration: BoxDecoration(color: color, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 3), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 5)]), child: Center(child: child));

  Widget _buildPlayroomDecor() {
    final tiles = [
      {"icon": Icons.calculate_rounded, "color": AppColors.primaryContainer},
      {"icon": Icons.emoji_objects_rounded, "color": AppColors.secondaryContainer},
      {"icon": Icons.auto_awesome_rounded, "color": AppColors.tertiaryContainer},
      {"icon": Icons.casino_rounded, "color": AppColors.outlineVariant},
    ];
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.4,
      children: tiles.map((t) => Container(
        decoration: BoxDecoration(
          color: (t["color"] as Color).withOpacity(0.5),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(t["icon"] as IconData, size: 44, color: Colors.white),
      )).toList(),
    );
  }
}