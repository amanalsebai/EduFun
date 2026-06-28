import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/custom_app_bar.dart';
import '../../core/widgets/custom_drawer.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/utils/audio_manager.dart'; // ✅ استيراد متحكم الصوت
import '../onboarding/age_selection_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _nameController = TextEditingController();
  bool _isMusicEnabled = true;
  bool _isSoundEnabled = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

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

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("تم حفظ الإعدادات بنجاح! 💾")),
      );
    }
  }

  Future<void> _resetApp() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const AgeSelectionScreen()),
            (route) => false,
      );
    }
  }

  void _showParentGate() {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Column(children: [
          Icon(Icons.lock_person_rounded, size: 50, color: AppColors.error),
          SizedBox(height: 8),
          Text("منطقة الآباء! 🔒", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.error))
        ]),
        content: const Text("أنت على وشك مسح جميع تقدم طفلك.\nللآباء فقط: كم ناتج ٣ × ٤؟", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: ["8", "12", "16"].map((answer) => ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryContainer),
              onPressed: () {
                Navigator.pop(dialogContext);
                if (answer == "12") { _resetApp(); }
                else { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("إجابة خاطئة!"))); }
              },
              child: Text(answer, style: const TextStyle(fontWeight: FontWeight.w900)),
            )).toList(),
          ),
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
            const CustomAppBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("الإعدادات", style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: AppColors.onBackground)),
                    const SizedBox(height: 30),

                    // إعداد الاسم
                    GlassCard(
                      child: TextField(
                        controller: _nameController,
                        decoration: const InputDecoration(labelText: "اسم البطل", border: OutlineInputBorder()),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // إعدادات الصوت
                    GlassCard(
                      child: Column(
                        children: [
                          SwitchListTile(
                            title: const Text("موسيقى الخلفية", style: TextStyle(fontWeight: FontWeight.bold)),
                            value: _isMusicEnabled,
                            onChanged: (val) => setState(() => _isMusicEnabled = val),
                          ),
                          SwitchListTile(
                            title: const Text("المؤثرات الصوتية", style: TextStyle(fontWeight: FontWeight.bold)),
                            value: _isSoundEnabled,
                            onChanged: (val) => setState(() => _isSoundEnabled = val),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),

                    // أزرار الحفظ والمسح
                    Row(
                      children: [
                        Expanded(child: ElevatedButton(onPressed: _saveSettings, child: const Text("حفظ"))),
                        const SizedBox(width: 10),
                        Expanded(child: ElevatedButton(onPressed: _showParentGate, style: ElevatedButton.styleFrom(backgroundColor: AppColors.error), child: const Text("إعادة التعيين", style: TextStyle(color: Colors.white)))),
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
}