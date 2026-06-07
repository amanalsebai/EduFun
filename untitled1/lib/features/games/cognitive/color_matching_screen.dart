import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/progress_manager.dart'; // ✅ تتبّع إكمال الألعاب وفتح المستوى التالي
import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/utils/score_manager.dart';

class ColorMatchingLevel {
  final String title;
  final String instruction;
  final List<ColorItem> items;
  final List<ColorTarget> targets;

  ColorMatchingLevel({required this.title, required this.instruction, required this.items, required this.targets});
}

class ColorItem {
  final String id; final String label; final String emoji; final Color nodeColor;
  ColorItem({required this.id, required this.label, required this.emoji, required this.nodeColor});
}

class ColorTarget {
  final String id; final String label; final Color color;
  ColorTarget({required this.id, required this.label, required this.color});
}

class ColorMatchingScreen extends StatefulWidget {
  const ColorMatchingScreen({super.key});

  @override
  State<ColorMatchingScreen> createState() => _ColorMatchingScreenState();
}

class _ColorMatchingScreenState extends State<ColorMatchingScreen> {
  final List<ColorMatchingLevel> _levels = [
    ColorMatchingLevel(
        title: "لعبة مطابقة الألوان",
        instruction: "وصّل كل فاكهة بلونها الصحيح!",
        items: [
          ColorItem(id: "red", label: "تفاحة", emoji: "🍎", nodeColor: AppColors.primaryContainer),
          ColorItem(id: "yellow", label: "موزة", emoji: "🍌", nodeColor: AppColors.tertiaryContainer),
          ColorItem(id: "blue", label: "توت", emoji: "🫐", nodeColor: AppColors.secondaryContainer),
        ],
        targets: [
          ColorTarget(id: "blue", label: "أزرق", color: AppColors.secondary),
          ColorTarget(id: "yellow", label: "أصفر", color: AppColors.tertiary),
          ColorTarget(id: "red", label: "أحمر", color: AppColors.primaryContainer),
        ]
    ),
  ];

  int _currentLevelIndex = 0;
  String? _selectedItemId;
  Map<String, String> _connections = {};

  @override
  Widget build(BuildContext context) {
    final currentLevel = _levels[_currentLevelIndex];
    return Scaffold(
      backgroundColor: AppColors.background,
      // ✅ تم تصحيح الـ CustomAppBar هنا بحذف الـ score
      appBar: const CustomAppBar(showBackButton: true),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              _buildHeader(currentLevel),
              const SizedBox(height: 30),
              _buildGameBoard(currentLevel),
            ],
          ),
        ),
      ),
    );
  }

  void _onItemSelect(String itemId) {
    setState(() {
      if (_selectedItemId == itemId) {
        _selectedItemId = null;
      } else {
        _selectedItemId = itemId;
      }
    });
  }

  void _onTargetSelect(String targetId) {
    if (_selectedItemId != null) {
      if (_selectedItemId == targetId) {
        setState(() {
          _connections[_selectedItemId!] = targetId;
          _selectedItemId = null;
        });

        if (_connections.length == _levels[_currentLevelIndex].items.length) {
          _goToNextLevel();
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("حاول مرة أخرى!")));
        setState(() { _selectedItemId = null; });
      }
    }
  }

  void _goToNextLevel() async {
    await ScoreManager.addStars(50);
    await ProgressManager.markGameCompleted('color_matching'); // ✅ تسجيل الفوز باللعبة

    if (!mounted) return;
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: const Text("تهانينا! 🎉"),
      content: const Text("لقد نجحت في التوصيل وحصلت على 50 نجمة! ⭐"),
      actions: [TextButton(onPressed: () {
        Navigator.of(ctx).pop();
        Navigator.of(context).pop();
      }, child: const Text("العودة"))],
    ));
  }

  Widget _buildHeader(ColorMatchingLevel level) => Column(children: [Text(level.title, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900)), const SizedBox(height: 8), Container(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10), decoration: BoxDecoration(color: AppColors.secondaryContainer, borderRadius: BorderRadius.circular(20)), child: Text(level.instruction, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.onSecondaryContainer)))]);
  Widget _buildGameBoard(ColorMatchingLevel level) => Container(padding: const EdgeInsets.all(24), decoration: BoxDecoration(color: AppColors.surfaceContainer, borderRadius: BorderRadius.circular(24)), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Column(mainAxisAlignment: MainAxisAlignment.spaceAround, children: level.targets.map((target) => _ColorTargetWidget(target: target, isConnected: _connections.containsValue(target.id), onTap: () => _onTargetSelect(target.id))).toList()), Column(mainAxisAlignment: MainAxisAlignment.spaceAround, children: level.items.map((item) => _ImageSourceWidget(item: item, isSelected: _selectedItemId == item.id, isConnected: _connections.containsKey(item.id), onTap: () => _onItemSelect(item.id))).toList())]));
}

class _ColorTargetWidget extends StatelessWidget {
  final ColorTarget target; final bool isConnected; final VoidCallback onTap;
  const _ColorTargetWidget({required this.target, required this.isConnected, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(onTap: onTap, child: Opacity(opacity: isConnected ? 0.5 : 1.0, child: Row(children: [Container(width: 20, height: 20, decoration: BoxDecoration(shape: BoxShape.circle, color: target.color)), const SizedBox(width: 10), Column(children: [Container(width: 80, height: 80, decoration: BoxDecoration(color: target.color, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), offset: const Offset(0, 4))]), child: isConnected ? const Icon(Icons.check_circle, color: Colors.white, size: 40) : null), const SizedBox(height: 8), Text(target.label, style: const TextStyle(fontWeight: FontWeight.bold))])])));
}

class _ImageSourceWidget extends StatelessWidget {
  final ColorItem item; final bool isSelected; final bool isConnected; final VoidCallback onTap;
  const _ImageSourceWidget({required this.item, required this.isSelected, required this.isConnected, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(onTap: isConnected ? null : onTap, child: Opacity(opacity: isConnected ? 0.5 : 1.0, child: Row(children: [Column(children: [Container(width: 100, height: 100, padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: isSelected ? Border.all(color: item.nodeColor, width: 4) : null, boxShadow: isSelected ? [BoxShadow(color: item.nodeColor, blurRadius: 10)] : null), child: Center(child: Text(item.emoji, style: const TextStyle(fontSize: 56)))), const SizedBox(height: 8), Text(item.label, style: const TextStyle(fontWeight: FontWeight.bold))]), const SizedBox(width: 10), Container(width: 20, height: 20, decoration: BoxDecoration(shape: BoxShape.circle, color: item.nodeColor))])));
}