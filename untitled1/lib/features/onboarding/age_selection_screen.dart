import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/glass_card.dart';
// استيراد شاشة لوحة الألعاب (Dashboard)
import '../dashboard/dashboard_screen.dart';

class AgeSelectionScreen extends StatelessWidget {
  const AgeSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              _buildHeader(),
              const Spacer(),
              _buildTitles(),
              const SizedBox(height: 40),
              _buildAgeButtonsGrid(context),
              const SizedBox(height: 40),
              _buildMascotTip(),
              const Spacer(),
              _buildProgressBar(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
            ],
          ),
          child: const Row(
            children: [
              Icon(Icons.favorite, color: AppColors.tertiary, size: 20),
              SizedBox(width: 8),
              Text(
                "PLAYZONE",
                style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.onSurface),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTitles() {
    return const Column(
      children: [
        Text(
          "أهلاً بك يا بطل!\nكم عمرك؟",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.w900,
            color: AppColors.tertiary,
            height: 1.2,
          ),
        ),
        SizedBox(height: 12),
        Text(
          "اختر عمرك لنبدأ المغامرة!",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildAgeButtonsGrid(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 20,
      crossAxisSpacing: 20,
      childAspectRatio: 1.0,
      children: [
        _AgeButton(
          age: "7 سنوات",
          icon: Icons.star_rounded,
          color: const Color(0xFFA5FF6F), // أخضر فاتح
          shadowColor: const Color(0xFF3B8700),
          onTap: () => _navigateToDashboard(context),
        ),
        _AgeButton(
          age: "8 سنوات",
          icon: Icons.rocket_launch_rounded,
          color: const Color(0xFFFDD400), // أصفر
          shadowColor: const Color(0xFF6D5A00),
          onTap: () => _navigateToDashboard(context),
        ),
        _AgeButton(
          age: "9 سنوات",
          icon: Icons.emoji_events_rounded,
          color: const Color(0xFFA7D7FF), // أزرق
          shadowColor: const Color(0xFF00618F),
          onTap: () => _navigateToDashboard(context),
        ),
        _AgeButton(
          age: "10 سنوات",
          icon: Icons.workspace_premium_rounded,
          color: const Color(0xFFFF8FA9), // وردي
          shadowColor: const Color(0xFFB60051),
          onTap: () => _navigateToDashboard(context),
        ),
      ],
    );
  }

  Widget _buildMascotTip() {
    return const GlassCard(
      child: Row(
        children: [
          Text("🌟", style: TextStyle(fontSize: 30)),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              "أهلاً بك! اختيار عمرك يساعدنا في العثور على أفضل الألعاب المناسبة لك.",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: AppColors.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return Column(
      children: [
        Row(
          children: [
            Container(
              height: 20,
              width: 100,
              decoration: BoxDecoration(
                color: AppColors.outlineVariant,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.only(left: 4),
                  child: Icon(Icons.eco, color: Colors.white, size: 16),
                ),
              ),
            ),
            Expanded(
              child: Container(
                height: 10,
                decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Text(
          "الخطوة الأولى من ٣",
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black38),
        ),
      ],
    );
  }

  // دالة الانتقال إلى صفحة عالم الألعاب
  void _navigateToDashboard(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const DashboardScreen()),
    );
  }
}

// ويدجت زر العمر (تصميم 3D Toy Block)
class _AgeButton extends StatefulWidget {
  final String age;
  final IconData icon;
  final Color color;
  final Color shadowColor;
  final VoidCallback onTap;

  const _AgeButton({
    required this.age,
    required this.icon,
    required this.color,
    required this.shadowColor,
    required this.onTap,
  });

  @override
  State<_AgeButton> createState() => _AgeButtonState();
}

class _AgeButtonState extends State<_AgeButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        // عند الضغط ينزل الزر للأسفل قليلاً ليخفي الظل (تأثير الزر الحقيقي)
        transform: Matrix4.translationValues(0, _isPressed ? 6 : 0, 0),
        decoration: BoxDecoration(
          color: widget.color,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: widget.shadowColor,
              offset: Offset(0, _isPressed ? 0 : 8), // الظل يختفي عند الضغط
              blurRadius: 0,
            )
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              top: -10,
              right: -10,
              child: Icon(widget.icon, size: 100, color: Colors.black.withOpacity(0.05)),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.5), shape: BoxShape.circle),
                    child: Icon(widget.icon, size: 40, color: AppColors.onSurface),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.age,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.onSurface),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}