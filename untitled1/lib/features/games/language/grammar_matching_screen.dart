import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/progress_manager.dart'; // ✅ تتبّع إكمال الألعاب وفتح المستوى التالي
import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/utils/score_manager.dart'; // ✅ استيراد متحكم النقاط

class GrammarItem {
  final String id; final String text;
  GrammarItem({required this.id, required this.text});
}

class GrammarLevel {
  final String sentence; final List<GrammarItem> words; final List<GrammarItem> terms;
  GrammarLevel({required this.sentence, required this.words, required List<GrammarItem> terms}) : terms = List.from(terms)..shuffle(Random());
}

class GrammarMatchingScreen extends StatefulWidget {
  const GrammarMatchingScreen({super.key});
  @override
  State<GrammarMatchingScreen> createState() => _GrammarMatchingScreenState();
}

class _GrammarMatchingScreenState extends State<GrammarMatchingScreen> {
  final List<GrammarLevel> _levels = [
    GrammarLevel(sentence: "أكل الولدُ التفاحةَ", words: [GrammarItem(id: "verb", text: "أكل"), GrammarItem(id: "subject", text: "الولدُ"), GrammarItem(id: "object", text: "التفاحةَ")], terms: [GrammarItem(id: "verb", text: "فعل ماضٍ"), GrammarItem(id: "subject", text: "فاعل مرفوع"), GrammarItem(id: "object", text: "مفعول به منصوب")]),
    GrammarLevel(sentence: "يقرأُ الطالبُ كتاباً", words: [GrammarItem(id: "verb", text: "يقرأُ"), GrammarItem(id: "subject", text: "الطالبُ"), GrammarItem(id: "object", text: "كتاباً")], terms: [GrammarItem(id: "verb", text: "فعل مضارع"), GrammarItem(id: "subject", text: "فاعل مرفوع"), GrammarItem(id: "object", text: "مفعول به منصوب")]),
  ];

  int _currentLevelIndex = 0;
  String? _selectedWordId; String? _selectedTermId; Set<String> _correctMatches = {};

  @override
  Widget build(BuildContext context) {
    final currentLevel = _levels[_currentLevelIndex];
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(showBackButton: true),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              _buildProgressBubbles(),
              const SizedBox(height: 20),
              _buildHeader(currentLevel),
              const SizedBox(height: 30),
              _buildMatchingBoard(currentLevel),
              const SizedBox(height: 40),
              _buildCheckAnswerButton(),
            ],
          ),
        ),
      ),
    );
  }

  void _onCardTap(String id, bool isWord) {
    setState(() { if (isWord) { _selectedWordId = id; } else { _selectedTermId = id; } });

    if (_selectedWordId != null && _selectedTermId != null) {
      if (_selectedWordId == _selectedTermId) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("إعراب صحيح وممتاز! 🎉", style: TextStyle(fontSize: 18))));
        setState(() { _correctMatches.add(_selectedWordId!); _selectedWordId = null; _selectedTermId = null; });

        if (_correctMatches.length == _levels[_currentLevelIndex].words.length) { _goToNextLevel(); }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("الإعراب غير صحيح، حاول مرة أخرى! 🧐", style: TextStyle(fontSize: 18))));
        setState(() { _selectedWordId = null; _selectedTermId = null; });
      }
    }
  }

  void _goToNextLevel() async {
    if (_currentLevelIndex < _levels.length - 1) {
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (!mounted) return;
        setState(() { _currentLevelIndex++; _correctMatches.clear(); _selectedWordId = null; _selectedTermId = null; });
      });
    } else {
      // ✅ إضافة 50 نجمة عند الفوز وحفظها
      await ScoreManager.addStars(50);
      await ProgressManager.markGameCompleted('grammar_matching'); // ✅ تسجيل الفوز باللعبة
      if (!mounted) return;
      showDialog(
        context: context, barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Text("عبقري النحو والصرف! 🏆", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w900)),
          content: const Text("لقد نجحت في توصيل الإعراب وحصلت على 50 نجمة! ⭐", textAlign: TextAlign.center),
          actions: [Center(child: ElevatedButton(onPressed: () { Navigator.pop(ctx); Navigator.pop(context); }, style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))), child: const Text("العودة للقائمة", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))))],
        ),
      );
    }
  }

  Widget _buildProgressBubbles() => Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(_levels.length, (index) { bool isDone = index < _currentLevelIndex; bool isActive = index == _currentLevelIndex; return Container(margin: const EdgeInsets.symmetric(horizontal: 4), width: isActive ? 45 : 35, height: isActive ? 45 : 35, decoration: BoxDecoration(color: isDone ? const Color(0xFF67E100) : (isActive ? AppColors.tertiaryContainer : AppColors.surfaceContainerHigh), shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 3), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 5)]), child: isDone ? const Icon(Icons.check, color: Colors.white, size: 20) : (isActive ? Center(child: Text("${index + 1}", style: const TextStyle(fontWeight: FontWeight.w900))) : null)); }));
  Widget _buildHeader(GrammarLevel level) => Column(children: [Container(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8), decoration: BoxDecoration(color: AppColors.tertiaryContainer, borderRadius: BorderRadius.circular(20)), child: const Text("تحدي القواعد", style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.onTertiaryContainer))), const SizedBox(height: 16), const Text("وصّل الكلمة بإعرابها الصحيح!", style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: AppColors.onBackground), textAlign: TextAlign.center), const SizedBox(height: 8), Row(mainAxisAlignment: MainAxisAlignment.center, children: [const Text("الجملة:", style: TextStyle(fontSize: 18, color: AppColors.onSurfaceVariant)), const SizedBox(width: 8), Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: Colors.white.withOpacity(0.5), borderRadius: BorderRadius.circular(10)), child: Text(level.sentence, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary)))])]);
  Widget _buildMatchingBoard(GrammarLevel level) => IntrinsicHeight(child: Stack(alignment: Alignment.center, children: [Positioned(top: 20, bottom: 20, child: Container(width: 2, color: AppColors.outlineVariant.withOpacity(0.2))), Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Expanded(child: Column(children: [for (final term in level.terms) Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: _GrammarTermCard(term: term.text, isMatched: _correctMatches.contains(term.id), isSelected: _selectedTermId == term.id, onTap: () => _correctMatches.contains(term.id) ? null : _onCardTap(term.id, false)))])), const SizedBox(width: 40), Expanded(child: Column(children: [for (final word in level.words) Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: _WordCard(word: word.text, isMatched: _correctMatches.contains(word.id), isSelected: _selectedWordId == word.id, onTap: () => _correctMatches.contains(word.id) ? null : _onCardTap(word.id, true)))]))])]));
  Widget _buildCheckAnswerButton() { bool isAllCorrect = _correctMatches.length == _levels[_currentLevelIndex].words.length; return Container(width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 20), decoration: BoxDecoration(color: isAllCorrect ? const Color(0xFF67E100) : AppColors.primaryContainer, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: isAllCorrect ? const Color(0xFF3B8700) : AppColors.primaryDim, offset: const Offset(0, 8), blurRadius: 0)]), child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Text(isAllCorrect ? "رائع! إجابة صحيحة" : "وصّل الكلمات بالإعراب أولاً", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: isAllCorrect ? Colors.white : AppColors.onPrimaryContainer)), const SizedBox(width: 8), Icon(isAllCorrect ? Icons.check_circle : Icons.help_outline, color: isAllCorrect ? Colors.white : AppColors.onPrimaryContainer)])); }
}

