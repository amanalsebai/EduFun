import 'package:flutter/material.dart';
import '../../core/data/models/game.dart';
import '../../core/data/repositories/game_repository.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/custom_app_bar.dart';
import '../../core/widgets/custom_drawer.dart';

import 'game_registry.dart';
import 'widgets/level_select_screen.dart'; // ✅ شاشة اختيار المراحل
import 'widgets/next_level_unlock_card.dart'; // ✅ بطاقة فتح المستوى التالي
import 'age_8_games_screen.dart'; // ✅ ألعاب المستوى التالي (٨ سنوات)

class Age7GamesScreen extends StatefulWidget {
  const Age7GamesScreen({super.key});

  @override
  State<Age7GamesScreen> createState() => _Age7GamesScreenState();
}

class _Age7GamesScreenState extends State<Age7GamesScreen> {
  List<Game> _games = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final all = await GameRepository().getByAge(7);
    if (!mounted) return;
    // نُبقي فقط ما له شاشة مسجّلة في Flutter.
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
            const CustomAppBar(showBackButton: false), // يفتح المنيو الجانبي
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    _buildWelcomeHero(),
                    const SizedBox(height: 30),
                    _buildGamesGrid(context),
                    const SizedBox(height: 24),
                    // ✅ يفتح ألعاب المستوى التالي عند إنهاء كل ألعاب هذا المستوى
                    NextLevelUnlockCard(
                      age: 7,
                      onGoToNextLevel: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const Age8GamesScreen()),
                      ),
                    ),
                    const SizedBox(height: 40),
                    _buildProgressSection(),
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

  Widget _buildWelcomeHero() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.4),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: -30, right: -30,
            child: Container(width: 150, height: 150, decoration: BoxDecoration(color: AppColors.tertiaryContainer.withOpacity(0.3), shape: BoxShape.circle)),
          ),
          Positioned(
            bottom: -30, left: -30,
            child: Container(width: 150, height: 150, decoration: BoxDecoration(color: AppColors.secondaryContainer.withOpacity(0.3), shape: BoxShape.circle)),
          ),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("مرحباً بك يا بطل!\nاختر تحدي اليوم", style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: AppColors.primary, height: 1.2)),
                    const SizedBox(height: 12),
                    Text("استعد لرحلة مليئة بالذكاء والمرح في عالم المعرفة!", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.onSurfaceVariant.withOpacity(0.8))),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // ✅ مجسّم البطل بأيقونة ثابتة بدل صورة الشبكة المؤقتة
              Container(
                width: 100, height: 100,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.6),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                ),
                child: const Center(child: Text("🦸", style: TextStyle(fontSize: 50))),
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

  Widget _buildGamesGrid(BuildContext context) {
    // إن وفّرت القاعدة محتوى نعرض منه؛ وإلا نَسقط على البطاقات الثابتة (offline).
    if (_games.isEmpty) {
      return Column(
        children: [
          _GameCard(
            title: "ترتيب الجمل",
            subtitle: "رتب الكلمات المبعثرة لتكوين جمل مفيدة بذكائك!",
            category: "لغويات",
            buttonText: "العب الآن",
            buttonIcon: Icons.play_arrow_rounded,
            themeColor: AppColors.tertiaryContainer,
            onColor: AppColors.onTertiaryContainer,
            shadowColor: AppColors.tertiaryDim,
            onTap: () => _openLevels(context, "sentence_game", "ترتيب الجمل"),
          ),
          _GameCard(
            title: "توصيل عربي-إنجليزي",
            subtitle: "تعلم كلمات جديدة ووصل المعاني ببعضها!",
            category: "لغات",
            buttonText: "ابدأ التحدي",
            buttonIcon: Icons.translate_rounded,
            themeColor: AppColors.secondaryContainer,
            onColor: AppColors.onSecondaryContainer,
            shadowColor: AppColors.secondaryDim,
            onTap: () => _openLevels(context, "ar_en_matching", "توصيل عربي-إنجليزي"),
          ),
          _GameCard(
            title: "الرياضيات المتقدمة",
            subtitle: "تحديات الجمع والطرح السريعة لتصبح عبقرياً!",
            category: "حساب",
            buttonText: "هيا بنا",
            buttonIcon: Icons.calculate_rounded,
            themeColor: AppColors.primaryContainer,
            onColor: AppColors.onPrimaryContainer,
            shadowColor: AppColors.primaryDim,
            onTap: () => _openLevels(context, "advanced_math", "الرياضيات المتقدمة"),
          ),
        ],
      );
    }

    // لوحة الألوان والأيقونات تُوزَّع دورياً للحفاظ على الشكل البصري الحالي.
    final palettes = <_CardPalette>[
      _CardPalette(AppColors.tertiaryContainer, AppColors.onTertiaryContainer, AppColors.tertiaryDim, Icons.play_arrow_rounded),
      _CardPalette(AppColors.secondaryContainer, AppColors.onSecondaryContainer, AppColors.secondaryDim, Icons.translate_rounded),
      _CardPalette(AppColors.primaryContainer, AppColors.onPrimaryContainer, AppColors.primaryDim, Icons.calculate_rounded),
    ];
    final buttons = ['العب الآن', 'ابدأ التحدي', 'هيا بنا'];

    return Column(
      children: [
        for (var i = 0; i < _games.length; i++)
          _GameCard(
            title: _games[i].title,
            subtitle: _games[i].subtitle,
            category: _games[i].categoryLabel,
            buttonText: buttons[i % buttons.length],
            buttonIcon: palettes[i % palettes.length].icon,
            themeColor: palettes[i % palettes.length].bg,
            onColor: palettes[i % palettes.length].onBg,
            shadowColor: palettes[i % palettes.length].shadow,
            onTap: () => _openLevels(context, _games[i].code, _games[i].title),
          ),
      ],
    );
  }

  Widget _buildProgressSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.8), borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("مستوى التقدم", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.primary)),
              Row(
                children: [
                  Text("المستوى 5", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.secondary)),
                  SizedBox(width: 4),
                  Icon(Icons.military_tech_rounded, color: AppColors.secondary),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            height: 24,
            width: double.infinity,
            decoration: BoxDecoration(color: AppColors.surfaceContainer, borderRadius: BorderRadius.circular(12)),
            child: FractionallySizedBox(
              alignment: Alignment.centerRight,
              widthFactor: 0.75,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.tertiary,
                  borderRadius: BorderRadius.circular(12),
                  image: const DecorationImage(image: NetworkImage("https://www.transparenttextures.com/patterns/diagonal-stripes.png"), fit: BoxFit.none, repeat: ImageRepeat.repeat, opacity: 0.2),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text("بقي لك 50 نجمة للوصول للمستوى 6!", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.onSurfaceVariant)),
        ],
      ),
    );
  }
}

