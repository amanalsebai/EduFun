import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/utils/score_manager.dart'; // ✅ استيراد متحكم النقاط

class SpellingLevel {
  final String word; final String imageUrl; final List<String> scrambledLetters; final String hint;
  SpellingLevel({required this.word, required this.imageUrl, required this.scrambledWords, required this.hint}) : scrambledLetters = List.from(scrambledWords)..shuffle();
  final List<String> scrambledWords;
}

class EnglishSpellingScreen extends StatefulWidget {
  const EnglishSpellingScreen({super.key});
  @override
  State<EnglishSpellingScreen> createState() => _EnglishSpellingScreenState();
}

class _EnglishSpellingScreenState extends State<EnglishSpellingScreen> {
  final List<SpellingLevel> _levels = [
    SpellingLevel(word: "STAR", imageUrl: "https://i.ibb.co/mXz44YQ/sun-toy.png", scrambledWords: ["S", "T", "A", "R"], hint: "تبدأ بحرف الـ S وتضيء في السماء ليلاً!"),
    SpellingLevel(word: "FROG", imageUrl: "https://i.ibb.co/cwtwqcV/frog-toy.png", scrambledWords: ["F", "R", "O", "G"], hint: "تبدأ بحرف الـ F ولونها أخضر وتقفز في الماء!"),
    SpellingLevel(word: "TOY", imageUrl: "https://i.ibb.co/LnbY94w/cat-toy.png", scrambledWords: ["T", "O", "Y"], hint: "تبدأ بحرف الـ T وتعني لعبة تسلينا دائماً!"),
  ];

  int _currentLevelIndex = 0;
  List<String> _poolLetters = [];
  List<String> _targetLetters = [];

  @override
  void initState() { super.initState(); _startLevel(); }
  void _startLevel() { _poolLetters = List.from(_levels[_currentLevelIndex].scrambledLetters); _targetLetters.clear(); }

  void _onLetterTap(String letter, bool isFromPool) {
    setState(() {
      if (isFromPool) { _poolLetters.remove(letter); _targetLetters.add(letter); } else { _targetLetters.remove(letter); _poolLetters.add(letter); }
    });
    _checkAnswer();
  }

