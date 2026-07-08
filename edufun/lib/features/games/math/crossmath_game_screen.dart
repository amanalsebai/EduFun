import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/progress_manager.dart';
import '../../../core/data/models/game_level.dart';
import '../../../core/utils/audio_manager.dart'; // ✅ متحكم الصوت // ✅ تتبّع إكمال الألعاب وفتح المستوى التالي
import '../../../core/widgets/custom_app_bar.dart';

class CrossMathGameScreen extends StatefulWidget {
  final GameLevel? level;
  const CrossMathGameScreen({super.key, this.level});
  @override
  State<CrossMathGameScreen> createState() => _CrossMathGameScreenState();
}

class _CrossMathGameScreenState extends State<CrossMathGameScreen> {
  int? _droppedValue;
  final List<int> _availableNumbers = [5, 3, 7, 1];
  final int _correctAnswer = 5;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(showBackButton: true),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            children: [
              _buildTitle(),
              const SizedBox(height: 20),
              _buildMascotHint(),
              const SizedBox(height: 30),
              _buildCrossMathGrid(),
              const SizedBox(height: 40),
              _buildNumbersTray(),
            ],
          ),
        ),
      ),
    );
  }

  void _checkResult(int value) async {
    if (value == _correctAnswer) {
      // ✅ إضافة نجومك للطفل وحفظها في ذاكرة الجوال
      await AudioManager.playWinSound(); // 🔊 صوت الفوز
      await ProgressManager.recordWin('crossmath', level: widget.level); // ✅ تسجيل الفوز باللعبة

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("إجابة صحيحة ومذهلة! ذكاء بطل! 🌟", style: TextStyle(fontSize: 18))));
      Future.delayed(const Duration(milliseconds: 500), _showWinDialog);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("المعادلتان غير صحيحتين، حاول مجدداً! 🧐", style: TextStyle(fontSize: 18))));
      Future.delayed(const Duration(milliseconds: 1000), () {
        setState(() { _droppedValue = null; });
      });
    }
  }

  void _showWinDialog() {
    showDialog(
      context: context, barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("عبقري الرياضيات! 🏆", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w900)),
        content: const Text("لقد قمت بحل المعادلات المتقاطعة بنجاح وحصلت على نجومك! ⭐", textAlign: TextAlign.center),
        actions: [Center(child: ElevatedButton(onPressed: () { Navigator.pop(ctx); Navigator.pop(context); }, style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))), child: const Text("العودة للقائمة", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))))],
      ),
    );
  }

  Widget _buildTitle() => const Column(children: [Text("لعبة كروس ماث", style: TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: AppColors.onBackground)), SizedBox(height: 4), Text("أكمل المعادلات لتفوز!", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.onSurfaceVariant))]);
  Widget _buildMascotHint() => Row(crossAxisAlignment: CrossAxisAlignment.end, children: [Container(width: 90, height: 90, margin: const EdgeInsets.only(bottom: 10), child: const Center(child: Text("🤖", style: TextStyle(fontSize: 52)))), const SizedBox(width: 8), Expanded(child: Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white.withOpacity(0.85), borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20), bottomLeft: Radius.circular(20)), border: Border.all(color: Colors.white.withOpacity(0.5), width: 2), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]), child: const Text("\"مرحباً! حاول سحب الرقم ٥ إلى المربع الفارغ لحل المعادلتين معاً.\"", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.onSurface, height: 1.4))))]);
  Widget _buildCrossMathGrid() => Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: AppColors.surfaceContainerLow, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))]), child: GridView.count(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), crossAxisCount: 4, mainAxisSpacing: 12, crossAxisSpacing: 12, children: [_buildCell(text: "8", isNumber: true), _buildCell(text: "−"), _buildDragTarget(), _buildCell(text: "= 3"), _buildCell(text: "+"), _buildCell(text: "", isVisible: false), _buildCell(text: "+"), _buildCell(text: "", isVisible: false), _buildCell(text: "4", isNumber: true), _buildCell(text: "+"), _buildCell(text: "2", isNumber: true), _buildCell(text: "= 6"), _buildCell(text: "= 12"), _buildCell(text: "", isVisible: false), _buildCell(text: "= 7"), _buildCell(text: "", isVisible: false)]));
  Widget _buildCell({required String text, bool isNumber = false, bool isVisible = true}) => !isVisible ? const SizedBox() : Container(decoration: BoxDecoration(color: isNumber ? Colors.white : Colors.transparent, borderRadius: BorderRadius.circular(12), boxShadow: isNumber ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5, offset: const Offset(0, 2))] : []), child: Center(child: Text(text, style: TextStyle(fontSize: isNumber ? 28 : 22, fontWeight: isNumber ? FontWeight.w900 : FontWeight.bold, color: isNumber ? AppColors.secondary : AppColors.onSurfaceVariant))));
  Widget _buildDragTarget() { bool hasData = _droppedValue != null; return DragTarget<int>(onAccept: (receivedValue) { setState(() { _droppedValue = receivedValue; }); _checkResult(receivedValue); }, builder: (context, candidateData, rejectedData) { return Container(decoration: BoxDecoration(color: hasData ? Colors.white : AppColors.surfaceContainerLow.withOpacity(0.5), borderRadius: BorderRadius.circular(12), border: Border.all(color: hasData ? AppColors.outlineVariant : AppColors.outlineVariant.withOpacity(0.5), width: 3, style: BorderStyle.solid)), child: Center(child: Text(hasData ? "$_droppedValue" : "", style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: AppColors.primary)))); }); }
  Widget _buildNumbersTray() => Column(children: [const Text("اسحب الأرقام:", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)), const SizedBox(height: 16), Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: _availableNumbers.map((num) { bool isUsed = _droppedValue == num; return isUsed ? const SizedBox(width: 65, height: 65) : Draggable<int>(data: num, feedback: Material(color: Colors.transparent, child: _buildNumberTile(num, scale: 1.1)), childWhenDragging: Opacity(opacity: 0.3, child: _buildNumberTile(num)), child: _buildNumberTile(num)); }).toList())]);
  Widget _buildNumberTile(int number, {double scale = 1.0}) => Transform.scale(scale: scale, child: Container(width: 65, height: 65, decoration: BoxDecoration(color: number == 7 ? AppColors.tertiaryContainer : AppColors.primaryContainer, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: number == 7 ? AppColors.tertiaryDim : AppColors.primaryDim, offset: const Offset(0, 5))]), child: Center(child: Text("$number", style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900, color: number == 7 ? AppColors.onTertiaryContainer : AppColors.onPrimaryContainer)))));
}