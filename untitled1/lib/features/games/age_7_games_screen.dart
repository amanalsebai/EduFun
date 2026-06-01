import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/custom_app_bar.dart';
import '../../core/widgets/custom_drawer.dart';

import 'language/sentence_game_screen.dart';
import 'cognitive/ar_en_matching_screen.dart';
import 'math/advanced_math_screen.dart';

class Age7GamesScreen extends StatelessWidget {
  const Age7GamesScreen({super.key});

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
              SizedBox(
                width: 100, height: 100,
                child: Image.network("https://lh3.googleusercontent.com/aida-public/AB6AXuAzUIuo56zIg3UluVFgVRrSgadKRH6CH3whQD-HPqYHmHFDRQ43Mnl7fNgv7Cz4khSRxk9_Mb98MRYg8vC7_dcGqaDl1V3NszXnASRujpp55aWWFgWcHBRnVNxGtES44kab5y4miFmo7stQgZCNUiuNDgSPoaiHFG-yau-6WZ3JYXU16BWeXmGtSoB1RM4lRPWhmEpHM_vJbSLMS7XZNkOxh0m900MbSFeHXlk29CtkGeE0WJV5MAIT3toS6gQxgTP8m6DUOL4gj5sD", fit: BoxFit.contain),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGamesGrid(BuildContext context) {
    return Column(
      children: [
        _GameCard(
          title: "ترتيب الجمل",
          subtitle: "رتب الكلمات المبعثرة لتكوين جمل مفيدة بذكائك!",
          category: "لغويات",
          buttonText: "العب الآن",
          buttonIcon: Icons.play_arrow_rounded,
          imageUrl: "https://lh3.googleusercontent.com/aida-public/AB6AXuC9Gvko4HcL8hpAdIVLmN4s74sCiyCFuTIAgaxNvEfCwNH1WhNFFlRhTHcf-VmPb7X9jzMwf-e9OaIgQFcLdACmy8zX_JxMV_sPziYD3THbcmurO92y1Zzxxer2Vg8dXzIPJrgEKiqN97mlL_XNrT5D4RMcGAANORY8S9GUBuzVUhN6vNTsO3NXCGrK9lSX6BN8vEHB3i6kgunkbQJkPl7QchQkJ6M7eYcy9b_NS9iSAAVxal7f5E9Lhd9gYeA9RZ1wyXFuTQMzcI30",
          themeColor: AppColors.tertiaryContainer,
          onColor: AppColors.onTertiaryContainer,
          shadowColor: AppColors.tertiaryDim,
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SentenceGameScreen())),
        ),
        _GameCard(
          title: "توصيل عربي-إنجليزي",
          subtitle: "تعلم كلمات جديدة ووصل المعاني ببعضها!",
          category: "لغات",
          buttonText: "ابدأ التحدي",
          buttonIcon: Icons.translate_rounded,
          imageUrl: "https://lh3.googleusercontent.com/aida-public/AB6AXuBCfNaZvF4bUeDghDl6f1C2pYMFoN5g07wx3NsbG1fVzzegPJVk52o-yGTYrKKOUDdSR3l8lRTe7ZRasMoQLk688kYZOA1688aZuemwYtFEEwALeFQvimej3XmE_ARFfIt8NDSIqBZOVcTxhzCGOAEIryVjykWmaTG-OKLvVx4ALIRml0o6ELL4iBJSfSxHWiK1oa0chTDbENK4zQ4PGpNXO2z9vkkD_zKTJ4rqSoXNEx3S0EPTIczbv7Vx6GIjw9Dd3I-2oxYPUap2",
          themeColor: AppColors.secondaryContainer,
          onColor: AppColors.onSecondaryContainer,
          shadowColor: AppColors.secondaryDim,
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ArEnMatchingScreen())),
        ),
        _GameCard(
          title: "الرياضيات المتقدمة",
          subtitle: "تحديات الجمع والطرح السريعة لتصبح عبقرياً!",
          category: "حساب",
          buttonText: "هيا بنا",
          buttonIcon: Icons.calculate_rounded,
          imageUrl: "https://lh3.googleusercontent.com/aida-public/AB6AXuAseXQBYdYb8kHiafKSm0ifkfZKNYhxrzdurdoxeoEJbgiJyw289WYVMJ7ZGjX4IeOFJAY4OsD-BKsna8FdZt3J9IUuMggfbkWe07E-qebAJrhWgJ5qvbcjaJ-i3XjGOZjl8d2NuJ_YAHZN5EZTD5mG08xB1ubhsvwYHWCiheOZJ1pZzJTmDWlfxlUSg-yu4N7lnVVMPYV7kAebO_NCO4nsPzz_GMMZwmHoHbSw1DQhrrEIpc74Cp4pyw0Rnnht1p4hNlqsgJ8cuJmT",
          themeColor: AppColors.primaryContainer,
          onColor: AppColors.onPrimaryContainer,
          shadowColor: AppColors.primaryDim,
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AdvancedMathScreen())),
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
  final String title, subtitle, category, buttonText, imageUrl;
  final IconData buttonIcon;
  final Color themeColor, onColor, shadowColor;
  final VoidCallback onTap;

  const _GameCard({
    required this.title, required this.subtitle, required this.category,
    required this.buttonText, required this.buttonIcon, required this.imageUrl,
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
          Container(
            height: 160, width: double.infinity,
            decoration: BoxDecoration(color: themeColor, borderRadius: BorderRadius.circular(16)),
            child: Stack(
              children: [
                ClipRRect(borderRadius: BorderRadius.circular(16), child: Image.network(imageUrl, width: double.infinity, height: double.infinity, fit: BoxFit.cover)),
                Container(decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), gradient: LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter, colors: [themeColor.withOpacity(0.8), Colors.transparent]))),
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