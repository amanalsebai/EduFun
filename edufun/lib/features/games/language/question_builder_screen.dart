import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/progress_manager.dart';
import '../../../core/data/models/game_level.dart';
import '../../../core/data/repositories/content_repository.dart'; // ✅ محتوى قابل للتعديل من الأدمن
import '../../../core/utils/audio_manager.dart'; // ✅ متحكم الصوت // ✅ تتبّع إكمال الألعاب وفتح المستوى التالي
import '../../../core/widgets/custom_app_bar.dart';

class QuestionLevel {
  final String answerText; final List<String> scrambledWords; final String correctQuestion; final String hintText;
  QuestionLevel({required this.answerText, required this.scrambledWords, required this.correctQuestion, required this.hintText});
}

class QuestionBuilderScreen extends StatefulWidget {
  final GameLevel? level;
  const QuestionBuilderScreen({super.key, this.level});
  @override
  State<QuestionBuilderScreen> createState() => _QuestionBuilderScreenState();
}

class _QuestionBuilderScreenState extends State<QuestionBuilderScreen> {
  // أسئلة مدمجة (fallback)؛ تُستبدل بمحتوى الأدمن عند توفّره.
  List<QuestionLevel> _levels = [
    QuestionLevel(answerText: "I am playing football", scrambledWords: ["doing?", "are", "What", "you"], correctQuestion: "What are you doing?", hintText: "ابدأ بكلمة السؤال (What) ثم الفعل المساعد (are)."),
    QuestionLevel(answerText: "My book is on the table", scrambledWords: ["is", "book?", "Where", "my"], correctQuestion: "Where is my book?", hintText: "ابدأ بكلمة السؤال عن المكان (Where) ثم الفعل المساعد (is)."),
  ];

  int _currentLevelIndex = 0; List<String> _wordPool = []; List<String> _targetWords = [];

  @override
  void initState() { super.initState(); _startLevel(); _loadContent(); }

  /// يجلب الأسئلة من الباك إند (قابلة للتعديل من لوحة الأدمن).
  Future<void> _loadContent() async {
    final items = await ContentRepository().getItems('question_builder', widget.level?.levelNumber ?? 1);
    if (items.isEmpty || !mounted) return;
    setState(() {
      _levels = [
        for (final it in items)
          QuestionLevel(
            answerText: it.text1,
            correctQuestion: it.text2,
            scrambledWords: it.text2.trim().split(RegExp(r'\s+')),
            hintText: it.text3,
          ),
      ];
      _currentLevelIndex = 0;
      _startLevel();
    });
  }

  void _startLevel() { _wordPool = List.from(_levels[_currentLevelIndex].scrambledWords)..shuffle(); _targetWords.clear(); }

  void _onWordTap(String word, bool isFromPool) {
    setState(() { if (isFromPool) { _wordPool.remove(word); _targetWords.add(word); } else { _targetWords.remove(word); _wordPool.add(word); } });
    _checkAnswer();
  }

  void _checkAnswer() {
    String currentSentence = _targetWords.join(" ");
    if (currentSentence == _levels[_currentLevelIndex].correctQuestion) {
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
              _buildInstructionSection(currentLevel),
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

  Widget _buildProgressBubbles() => Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(_levels.length, (index) { bool isDone = index < _currentLevelIndex; bool isActive = index == _currentLevelIndex; return Container(margin: const EdgeInsets.symmetric(horizontal: 4), width: isActive ? 45 : 35, height: isActive ? 45 : 35, decoration: BoxDecoration(color: isDone ? const Color(0xFF67E100) : (isActive ? AppColors.tertiaryContainer : AppColors.surfaceContainerHigh), shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 3), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 5)]), child: isDone ? const Icon(Icons.check, color: Colors.white, size: 20) : (isActive ? Center(child: Text("${index + 1}", style: const TextStyle(fontWeight: FontWeight.w900))) : null)); }));
  Widget _buildInstructionSection(QuestionLevel level) => Column(children: [const Text("كوّن السؤال الصحيح للإجابة التالية:", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.onBackground), textAlign: TextAlign.center), const SizedBox(height: 20), Container(padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20), decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), borderRadius: BorderRadius.circular(24), border: Border.all(color: AppColors.secondaryContainer, width: 4), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]), child: Text("\"${level.answerText}\"", textDirection: TextDirection.ltr, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.secondary, letterSpacing: 0.5)))]);
  Widget _buildDropZone() { bool isEmpty = _targetWords.isEmpty; return Container(width: double.infinity, constraints: const BoxConstraints(minHeight: 120), padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white.withOpacity(0.3), borderRadius: BorderRadius.circular(24), border: Border.all(color: AppColors.secondaryContainer.withOpacity(0.5), width: 3, style: BorderStyle.solid)), child: isEmpty ? const Center(child: Text("اضغط على الكلمات بالترتيب...", style: TextStyle(color: AppColors.onSurfaceVariant, fontWeight: FontWeight.bold, fontSize: 16))) : Wrap(spacing: 10, runSpacing: 10, alignment: WrapAlignment.center, children: _targetWords.map((word) => _buildWordCard(word, false)).toList())); }
  Widget _buildMascotHint(QuestionLevel level) => Row(children: [const SizedBox(width: 90, height: 90, child: Center(child: Text("🤖", style: TextStyle(fontSize: 52)))), const SizedBox(width: 12), Expanded(child: Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white.withOpacity(0.85), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withOpacity(0.5), width: 2)), child: Text("تلميح: ${level.hintText}", style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.onSurface))))]);
  Widget _buildWordPool() => Column(children: [const Text("الكلمات المتاحة:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)), const SizedBox(height: 16), Wrap(spacing: 12, runSpacing: 12, alignment: WrapAlignment.center, children: _wordPool.map((word) => _buildWordCard(word, true)).toList())]);
  Widget _buildWordCard(String word, bool isFromPool) => GestureDetector(onTap: () => _onWordTap(word, isFromPool), child: Container(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12), decoration: BoxDecoration(color: AppColors.primaryContainer, borderRadius: BorderRadius.circular(12), border: const Border(bottom: BorderSide(color: AppColors.primaryDim, width: 4))), child: Text(word, textDirection: TextDirection.ltr, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.onPrimaryContainer))));

  void _showSuccessDialog() {
    showDialog(
      context: context, barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 100, height: 100, decoration: const BoxDecoration(color: AppColors.primaryContainer, shape: BoxShape.circle), child: const Icon(Icons.celebration, color: AppColors.primary, size: 60)),
            const SizedBox(height: 20),
            const Text("أحسنت يا بطل! 🎉", style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: AppColors.primary)),
            const SizedBox(height: 10),
            const Text("لقد قمت بصياغة السؤال بشكل صحيح تماماً!", textAlign: TextAlign.center, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
      // ✅ إضافة نجومك وحفظها عند الفوز بالكامل
      await AudioManager.playWinSound(); // 🔊 صوت الفوز
      await ProgressManager.recordWin('question_builder', level: widget.level); // ✅ تسجيل الفوز باللعبة
      if (!mounted) return;
      showDialog(
        context: context, barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Text("عبقري اللغات! 🏆", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w900)),
          content: const Text("لقد أتقنت تركيب الأسئلة بالإنجليزية وحصلت على نجومك! ⭐", textAlign: TextAlign.center),
          actions: [Center(child: ElevatedButton(onPressed: () { Navigator.pop(ctx); Navigator.pop(context); }, style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))), child: const Text("العودة للقائمة", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))))],
        ),
      );
    }
  }
}