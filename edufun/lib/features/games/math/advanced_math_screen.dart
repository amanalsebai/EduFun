import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/progress_manager.dart'; // ✅ تتبّع إكمال الألعاب وفتح المستوى التالي
import '../../../core/widgets/custom_app_bar.dart';

class AdvancedMathLevel {
  final int num1; final int num2; final bool isSubtraction;
  late final int correctAnswer; late final List<int> options;

  AdvancedMathLevel()
      : isSubtraction = Random().nextBool(),
        num1 = Random().nextInt(10) + 10,
        num2 = Random().nextInt(8) + 2
  {
    if (isSubtraction) { correctAnswer = num1 - num2; } else { correctAnswer = num1 + num2; }
    final random = Random(); final optionsSet = <int>{correctAnswer};
    while (optionsSet.length < 3) {
      int wrongOption = correctAnswer + (random.nextBool() ? 1 : -1) * (random.nextInt(3) + 1);
      if (wrongOption > 0 && wrongOption != correctAnswer) { optionsSet.add(wrongOption); }
    }
    options = optionsSet.toList()..shuffle();
  }
}

class AdvancedMathScreen extends StatefulWidget {
  const AdvancedMathScreen({super.key});
  @override
  State<AdvancedMathScreen> createState() => _AdvancedMathScreenState();
}

class _AdvancedMathScreenState extends State<AdvancedMathScreen> {
  final List<AdvancedMathLevel> _levels = List.generate(6, (index) => AdvancedMathLevel());
  int _currentLevelIndex = 0;

  @override
  Widget build(BuildContext context) {
    final currentLevel = _levels[_currentLevelIndex];
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(showBackButton: true), // تم تصفير الـ score
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
                child: Column(
                  children: [
                    _buildProgressBubbles(),
                    const SizedBox(height: 30),
                    _buildQuestionCard(currentLevel),
                    const SizedBox(height: 30),
                    if (currentLevel.isSubtraction) _buildVisualAids(currentLevel),
                    const SizedBox(height: 40),
                    _buildAnswerChoices(currentLevel),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _checkAnswer(int selectedAnswer) {
    if (selectedAnswer == _levels[_currentLevelIndex].correctAnswer) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("صحيح! أنت عبقري! ✨", style: TextStyle(fontSize: 18))));
      Future.delayed(const Duration(seconds: 1), _goToNextLevel);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("إجابة خاطئة، حاول مجدداً!", style: TextStyle(fontSize: 18))));
    }
  }

  void _goToNextLevel() async {
    if (_currentLevelIndex < _levels.length - 1) {
      setState(() => _currentLevelIndex++);
    } else {
      // ✅ إضافة 50 نجمة للطفل عند الفوز بالكامل وحفظها بالذاكرة
      await ProgressManager.markGameCompleted('advanced_math'); // ✅ تسجيل الفوز باللعبة
      if (!mounted) return;
      showDialog(context: context, builder: (ctx) => AlertDialog(
        title: const Text("لقد فزت! 🥳"), content: const Text("أنهيت كل التحديات بنجاح وحصلت على 50 نجمة! ⭐"),
        actions: [TextButton(onPressed: () { Navigator.of(ctx).pop(); Navigator.of(context).pop(); }, child: const Text("العودة"))],
      ));
    }
  }

  Widget _buildProgressBubbles() => Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(6, (index) { bool isDone = index < _currentLevelIndex; bool isActive = index == _currentLevelIndex; return Container(margin: const EdgeInsets.symmetric(horizontal: 4), width: isActive ? 35 : 30, height: isActive ? 35 : 30, decoration: BoxDecoration(color: isDone ? const Color(0xFF67E100) : (isActive ? AppColors.tertiaryContainer : AppColors.surfaceContainerHigh), shape: BoxShape.circle, border: isActive ? Border.all(color: Colors.white, width: 3) : null, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 5, offset: const Offset(0, 3))])); }));
  Widget _buildQuestionCard(AdvancedMathLevel level) => Container(padding: const EdgeInsets.all(24), decoration: BoxDecoration(color: AppColors.surfaceContainerLowest, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 40, offset: const Offset(0, 20))]), child: Column(children: [SizedBox(height: 60, child: FittedBox(child: Text("كم ناتج ${level.num1} ${level.isSubtraction ? '-' : '+'} ${level.num2} = ؟", style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.onBackground)))), const SizedBox(height: 8), Text(level.isSubtraction ? "هيا نطرح المكعبات!" : "هيا نجمع المكعبات!", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.onSurfaceVariant))]));
  Widget _buildVisualAids(AdvancedMathLevel level) => GridView.builder(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), itemCount: level.num1, gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 5, mainAxisSpacing: 16, crossAxisSpacing: 16), itemBuilder: (context, index) { bool isSubtracted = index >= level.correctAnswer; return isSubtracted ? const _SubtractedBlock() : const _ActiveBlock(); });
  Widget _buildAnswerChoices(AdvancedMathLevel level) => Row(children: [Expanded(child: _AnswerButton(number: level.options[0], color: AppColors.tertiaryContainer, shadow: AppColors.tertiary, icon: Icons.grass, onTap: () => _checkAnswer(level.options[0]))), const SizedBox(width: 12), Expanded(child: _AnswerButton(number: level.options[1], color: AppColors.primaryContainer, shadow: AppColors.primaryDim, icon: Icons.star, onTap: () => _checkAnswer(level.options[1]))), const SizedBox(width: 12), Expanded(child: _AnswerButton(number: level.options[2], color: AppColors.secondaryContainer, shadow: AppColors.secondary, icon: Icons.psychology, onTap: () => _checkAnswer(level.options[2])))]);
}

class _ActiveBlock extends StatelessWidget { const _ActiveBlock(); @override Widget build(BuildContext context) => Container(decoration: BoxDecoration(color: AppColors.secondaryContainer, borderRadius: BorderRadius.circular(12), border: const Border(bottom: BorderSide(color: AppColors.secondaryDim, width: 4))), child: const Center(child: Text("🍎", style: TextStyle(fontSize: 22)))); }
class _SubtractedBlock extends StatelessWidget { const _SubtractedBlock(); @override Widget build(BuildContext context) => Container(decoration: BoxDecoration(color: AppColors.surfaceContainerLow, borderRadius: BorderRadius.circular(12)), child: const Center(child: Icon(Icons.close, color: AppColors.error, size: 30))); }
class _AnswerButton extends StatelessWidget { final int number; final Color color, shadow; final IconData icon; final VoidCallback onTap; const _AnswerButton({required this.number, required this.color, required this.shadow, required this.icon, required this.onTap}); @override Widget build(BuildContext context) { return GestureDetector(onTap: onTap, child: Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(20), border: Border(bottom: BorderSide(color: shadow, width: 8)), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, 10))]), child: Stack(alignment: Alignment.center, children: [Positioned(top: -5, left: -5, child: Icon(icon, color: Colors.black.withOpacity(0.1), size: 30)), FittedBox(fit: BoxFit.scaleDown, child: Text("$number", style: const TextStyle(fontSize: 50, fontWeight: FontWeight.w900)))]))); } }