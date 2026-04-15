import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/widgets/custom_bottom_nav.dart';

class AdditionGameScreen extends StatelessWidget {
  const AdditionGameScreen({super.key});

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
                const CustomAppBar(score: 125),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                    child: Column(
                      children: [
                        _buildHeader(),
                        const SizedBox(height: 30),
                        _buildEquationCard(),
                        const SizedBox(height: 40),
                        _buildAnswerChoices(),
                        const SizedBox(height: 40),
                        _buildProgressIndicator(),
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
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.secondaryContainer,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(color: AppColors.secondaryContainer.withOpacity(0.5), blurRadius: 10)
            ],
          ),
          child: const Text(
            "الرياضيات",
            style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.onSecondaryContainer),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          "كم المجموع يا بطل؟",
          style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: AppColors.onBackground),
        ),
        const SizedBox(height: 8),
        const Text(
          "اختر الإجابة الصحيحة لتحصل على النجوم!",
          style: TextStyle(fontSize: 16, color: AppColors.onSurfaceVariant),
        ),
      ],
    );
  }

  Widget _buildEquationCard() {
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.surfaceContainer, width: 4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("1", style: TextStyle(fontSize: 80, fontWeight: FontWeight.w900)),
          const SizedBox(width: 20),
          const Text("+", style: TextStyle(fontSize: 60, fontWeight: FontWeight.w900, color: AppColors.primary)),
          const SizedBox(width: 20),
          const Text("2", style: TextStyle(fontSize: 80, fontWeight: FontWeight.w900)),
          const SizedBox(width: 20),
          const Text("=", style: TextStyle(fontSize: 60, fontWeight: FontWeight.w900, color: AppColors.secondary)),
          const SizedBox(width: 20),
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.tertiaryContainer.withOpacity(0.3),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.tertiaryContainer,
                width: 3,
                style: BorderStyle.solid,
              ),
            ),
            child: const Center(
              child: Text("؟", style: TextStyle(fontSize: 40, fontWeight: FontWeight.w900, color: AppColors.tertiary)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnswerChoices() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _AnswerButton(text: "2", color: AppColors.secondaryContainer, shadowColor: AppColors.secondary),
        _AnswerButton(text: "3", color: AppColors.primaryContainer, shadowColor: AppColors.primary, isCorrect: true),
        _AnswerButton(text: "4", color: AppColors.tertiaryContainer, shadowColor: AppColors.tertiary),
      ],
    );
  }

  Widget _buildProgressIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: index == 2 ? 30 : 15,
          height: index == 2 ? 30 : 15,
          decoration: BoxDecoration(
            color: index < 2
                ? AppColors.outlineVariant
                : (index == 2 ? AppColors.tertiaryContainer : AppColors.surfaceContainerHigh),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 3),
          ),
        );
      }),
    );
  }
}

// ويدجت زر الإجابة (تأثير 3D)
class _AnswerButton extends StatelessWidget {
  final String text;
  final Color color;
  final Color shadowColor;
  final bool isCorrect;

  const _AnswerButton({
    required this.text,
    required this.color,
    required this.shadowColor,
    this.isCorrect = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: isCorrect ? 100 : 80,
      height: isCorrect ? 100 : 80,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: shadowColor.withOpacity(0.8), offset: const Offset(0, 6)),
          if (isCorrect) BoxShadow(color: color, blurRadius: 20, spreadRadius: 5)
        ],
      ),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            fontSize: isCorrect ? 50 : 40,
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}