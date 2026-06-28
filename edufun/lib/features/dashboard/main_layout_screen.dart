import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // استيراد الذاكرة لتعلم عمر الطفل
import '../../core/theme/app_colors.dart';
import '../../core/network/connection_settings_dialog.dart';
import '../../core/utils/progress_manager.dart';

// استيراد الشاشات الأساسية للألعاب والدروس والإعدادات وبوابة الأهل
import '../games/age_6_games_screen.dart';    // ألعاب 6 سنوات
import '../lessons/lessons_screen.dart';      // ✅ شاشة الدروس الذكية المفعّلة والجديدة
import '../settings/settings_screen.dart';     // شاشة الإعدادات الكاملة
import 'parent_portal_screen.dart';           // بوابة الآباء

// استيراد ملفي البطاقات التعليمية المنفصلين
import '../flashcards/flashcards_screen_6_to_7.dart'; // بطاقات عمر 6-7
import '../flashcards/flashcards_screen_8_to_9.dart'; // بطاقات عمر 8-9

class MainLayoutScreen extends StatefulWidget {
  final int initialIndex;
  const MainLayoutScreen({super.key, this.initialIndex = 0});

  @override
  State<MainLayoutScreen> createState() => _MainLayoutScreenState();
}

class _MainLayoutScreenState extends State<MainLayoutScreen> {
  late int _currentIndex;
  int _childAge = 6; // العمر الافتراضي للطفل
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _loadChildAge(); // تحميل عمر الطفل من الذاكرة
    // زامِن التقدّم والنجوم مع السيرفر في الخلفية (بديل محلي تلقائي عند الانقطاع)
    ProgressManager.syncFromServer();
  }

  // قراءة عمر الطفل المسجل من الذاكرة المحلية لتحديد البطاقات
  Future<void> _loadChildAge() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _childAge = prefs.getInt('child_age') ?? 6;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // فتح نافذة إعدادات الاتصال بالسيرفر (IP + البورت + اختبار الاتصال)
  Future<void> _openConnectionSettings(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final saved = await showDialog<bool>(
      context: context,
      builder: (_) => const ConnectionSettingsDialog(),
    );
    if (saved == true && mounted) {
      messenger.showSnackBar(
        const SnackBar(content: Text('تم حفظ إعدادات الاتصال')),
      );
      // أعد المزامنة بالعنوان الجديد
      ProgressManager.syncFromServer();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    // ✅ بناء قائمة الصفحات ديناميكياً لتشمل شاشة الدروس الحقيقية والبطاقات المناسبة للعمر
    final List<Widget> pages = [
      const Age6GamesScreen(),                  // Index 0: ألعاب 6 سنوات
      const LessonsScreen(),                    // ✅ Index 1: شاشة الدروس الذكية المفعّلة!

      // اختيار صفحة البطاقات المناسبة لعمر الطفل تلقائياً بدون دمج الملفات
      (_childAge == 6 || _childAge == 7)
          ? const FlashcardsScreen6to7()        // يفتح بطاقات عمر 6-7
          : const FlashcardsScreen8to9(),        // يفتح بطاقات عمر 8-9

      const SettingsScreen(),                   // Index 3: شاشة الإعدادات الكاملة
      const ParentPortalScreen(),               // Index 4: بوابة الآباء
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'إعدادات الاتصال بالسيرفر',
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        onPressed: () => _openConnectionSettings(context),
        child: const Icon(Icons.cloud_sync),
      ),
    );
  }
}

// ---------------------------------------------------------
// شاشة مؤقتة (Placeholder) للأقسام التي لم يتم تصميمها بعد
// ---------------------------------------------------------
class _ComingSoonScreen extends StatelessWidget {
  final String title;
  const _ComingSoonScreen({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.construction_rounded, size: 100, color: AppColors.primaryContainer),
            const SizedBox(height: 24),
            Text("قسم $title", style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: AppColors.primary)),
            const SizedBox(height: 8),
            const Text("قريباً يا بطل! 🚀", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.onSurfaceVariant)),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const MainLayoutScreen(initialIndex: 0)),
                );
              },
              icon: const Icon(Icons.home_rounded),
              label: const Text("العودة للرئيسية"),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
            )
          ],
        ),
      ),
    );
  }
}