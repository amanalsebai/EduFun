import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/custom_app_bar.dart';

class PunctuationScreen extends StatelessWidget {
  const PunctuationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const CustomAppBar(score: 250),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    _buildProgressBubbles(),
                    const SizedBox(height: 20),
                    _buildHeader(),
                    const SizedBox(height: 30),
                    _buildGameArea(),
                    const SizedBox(height: 30),
                    _buildInfoCards(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBubbles() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildBubble(isActive: true, isDone: true),
        _buildBubble(isActive: true, isDone: false),
        _buildBubble(isActive: false, isDone: false),
        _buildBubble(isActive: false, isDone: false),
      ],
    );
  }

  Widget _buildBubble({required bool isActive, required bool isDone}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: isDone ? const Color(0xFF67E100) : (isActive ? AppColors.tertiaryContainer : AppColors.surfaceContainerHigh),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 3),
      ),
      child: isDone ? const Icon(Icons.check, color: Colors.white, size: 20) : null,
    );
  }

  Widget _buildHeader() {
    return const Column(
      children: [
        Text("ضع علامة الترقيم المناسبة!", textAlign: TextAlign.center, style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: AppColors.onBackground)),
        SizedBox(height: 8),
        Text("لعبة علامات الترقيم للأذكياء الصغار", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.onSurfaceVariant)),
      ],
    );
  }

  Widget _buildGameArea() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: const Border(bottom: BorderSide(color: AppColors.surfaceContainerLow, width: 8)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(
        children: [
          // الجملة والمربع الفارغ
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
            decoration: BoxDecoration(color: AppColors.surfaceContainerLow, borderRadius: BorderRadius.circular(16)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("ما أجمل السماء", style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900)),
                const SizedBox(width: 16),
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.primaryContainer, width: 3),
                  ),
                  child: const Center(child: Text("؟", style: TextStyle(fontSize: 30, color: AppColors.primaryContainer, fontWeight: FontWeight.bold))),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          // خيارات الإجابة
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildChoiceButton(".", "نقطة", false),
              _buildChoiceButton("،", "فاصلة", false),
              _buildChoiceButton("!", "تعجب", true), // الإجابة الصحيحة
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChoiceButton(String symbol, String label, bool isCorrect) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
      decoration: BoxDecoration(
        color: isCorrect ? AppColors.primaryContainer : AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border(bottom: BorderSide(color: isCorrect ? AppColors.primaryDim : AppColors.outlineVariant, width: 6)),
      ),
      child: Column(
        children: [
          Text(symbol, style: TextStyle(fontSize: 40, fontWeight: FontWeight.w900, color: isCorrect ? AppColors.onPrimaryContainer : AppColors.onSurface)),
          Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isCorrect ? AppColors.onPrimaryContainer : AppColors.onSurfaceVariant)),
        ],
      ),
    );
  }

  Widget _buildInfoCards() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: AppColors.secondaryContainer, borderRadius: BorderRadius.circular(16)),
          child: const Row(
            children: [
              Icon(Icons.emoji_events, size: 40, color: AppColors.secondary),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("تحدي اليوم", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.onSecondaryContainer)),
                    Text("أكمل ٥ جمل صحيحة لتحصل على شارة ذهبية!", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.onSecondaryContainer)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}