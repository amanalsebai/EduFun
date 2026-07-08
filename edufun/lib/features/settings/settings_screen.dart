import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/custom_app_bar.dart';
import '../../core/widgets/custom_drawer.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/utils/audio_manager.dart';
import '../onboarding/age_selection_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _nameController = TextEditingController();
  bool _isMusicEnabled = true; bool _isSoundEnabled = true; bool _isLoading = true;

  @override
  void initState() { super.initState(); _loadSettings(); }
  @override
  void dispose() { _nameController.dispose(); super.dispose(); }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _nameController.text = prefs.getString('child_name') ?? "بطلنا الصغير";
      _isMusicEnabled = prefs.getBool('music_enabled') ?? true;
      _isSoundEnabled = prefs.getBool('sound_enabled') ?? true;
      _isLoading = false;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('child_name', _nameController.text);
    await prefs.setBool('music_enabled', _isMusicEnabled);
    await prefs.setBool('sound_enabled', _isSoundEnabled);

    // تطبيق إعدادات الصوت فوراً
    if (_isMusicEnabled) {
      AudioManager.playBackgroundMusic();
    } else {
      AudioManager.stopMusic();
    }

    if (mounted) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("تم حفظ الإعدادات بنجاح! 💾"))); }
  }

  Future<void> _resetApp() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => const AgeSelectionScreen()), (route) => false);
    }
  }

  void _showParentGate() {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Colors.white,
        title: const Column(children: [Icon(Icons.lock_person_rounded, size: 50, color: AppColors.error), SizedBox(height: 8), Text("منطقة الآباء! 🔒", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.error))]),
        content: const Text("أنت على وشك مسح جميع تقدم طفلك وإعادة التقييم.\nللأباء فقط: كم ناتج ٣ × ٤؟", textAlign: TextAlign.center, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.onBackground)),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: ["8", "12", "16"].map((answer) => ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryContainer, foregroundColor: AppColors.onPrimaryContainer, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
              onPressed: () {
                Navigator.pop(dialogContext);
                if (answer == "12") { _resetApp(); } else { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("إجابة خاطئة! تم إلغاء العملية."))); }
              },
              child: Text(answer, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
            )).toList(),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator(color: AppColors.primary)));
    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const CustomDrawer(currentIndex: 3),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const CustomAppBar(showBackButton: false), // تم تصفير الـ score ليعمل تلقائياً
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(left: 24, right: 24, top: 24, bottom: 120),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("الإعدادات والملف الشخصي", style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: AppColors.onBackground)),
                    const SizedBox(height: 24),
                    _buildSectionTitle("الملف الشخصي للبطل"),
                    const SizedBox(height: 12),
                    GlassCard(child: Column(children: [TextField(controller: _nameController, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.onSurface), decoration: InputDecoration(labelText: "اسم البطل الصغير", labelStyle: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold), prefixIcon: const Icon(Icons.face_rounded, color: AppColors.primary), border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)), focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: AppColors.primary, width: 2), borderRadius: BorderRadius.circular(16))))])),
                    const SizedBox(height: 30),
                    _buildSectionTitle("أصوات الألعاب"),
                    const SizedBox(height: 12),
                    GlassCard(child: Column(children: [SwitchListTile(title: const Text("موسيقى الخلفية", style: TextStyle(fontWeight: FontWeight.bold)), secondary: const Icon(Icons.music_note_rounded, color: AppColors.secondary), value: _isMusicEnabled, activeColor: AppColors.secondary, onChanged: (val) => setState(() => _isMusicEnabled = val)), const Divider(color: Colors.black12), SwitchListTile(title: const Text("المؤثرات الصوتية", style: TextStyle(fontWeight: FontWeight.bold)), secondary: const Icon(Icons.volume_up_rounded, color: AppColors.secondary), value: _isSoundEnabled, activeColor: AppColors.secondary, onChanged: (val) => setState(() => _isSoundEnabled = val))])),
                    const SizedBox(height: 40),
                    Row(
                      children: [
                        Expanded(child: ElevatedButton.icon(onPressed: _saveSettings, icon: const Icon(Icons.save_rounded), label: const Text("حفظ التغييرات"), style: ElevatedButton.styleFrom(backgroundColor: AppColors.outline, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))))),
                        const SizedBox(width: 16),
                        Expanded(child: ElevatedButton.icon(onPressed: _showParentGate, icon: const Icon(Icons.restart_alt_rounded), label: const Text("إعادة التقييم"), style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))))),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) => Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.onSurfaceVariant));
}