class _GameCard extends StatelessWidget {
  final String title, subtitle, category, buttonText;
  final IconData buttonIcon;
  final Color themeColor, onColor, shadowColor;
  final VoidCallback onTap;

  const _GameCard({
    required this.title, required this.subtitle, required this.category,
    required this.buttonText, required this.buttonIcon,
    required this.themeColor, required this.onColor, required this.shadowColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppColors.surfaceContainerLowest, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 8))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ✅ ترويسة بصرية ثابتة (تدرّج + أيقونة) بدل صورة الشبكة المؤقتة
          Container(
            height: 160, width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [themeColor, themeColor.withOpacity(0.6)]),
            ),
            child: Stack(
              children: [
                Positioned(top: -20, left: -20, child: Container(width: 90, height: 90, decoration: BoxDecoration(color: Colors.white.withOpacity(0.18), shape: BoxShape.circle))),
                Center(child: Icon(buttonIcon, size: 64, color: Colors.white.withOpacity(0.9))),
                Container(decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), gradient: LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter, colors: [shadowColor.withOpacity(0.55), Colors.transparent]))),
                Positioned(bottom: 16, right: 16, child: Text(category, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18))),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(title, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: themeColor == AppColors.tertiaryContainer ? AppColors.tertiary : (themeColor == AppColors.secondaryContainer ? AppColors.secondary : AppColors.primary))),
          const SizedBox(height: 8),
          Text(subtitle, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.onSurfaceVariant)),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: onTap,
            child: Container(
              width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(color: themeColor, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: shadowColor, offset: const Offset(0, 4), blurRadius: 0)]),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(buttonText, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: onColor)),
                  const SizedBox(width: 8),
                  Icon(buttonIcon, color: onColor),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// مزيج ألوان/أيقونة لبطاقة لعبة (يُوزَّع دورياً على البطاقات القادمة من القاعدة).
class _CardPalette {
  final Color bg, onBg, shadow;
  final IconData icon;
  const _CardPalette(this.bg, this.onBg, this.shadow, this.icon);
}