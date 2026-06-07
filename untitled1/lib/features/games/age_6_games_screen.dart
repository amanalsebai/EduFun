import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/custom_app_bar.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/custom_drawer.dart';
import 'widgets/category_card.dart';
import 'widgets/next_level_unlock_card.dart'; // ✅ بطاقة فتح المستوى التالي

import 'language/word_game_screen.dart';
import 'cognitive/color_matching_screen.dart';
import 'math/addition_game_screen.dart';
import 'age_7_games_screen.dart'; // ✅ ألعاب المستوى التالي (٧ سنوات)

class Age6GamesScreen extends StatelessWidget {
  const Age6GamesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryContainer,
      drawer: const CustomDrawer(currentIndex: 0),
      body: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.05,
              child: CustomPaint(painter: _DotPatternPainter()),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                const CustomAppBar(), // تم إزالة الـ score
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.only(left: 24, right: 24, top: 24, bottom: 40),
                    children: [
                      _buildGreetingCard(),
                      const SizedBox(height: 30),
                      CategoryCard(
                        title: "ترتيب الكلمات",
                        imageUrl: "https://lh3.googleusercontent.com/aida-public/AB6AXuCz0YYSyQeDnWmL0b4gdAySCu0Qgvh2FWLi0ic358y4BdCph8ufNJ-d6l4bS5HqR5UMyUV5yrkXaLi6foWMffaRv7lkhfNpyL_l8eZUzdj5cxk7bIlkXuyKN_gB5DjlXT7OQRtQHxxm4m7Ho3cCGwd_Ys2ec0mjyDB85iwOz3DdFy-SBC5hChc0v7wWh5tQ5c1oBjIKZLisuPFJdplK7w7NoiVnepuCdskmmnYH_xM4ppE1aQq9bytQBi8wE_jIX0h1TFBZUCjKwmPv",
                        icon: Icons.extension_rounded,
                        themeColor: const Color(0xFF80FF2C),
                        shadowColor: const Color(0xFF3B8700),
                        buttonText: "ابدأ اللعب",
                        rotationAngle: 0.0,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const WordGameScreen())),
                      ),
                      CategoryCard(
                        title: "توصيل الألوان",
                        imageUrl: "https://lh3.googleusercontent.com/aida-public/AB6AXuAfiuhh9QjaKI9pk5L2_j2yPE14rdQohNmpq10yJbokH6lgmEM0AgMkfOmYoU380GV252HJu6EK8ZbNWMLO1AH_NB7UULcvfyOH8NPYC8gjZczkz_1J0CUTGhh1SC9w9eNSZo4s_Y_1eQmT9EjkSzKEYd-z3SambUm5-Pbh2ipWK4AQh9Qr3Ooe9BS89M-wRFnPF7XqQ80IGMaaQirrnl-BBBF_iQGjQFFHuIFRsxOQI4vmnXyYr3svagbP2y3TARa6tsfKxwG8Drrc",
                        icon: Icons.palette_rounded,
                        themeColor: const Color(0xFFFF8FA9),
                        shadowColor: const Color(0xFF9C3756),
                        buttonText: "العب الآن",
                        rotationAngle: -0.02,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ColorMatchingScreen())),
                      ),
                      CategoryCard(
                        title: "الرياضيات الممتعة",
                        imageUrl: "https://lh3.googleusercontent.com/aida-public/AB6AXuCBm7T9vri555h1r35PNG0q6gdXb8pqYcZsw0sMR2Q8gu5vhYlmxXs7WW0lwHMqZEg5X__jeiqLrNnBopa0_vZ3jvi00qb02A2v0erox77VVKp-bAH02G4Q6LExL9r3qUtoXHdHxl50hgGPQa5XiCl0fo0ymZDufFjt4dX196AWutiorrn9D7cN2ynZVEbPbNqva5LHA_lOkD_0bidng_6dFwK22WUkZw8oOfzuBuGa-lqStW5-1JKk56rdBUzvvfN_EtMbYdosm0xh",
                        icon: Icons.calculate_rounded,
                        themeColor: const Color(0xFFA7D7FF),
                        shadowColor: const Color(0xFF004C71),
                        buttonText: "هيا بنا!",
                        rotationAngle: 0.02,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AdditionGameScreen())),
                      ),
                      const SizedBox(height: 10),
                      // ✅ يفتح ألعاب المستوى التالي عند إنهاء كل ألعاب هذا المستوى
                      NextLevelUnlockCard(
                        age: 6,
                        onGoToNextLevel: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const Age7GamesScreen()),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGreetingCard() {
    return Transform.rotate(
      angle: 0.02,
      child: GlassCard(
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("مرحباً بك، يا بطل!", style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: AppColors.onSurface)),
                SizedBox(height: 4),
                Text("أي عالم ستستكشفه اليوم؟", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.onSurfaceVariant)),
              ],
            ),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.5), shape: BoxShape.circle),
              child: const Icon(Icons.celebration_rounded, color: AppColors.tertiary, size: 30),
            ),
          ],
        ),
      ),
    );
  }
}

class _DotPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFF645300)..style = PaintingStyle.fill;
    for (double y = 0; y < size.height; y += 40) {
      for (double x = 0; x < size.width; x += 40) {
        canvas.drawCircle(Offset(x, y), 2, paint);
      }
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}