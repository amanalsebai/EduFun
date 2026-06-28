import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/progress_manager.dart'; // ✅ تتبّع إكمال الألعاب وفتح المستوى التالي
import '../../../core/widgets/custom_app_bar.dart';

class AdventureMathLevel {
  late final int num1;
  final int num2;
  final bool isDivision;
  late final int correctAnswer;
  late final List<int> options;

  AdventureMathLevel()
      : isDivision = Random().nextBool(),
        num2 = Random().nextInt(8) + 2 {

    final random = Random();
    int generatedNum1;

    if (isDivision) {
      int multiplier = random.nextInt(8) + 2;
      generatedNum1 = num2 * multiplier;
      correctAnswer = multiplier;
    } else {
      generatedNum1 = random.nextInt(8) + 2;
      correctAnswer = generatedNum1 * num2;
    }

    num1 = generatedNum1;

    final optionsSet = <int>{correctAnswer};
    while (optionsSet.length < 3) {
      int wrongOption = correctAnswer + (random.nextBool() ? 1 : -1) * (random.nextInt(4) + 1);
      if (wrongOption > 0 && wrongOption != correctAnswer) {
        optionsSet.add(wrongOption);
      }
    }
    options = optionsSet.toList()..shuffle();
  }
}

class MathAdventureScreen extends StatefulWidget {
  const MathAdventureScreen({super.key});

  @override
  State<MathAdventureScreen> createState() => _MathAdventureScreenState();
}

class _MathAdventureScreenState extends State<MathAdventureScreen> {
  final List<AdventureMathLevel> _levels = [];
  int _currentLevelIndex = 0;

  @override
  void initState() {
    super.initState();
    _generateLevels();
  }

  void _generateLevels() {
    for (int i = 0; i < 5; i++) {
      _levels.add(AdventureMathLevel());
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
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              _buildHeader(),
              const SizedBox(height: 30),
              _buildProblemBento(currentLevel),
              const SizedBox(height: 40),
              _buildAnswerChoices(currentLevel),
              const SizedBox(height: 40),
              _buildHintCard(),
            ],
          ),
        ),
      ),
    );
  }

  void _checkAnswer(int selectedAnswer) {
    if (selectedAnswer == _levels[_currentLevelIndex].correctAnswer) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("إجابة صحيحة! بطل رياضيات خارق! 🚀", style: TextStyle(fontSize: 18))),
      );
      Future.delayed(const Duration(seconds: 1), _goToNextLevel);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("حاول مرة أخرى يا بطل!", style: TextStyle(fontSize: 18))),
      );
    }
  }

  void _goToNextLevel() async {
    if (_currentLevelIndex < _levels.length - 1) {
      setState(() {
        _currentLevelIndex++;
      });
    } else {
      // ✅ إضافة 50 نجمة للطفل وحفظها في ذاكرة الجوال
      await ProgressManager.markGameCompleted('math_adventure'); // ✅ تسجيل الفوز باللعبة

      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Text("عبقري الحساب! 🏆", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w900)),
          content: const Text("لقد أتقنت الضرب والقسمة السريعة بنجاح وحصلت على 50 نجمة! ⭐", textAlign: TextAlign.center),
          actions: [
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                child: const Text("العودة للقائمة", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.tertiaryContainer,
            borderRadius: BorderRadius.circular(20),
            border: const Border(bottom: BorderSide(color: AppColors.tertiary, width: 3)),
          ),
          child: const Text("ضرب وقسمة", style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 16),
        const Text("اختر الإجابة الصحيحة!", style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: AppColors.onBackground)),
        const SizedBox(height: 8),
        const Text("أنت ذكي جداً، يمكنك حل هذه المسألة!", style: TextStyle(fontSize: 16, color: AppColors.onSurfaceVariant, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildProblemBento(AdventureMathLevel level) {
    String operatorSymbol = level.isDivision ? "÷" : "×";

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Container(
            padding: const EdgeInsets.all(24),
            height: 160,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10))],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                FittedBox(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("${level.num1}", style: const TextStyle(fontSize: 50, fontWeight: FontWeight.w900, color: AppColors.secondary)),
                      const SizedBox(width: 10),
                      Text(operatorSymbol, style: const TextStyle(fontSize: 40, color: AppColors.primaryContainer, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 10),
                      Text("${level.num2}", style: const TextStyle(fontSize: 50, fontWeight: FontWeight.w900, color: AppColors.secondary)),
                      const SizedBox(width: 10),
                      const Text("=", style: TextStyle(fontSize: 40, color: AppColors.primary, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 10),
                      Container(
                        width: 60, height: 60,
                        decoration: BoxDecoration(color: AppColors.surfaceContainerLow, borderRadius: BorderRadius.circular(15), border: Border.all(color: AppColors.outlineVariant, width: 3)),
                        child: const Center(child: Text("؟", style: TextStyle(fontSize: 30, color: AppColors.outlineVariant, fontWeight: FontWeight.bold))),
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    bool isDone = index < _currentLevelIndex;
                    bool isActive = index == _currentLevelIndex;
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: isActive ? 16 : 10, height: isActive ? 16 : 10,
                      decoration: BoxDecoration(
                        color: isDone ? AppColors.outlineVariant : (isActive ? AppColors.tertiaryContainer : AppColors.surfaceContainer),
                        shape: BoxShape.circle,
                      ),
                    );
                  }),
                )
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 1,
          child: Container(
            height: 160,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [BoxShadow(color: AppColors.primaryDim.withOpacity(0.5), offset: const Offset(0, 6))],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("🚀", style: TextStyle(fontSize: 44)),
                const SizedBox(height: 8),
                const Text("انطلق!", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAnswerChoices(AdventureMathLevel level) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(3, (index) {
        final option = level.options[index];
        return GestureDetector(
          onTap: () => _checkAnswer(option),
          child: Container(
            width: 90, height: 90,
            decoration: BoxDecoration(
              color: index == 0 ? AppColors.secondaryContainer : (index == 1 ? AppColors.primaryContainer : AppColors.tertiaryContainer),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: (index == 0 ? AppColors.secondary : (index == 1 ? AppColors.primary : AppColors.tertiary)).withOpacity(0.8),
                  offset: const Offset(0, 6),
                )
              ],
            ),
            child: Center(
              child: Text("$option", style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w900)),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildHintCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppColors.surfaceContainerLow, borderRadius: BorderRadius.circular(20)),
      child: const Row(
        children: [
          Icon(Icons.lightbulb_rounded, color: AppColors.onSurfaceVariant, size: 30),
          SizedBox(width: 16),
          Expanded(
            child: Text(
              "تلميح: فكر بالجدول الحسابي، ما الرقم الذي تضربه لتحصل على الناتج؟ أنت عبقري وتستطيع حلها!",
              style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }
}