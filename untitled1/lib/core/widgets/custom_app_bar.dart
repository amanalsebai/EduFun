import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../utils/score_manager.dart'; // ✅ استيراد متحكم النقاط الذكي

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  final bool showBackButton;

  // البناء الموحد بدون الحاجة لتمرير متغير score يدوياً بعد الآن
  const CustomAppBar({
    super.key,
    this.showBackButton = false,
  });

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();

  // تحديد الارتفاع المخصص للشريط العلوي
  @override
  Size get preferredSize => const Size.fromHeight(100);
}

class _CustomAppBarState extends State<CustomAppBar> {
  @override
  void initState() {
    super.initState();
    // قراءة النجوم المخزنة لمزامنة المُخطِر الحيّ مع ذاكرة الهاتف
    ScoreManager.getStars();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 40, left: 24, right: 24, bottom: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFE4FFCD), Color(0xFFCEFFAC)],
        ),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(48)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6D5A00).withOpacity(0.1),
            blurRadius: 30,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              // التنقل الذكي: إما زر الرجوع السهم أو فتح القائمة الجانبية
              if (widget.showBackButton)
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.onBackground, size: 28),
                  onPressed: () => Navigator.of(context).pop(),
                )
              else
                IconButton(
                  icon: const Icon(Icons.menu_rounded, color: AppColors.onBackground, size: 32),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
              const SizedBox(width: 8),
              const Text(
                "Play & Learn",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  fontStyle: FontStyle.italic,
                  color: AppColors.onBackground,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),

          // عرض النجوم الحقيقية والمحدثة تلقائياً
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.6),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: AppColors.outlineVariant.withOpacity(0.1)),
            ),
            child: Row(
              children: [
                const Text("⭐ ", style: TextStyle(fontSize: 16)),
                // ✅ يستمع للمُخطِر الحيّ فيتحدث الرقم فوراً عند ربح أي نجوم
                ValueListenableBuilder<int>(
                  valueListenable: ScoreManager.starsNotifier,
                  builder: (context, score, _) => Text(
                    "$score", // نقاط البطل الحقيقية والمحدّثة لحظياً
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
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
}