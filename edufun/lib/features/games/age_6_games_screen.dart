import 'package:flutter/material.dart';
import '../../core/data/models/game.dart';
import '../../core/data/repositories/game_repository.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/custom_app_bar.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/custom_drawer.dart';
import 'game_registry.dart';
import 'widgets/category_card.dart';
import 'widgets/level_select_screen.dart'; // ✅ شاشة اختيار المراحل
import 'widgets/next_level_unlock_card.dart'; // ✅ بطاقة فتح المستوى التالي

import 'age_7_games_screen.dart'; // ✅ ألعاب المستوى التالي (٧ سنوات)

class Age6GamesScreen extends StatefulWidget {
  const Age6GamesScreen({super.key});

  @override
  State<Age6GamesScreen> createState() => _Age6GamesScreenState();
}

class _Age6GamesScreenState extends State<Age6GamesScreen> {
  List<Game> _games = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final all = await GameRepository().getByAge(6);
    if (!mounted) return;
    setState(() {
      _games = all.where((g) => hasGameScreen(g.code)).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryContainer,
      drawer: const CustomDrawer(currentIndex: 0),
      body: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.05,
              child: CustomPaint(painter: _DotPatternPainter()),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                const CustomAppBar(), // تم إزالة الـ score
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.only(left: 24, right: 24, top: 24, bottom: 40),
                    children: [
                      _buildGreetingCard(),
                      const SizedBox(height: 30),
                      ..._buildGameCards(context),
                      const SizedBox(height: 10),
                      // ✅ يفتح ألعاب المستوى التالي عند إنهاء كل ألعاب هذا المستوى
                      NextLevelUnlockCard(
                        age: 6,
                        onGoToNextLevel: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const Age7GamesScreen()),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
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

  /// يبني بطاقات الألعاب: من القاعدة إن وُجدت، وإلا البطاقات الثابتة (offline).
  List<Widget> _buildGameCards(BuildContext context) {
    if (_games.isEmpty) {
      return [
        CategoryCard(
          title: "ترتيب الكلمات",
          imageUrl: "",
          icon: Icons.extension_rounded,
          themeColor: const Color(0xFF80FF2C),
          shadowColor: const Color(0xFF3B8700),
          buttonText: "ابدأ اللعب",
          rotationAngle: 0.0,
          onTap: () => _openLevels(context, "word_game", "ترتيب الكلمات"),
        ),
        CategoryCard(
          title: "توصيل الألوان",
          imageUrl: "",
          icon: Icons.palette_rounded,
          themeColor: const Color(0xFFFF8FA9),
          shadowColor: const Color(0xFF9C3756),
          buttonText: "العب الآن",
          rotationAngle: -0.02,
          onTap: () => _openLevels(context, "color_matching", "توصيل الألوان"),
        ),
        CategoryCard(
          title: "الرياضيات الممتعة",
          imageUrl: "",
          icon: Icons.calculate_rounded,
          themeColor: const Color(0xFFA7D7FF),
          shadowColor: const Color(0xFF004C71),
          buttonText: "هيا بنا!",
          rotationAngle: 0.02,
          onTap: () => _openLevels(context, "addition_game", "الرياضيات الممتعة"),
        ),
      ];
    }

    // لوحة ألوان/أيقونة خاصة بكل لعبة (مفتاحها game_code) للحفاظ على الشكل الحالي.
    const visuals = <String, _CardVisual>{
      'word_game': _CardVisual(Color(0xFF80FF2C), Color(0xFF3B8700), Icons.extension_rounded, 'ابدأ اللعب'),
      'color_matching': _CardVisual(Color(0xFFFF8FA9), Color(0xFF9C3756), Icons.palette_rounded, 'العب الآن'),
      'addition_game': _CardVisual(Color(0xFFA7D7FF), Color(0xFF004C71), Icons.calculate_rounded, 'هيا بنا!'),
    };
    const rotations = [0.0, -0.02, 0.02];

    return [
      for (var i = 0; i < _games.length; i++)
        CategoryCard(
          title: _games[i].title,
          imageUrl: "",
          icon: (visuals[_games[i].code] ?? const _CardVisual(AppColors.tertiary, AppColors.tertiaryDim, Icons.games, 'العب الآن')).icon,
          themeColor: (visuals[_games[i].code] ?? const _CardVisual(AppColors.tertiary, AppColors.tertiaryDim, Icons.games, 'العب الآن')).bg,
          shadowColor: (visuals[_games[i].code] ?? const _CardVisual(AppColors.tertiary, AppColors.tertiaryDim, Icons.games, 'العب الآن')).shadow,
          buttonText: (visuals[_games[i].code] ?? const _CardVisual(AppColors.tertiary, AppColors.tertiaryDim, Icons.games, 'العب الآن')).buttonText,
          rotationAngle: rotations[i % rotations.length],
          onTap: () => _openLevels(context, _games[i].code, _games[i].title),
        ),
    ];
  }

  Widget _buildGreetingCard() {
    return Transform.rotate(
      angle: 0.02,
      child: GlassCard(
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("مرحباً بك، يا بطل!", style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: AppColors.onSurface)),
                SizedBox(height: 4),
                Text("أي عالم ستستكشفه اليوم؟", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.onSurfaceVariant)),
              ],
            ),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.5), shape: BoxShape.circle),
              child: const Icon(Icons.celebration_rounded, color: AppColors.tertiary, size: 30),
            ),
          ],
        ),
      ),
    );
  }
}

class _DotPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFF645300)..style = PaintingStyle.fill;
    for (double y = 0; y < size.height; y += 40) {
      for (double x = 0; x < size.width; x += 40) {
        canvas.drawCircle(Offset(x, y), 2, paint);
      }
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// بيانات بصرية ثابتة لكل لعبة (لون/ظل/أيقونة/نص زر) للحفاظ على الشكل الأصلي.
class _CardVisual {
  final Color bg;
  final Color shadow;
  final IconData icon;
  final String buttonText;
  const _CardVisual(this.bg, this.shadow, this.icon, this.buttonText);
}