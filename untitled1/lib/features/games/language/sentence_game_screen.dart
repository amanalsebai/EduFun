import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/utils/score_manager.dart';

class SentenceGameScreen extends StatefulWidget {
  const SentenceGameScreen({super.key});
  @override
  State<SentenceGameScreen> createState() => _SentenceGameScreenState();
}

class _SentenceGameScreenState extends State<SentenceGameScreen> {
  final List<String?> targetSlots = [null, null, null];
  final List<Map<String, dynamic>> availableWords = [
    {"word": "يحبني", "color": AppColors.primaryContainer, "onColor": AppColors.onPrimaryContainer},
    {"word": "هذا", "color": AppColors.secondaryContainer, "onColor": AppColors.onSecondaryContainer},
    {"word": "بابا", "color": AppColors.tertiaryContainer, "onColor": AppColors.onTertiaryContainer},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      // ✅ تم تصحيح الـ CustomAppBar هنا بحذف الـ score
      appBar: const CustomAppBar(showBackButton: true),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 120, top: 20, left: 20, right: 20),
                child: Column(
                  children: [
                    _buildTitle(),
                    const SizedBox(height: 30),
                    _buildGameArea(),
                    const SizedBox(height: 40),
                    _buildStatsBento(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.large(
        onPressed: () async {
          if (targetSlots[0] == "هذا" && targetSlots[1] == "بابا" && targetSlots[2] == "يحبني") {
            await ScoreManager.addStars(50);

            if (!mounted) return;
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (ctx) => AlertDialog(
                title: const Text("تهانينا! 🎉"),
                content: const Text("لقد رتبت الجملة بشكل صحيح وحصلت على 50 نجمة! ⭐"),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      Navigator.of(context).pop();
                    },
                    child: const Text("العودة"),
                  ),
                ],
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("ترتيب غير صحيح، حاول مجدداً! 🧐")));
          }
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.check_circle, color: Colors.white, size: 40),
      ),
    );
  }

  Widget _buildTitle() => const Column(children: [Text("رتب الكلمات لتكون\nجملة مفيدة!", textAlign: TextAlign.center, style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: AppColors.onBackground, height: 1.2)), SizedBox(height: 8), Text("اسحب الكلمات إلى المربعات الفارغة", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.onSurfaceVariant))]);
  Widget _buildGameArea() => Container(padding: const EdgeInsets.all(24), decoration: BoxDecoration(color: AppColors.surfaceContainerLow, borderRadius: BorderRadius.circular(24)), child: Column(children: [Wrap(spacing: 16, runSpacing: 16, alignment: WrapAlignment.center, children: availableWords.map((item) { bool isUsed = targetSlots.contains(item["word"]); return isUsed ? const SizedBox(width: 100, height: 100) : Draggable<String>(data: item["word"]!, feedback: Material(color: Colors.transparent, child: _buildWordBubble(item["word"]!, item["color"], item["onColor"]!, scale: 1.1)), childWhenDragging: Opacity(opacity: 0.3, child: _buildWordBubble(item["word"]!, item["color"], item["onColor"]!)), child: _buildWordBubble(item["word"]!, item["color"], item["onColor"]!)); }).toList()), const SizedBox(height: 50), Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: List.generate(3, (index) => _buildDragTarget(index)))]));
  Widget _buildWordBubble(String word, Color bgColor, Color textColor, {double scale = 1.0}) => Transform.scale(scale: scale, child: Container(width: 100, height: 100, decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle, border: Border.all(color: Colors.white.withOpacity(0.5), width: 4), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))]), child: Center(child: Text(word, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: textColor)))));
  Widget _buildDragTarget(int index) => DragTarget<String>(onAccept: (receivedWord) { setState(() { targetSlots[index] = receivedWord; }); }, builder: (context, candidateData, rejectedData) { bool hasData = targetSlots[index] != null; return Container(width: 90, height: 70, decoration: BoxDecoration(color: hasData ? Colors.transparent : AppColors.surfaceContainerHighest.withOpacity(0.2), borderRadius: BorderRadius.circular(12), border: Border.all(color: hasData ? Colors.transparent : AppColors.outlineVariant.withOpacity(0.3), width: 3, style: BorderStyle.solid)), child: hasData ? _buildWordBubble(targetSlots[index]!, Colors.white, AppColors.onSurface, scale: 0.8) : Center(child: Text("${index + 1}", style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900, color: AppColors.outlineVariant.withOpacity(0.3))))); });
  Widget _buildStatsBento() => Row(children: [_buildStatCard(Icons.timer, "الوقت", "02:45", AppColors.secondaryContainer, AppColors.secondary), const SizedBox(width: 12), _buildStatCard(Icons.star_rounded, "النقاط", "850", AppColors.primaryContainer, AppColors.primary)]);
  Widget _buildStatCard(IconData icon, String title, String value, Color bgColor, Color iconColor) => Expanded(child: Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border(bottom: BorderSide(color: bgColor, width: 6))), child: Row(children: [Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle), child: Icon(icon, color: iconColor)), const SizedBox(width: 12), Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.onSurfaceVariant)), Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.onSurface))])])));
}