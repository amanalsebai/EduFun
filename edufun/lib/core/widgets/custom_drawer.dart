import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/games/age_7_games_screen.dart';
import '../../features/games/age_8_games_screen.dart';
import '../../features/games/age_9_games_screen.dart';
import '../theme/app_colors.dart';
import '../utils/score_manager.dart'; // ✅ متحكم النقاط الحيّ
import '../../features/dashboard/main_layout_screen.dart';
import '../../features/dashboard/parent_portal_screen.dart'; // ✅ استيراد البوابة

class CustomDrawer extends StatefulWidget {
  final int currentIndex;
  const CustomDrawer({super.key, this.currentIndex = 0});

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  int childAge = 6;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadChildAge();
  }

  Future<void> _loadChildAge() async {
    ScoreManager.getStars(); // مزامنة عدد النجوم مع الذاكرة عند فتح الدرج
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        childAge = prefs.getInt('child_age') ?? 6;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(left: Radius.circular(48)),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            _buildProfileSection(),
            const SizedBox(height: 30),

            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildHomeItem(context),
                  _buildDrawerItem(context, icon: Icons.menu_book_rounded, title: "الدروس", index: 1),
                  _buildDrawerItem(context, icon: Icons.style_rounded, title: "البطاقات التعليمية", index: 2),
                  _buildDrawerItem(context, icon: Icons.settings_rounded, title: "الإعدادات", index: 3),

                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Divider(color: Colors.black12, thickness: 1, indent: 24, endIndent: 24),
                  ),

                  // زر بوابة الآباء
                  _buildParentPortalBtn(context),
                ],
              ),
            ),
            _buildBottomPromoCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildParentPortalBtn(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh.withOpacity(0.5),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppColors.outlineVariant.withOpacity(0.3), width: 1),
      ),
      child: ListTile(
        leading: const Icon(Icons.admin_panel_settings_rounded, color: AppColors.outline),
        title: const Text("بوابة الآباء", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.onSurface)),
        trailing: const Icon(Icons.lock_rounded, color: AppColors.onSurfaceVariant, size: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        onTap: () {
          // ✅ نلتقط NavigatorState قبل إغلاق الدرج، لأن context الخاص بالدرج
          // يصبح غير صالح بعد إغلاقه فلا يعمل Navigator.push لاحقاً
          final navigator = Navigator.of(context);
          Navigator.pop(context); // إغلاق المنيو
          _showParentPinDialog(navigator); // فتح نافذة الـ PIN السرّي
        },
      ),
    );
  }

  // 🔒 نافذة إدخال الرمز السري للأهل (الرمز الافتراضي: 2026)
  void _showParentPinDialog(NavigatorState navigator) {
    final TextEditingController pinController = TextEditingController();

    showDialog(
      context: navigator.context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Column(
          children: [
            Icon(Icons.security_rounded, size: 50, color: AppColors.primary),
            SizedBox(height: 8),
            Text("للآباء فقط! 🔒", style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.primary)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("الرجاء إدخال الرمز السري للدخول البوابة:", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(
              controller: pinController,
              keyboardType: TextInputType.number,
              maxLength: 4,
              obscureText: true, // لإخفاء الرمز أثناء الكتابة (نجمات)
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 10),
              decoration: InputDecoration(
                counterText: "",
                hintText: "••••",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ],
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text("إلغاء", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                  onPressed: () {
                    final pin = pinController.text;
                    Navigator.pop(ctx); // إغلاق النافذة

                    // تحقق من الرمز السري (يمكنك تغيير 2026 لأي رقم تريده)
                    if (pin == "2026") {
                      // ✅ نستخدم navigator الملتقَط مسبقاً ليعمل الانتقال دائماً
                      navigator.push(
                        MaterialPageRoute(builder: (context) => const ParentPortalScreen()),
                      );
                    } else {
                      ScaffoldMessenger.of(navigator.context).showSnackBar(
                          const SnackBar(content: Text("الرمز السري غير صحيح! عذراً، لا يمكنك الدخول."))
                      );
                    }
                  },
                  child: const Text("دخول", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildHomeItem(BuildContext context) {
    bool isActive = widget.currentIndex == 0;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(color: isActive ? AppColors.primaryContainer : Colors.transparent, borderRadius: BorderRadius.circular(30)),
      child: ListTile(
        leading: Icon(Icons.home_rounded, color: isActive ? Colors.white : AppColors.onBackground.withOpacity(0.7)),
        title: Text("الصفحة الرئيسية", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isActive ? Colors.white : AppColors.onBackground.withOpacity(0.8))),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        onTap: () {
          Navigator.pop(context);
          Widget targetScreen;
          switch (childAge) {
            case 6: targetScreen = const MainLayoutScreen(initialIndex: 0); break;
            case 7: targetScreen = const Age7GamesScreen(); break;
            case 8: targetScreen = const Age8GamesScreen(); break;
            case 9: targetScreen = const Age9GamesScreen(); break;
            default: targetScreen = const MainLayoutScreen(initialIndex: 0);
          }
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => targetScreen));
        },
      ),
    );
  }

  Widget _buildDrawerItem(BuildContext context, {required IconData icon, required String title, required int index}) {
    bool isActive = widget.currentIndex == index;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? AppColors.primaryContainer : Colors.transparent,
        borderRadius: BorderRadius.circular(30),
        boxShadow: isActive ? [BoxShadow(color: AppColors.primaryContainer.withOpacity(0.4), blurRadius: 8, offset: const Offset(0, 4))] : null,
      ),
      child: ListTile(
        leading: Icon(icon, color: isActive ? Colors.white : AppColors.onBackground.withOpacity(0.7)),
        title: Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isActive ? Colors.white : AppColors.onBackground.withOpacity(0.8))),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        onTap: () {
          Navigator.pop(context);
          if (widget.currentIndex != index) {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MainLayoutScreen(initialIndex: index)));
          }
        },
      ),
    );
  }

  Widget _buildProfileSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 80, height: 80, padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white, shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primaryContainer, width: 4),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))],
                ),
                child: ClipOval(
                  // ✅ أفاتار البطل بأيقونة ثابتة بدل صورة الشبكة المؤقتة
                  child: Container(
                    color: AppColors.primaryContainer.withOpacity(0.4),
                    child: const Center(child: Text("🦸", style: TextStyle(fontSize: 40))),
                  ),
                ),
              ),
              Positioned(
                bottom: 0, right: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(color: AppColors.tertiaryContainer, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
                  child: const Icon(Icons.star_rounded, color: AppColors.tertiary, size: 16),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text("بطلنا الصغير", style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.onBackground)),
          Row(
            children: [
              // ✅ عدد النجوم الحقيقي والمحدّث لحظياً بدل الرقم الثابت
              ValueListenableBuilder<int>(
                valueListenable: ScoreManager.starsNotifier,
                builder: (context, score, _) => Text("$score نجمة", style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primary)),
              ),
              const Padding(padding: EdgeInsets.symmetric(horizontal: 8.0), child: Icon(Icons.circle, size: 6, color: AppColors.outlineVariant)),
              Text("Level 5", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.onBackground.withOpacity(0.6))),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildBottomPromoCard() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFFCEFFAC), Color(0xFFA5FF6F)], begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("جاهز للمغامرة القادمة؟", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.onBackground)),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white, foregroundColor: AppColors.primary, elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  child: const Text("ابدأ الآن", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12)),
                ),
              ],
            ),
            Positioned(bottom: -20, left: -10, child: Transform.rotate(angle: 0.2, child: const Icon(Icons.rocket_launch_rounded, size: 80, color: Colors.white30))),
          ],
        ),
      ),
    );
  }
}