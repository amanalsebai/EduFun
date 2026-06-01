import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/custom_app_bar.dart';
import '../../core/widgets/custom_drawer.dart';

// استيراد ألعاب عمر 9 سنوات
import 'math/crossmath_game_screen.dart';
import 'language/error_hunter_screen.dart';
import 'language/question_builder_screen.dart';

class Age9GamesScreen extends StatelessWidget {
  const Age9GamesScreen({super.key});

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
              SizedBox(
                width: 130, height: 130,
                child: Image.network("https://lh3.googleusercontent.com/aida-public/AB6AXuBu6Q_t9b_LnWs0r7KXZf7nBPYWhr6mYKuiEYhbuPoz_QiXhWhlNIBhNeOtvTRcIbIXscWFlYL_Jn3lrJ1BIk3s4MONr40ia_QUsz_2-FAhXGWNP8LTWZAFCrcwggWABvdfM7X8qq8xCoTrgw5yJVzMAfdBNRYHVIQEZcF8mKqnCDh9q_LTfBomB4L48X_T4R6rybInn65g6snNpFOcOUyQbmvTmiWh8Mu_X7LLUW0xh1fG8SKwUrNHDV404sXwAuzoshntJSvBi4mJ", fit: BoxFit.contain),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVerticalGamesList(BuildContext context) {
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
          imageUrl: "https://lh3.googleusercontent.com/aida-public/AB6AXuC9Gvko4HcL8hpAdIVLmN4s74sCiyCFuTIAgaxNvEfCwNH1WhNFFlRhTHcf-VmPb7X9jzMwf-e9OaIgQFcLdACmy8zX_JxMV_sPziYD3THbcmurO92y1Zzxxer2Vg8dXzIPJrgEKiqN97mlL_XNrT5D4RMcGAANORY8S9GUBuzVUhN6vNTsO3NXCGrK9lSX6BN8vEHB3i6kgunkbQJkPl7QchQkJ6M7eYcy9b_NS9iSAAVxal7f5E9Lhd9gYeA9RZ1wyXFuTQMzcI30",
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const CrossMathGameScreen())),
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
          imageUrl: "https://lh3.googleusercontent.com/aida-public/AB6AXuBCfNaZvF4bUeDghDl6f1C2pYMFoN5g07wx3NsbG1fVzzegPJVk52o-yGTYrKKOUDdSR3l8lRTe7ZRasMoQLk688kYZOA1688aZuemwYtFEEwALeFQvimej3XmE_ARFfIt8NDSIqBZOVcTxhzCGOAEIryVjykWmaTG-OKLvVx4ALIRml0o6ELL4iBJSfSxHWiK1oa0chTDbENK4zQ4PGpNXO2z9vkkD_zKTJ4rqSoXNEx3S0EPTIczbv7Vx6GIjw9Dd3I-2oxYPUap2",
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ErrorHunterScreen())),
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
          imageUrl: "https://lh3.googleusercontent.com/aida-public/AB6AXuAseXQBYdYb8kHiafKSm0ifkfZKNYhxrzdurdoxeoEJbgiJyw289WYVMJ7ZGjX4IeOFJAY4OsD-BKsna8FdZt3J9IUuMggfbkWe07E-qebAJrhWgJ5qvbcjaJ-i3XjGOZjl8d2NuJ_YAHZN5EZTD5mG08xB1ubhsvwYHWCiheOZJ1pZzJTmDWlfxlUSg-yu4N7lnVVMPYV7kAebO_NCO4nsPzz_GMMZwmHoHbSw1DQhrrEIpc74Cp4pyw0Rnnht1p4hNlqsgJ8cuJmT",
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const QuestionBuilderScreen())),
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