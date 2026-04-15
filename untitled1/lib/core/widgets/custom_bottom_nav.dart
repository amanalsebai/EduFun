import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class CustomBottomNav extends StatelessWidget {
  final int currentIndex;

  const CustomBottomNav({super.key, this.currentIndex = 0});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(40),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            height: 70,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.85),
              borderRadius: BorderRadius.circular(40),
              boxShadow: [
                BoxShadow(
                  color: AppColors.onBackground.withOpacity(0.08),
                  blurRadius: 40,
                  offset: const Offset(0, -10),
                )
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildNavItem(icon: Icons.home_rounded, label: "Home", index: 0, isActive: currentIndex == 0),
                _buildNavItem(icon: Icons.school_rounded, label: "Lessons", index: 1, isActive: currentIndex == 1),
                _buildNavItem(icon: Icons.style_rounded, label: "Cards", index: 2, isActive: currentIndex == 2),
                _buildNavItem(icon: Icons.settings_rounded, label: "Settings", index: 3, isActive: currentIndex == 3),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({required IconData icon, required String label, required int index, required bool isActive}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: EdgeInsets.symmetric(horizontal: isActive ? 20 : 12, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? AppColors.primaryContainer : Colors.transparent,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isActive ? Colors.white : AppColors.onBackground.withOpacity(0.6),
            size: isActive ? 28 : 24,
          ),
          if (isActive)
            Text(
              label.toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w900,
              ),
            ),
        ],
      ),
    );
  }
}