class _WordCard extends StatelessWidget {
  final String word; final bool isMatched; final bool isSelected; final VoidCallback onTap;
  const _WordCard({required this.word, required this.isMatched, required this.isSelected, required this.onTap});
  @override
  Widget build(BuildContext context) { Color cardColor = isMatched ? const Color(0xFF67E100) : Colors.white; Color borderAndNodeColor = isMatched ? const Color(0xFF3B8700) : (isSelected ? AppColors.primary : AppColors.primaryContainer); return GestureDetector(onTap: onTap, child: AnimatedContainer(duration: const Duration(milliseconds: 200), padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20), decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: borderAndNodeColor, width: isSelected || isMatched ? 3 : 1), boxShadow: isSelected ? [BoxShadow(color: AppColors.primaryContainer, blurRadius: 10)] : []), child: Stack(clipBehavior: Clip.none, alignment: Alignment.center, children: [FittedBox(fit: BoxFit.scaleDown, child: Text(word, style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: isMatched ? Colors.white : AppColors.primary))), Positioned(left: -11, child: Container(width: 22, height: 22, decoration: BoxDecoration(color: borderAndNodeColor, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 4)), child: isMatched ? const Icon(Icons.check, color: Colors.white, size: 10) : null))]))); }
}

class _GrammarTermCard extends StatelessWidget {
  final String term; final bool isMatched; final bool isSelected; final VoidCallback onTap;
  const _GrammarTermCard({required this.term, required this.isMatched, required this.isSelected, required this.onTap});
  @override
  Widget build(BuildContext context) { Color cardColor = isMatched ? const Color(0xFF67E100) : AppColors.secondaryContainer; Color borderAndNodeColor = isMatched ? const Color(0xFF3B8700) : (isSelected ? AppColors.secondary : AppColors.secondaryContainer); return GestureDetector(onTap: onTap, child: AnimatedContainer(duration: const Duration(milliseconds: 200), padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16), decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: borderAndNodeColor, width: isSelected || isMatched ? 3 : 1), boxShadow: isSelected ? [BoxShadow(color: AppColors.secondaryContainer, blurRadius: 10)] : []), child: Stack(clipBehavior: Clip.none, alignment: Alignment.center, children: [Text(term, textAlign: TextAlign.center, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: isMatched ? Colors.white : AppColors.onSecondaryContainer)), Positioned(right: -11, child: Container(width: 22, height: 22, decoration: BoxDecoration(color: borderAndNodeColor, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 4)), child: isMatched ? const Icon(Icons.check, color: Colors.white, size: 10) : null))]))); }
}