import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../utils/score_manager.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  final bool showBackButton;
  final bool isGlobal; // 🟢 هل نعرض المجموع الكلي (true) أم نقاط اللعبة الحالية فقط (false)؟
  final int sessionScore; // 🟢 نقاط اللعبة الحالية الممررة من الشاشة

  const CustomAppBar({
    super.key,
    this.showBackButton = false,
    this.isGlobal = true, // الافتراضي هو عرض المجموع الكلي
    this.sessionScore = 0,
  });

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();

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
          begin: Alignment.topCenter, end: Alignment.bottomCenter,
          colors: [Color(0xFFE4FFCD), Color(0xFFCEFFAC)],
        ),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(48)),
        boxShadow: [
          BoxShadow(color: const Color(0xFF6D5A00).withOpacity(0.1), blurRadius: 30, offset: const Offset(0, 10))
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
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
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic, color: AppColors.onBackground),
              ),
            ],
          ),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.6),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              children: [
                const Text("⭐ ", style: TextStyle(fontSize: 16)),
                if (widget.isGlobal)
                // ✅ إذا كان المطلوب عرض النجوم الكلية: يستمع للمُخطِر الحيّ ليتحدث الرقم فوراً
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
                  )
                else
                // 🟢 إذا كان المطلوب نقاط اللعبة الحالية فقط
                  Text(
                    "${widget.sessionScore}",
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
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