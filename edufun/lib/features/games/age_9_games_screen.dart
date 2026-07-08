import 'package:flutter/material.dart';
import '../../core/data/models/game.dart';
import '../../core/data/repositories/game_repository.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/custom_app_bar.dart';
import '../../core/widgets/custom_drawer.dart';

// استيراد ألعاب عمر 9 سنوات
import 'game_registry.dart';
import 'widgets/level_select_screen.dart'; // ✅ شاشة اختيار المراحل
import 'widgets/next_level_unlock_card.dart'; // ✅ بطاقة تقدّم المستوى (أعلى مستوى)

class Age9GamesScreen extends StatefulWidget {
  const Age9GamesScreen({super.key});

  @override
  State<Age9GamesScreen> createState() => _Age9GamesScreenState();
}

class _Age9GamesScreenState extends State<Age9GamesScreen> {
  List<Game> _games = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final all = await GameRepository().getByAge(9);
    if (!mounted) return;
    setState(() {
      _games = all.where((g) => hasGameScreen(g.code)).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const CustomDrawer(),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // ✅ تم إزالة الـ score ليعمل تلقائياً
            const CustomAppBar(showBackButton: false),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    _buildMascotHeroSection(),
                    const SizedBox(height: 30),
                    _buildVerticalGamesList(context),
                    const SizedBox(height: 24),
                    // ✅ بطاقة التقدّم — هذا أعلى مستوى فلا يوجد مستوى تالٍ
                    const NextLevelUnlockCard(age: 9),
                    const SizedBox(height: 30),
                    _buildDailyMissionSection(),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMascotHeroSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: AppColors.surfaceContainerHigh, borderRadius: BorderRadius.circular(32)),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Positioned(
            top: -20, right: -20,
            child: Container(width: 100, height: 100, decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle)),
          ),
          Column(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.white.withOpacity(0.5), width: 2)),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("أهلاً يا بطل! 👋", style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.onSurface)),
                        SizedBox(height: 6),
                        Text("أي تحدي ستختار اليوم؟ لديك 3 ألعاب جديدة بانتظارك!", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black45)),
                      ],
                    ),
                  ),
                  Positioned(
                    bottom: -10, right: 40,
                    child: Transform.rotate(
                      angle: 0.785,
                      child: Container(width: 20, height: 20, decoration: BoxDecoration(color: Colors.white, border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.5), width: 2), right: BorderSide(color: Colors.white.withOpacity(0.5), width: 2)))),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              // ✅ مجسّم البطل بأيقونة ثابتة بدل صورة الشبكة المؤقتة
              Container(
                width: 130, height: 130,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.7),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 4),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 15, offset: const Offset(0, 8))],
                ),
                child: const Center(child: Text("🚀", style: TextStyle(fontSize: 64))),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// يفتح شاشة اختيار المراحل للعبة (المراحل من الباك إند مع بديل محلي).
  void _openLevels(BuildContext context, String code, String title) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => LevelSelectScreen(gameCode: code, title: title)),
    );
  }

  Widget _buildVerticalGamesList(BuildContext context) {
    if (_games.isEmpty) {
      return Column(
        children: [
          _VerticalGameCard(
            title: "كروس ماث",
            description: "ألعاب ذكاء ورياضيات ممتعة! حل المعادلات المتقاطعة لتصبح عبقرياً في الحساب.",
            badgeText: "جديد!",
            badgeColor: AppColors.primaryContainer,
            icon: Icons.grid_view_rounded,
            iconColor: AppColors.secondary,
            buttonColor: AppColors.tertiaryContainer,
            shadowColor: AppColors.tertiary,
            imageUrl: "",
            onTap: () => _openLevels(context, "crossmath", "كروس ماث"),
          ),
          _VerticalGameCard(
            title: "صائد الأخطاء",
            description: "هل يمكنك العثور على الأخطاء وعلامات الترقيم المخفية؟ ضع كل علامة في مكانها!",
            badgeText: "برمجة",
            badgeColor: AppColors.tertiaryContainer,
            icon: Icons.pest_control_rounded,
            iconColor: AppColors.outlineVariant,
            buttonColor: AppColors.surfaceContainerHigh,
            shadowColor: AppColors.outline,
            imageUrl: "",
            onTap: () => _openLevels(context, "error_hunter", "صائد الأخطاء"),
          ),
          _VerticalGameCard(
            title: "صانع الأسئلة",
            description: "رتب الكلمات الإنجليزية المبعثرة لتصنع سؤالاً صحيحاً بطريقة تفاعلية مسلية.",
            badgeText: "تحدي",
            badgeColor: AppColors.secondaryContainer,
            icon: Icons.quiz_rounded,
            iconColor: AppColors.primaryContainer,
            buttonColor: AppColors.primaryContainer,
            shadowColor: AppColors.primary,
            imageUrl: "",
            onTap: () => _openLevels(context, "question_builder", "صانع الأسئلة"),
          ),
        ],
      );
    }

    // بيانات بصرية خاصة بكل لعبة (مفتاحها game_code) للحفاظ على الشكل الأصلي.
    const visuals = <String, _VVisual>{
      'crossmath': _VVisual('جديد!', AppColors.primaryContainer, AppColors.secondary, AppColors.tertiaryContainer, AppColors.tertiary, Icons.grid_view_rounded),
      'error_hunter': _VVisual('برمجة', AppColors.tertiaryContainer, AppColors.outlineVariant, AppColors.surfaceContainerHigh, AppColors.outline, Icons.pest_control_rounded),
      'question_builder': _VVisual('تحدي', AppColors.secondaryContainer, AppColors.primaryContainer, AppColors.primaryContainer, AppColors.primary, Icons.quiz_rounded),
    };
    const fallback = _VVisual('لعبة', AppColors.surfaceContainerHigh, AppColors.outlineVariant, AppColors.tertiaryContainer, AppColors.tertiary, Icons.games_rounded);

    return Column(
      children: [
        for (final g in _games)
          _VerticalGameCard(
            title: g.title,
            description: g.subtitle,
            badgeText: (visuals[g.code] ?? fallback).badge,
            badgeColor: (visuals[g.code] ?? fallback).badgeColor,
            icon: (visuals[g.code] ?? fallback).icon,
            iconColor: (visuals[g.code] ?? fallback).iconColor,
            buttonColor: (visuals[g.code] ?? fallback).buttonColor,
            shadowColor: (visuals[g.code] ?? fallback).shadow,
            imageUrl: "",
            onTap: () => _openLevels(context, g.code, g.title),
          ),
      ],
    );
  }

  Widget _buildDailyMissionSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.5), borderRadius: BorderRadius.circular(32), border: Border.all(color: AppColors.surfaceContainerHigh.withOpacity(0.3), width: 2)),
      child: Column(
        children: [
          const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text("المهمة اليومية", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)), Text("80%", style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w900, fontSize: 16))]),
          const SizedBox(height: 12),
          Container(height: 24, padding: const EdgeInsets.all(2), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.surfaceContainerHigh.withOpacity(0.5))), child: FractionallySizedBox(alignment: Alignment.centerRight, widthFactor: 0.8, child: Container(decoration: BoxDecoration(gradient: const LinearGradient(colors: [AppColors.primaryContainer, AppColors.primary]), borderRadius: BorderRadius.circular(12))))),
          const SizedBox(height: 16),
          const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text("باقي القليل للصندوق الذهبي! 🎁", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black45)), Row(children: [Text("🔥 ", style: TextStyle(fontSize: 16)), Text("5 أيام", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14))])])
        ],
      ),
    );
  }
}

