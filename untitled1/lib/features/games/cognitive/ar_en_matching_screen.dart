import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/widgets/custom_bottom_nav.dart';

class ArEnMatchingScreen extends StatelessWidget {
  const ArEnMatchingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                const CustomAppBar(score: 180),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(left: 24, right: 24, top: 20, bottom: 120),
                    child: Column(
                      children: [
                        _buildHeader(),
                        const SizedBox(height: 30),
                        _buildMatchingBoard(),
                        const SizedBox(height: 40),
                        _buildInfoBento(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: CustomBottomNav(currentIndex: 1),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.tertiaryContainer,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.tertiaryContainer.withOpacity(0.5),
                blurRadius: 15,
                offset: const Offset(0, 5),
              )
            ],
          ),
          child: Column(
            children: [
              const Text(
                "وصّل الكلمة بمعناها!",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.onTertiaryContainer),
              ),
              Text(
                "Match the word with its meaning!",
                style: TextStyle(color: AppColors.onTertiaryContainer.withOpacity(0.8), fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // فقاعات التقدم
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildProgressBubble(isActive: true),
            _buildProgressBubble(isActive: true),
            _buildProgressBubble(isActive: false),
          ],
        )
      ],
    );
  }

  Widget _buildProgressBubble({required bool isActive}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: 25,
      height: 25,
      decoration: BoxDecoration(
        color: isActive ? AppColors.outlineVariant : AppColors.surfaceContainerHigh,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 3),
      ),
    );
  }

  Widget _buildMatchingBoard() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // العمود الأيسر (الكلمات الإنجليزية)
        Expanded(
          child: Column(
            children: [
              _MatchingCard(
                text: "Apple",
                textColor: AppColors.secondary,
                borderColor: AppColors.secondaryContainer,
                isLeft: true,
                offset: const Offset(10, 0),
              ),
              _MatchingCard(
                text: "Dog",
                textColor: AppColors.secondary,
                borderColor: AppColors.secondaryContainer,
                isLeft: true,
                offset: const Offset(-15, 0),
              ),
              // البطاقة المختارة
              _MatchingCard(
                text: "Cat",
                textColor: AppColors.secondary,
                borderColor: AppColors.secondaryContainer,
                isLeft: true,
                offset: const Offset(5, 0),
                isSelected: true,
              ),
            ],
          ),
        ),
        const SizedBox(width: 20),
        // العمود الأيمن (الكلمات العربية)
        Expanded(
          child: Column(
            children: [
              _MatchingCard(
                text: "قطة",
                emoji: "🐱",
                textColor: AppColors.primary,
                borderColor: AppColors.primaryContainer,
                isLeft: false,
                offset: const Offset(0, 0),
              ),
              _MatchingCard(
                text: "كلب",
                emoji: "🐶",
                textColor: AppColors.primary,
                borderColor: AppColors.primaryContainer,
                isLeft: false,
                offset: const Offset(15, 0),
              ),
              _MatchingCard(
                text: "تفاحة",
                emoji: "🍎",
                textColor: AppColors.primary,
                borderColor: AppColors.primaryContainer,
                isLeft: false,
                offset: const Offset(-5, 0),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoBento() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "تعلم كلمات جديدة!",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.onBackground),
                ),
                const SizedBox(height: 8),
                Text(
                  "أكمل هذا المستوى لفتح بطاقات الحيوانات والفاكهة الجديدة.",
                  style: TextStyle(color: AppColors.onBackground.withOpacity(0.7)),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 1,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primaryContainer,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Column(
              children: [
                Icon(Icons.emoji_events, size: 30, color: AppColors.onPrimaryContainer),
                SizedBox(height: 8),
                Text(
                  "جائزة اليوم",
                  style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.onPrimaryContainer),
                ),
                Text("+50 XP", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.onPrimaryContainer)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _MatchingCard extends StatelessWidget {
  final String text;
  final String? emoji;
  final Color textColor;
  final Color borderColor;
  final bool isLeft;
  final Offset offset;
  final bool isSelected;

  const _MatchingCard({
    required this.text,
    this.emoji,
    required this.textColor,
    required this.borderColor,
    required this.isLeft,
    this.offset = Offset.zero,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: offset,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 12),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? borderColor.withOpacity(0.2) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: borderColor,
            width: isSelected ? 3 : 1,
            style: BorderStyle.solid,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: borderColor,
                blurRadius: 15,
              )
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isLeft)
              Container(width: 15, height: 15, decoration: BoxDecoration(shape: BoxShape.circle, color: borderColor)),
            const Spacer(),
            if (emoji != null) Text(emoji!, style: const TextStyle(fontSize: 24)),
            if (emoji != null) const SizedBox(width: 8),
            Text(
              text,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: textColor,
              ),
            ),
            const Spacer(),
            if (!isLeft)
              Container(width: 15, height: 15, decoration: BoxDecoration(shape: BoxShape.circle, color: borderColor)),
          ],
        ),
      ),
    );
  }
}