import 'package:flutter/material.dart';

import '../../core/network/connection_settings_dialog.dart';
import '../../core/network/session.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/glass_card.dart';
import 'assessment_screen.dart';

/// شاشة إدخال اسم الطفل — تأتي بعد اختيار العمر وقبل التقييم.
///
/// عند المتابعة تُسجّل طفلاً **جديداً** على السيرفر عبر [Session.registerNewChild]
/// ثم تنتقل لشاشة التقييم. إن كان السيرفر متوقّفاً تتابع في «الوضع المحلي» دون توقّف.
class NameInputScreen extends StatefulWidget {
  final int childAge;
  const NameInputScreen({super.key, required this.childAge});

  @override
  State<NameInputScreen> createState() => _NameInputScreenState();
}

class _NameInputScreenState extends State<NameInputScreen> {
  final _controller = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _continue() async {
    final name = _controller.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('اكتب اسمك أولاً يا بطل 😊')),
      );
      return;
    }

    setState(() => _saving = true);

    // يُسجّل طفلاً جديداً على القاعدة (ويحفظ الاسم/العمر محلياً كبديل).
    final id = await Session.registerNewChild(name, widget.childAge);

    if (!mounted) return;
    if (id == 0) {
      // لم نصل للسيرفر — نكمل محلياً، ونقترح فتح إعدادات الاتصال لتصحيح العنوان.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('تعذّر الوصول للسيرفر — سنكمل محلياً. افتح «ضبط الاتصال» لتصحيح IP'),
          action: SnackBarAction(
            label: 'ضبط الاتصال',
            onPressed: () => showDialog(
              context: context,
              builder: (_) => const ConnectionSettingsDialog(),
            ),
          ),
        ),
      );
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => AssessmentScreen(childAge: widget.childAge),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          // زرّ اتصال «شبكة أمان» في حال وصل المستخدم لهذه الشاشة مباشرة.
          IconButton(
            tooltip: 'إعدادات الاتصال بالسيرفر',
            icon: const Icon(Icons.wifi_tethering, color: AppColors.tertiary),
            onPressed: () => showDialog(
              context: context,
              builder: (_) => const ConnectionSettingsDialog(),
            ),
          ),
        ],
      ),
      // المحتوى العلوي قابل للتمرير (يتجنّب الـ overflow عند ظهور لوحة المفاتيح)،
      // والزر يبقى مثبّتاً بالأسفل.
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 12),
                      const Text(
                        'ما اسمك يا بطل؟',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.w900,
                          color: AppColors.tertiary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'سنسجّل لك ملفاً خاصاً لحفظ نجومك وتقدّمك ⭐',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 32),
                      const Center(child: Text('🦸', style: TextStyle(fontSize: 90))),
                      const SizedBox(height: 32),
                      GlassCard(
                        child: TextField(
                          controller: _controller,
                          textAlign: TextAlign.center,
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => _continue(),
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: AppColors.onSurface,
                          ),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: 'اكتب اسمك هنا',
                            hintStyle: TextStyle(
                              color: AppColors.onSurfaceVariant,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _saving ? null : _continue,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.tertiary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: _saving
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 3,
                        ),
                      )
                    : const Text(
                        'هيا نبدأ المغامرة! 🚀',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
