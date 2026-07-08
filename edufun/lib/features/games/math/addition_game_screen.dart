import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/progress_manager.dart';
import '../../../core/data/models/game_level.dart';
import '../../../core/utils/audio_manager.dart'; // ✅ متحكم الصوت // ✅ تتبّع إكمال الألعاب وفتح المستوى التالي
import '../../../core/widgets/custom_app_bar.dart';

class MathLevel {
  final int num1; final int num2;
  late final int correctAnswer; late final List<int> options;

  MathLevel({required this.num1, required this.num2}) {
    correctAnswer = num1 + num2;
    final random = Random();
    final optionsSet = <int>{correctAnswer};
    while (optionsSet.length < 3) {
      int wrongOption = correctAnswer + (random.nextBool() ? 1 : -1) * (random.nextInt(4) + 1);
      if (wrongOption > 0 && wrongOption != correctAnswer) { optionsSet.add(wrongOption); }
    }
    options = optionsSet.toList()..shuffle();
  }
}

class AdditionGameScreen extends StatefulWidget {
  final GameLevel? level;
  const AdditionGameScreen({super.key, this.level});
  @override
  State<AdditionGameScreen> createState() => _AdditionGameScreenState();
}

class _AdditionGameScreenState extends State<AdditionGameScreen> {
  final List<MathLevel> _levels = [];
  int _currentLevelIndex = 0;

  @override
  void initState() { super.initState(); _generateLevels(); }
  void _generateLevels() {
    final random = Random();
    // عدد الجولات ونطاق الأرقام يأتيان من إعدادات المرحلة (config) إن وُجدت.
    final rounds = widget.level?.cfgInt('rounds', 5) ?? 5;
    final maxN = widget.level?.cfgInt('maxNumber', 10) ?? 10;
    for (int i = 0; i < rounds; i++) {
      _levels.add(MathLevel(num1: random.nextInt(maxN) + 1, num2: random.nextInt(maxN) + 1));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_levels.isEmpty) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    final currentLevel = _levels[_currentLevelIndex];
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(showBackButton: true), // تم تصفير الـ score
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            children: [
              _buildHeader(),
              const SizedBox(height: 30),
              _buildEquationCard(currentLevel),
              const SizedBox(height: 40),
              _buildAnswerChoices(currentLevel),
              const SizedBox(height: 40),
              _buildProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }

  void _checkAnswer(int selectedAnswer) {
    if (selectedAnswer == _levels[_currentLevelIndex].correctAnswer) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("إجابة صحيحة! أحسنت يا بطل! 🎈", style: TextStyle(fontSize: 18))));
      Future.delayed(const Duration(seconds: 1), _goToNextLevel);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("حاول مرة أخرى!", style: TextStyle(fontSize: 18))));
    }
  }

  void _goToNextLevel() async {
    if (_currentLevelIndex < _levels.length - 1) {
      setState(() { _currentLevelIndex++; });
    } else {
      // ✅ تفعيل إضافة النجوم وحفظها
      await AudioManager.playWinSound(); // 🔊 صوت الفوز
      await ProgressManager.recordWin('addition_game', level: widget.level); // ✅ تسجيل الفوز باللعبة
      if (!mounted) return;
      showDialog(context: context, barrierDismissible: false, builder: (ctx) => AlertDialog(title: const Text("أحسنت! 🏆"), content: const Text("لقد أكملت جميع المسائل بنجاح وحصلت على نجومك! ⭐"), actions: [TextButton(onPressed: () { Navigator.of(ctx).pop(); Navigator.of(context).pop(); }, child: const Text("العودة"))]));
    }
  }

  Widget _buildHeader() => Column(children: [Container(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8), decoration: BoxDecoration(color: AppColors.secondaryContainer, borderRadius: BorderRadius.circular(30)), child: const Text("الرياضيات", style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.onSecondaryContainer))), const SizedBox(height: 16), const Text("كم المجموع يا بطل؟", style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: AppColors.onBackground)), const SizedBox(height: 8), const Text("اختر الإجابة الصحيحة لتحصل على النجوم!", style: TextStyle(fontSize: 16, color: AppColors.onSurfaceVariant))]);
  Widget _buildEquationCard(MathLevel level) => Container(height: 150, padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: AppColors.surfaceContainer, width: 4)), child: FittedBox(fit: BoxFit.contain, child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Text("${level.num1}", style: const TextStyle(fontSize: 80, fontWeight: FontWeight.w900)), const SizedBox(width: 20), const Text("+", style: TextStyle(fontSize: 60, fontWeight: FontWeight.w900, color: AppColors.primary)), const SizedBox(width: 20), Text("${level.num2}", style: const TextStyle(fontSize: 80, fontWeight: FontWeight.w900)), const SizedBox(width: 20), const Text("=", style: TextStyle(fontSize: 60, fontWeight: FontWeight.w900, color: AppColors.secondary)), const SizedBox(width: 20), Container(width: 80, height: 80, decoration: BoxDecoration(color: AppColors.tertiaryContainer.withOpacity(0.3), borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.tertiaryContainer, width: 3)), child: const Center(child: Text("؟", style: TextStyle(fontSize: 40, fontWeight: FontWeight.w900, color: AppColors.tertiary))))])));
  Widget _buildAnswerChoices(MathLevel level) { final colors = [AppColors.secondaryContainer, AppColors.primaryContainer, AppColors.tertiaryContainer]..shuffle(); final shadowColors = [AppColors.secondary, AppColors.primary, AppColors.tertiary]..shuffle(); return Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: List.generate(3, (index) { final option = level.options[index]; return _AnswerButton(text: "$option", color: colors[index], shadowColor: shadowColors[index], onTap: () => _checkAnswer(option)); })); }
  Widget _buildProgressIndicator() => Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(_levels.length, (index) { bool isDone = index < _currentLevelIndex; bool isActive = index == _currentLevelIndex; return Container(margin: const EdgeInsets.symmetric(horizontal: 4), width: isActive ? 30 : 15, height: isActive ? 30 : 15, decoration: BoxDecoration(color: isDone ? AppColors.outlineVariant : (isActive ? AppColors.tertiaryContainer : AppColors.surfaceContainerHigh), shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 3))); }));
}

class _AnswerButton extends StatelessWidget {
  final String text; final Color color; final Color shadowColor; final VoidCallback onTap;
  const _AnswerButton({required this.text, required this.color, required this.shadowColor, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(onTap: onTap, child: Container(width: 90, height: 90, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: shadowColor.withOpacity(0.8), offset: const Offset(0, 6))]), child: Center(child: Text(text, style: const TextStyle(fontSize: 40, fontWeight: FontWeight.w900, color: Colors.white)))));
}