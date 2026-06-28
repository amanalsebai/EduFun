import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/audio_manager.dart';
import '../../../core/utils/progress_manager.dart'; // ✅ تتبّع إكمال الألعاب وفتح المستوى التالي
import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/utils/score_manager.dart'; // استيراد متحكم النقاط

class ErrorHunterLevel {
  final List<String> words;
  final int errorWordIndex;
  final String correctWord;
  final String hint;

  ErrorHunterLevel({
    required this.words,
    required this.errorWordIndex,
    required this.correctWord,
    required this.hint,
  });
}

class ErrorHunterScreen extends StatefulWidget {
  const ErrorHunterScreen({super.key});

  @override
  State<ErrorHunterScreen> createState() => _ErrorHunterScreenState();
}

class _ErrorHunterScreenState extends State<ErrorHunterScreen> {
  final List<ErrorHunterLevel> _levels = [
    ErrorHunterLevel(
      words: ["ذهب", "الولد", "الا", "المدرسة"],
      errorWordIndex: 2,
      correctWord: "إلى",
      hint: "كلمة 'الا' تحتاج لشيء في بدايتها وتحتها لتصبح حرف جر صحيح!",
    ),
    ErrorHunterLevel(
      words: ["هاذا", "بيت", "جميل", "جداً"],
      errorWordIndex: 0,
      correctWord: "هذا",
      hint: "هناك حرف ألف زائد ينطق ولا يكتب في اسم الإشارة الأول!",
    ),
    ErrorHunterLevel(
      words: ["قراءت", "قصة", "ممتعة", "أمس"],
      errorWordIndex: 0,
      correctWord: "قرأتُ",
      hint: "الهمزة في كلمة 'قراءت' يجب أن تجلس فوق الألف وليس على السطر!",
    ),
  ];

  int _currentLevelIndex = 0;
  int _timeLeft = 45;
  Timer? _gameTimer;

  final Set<int> _wrongClickedIndices = {};
  bool _isCorrectAnswerFound = false;

  @override
  void initState() {
    super.initState();
    _startNewLevel();
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    super.dispose();
  }

  void _startNewLevel() {
    _timeLeft = 45;
    _isCorrectAnswerFound = false;
    _wrongClickedIndices.clear();
    _startTimer();
  }

