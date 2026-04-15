import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class CategoryCard extends StatelessWidget {
  final String title;
  final String imageUrl;
  final IconData icon;
  final Color themeColor;
  final Color shadowColor;
  final String buttonText;
  final double rotationAngle; // لعمل ميلان خفيف للبطاقة
  final VoidCallback onTap;

  const CategoryCard({
    super.key,
    required this.title,
    required this.imageUrl,
    required this.icon,
    required this.themeColor,
    required this.shadowColor,
    required this.buttonText,
    this.rotationAngle = 0.0,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Transform.rotate(
        angle: rotationAngle,
        child: Container(
          margin: const EdgeInsets.only(bottom: 24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            // تأثير 3D (الحد السفلي السميك والظل)
            border: Border(bottom: BorderSide(color: shadowColor, width: 8)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 15,
                offset: const Offset(0, 10),
              )
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // الجزء العلوي (الصورة مع التدرج والأيقونة)
              SizedBox(
                height: 180,
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // الصورة الخلفية
                      Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            Container(color: themeColor.withOpacity(0.3), child: const Icon(Icons.image, size: 50)),
                      ),
                      // تدرج لوني من الأسفل لدمج الصورة مع الكارت الأبيض
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [Colors.white, Colors.white.withOpacity(0.0)],
                            stops: const [0.0, 0.5],
                          ),
                        ),
                      ),
                      // الأيقونة الدائرية في الزاوية العلوية
                      Positioned(
                        top: 16,
                        right: 16, // يسار الشاشة لأننا RTL
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            shape: BoxShape.circle,
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)],
                          ),
                          child: Icon(icon, color: shadowColor, size: 30),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // الجزء السفلي (النص والزر)
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // زر اللعب (مدمج داخل البطاقة)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: themeColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border(bottom: BorderSide(color: shadowColor, width: 4)),
                      ),
                      child: Text(
                        buttonText,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: AppColors.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}