  void _checkAnswer() {
    String currentWord = _targetLetters.join();
    if (currentWord == _levels[_currentLevelIndex].word) {
      Future.delayed(const Duration(milliseconds: 300), () => _showSuccessDialog());
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentLevel = _levels[_currentLevelIndex];
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(showBackButton: true),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            children: [
              _buildProgressBubbles(),
              const SizedBox(height: 24),
              _buildGameCanvas(currentLevel),
              const SizedBox(height: 30),
              _buildDropZone(),
              const SizedBox(height: 30),
              _buildMascotHint(currentLevel),
              const SizedBox(height: 30),
              _buildWordPool(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressBubbles() => Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(_levels.length, (index) { bool isDone = index < _currentLevelIndex; bool isActive = index == _currentLevelIndex; return Container(margin: const EdgeInsets.symmetric(horizontal: 4), width: isActive ? 45 : 35, height: isActive ? 45 : 35, decoration: BoxDecoration(color: isDone ? const Color(0xFF67E100) : (isActive ? AppColors.tertiaryContainer : AppColors.surfaceContainerHigh), shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 3), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 5)]), child: isDone ? const Icon(Icons.check, color: Colors.white, size: 20) : (isActive ? Center(child: Text("${index + 1}", style: const TextStyle(fontWeight: FontWeight.w900))) : null)); } ));
  Widget _buildGameCanvas(SpellingLevel level) => Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, border: Border.all(color: AppColors.secondaryContainer, width: 8), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]), child: Container(width: 140, height: 140, decoration: const BoxDecoration(shape: BoxShape.circle), child: Image.network(level.imageUrl, fit: BoxFit.contain)));
  Widget _buildDropZone() { bool isEmpty = _targetLetters.isEmpty; return Container(width: double.infinity, constraints: const BoxConstraints(minHeight: 100), padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white.withOpacity(0.3), borderRadius: BorderRadius.circular(24), border: Border.all(color: AppColors.secondaryContainer.withOpacity(0.5), width: 3, style: BorderStyle.solid)), child: isEmpty ? const Center(child: Text("اضغط على الحروف لتهجئة الكلمة...", style: TextStyle(color: AppColors.onSurfaceVariant, fontWeight: FontWeight.bold, fontSize: 16))) : Wrap(spacing: 10, runSpacing: 10, alignment: WrapAlignment.center, children: _targetLetters.map((char) => _buildLetterCard(char, false)).toList())); }
  Widget _buildMascotHint(SpellingLevel level) => Row(children: [SizedBox(width: 80, height: 80, child: Image.network("https://lh3.googleusercontent.com/aida-public/AB6AXuBfwlXy29uqNMJzX2YxFXjKRsQ6wo3uuT6Y_TFKToE2DTb0waB2s8Ln0nvBYHF8xi0UHDBHXy6N11P-wNRMhAjxZrlKvxgnTynPaqaobp7fqYjU1-Xjdf0YXKXyhMggVWNqYYxgyZs_SJ42N6oFIYOo3TJAvdOUB-Fom-lyx04P-Fgw23KYE1xJji6T9_vVkltnkJ1TKM9dpxqouDpkAKEcmQWuVAta7BanPhzieo_mCxSP2s3LqXls0I8yWDbWbLGlrzs0VWd9eZDQ", fit: BoxFit.contain)), const SizedBox(width: 12), Expanded(child: Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white.withOpacity(0.85), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withOpacity(0.5), width: 2)), child: Text("تلميح: ${level.hint}", style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.onSurface))))]);
  Widget _buildWordPool() => Column(children: [const Text("الحروف المتاحة:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)), const SizedBox(height: 16), Wrap(spacing: 12, runSpacing: 12, alignment: WrapAlignment.center, children: _poolLetters.map((char) => _buildLetterCard(char, true)).toList())]);
  Widget _buildLetterCard(String char, bool isFromPool) => GestureDetector(onTap: () => _onLetterTap(char, isFromPool), child: Container(width: 65, height: 65, decoration: BoxDecoration(color: AppColors.primaryContainer, borderRadius: BorderRadius.circular(16), border: const Border(bottom: BorderSide(color: AppColors.primaryDim, width: 4))), child: Center(child: Text(char, textDirection: TextDirection.ltr, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: AppColors.onPrimaryContainer)))));

  void _showSuccessDialog() {
    final level = _levels[_currentLevelIndex];
    showDialog(
      context: context, barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 100, height: 100, decoration: const BoxDecoration(color: AppColors.primaryContainer, shape: BoxShape.circle), child: const Icon(Icons.celebration, color: AppColors.primary, size: 60)),
            const SizedBox(height: 20),
            const Text("تهانينا يا بطل! 🎉", style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: AppColors.primary)),
            const SizedBox(height: 10),
            Text("لقد قمت بتهجئة كلمة [ ${level.word} ] بشكل صحيح!", textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () { Navigator.pop(ctx); _goToNextLevel(); },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
              child: const Text("المرحلة التالية 🚀", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }

  void _goToNextLevel() async {
    if (_currentLevelIndex < _levels.length - 1) {
      setState(() { _currentLevelIndex++; _startLevel(); });
    } else {
      // ✅ إضافة 50 نجمة وحفظها عند الفوز بالكامل
      await ScoreManager.addStars(50);
      if (!mounted) return;
      showDialog(
        context: context, barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Text("ملك الهجاء! 👑", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w900)),
          content: const Text("أنت مذهل جداً في اللغة الإنجليزية وحصلت على 50 نجمة! ⭐", textAlign: TextAlign.center),
          actions: [Center(child: ElevatedButton(onPressed: () { Navigator.pop(ctx); Navigator.pop(context); }, style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))), child: const Text("العودة للقائمة", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))))],
        ),
      );
    }
  }
}