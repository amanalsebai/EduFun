import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final int score;
  final VoidCallback? onMenuTap;

  const CustomAppBar({
    super.key,
    this.score = 125,
    this.onMenuTap,
  });

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
              IconButton(
                icon: const Icon(Icons.menu_rounded, color: AppColors.onBackground, size: 32),
                onPressed: onMenuTap,
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
                Text(
                  "$score",
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

  @override
  Size get preferredSize => const Size.fromHeight(100);
}