class _VerticalGameCard extends StatelessWidget {
  final String title, description, badgeText, imageUrl; final Color badgeColor, iconColor, buttonColor, shadowColor; final IconData icon; final VoidCallback onTap;
  const _VerticalGameCard({required this.title, required this.description, required this.badgeText, required this.badgeColor, required this.icon, required this.iconColor, required this.buttonColor, required this.shadowColor, required this.onTap, required this.imageUrl});
  @override
  Widget build(BuildContext context) { return Container(margin: const EdgeInsets.only(bottom: 24), padding: const EdgeInsets.all(24), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(32), border: Border(bottom: BorderSide(color: shadowColor.withOpacity(0.3), width: 6)), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 10))]), child: Column(children: [Stack(clipBehavior: Clip.none, children: [Container(width: 90, height: 90, decoration: BoxDecoration(color: iconColor.withOpacity(0.1), shape: BoxShape.circle, border: Border.all(color: iconColor.withOpacity(0.2), width: 2)), child: Icon(icon, size: 45, color: iconColor)), Positioned(top: -5, right: -5, child: Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: badgeColor, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)]), child: Text(badgeText, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: badgeColor == AppColors.primaryContainer ? AppColors.onPrimaryContainer : AppColors.onSurface))))]), const SizedBox(height: 16), Text(title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.onSurface)), const SizedBox(height: 8), Text(description, textAlign: TextAlign.center, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.onSurfaceVariant)), const SizedBox(height: 24), _TactileButton(text: "العب الآن", color: buttonColor, shadowColor: shadowColor, onTap: onTap)])); }
}

class _TactileButton extends StatefulWidget {
  final String text; final Color color, shadowColor; final VoidCallback onTap;
  const _TactileButton({required this.text, required this.color, required this.shadowColor, required this.onTap});
  @override
  State<_TactileButton> createState() => _TactileButtonState();
}

class _TactileButtonState extends State<_TactileButton> {
  bool _isPressed = false;
  @override
  Widget build(BuildContext context) { return GestureDetector(onTapDown: (_) => setState(() => _isPressed = true), onTapUp: (_) { setState(() => _isPressed = false); widget.onTap(); }, onTapCancel: () => setState(() => _isPressed = false), child: AnimatedContainer(duration: const Duration(milliseconds: 100), width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 16), transform: Matrix4.translationValues(0, _isPressed ? 4 : 0, 0), decoration: BoxDecoration(color: widget.color, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: widget.shadowColor, offset: Offset(0, _isPressed ? 0 : 6), blurRadius: 0)]), child: Text(widget.text, textAlign: TextAlign.center, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.onSurface)))); }
}

/// بيانات بصرية ثابتة لكل بطاقة عمودية (شارة/ألوان/أيقونة) للحفاظ على الشكل الأصلي.
class _VVisual {
  final String badge;
  final Color badgeColor;
  final Color iconColor;
  final Color buttonColor;
  final Color shadow;
  final IconData icon;
  const _VVisual(this.badge, this.badgeColor, this.iconColor, this.buttonColor, this.shadow, this.icon);
}