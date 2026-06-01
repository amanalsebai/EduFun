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
  Widget _buildFlashcardsGrid() => _selectedCategory == "even_odd" ?  GridView.count(crossAxisCount: 2, shrinkWrap: true, physics: NeverScrollableScrollPhysics(), mainAxisSpacing: 20, crossAxisSpacing: 20, childAspectRatio: 0.8, children: [FlashcardFlip(frontIcon: "❓", frontTitle: "ما هو العدد الزوجي؟", backTitle: "يقبل القسمة على 2", backSubtitle: "مثل: 2, 4, 6, 8", themeColor: AppColors.primaryContainer), FlashcardFlip(frontIcon: "❓", frontTitle: "ما هو العدد الفردي؟", backTitle: "لا يقبل القسمة على 2", backSubtitle: "مثل: 1, 3, 5, 7", themeColor: AppColors.secondaryContainer)]) : (_selectedCategory == "multiples" ?  GridView.count(crossAxisCount: 2, shrinkWrap: true, physics: NeverScrollableScrollPhysics(), mainAxisSpacing: 20, crossAxisSpacing: 20, childAspectRatio: 0.8, children: [FlashcardFlip(frontIcon: "🔢", frontTitle: "مضاعفات العدد 2؟", backTitle: "2, 4, 6, 8, 10", backSubtitle: "نزيد 2 في كل مرة!", themeColor: AppColors.primaryContainer), FlashcardFlip(frontIcon: "🔢", frontTitle: "مضاعفات العدد 5؟", backTitle: "5, 10, 15, 20", backSubtitle: "نزيد 5 في كل مرة!", themeColor: AppColors.secondaryContainer)]) :  GridView.count(crossAxisCount: 2, shrinkWrap: true, physics: NeverScrollableScrollPhysics(), mainAxisSpacing: 20, crossAxisSpacing: 20, childAspectRatio: 0.8, children: [FlashcardFlip(frontIcon: "↔️", frontTitle: "علامة الأكبر من؟", backTitle: " [ < ] ", backSubtitle: "تفتح فمها دائماً للعدد الكبير!", themeColor: AppColors.primaryContainer), FlashcardFlip(frontIcon: "↔️", frontTitle: "علامة الأصغر من؟", backTitle: " [ > ] ", backSubtitle: "تشير للعدد الصغير!", themeColor: AppColors.secondaryContainer)]));
  Widget _buildProgressBubbles() => Row(mainAxisAlignment: MainAxisAlignment.center, children: [_buildBubble(color: const Color(0xFF67E100), child: const Icon(Icons.check, color: Colors.white, size: 20)), _buildBubble(color: const Color(0xFFFFE170), size: 40, child: const Text("1", style: TextStyle(color: Color(0xFF615000), fontWeight: FontWeight.w900, fontSize: 20))), _buildBubble(color: AppColors.surfaceContainerHigh), _buildBubble(color: AppColors.surfaceContainerHigh), _buildBubble(color: AppColors.surfaceContainerHigh)]);
  Widget _buildBubble({required Color color, double size = 30, Widget? child}) => Container(margin: const EdgeInsets.symmetric(horizontal: 4), width: size, height: size, decoration: BoxDecoration(color: color, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 3), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 5)]), child: Center(child: child));
  Widget _buildPlayroomDecor() { final images = [ "https://lh3.googleusercontent.com/aida-public/AB6AXuAY5Ef1h7eLRT_7LbEhrY-g7jwvVAvwYXY7eIdRZPqLT5c6VQ2wESRFwXK-kl1vq9gsdIuSB-iH0383AtlWz6fmyQ860JzAfARZnQQDZg23iuWCNml6VuXl8WSX-aIKv7cNzMubeNwcE_yJfE_i-KTAC7k7n1Zt8lUwkzEcq92fR38gRogYo0BKYl33nCPughRPNUKLArrS_j0GzDLWBJpKXOpjWn8O79IVwk9OyyFm3wr5Z7Km7L5jRgcXmyMFhIDuc_HAWUcqtW_B", "https://lh3.googleusercontent.com/aida-public/AB6AXuA_D_9yKrwdx5rSk-GrYKCudIMLHm-Mubo0zWkQS1QhKO1MpeSwRY6BRKK2mWC2ExuQbAyzri-WqKnr37JSBAdojf1fuveAzvgGD6NwfLp5g8jLl13exuRSCncBDYf6v52qV182maqlkjVZ2UflnxvPrhxDXGeytpQlHc6yUb8PK6EjPnul8KZBWHr6H1ov68vKZMpncs7mTvQ-TUUgH8KquLHbmSvVjW3TMGF0opOqcNMGjj_0Op6KeFQnVH9ajqIiDKu9ecObIDoX", "https://lh3.googleusercontent.com/aida-public/AB6AXuCPTOXQieSMvda3Y_8lJvi9vuExh3UzST4KeoJ9Cyru3u4Xn3HXmsoy5mVJS3-awd2Nph3Q8c3ze_xKru7zKux6IAFGLrnvjsCs_4n1HFg2mhRPURmnm0dc0hVVIpsNZ_bDwnYDb3fQxMAD3HbbPYOGdm8Hos3latRMk6RXjz5fdYfvAE-SMbvh0_4id1-QJKxFQYWrmyp9jFnvGim3xEUjKF7ZikGSrBHBqQP35nlHr1Rjk4csjDzUAd6QQUARBFJqucWr6o9PIMkc", "https://lh3.googleusercontent.com/aida-public/AB6AXuCQOtT-mqNlC05xmgFut0LtUJ919ap72mRfhgBkFQQ8ZraDEHSSgR2K601u0KtEjVGGp828rHBWB4fZcAl9Lzj15KUZ6lyL1dvhJhFe6isVq5vimOLHuGqwUz07GBfPuPpf70AmG6L9FqyfDEz__w-BKIltJ3ANlYdtXZgi95kYFcw_s0Jcyycfw3WiNzq9ag4EaTVc2kGRvxQRZVaUdmOgVdPHaKZ5zmt3iy7Ab8Ojbi6wk171X6MoAKdKW1LRKmnxtF5nWHtTUvYf" ]; return GridView.count(crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), mainAxisSpacing: 16, crossAxisSpacing: 16, children: images.map((url) => ClipRRect(borderRadius: BorderRadius.circular(16), child: Image.network(url, fit: BoxFit.cover, color: Colors.white.withOpacity(0.8), colorBlendMode: BlendMode.dstATop))).toList()); }
}