import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/custom_app_bar.dart';
import '../../core/widgets/custom_drawer.dart';
import 'data/flashcards_data.dart';
import 'widgets/flip_card.dart';

class FlashcardsScreen6to7 extends StatefulWidget {
  const FlashcardsScreen6to7({super.key});
  @override
  State<FlashcardsScreen6to7> createState() => _FlashcardsScreen6to7State();
}

class _FlashcardsScreen6to7State extends State<FlashcardsScreen6to7> {
  String _selectedCategory = "even_odd";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      drawer: const CustomDrawer(currentIndex: 2),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // ✅ تم تصحيح الـ CustomAppBar هنا بحذف الـ score
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
                    _buildFlashcardsGrid(),
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
  // ألوان البطاقات تتناوب حسب ترتيب البطاقة في الشبكة
  static const List<Color> _cardColors = [AppColors.primaryContainer, AppColors.secondaryContainer, AppColors.tertiaryContainer, AppColors.outlineVariant];

  Widget _buildFlashcardsGrid() {
    final cards = _selectedCategory == "even_odd"
        ? evenOddCards6to7
        : (_selectedCategory == "multiples" ? multiplesCards6to7 : compareCards6to7);
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 20,
      crossAxisSpacing: 20,
      childAspectRatio: 0.8,
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
  Widget _buildProgressBubbles() => Row(mainAxisAlignment: MainAxisAlignment.center, children: [_buildBubble(color: const Color(0xFF67E100), child: const Icon(Icons.check, color: Colors.white, size: 20)), _buildBubble(color: const Color(0xFFFFE170), size: 40, child: const Text("1", style: TextStyle(color: Color(0xFF615000), fontWeight: FontWeight.w900, fontSize: 20))), _buildBubble(color: AppColors.surfaceContainerHigh), _buildBubble(color: AppColors.surfaceContainerHigh), _buildBubble(color: AppColors.surfaceContainerHigh)]);
  Widget _buildBubble({required Color color, double size = 30, Widget? child}) => Container(margin: const EdgeInsets.symmetric(horizontal: 4), width: size, height: size, decoration: BoxDecoration(color: color, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 3), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 5)]), child: Center(child: child));
  // ✅ زخرفة غرفة اللعب بأيقونات ملوّنة ثابتة بدل صور الشبكة المؤقتة المكسورة
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