import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/custom_app_bar.dart';
import '../../core/widgets/custom_bottom_nav.dart';
import '../../core/widgets/glass_card.dart';
import 'widgets/category_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // لون الخلفية الأصفر كما في تصميم HTML
      backgroundColor: AppColors.primaryContainer,
      body: Stack(
        children: [
          // خلفية منقطة (محاكاة لـ radial-gradient في CSS)
          Positioned.fill(
            child: Opacity(
              opacity: 0.05,
              child: CustomPaint(painter: _DotPatternPainter()),
            ),
          ),

          // المحتوى الرئيسي
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                // الشريط العلوي الذي بنيناه سابقاً
                const CustomAppBar(score: 150),

                // قائمة الألعاب قابلة للتمرير
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.only(left: 24, right: 24, top: 24, bottom: 120),
                    children: [
                      _buildGreetingCard(),
                      const SizedBox(height: 30),

                      // لعبة 1: الكلمات
                      CategoryCard(
                        title: "ترتيب الكلمات",
                        imageUrl: "https://lh3.googleusercontent.com/aida-public/AB6AXuCz0YYSyQeDnWmL0b4gdAySCu0Qgvh2FWLi0ic358y4BdCph8ufNJ-d6l4bS5HqR5UMyUV5yrkXaLi6foWMffaRv7lkhfNpyL_l8eZUzdj5cxk7bIlkXuyKN_gB5DjlXT7OQRtQHxxm4m7Ho3cCGwd_Ys2ec0mjyDB85iwOz3DdFy-SBC5hChc0v7wWh5tQ5c1oBjIKZLisuPFJdplK7w7NoiVnepuCdskmmnYH_xM4ppE1aQq9bytQBi8wE_jIX0h1TFBZUCjKwmPv",
                        icon: Icons.extension_rounded,
                        themeColor: const Color(0xFF80FF2C), // أخضر
                        shadowColor: const Color(0xFF3B8700),
                        buttonText: "ابدأ اللعب",
                        rotationAngle: 0.0,
                        onTap: () {
                          // TODO: انتقال للعبة الكلمات
                        },
                      ),

                      // لعبة 2: الألوان (مائلة قليلاً لليسار)
                      CategoryCard(
                        title: "توصيل الألوان",
                        imageUrl: "https://lh3.googleusercontent.com/aida-public/AB6AXuAfiuhh9QjaKI9pk5L2_j2yPE14rdQohNmpq10yJbokH6lgmEM0AgMkfOmYoU380GV252HJu6EK8ZbNWMLO1AH_NB7UULcvfyOH8NPYC8gjZczkz_1J0CUTGhh1SC9w9eNSZo4s_Y_1eQmT9EjkSzKEYd-z3SambUm5-Pbh2ipWK4AQh9Qr3Ooe9BS89M-wRFnPF7XqQ80IGMaaQirrnl-BBBF_iQGjQFFHuIFRsxOQI4vmnXyYr3svagbP2y3TARa6tsfKxwG8Drrc",
                        icon: Icons.palette_rounded,
                        themeColor: const Color(0xFFFF8FA9), // وردي
                        shadowColor: const Color(0xFF9C3756),
                        buttonText: "العب الآن",
                        rotationAngle: -0.02,
                        onTap: () {
                          // TODO: انتقال للعبة الألوان
                        },
                      ),

                      // لعبة 3: الرياضيات (مائلة قليلاً لليمين)
                      CategoryCard(
                        title: "الرياضيات الممتعة",
                        imageUrl: "https://lh3.googleusercontent.com/aida-public/AB6AXuCBm7T9vri555h1r35PNG0q6gdXb8pqYcZsw0sMR2Q8gu5vhYlmxXs7WW0lwHMqZEg5X__jeiqLrNnBopa0_vZ3jvi00qb02A2v0erox77VVKp-bAH02G4Q6LExL9r3qUtoXHdHxl50hgGPQa5XiCl0fo0ymZDufFjt4dX196AWutiorrn9D7cN2ynZVEbPbNqva5LHA_lOkD_0bidng_6dFwK22WUkZw8oOfzuBuGa-lqStW5-1JKk56rdBUzvvfN_EtMbYdosm0xh",
                        icon: Icons.calculate_rounded,
                        themeColor: const Color(0xFFA7D7FF), // أزرق
                        shadowColor: const Color(0xFF004C71),
                        buttonText: "هيا بنا!",
                        rotationAngle: 0.02,
                        onTap: () {
                          // TODO: انتقال للعبة الرياضيات
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // شريط التنقل السفلي عائم
          const Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: CustomBottomNav(currentIndex: 0),
          ),
        ],
      ),
    );
  }

  // بطاقة الترحيب الزجاجية
  Widget _buildGreetingCard() {
    return Transform.rotate(
      angle: 0.02, // ميلان خفيف
      child: GlassCard(
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "مرحباً بك، يا بطل!",
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: AppColors.onSurface),
                ),
                SizedBox(height: 4),
                Text(
                  "أي عالم ستستكشفه اليوم؟",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.onSurfaceVariant),
                ),
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

// رسم الخلفية المنقطة (نقاط بنية خفيفة على الخلفية الصفراء)
class _DotPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF645300)
      ..style = PaintingStyle.fill;

    const double spacing = 40.0;
    const double radius = 2.0;

    for (double y = 0; y < size.height; y += spacing) {
      for (double x = 0; x < size.width; x += spacing) {
        canvas.drawCircle(Offset(x, y), radius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}