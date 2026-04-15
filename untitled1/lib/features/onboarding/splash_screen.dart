import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/mascot_robot.dart';
import 'age_selection_screen.dart'; // سنقوم بإنشائه في الخطوة التالية

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // الانتقال التلقائي بعد 3 ثوانٍ
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const AgeSelectionScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondaryContainer, // لون السماء (أزرق فاتح)
      body: Stack(
        children: [
          // 1. السحب والطائرات في الخلفية
          _buildBackgroundClouds(),

          // 2. المحتوى الرئيسي (اللمبة والنص)
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildHeroBulb(),
                const SizedBox(height: 30),
                _buildTitle(),
                const SizedBox(height: 50),
                _buildLoadingBar(),
              ],
            ),
          ),

          // 3. الروبوت والفقاعة النصية في الأسفل
          Positioned(
            bottom: 30,
            left: 20,
            child: _buildRobotWithBubble(),
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundClouds() {
    return Stack(
      children: [
        Positioned(top: 100, left: 50, child: Icon(Icons.flight, color: Colors.white.withOpacity(0.5), size: 60)),
        Positioned(top: 250, right: 40, child: Transform.rotate(angle: 0.2, child: Icon(Icons.flight, color: AppColors.secondary.withOpacity(0.2), size: 50))),
        Positioned(top: 150, left: 80, child: Container(width: 100, height: 40, decoration: BoxDecoration(color: Colors.white.withOpacity(0.4), borderRadius: BorderRadius.circular(50), boxShadow: [BoxShadow(color: Colors.white.withOpacity(0.5), blurRadius: 20)]))),
      ],
    );
  }

  Widget _buildHeroBulb() {
    return SizedBox(
      width: 200,
      height: 200,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // العباءة الحمراء
          Positioned(
            top: 20,
            child: Transform.rotate(
              angle: 0.1,
              child: Container(
                width: 160,
                height: 100,
                decoration: const BoxDecoration(
                  color: AppColors.tertiary, // اللون الأحمر الداكن
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(100)),
                  boxShadow: [BoxShadow(color: Color(0xFF380014), offset: Offset(0, 8))],
                ),
              ),
            ),
          ),
          // اللمبة
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.primaryContainer, // أصفر
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 8),
              boxShadow: const [BoxShadow(color: AppColors.tertiary, offset: Offset(0, 10))],
            ),
            child: const Icon(Icons.lightbulb_rounded, size: 80, color: AppColors.tertiary),
          ),
          // نجوم متناثرة
          const Positioned(top: 0, right: 10, child: Icon(Icons.star, color: Colors.white, size: 30)),
          const Positioned(bottom: 20, left: 0, child: Icon(Icons.star, color: AppColors.primaryContainer, size: 40)),
        ],
      ),
    );
  }

  Widget _buildTitle() {
    return Column(
      children: [
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [AppColors.tertiary, AppColors.secondary, AppColors.primaryContainer],
          ).createShader(bounds),
          child: const Text(
            "ألعاب ذكية",
            style: TextStyle(fontSize: 60, fontWeight: FontWeight.w900, color: Colors.white),
          ),
        ),
        const Text("SMART GAMES", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.onSecondaryContainer, letterSpacing: 2)),
      ],
    );
  }

  Widget _buildLoadingBar() {
    return Column(
      children: [
        Container(
          width: 200,
          height: 16,
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.4), borderRadius: BorderRadius.circular(20)),
          child: Align(
            alignment: Alignment.centerRight,
            child: Container(
              width: 140, // نسبة التقدم
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [AppColors.tertiary, AppColors.tertiaryContainer]),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        const Text("جاري التحميل...", style: TextStyle(color: AppColors.onSecondaryContainer, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildRobotWithBubble() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        const MascotRobot(size: 140),
        Positioned(
          top: -30,
          right: -40,
          child: Transform.rotate(
            angle: 0.1,
            child: const GlassCard(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text("مرحباً يا بطل!", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.onSurface)),
            ),
          ),
        ),
      ],
    );
  }
}