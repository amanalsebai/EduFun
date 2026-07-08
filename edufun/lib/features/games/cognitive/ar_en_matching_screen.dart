import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/progress_manager.dart';
import '../../../core/data/models/game_level.dart';
import '../../../core/data/repositories/content_repository.dart'; // ✅ محتوى قابل للتعديل من الأدمن
import '../../../core/utils/audio_manager.dart'; // ✅ متحكم الصوت // ✅ تتبّع إكمال الألعاب وفتح المستوى التالي
import '../../../core/widgets/custom_app_bar.dart';

class WordItem {
  final String id; final String text; final String? emoji;
  WordItem({required this.id, required this.text, this.emoji});
}

class MatchingLevel {
  final List<WordItem> arabicWords; final List<WordItem> englishWords;
  MatchingLevel({required this.arabicWords, required List<WordItem> englishWords}) : englishWords = List.from(englishWords)..shuffle(Random());
}

class ArEnMatchingScreen extends StatefulWidget {
  final GameLevel? level;
  const ArEnMatchingScreen({super.key, this.level});
  @override
  State<ArEnMatchingScreen> createState() => _ArEnMatchingScreenState();
}

class _ArEnMatchingScreenState extends State<ArEnMatchingScreen> {
  // لوح توصيل مدمج (fallback)؛ يُستبدل بمحتوى الأدمن عند توفّره.
  List<MatchingLevel> _levels = [
    MatchingLevel(
      arabicWords: [
        WordItem(id: 'cat', text: 'قطة', emoji: '🐱'),
        WordItem(id: 'dog', text: 'كلب', emoji: '🐶'),
        WordItem(id: 'apple', text: 'تفاحة', emoji: '🍎'),
      ],
      englishWords: [
        WordItem(id: 'apple', text: 'Apple'),
        WordItem(id: 'cat', text: 'Cat'),
        WordItem(id: 'dog', text: 'Dog'),
      ],
    ),
  ];

  int _currentLevelIndex = 0;
  String? _selectedArabicId;
  String? _selectedEnglishId;
  Set<String> _correctMatches = {};

  @override
  void initState() {
    super.initState();
    _loadContent();
  }

  /// يجلب أزواج التوصيل من الباك إند (قابلة للتعديل من لوحة الأدمن).
  Future<void> _loadContent() async {
    final items = await ContentRepository().getItems('ar_en_matching', widget.level?.levelNumber ?? 1);
    if (items.isEmpty || !mounted) return;
    setState(() {
      _levels = [
        MatchingLevel(
          arabicWords: [
            for (int i = 0; i < items.length; i++)
              WordItem(id: 'p$i', text: items[i].text1, emoji: items[i].text3.isEmpty ? null : items[i].text3),
          ],
          englishWords: [
            for (int i = 0; i < items.length; i++) WordItem(id: 'p$i', text: items[i].text2),
          ],
        ),
      ];
      _currentLevelIndex = 0;
      _selectedArabicId = null;
      _selectedEnglishId = null;
      _correctMatches = {};
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentLevel = _levels[_currentLevelIndex];
    return Scaffold(
      backgroundColor: AppColors.background,
      // ✅ تم تصحيح الـ CustomAppBar هنا بحذف الـ score
      appBar: const CustomAppBar(showBackButton: true),
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(left: 24, right: 24, top: 20, bottom: 40),
          child: Column(
            children: [
              _buildHeader(),
              const SizedBox(height: 30),
              _buildMatchingBoard(currentLevel),
              const SizedBox(height: 40),
              _buildInfoBento(),
            ],
          ),
        ),
      ),
    );
  }

  void _onCardTap(String id, bool isArabic) {
    final currentLevel = _levels[_currentLevelIndex];
    setState(() {
      if (isArabic) { _selectedArabicId = id; } else { _selectedEnglishId = id; }
    });

    if (_selectedArabicId != null && _selectedEnglishId != null) {
      if (_selectedArabicId == _selectedEnglishId) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("تطابق صحيح! ممتاز! 👍")));
        setState(() {
          _correctMatches.add(_selectedArabicId!);
          _selectedArabicId = null;
          _selectedEnglishId = null;
        });