  void _startTimer() {
    _gameTimer?.cancel();
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft > 0) {
        setState(() {
          _timeLeft--;
        });
      } else {
        _gameTimer?.cancel();
        _showTimeOutDialog();
      }
    });
  }

  void _onWordTap(int index, bool isErrorWord) {
    if (_isCorrectAnswerFound) return;

    if (isErrorWord) {
      _gameTimer?.cancel();
      setState(() {
        _isCorrectAnswerFound = true;
      });

      Future.delayed(const Duration(milliseconds: 500), () {
        _showSuccessDialog();
      });
    } else {
      setState(() {
        _wrongClickedIndices.add(index);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("هذه الكلمة صحيحة! ابحث عن الكلمة المكتوبة بشكل خاطئ. 🔎")),
      );
      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted) {
          setState(() {
            _wrongClickedIndices.remove(index);
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentLevel = _levels[_currentLevelIndex];
    String timerText = "00:${_timeLeft.toString().padLeft(2, '0')}";

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(showBackButton: true),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(left: 24, right: 24, top: 10, bottom: 40),
          child: Column(
            children: [
              _buildProgressBubbles(),
              const SizedBox(height: 24),
              _buildMascotSection(),
              const SizedBox(height: 30),
              _buildSentenceCanvas(currentLevel),
              const SizedBox(height: 30),
              _buildHintAndTimerRow(currentLevel, timerText),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressBubbles() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_levels.length, (index) {
        bool isDone = index < _currentLevelIndex;
        bool isActive = index == _currentLevelIndex;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 45 : 35,
          height: isActive ? 45 : 35,
          decoration: BoxDecoration(
            color: isDone ? const Color(0xFF67E100) : (isActive ? AppColors.tertiaryContainer : AppColors.surfaceContainerHigh),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 5)],
          ),
          child: isDone
              ? const Icon(Icons.check, color: Colors.white, size: 20)
              : (isActive ? Center(child: Text("${index + 1}", style: const TextStyle(fontWeight: FontWeight.w900))) : null),
        );
      }),
    );
  }

  Widget _buildMascotSection() {
    return Row(
      children: [
        SizedBox(
          width: 100, height: 100,
          child: const Center(child: Text("🕵️", style: TextStyle(fontSize: 60))),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.85),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
                bottomLeft: Radius.circular(20),
              ),
              border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
            ),
            child: const Text(
              "يا بطل! هناك كلمة مكتوبة بشكل خاطئ مختبئة في هذه الجملة.. هل يمكنك العثور عليها والضغط عليها؟ 🔎",
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.secondary, height: 1.4),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSentenceCanvas(ErrorHunterLevel level) {
    return Container(
      padding: const EdgeInsets.all(24),
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        alignment: WrapAlignment.center,
        children: List.generate(level.words.length, (index) {
          bool isErrorWord = index == level.errorWordIndex;
          bool isClickedWrong = _wrongClickedIndices.contains(index);
          bool isCorrectAndFound = isErrorWord && _isCorrectAnswerFound;

          Color cardBg = isCorrectAndFound
              ? const Color(0xFF67E100)
              : (isClickedWrong ? AppColors.error : AppColors.surfaceContainerLow);

          Color shadowColor = isCorrectAndFound
              ? const Color(0xFF3B8700)
              : (isClickedWrong ? const Color(0xFF8A1D00) : AppColors.outlineVariant);

          return _WordBubbleButton(
            text: level.words[index],
            bgColor: cardBg,
            shadowColor: shadowColor,
            textColor: (isCorrectAndFound || isClickedWrong) ? Colors.white : AppColors.onSurface,
            onTap: () => _onWordTap(index, isErrorWord),
          );
        }),
      ),
    );
  }

  Widget _buildHintAndTimerRow(ErrorHunterLevel level, String timerText) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.tertiaryContainer,
              borderRadius: BorderRadius.circular(20),
              border: const Border(bottom: BorderSide(color: AppColors.tertiary, width: 4)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.3), shape: BoxShape.circle),
                  child: const Icon(Icons.lightbulb_rounded, color: AppColors.onTertiaryContainer, size: 24),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("تلميح ذكي", style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.onTertiaryContainer, fontSize: 14)),
                      const SizedBox(height: 4),
                      Expanded(
                        child: Text(
                            level.hint,
                            style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.onTertiaryContainer.withOpacity(0.8), fontSize: 11, height: 1.3)
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.secondaryContainer,
              borderRadius: BorderRadius.circular(20),
              border: const Border(bottom: BorderSide(color: AppColors.secondary, width: 4)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.3), shape: BoxShape.circle),
                  child: const Icon(Icons.timer_rounded, color: AppColors.onSecondaryContainer, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("وقت التحدي", style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.onSecondaryContainer, fontSize: 14)),
                      const SizedBox(height: 4),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(timerText, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.onSecondaryContainer, letterSpacing: 1)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showSuccessDialog() {
    final level = _levels[_currentLevelIndex];
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 100, height: 100,
              decoration: const BoxDecoration(color: AppColors.primaryContainer, shape: BoxShape.circle),
              child: const Icon(Icons.celebration, color: AppColors.primary, size: 60),
            ),
            const SizedBox(height: 20),
            const Text("رائع جداً! 🎉", style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: AppColors.primary)),
            const SizedBox(height: 10),
            Text(
              "لقد وجدت الخطأ! الكلمة الصحيحة هي: [ ${level.correctWord} ]",
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                _goToNextLevel();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              child: const Text("المرحلة التالية 🚀", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }

  void _showTimeOutDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.hourglass_empty_rounded, color: AppColors.error, size: 80),
            const SizedBox(height: 20),
            const Text("انتهى الوقت! ⏳", style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: AppColors.error)),
            const SizedBox(height: 10),
            const Text("حاول مرة أخرى لتصطاد الأخطاء أسرع!", textAlign: TextAlign.center, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                setState(() {
                  _startNewLevel();
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              child: const Text("إعادة المحاولة 🔄", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }

  void _goToNextLevel() async {
    if (_currentLevelIndex < _levels.length - 1) {
      setState(() {
        _currentLevelIndex++;
        _startNewLevel();
      });
    } else {
      // ✅ إضافة وحفظ 50 نجمة للطفل في ذاكرة الجوال
      await ScoreManager.addStars(50);
      await ProgressManager.markGameCompleted('error_hunter'); // ✅ تسجيل الفوز باللعبة
      await AudioManager.playWinSound();
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Text("بطل الإملاء! 🏆", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w900)),
          content: const Text("لقد اصطدت جميع الكلمات الخاطئة بنجاح وحصلت على 50 نجمة! ⭐", textAlign: TextAlign.center),
          actions: [
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
                child: const Text("العودة للقائمة", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      );
    }
  }
}

class _WordBubbleButton extends StatelessWidget {
  final String text;
  final Color bgColor;
  final Color shadowColor;
  final Color textColor;
  final VoidCallback onTap;

  const _WordBubbleButton({
    required this.text,
    required this.bgColor,
    required this.shadowColor,
    required this.textColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border(bottom: BorderSide(color: shadowColor, width: 6)),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            color: textColor,
          ),
        ),
      ),
    );
  }
}