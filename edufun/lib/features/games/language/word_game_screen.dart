import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/progress_manager.dart'; // ✅ تتبّع إكمال الألعاب وفتح المستوى التالي
import '../../../core/widgets/custom_app_bar.dart';

class WordGameLevel {
  final String correctAnswer; final String emoji; final List<Map<String, dynamic>> letters;
  WordGameLevel({required this.correctAnswer, required this.emoji, required this.letters});
}

class WordGameScreen extends StatefulWidget {
  const WordGameScreen({super.key});
  @override
  State<WordGameScreen> createState() => _WordGameScreenState();
}

class _WordGameScreenState extends State<WordGameScreen> {
  final List<WordGameLevel> _gameLevels = [
    WordGameLevel(
      correctAnswer: "موز",
      emoji: "🍌",
      letters: [{"char": "ز", "color": AppColors.outlineVariant}, {"char": "م", "color": AppColors.error}, {"char": "و", "color": AppColors.secondary}]..shuffle(),
    ),
    WordGameLevel(
      correctAnswer: "قط",
      emoji: "🐱",
      letters: [{"char": "ط", "color": AppColors.secondaryContainer}, {"char": "ق", "color": AppColors.primaryContainer}]..shuffle(),
    ),
  ];

  int _currentLevelIndex = 0; late List<String?> _targetSlots; late List<Map<String, dynamic>> _availableLetters;

  @override
  void initState() { super.initState(); _setupLevel(); }
  void _setupLevel() { final currentLevel = _gameLevels[_currentLevelIndex]; _targetSlots = List.generate(currentLevel.correctAnswer.length, (index) => null); _availableLetters = List.from(currentLevel.letters); }

  @override
  Widget build(BuildContext context) {
    final currentLevel = _gameLevels[_currentLevelIndex];
    return Scaffold(
      backgroundColor: const Color(0xFFE4FFCD),
      appBar: const CustomAppBar(showBackButton: true), // تم تصفير الـ score
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 120, top: 20, left: 24, right: 24),
                child: Column(
                  children: [
                    _buildTitle(),
                    const SizedBox(height: 30),
                    _buildGameCard(currentLevel),
                    const SizedBox(height: 40),
                    _buildHintButton(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.large(
        onPressed: _checkAnswer,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.check_circle, color: Colors.white, size: 40),
      ),
    );
  }

  void _checkAnswer() async {
    final joinedAnswer = _targetSlots.join();
    if (joinedAnswer == _gameLevels[_currentLevelIndex].correctAnswer) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("إجابة صحيحة! أحسنت يا بطل! 🌟", style: TextStyle(fontSize: 18))));

      Future.delayed(const Duration(seconds: 1), () async {
        if (_currentLevelIndex < _gameLevels.length - 1) {
          setState(() { _currentLevelIndex++; _setupLevel(); });
        } else {
          await ProgressManager.markGameCompleted('word_game'); // ✅ تسجيل الفوز باللعبة
          if (!mounted) return;
          showDialog(
            context: context, barrierDismissible: false,
            builder: (ctx) => AlertDialog(
              title: const Text("تهانينا! 🎉"),
              content: const Text("لقد أكملت كل الكلمات بنجاح وحصلت على 50 نجمة! ⭐"),
              actions: [TextButton(onPressed: () { Navigator.of(ctx).pop(); Navigator.of(context).pop(); }, child: const Text("العودة"))],
            ),
          );
        }
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("حاول مرة أخرى!", style: TextStyle(fontSize: 18))));
    }
  }

  Widget _buildGameCard(WordGameLevel level) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.8), borderRadius: BorderRadius.circular(24)),
      child: Column(
        children: [
          Container(width: 180, height: 180, padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, border: Border.all(color: AppColors.secondaryContainer, width: 8)), child: Center(child: Text(level.emoji, style: const TextStyle(fontSize: 100)))),
          const SizedBox(height: 40),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(level.correctAnswer.length, (index) => _buildDragTarget(index))),
          const SizedBox(height: 40),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: _availableLetters.map((letter) { bool isUsed = _targetSlots.contains(letter["char"]); return isUsed ? const SizedBox(width: 80, height: 80) : _buildDraggableLetter(letter["char"], letter["color"]); }).toList()),
        ],
      ),
    );
  }

  Widget _buildDragTarget(int index) => Padding(padding: const EdgeInsets.symmetric(horizontal: 8), child: DragTarget<String>(onAccept: (receivedLetter) { setState(() { _targetSlots[index] = receivedLetter; }); }, builder: (context, candidateData, rejectedData) { bool hasData = _targetSlots[index] != null; return Container(width: 70, height: 70, decoration: BoxDecoration(color: hasData ? Colors.transparent : AppColors.secondaryContainer.withOpacity(0.2), shape: BoxShape.circle, border: Border.all(color: hasData ? Colors.transparent : AppColors.secondaryContainer, width: 3)), child: hasData ? _buildLetterBall(_targetSlots[index]!, AppColors.outline) : null); }));
  Widget _buildTitle() => const Column(children: [Text("ترتيب الكلمات", style: TextStyle(fontSize: 40, fontWeight: FontWeight.w900, color: AppColors.secondary)), SizedBox(height: 8), Text("اسحب الحروف لتكوين الكلمة!", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.onSurfaceVariant))]);
  Widget _buildDraggableLetter(String char, Color color) => Padding(padding: const EdgeInsets.symmetric(horizontal: 8), child: Draggable<String>(data: char, feedback: Material(color: Colors.transparent, child: _buildLetterBall(char, color, scale: 1.2)), childWhenDragging: Opacity(opacity: 0.3, child: _buildLetterBall(char, color)), child: _buildLetterBall(char, color)));
  Widget _buildLetterBall(String char, Color color, {double scale = 1.0}) => Transform.scale(scale: scale, child: Container(width: 70, height: 70, decoration: BoxDecoration(color: color, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), offset: const Offset(0, 6), blurRadius: 0)]), child: Stack(children: [Positioned(top: 8, left: 15, child: Transform.rotate(angle: -0.8, child: Container(width: 20, height: 10, decoration: BoxDecoration(color: Colors.white.withOpacity(0.3), borderRadius: BorderRadius.circular(10))))), Center(child: Text(char, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.white)))])));
  Widget _buildHintButton() => Column(children: [Container(width: 60, height: 60, decoration: const BoxDecoration(color: AppColors.primaryContainer, shape: BoxShape.circle, boxShadow: [BoxShadow(color: AppColors.tertiary, offset: Offset(0, 6))]), child: const Icon(Icons.lightbulb_rounded, color: AppColors.onPrimaryContainer, size: 30)), const SizedBox(height: 8), const Text("تلميح", style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.primary))]);
}