        if (_correctMatches.length == currentLevel.arabicWords.length) {
          _goToNextLevel();
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("حاول مرة أخرى!")));
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) { setState(() { _selectedArabicId = null; _selectedEnglishId = null; }); }
        });
      }
    }
  }

  void _goToNextLevel() async {
    await AudioManager.playWinSound(); // 🔊 صوت الفوز
    await ProgressManager.recordWin('ar_en_matching', level: widget.level); // ✅ تسجيل الفوز باللعبة

    if (!mounted) return;
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: const Text("لقد فزت! 🎉"),
      content: const Text("أكملت التوصيل بنجاح وحصلت على نجومك! ⭐"),
      actions: [TextButton(onPressed: () {
        Navigator.of(ctx).pop();
        Navigator.of(context).pop();
      }, child: const Text("العودة"))],
    ));
  }

  Widget _buildMatchingBoard(MatchingLevel level) => Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.start, children: [Expanded(child: Column(children: level.englishWords.map((word) => _MatchingCard(wordItem: word, textColor: AppColors.secondary, borderColor: AppColors.secondaryContainer, isLeft: true, isSelected: _selectedEnglishId == word.id, isMatched: _correctMatches.contains(word.id), onTap: () => _onCardTap(word.id, false))).toList())), const SizedBox(width: 20), Expanded(child: Column(children: level.arabicWords.map((word) => _MatchingCard(wordItem: word, textColor: AppColors.primary, borderColor: AppColors.primaryContainer, isLeft: false, isSelected: _selectedArabicId == word.id, isMatched: _correctMatches.contains(word.id), onTap: () => _onCardTap(word.id, true))).toList()))]);
  Widget _buildHeader() => Column(children: [Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: AppColors.tertiaryContainer, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: AppColors.tertiaryContainer.withOpacity(0.5), blurRadius: 15, offset: const Offset(0, 5))]), child: Column(children: [const Text("وصّل الكلمة بمعناها!", style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.onTertiaryContainer)), Text("Match the word with its meaning!", style: TextStyle(color: AppColors.onTertiaryContainer.withOpacity(0.8), fontWeight: FontWeight.bold))])), const SizedBox(height: 16), Row(mainAxisAlignment: MainAxisAlignment.center, children: [_buildProgressBubble(isActive: true), _buildProgressBubble(isActive: true), _buildProgressBubble(isActive: false)])]);
  Widget _buildProgressBubble({required bool isActive}) => Container(margin: const EdgeInsets.symmetric(horizontal: 4), width: 25, height: 25, decoration: BoxDecoration(color: isActive ? AppColors.outlineVariant : AppColors.surfaceContainerHigh, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 3)));
  Widget _buildInfoBento() => Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Expanded(flex: 2, child: Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: AppColors.surfaceContainerLow, borderRadius: BorderRadius.circular(20)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text("تعلم كلمات جديدة!", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.onBackground)), const SizedBox(height: 8), Text("أكمل هذا المستوى لفتح بطاقات الحيوانات والفاكهة الجديدة.", style: TextStyle(color: AppColors.onBackground.withOpacity(0.7))) ]))), const SizedBox(width: 16), Expanded(flex: 1, child: Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: AppColors.primaryContainer, borderRadius: BorderRadius.circular(20)), child: const Column(children: [Icon(Icons.emoji_events, size: 30, color: AppColors.onPrimaryContainer), SizedBox(height: 8), Text("جائزة اليوم", style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.onPrimaryContainer)), Text("+50 XP", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.onPrimaryContainer)) ])))]);
}

class _MatchingCard extends StatelessWidget {
  final WordItem wordItem; final Color textColor; final Color borderColor; final bool isLeft; final bool isSelected; final bool isMatched; final VoidCallback onTap;
  const _MatchingCard({required this.wordItem, required this.textColor, required this.borderColor, required this.isLeft, required this.isSelected, required this.isMatched, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(onTap: isMatched ? null : onTap, child: Opacity(opacity: isMatched ? 0.5 : 1.0, child: Container(margin: const EdgeInsets.symmetric(vertical: 12), padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 18), decoration: BoxDecoration(color: isSelected ? borderColor.withOpacity(0.2) : Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: borderColor, width: isSelected ? 3 : 1), boxShadow: isSelected ? [BoxShadow(color: borderColor, blurRadius: 15)] : []), child: Row(children: [if (isLeft) Container(width: 15, height: 15, decoration: BoxDecoration(shape: BoxShape.circle, color: borderColor)), Expanded(child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [if (wordItem.emoji != null) Text(wordItem.emoji!, style: const TextStyle(fontSize: 24)), if (wordItem.emoji != null) const SizedBox(width: 8), Flexible(child: FittedBox(fit: BoxFit.scaleDown, child: Text(wordItem.text, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: textColor))))])), if (!isLeft) Container(width: 15, height: 15, decoration: BoxDecoration(shape: BoxShape.circle, color: borderColor))]))));
}