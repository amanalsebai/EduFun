# 06 — زر الاتصال العائم (FloatingActionButton)

الهدف: زر عائم في التطبيق يفتح نافذة لإدخال **IP اللابتوب** و**رقم البورت**،
مع زر **اختبار الاتصال** يستدعي `/ping.php`، ثم **حفظ** الإعدادات.

```
┌──────────────────────────────┐
│   إعدادات الاتصال بالسيرفر     │
│  ┌────────────────────────┐  │
│  │ IP اللابتوب: 192.168.1.20│  │
│  └────────────────────────┘  │
│  ┌────────────────────────┐  │
│  │ البورت: 80              │  │
│  └────────────────────────┘  │
│  المسار الناتج:              │
│  http://192.168.1.20:80/     │
│           edufun/api         │
│                              │
│  [ اختبار الاتصال ]  ✅/❌     │
│  [ إلغاء ]      [ حفظ ]       │
└──────────────────────────────┘
```

## 1. الويدجت — `connection_settings_dialog.dart`

ضعه في `untitled1/lib/core/network/connection_settings_dialog.dart`:

```dart
import 'package:flutter/material.dart';
import 'connection_settings.dart';
import 'api_config.dart';
import 'api_client.dart';

class ConnectionSettingsDialog extends StatefulWidget {
  const ConnectionSettingsDialog({super.key});

  @override
  State<ConnectionSettingsDialog> createState() => _State();
}

class _State extends State<ConnectionSettingsDialog> {
  final _ipCtrl   = TextEditingController();
  final _portCtrl = TextEditingController();
  String _status = '';
  bool _testing = false;
  bool _ok = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    _ipCtrl.text   = await ConnectionSettings.getIp();
    _portCtrl.text = await ConnectionSettings.getPort();
    setState(() {});
  }

  String get _preview =>
      'http://${_ipCtrl.text}:${_portCtrl.text}/edufun/api';

  Future<void> _test() async {
    setState(() { _testing = true; _status = 'جارٍ الاختبار…'; });
    // احفظ مؤقتاً ثم جرّب ping
    await ConnectionSettings.save(_ipCtrl.text, _portCtrl.text);
    ApiConfig.invalidate();
    final ok = await ApiClient.ping();
    setState(() {
      _testing = false;
      _ok = ok;
      _status = ok ? 'الاتصال ناجح ✅' : 'فشل الاتصال ❌ تحقّق من IP/البورت';
    });
  }

  Future<void> _save() async {
    await ConnectionSettings.save(_ipCtrl.text, _portCtrl.text);
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('إعدادات الاتصال بالسيرفر'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _ipCtrl,
              keyboardType: TextInputType.url,
              decoration: const InputDecoration(
                labelText: 'IP اللابتوب',
                hintText: 'مثال: 192.168.1.20  (أو 10.0.2.2 للمحاكي)',
                prefixIcon: Icon(Icons.lan),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _portCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'رقم البورت',
                hintText: '80  (بورت XAMPP/Apache الافتراضي)',
                prefixIcon: Icon(Icons.settings_ethernet),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),
            Text('المسار الناتج:',
                style: Theme.of(context).textTheme.bodySmall),
            SelectableText(_preview,
                style: const TextStyle(fontFamily: 'monospace')),
            const SizedBox(height: 12),
            if (_status.isNotEmpty)
              Text(_status,
                  style: TextStyle(
                      color: _ok ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold)),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _testing ? null : _test,
          child: _testing
              ? const SizedBox(
                  width: 18, height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('اختبار الاتصال'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('إلغاء'),
        ),
        FilledButton(onPressed: _save, child: const Text('حفظ')),
      ],
    );
  }
}
```

## 2. إضافة الـ FloatingActionButton

أضف الزر إلى الشاشة الرئيسية (مثلاً `main_layout_screen.dart`):

```dart
Scaffold(
  // ... appBar, body, drawer كما هي
  floatingActionButton: FloatingActionButton(
    tooltip: 'إعدادات الاتصال بالسيرفر',
    backgroundColor: AppColors.primary, // من theme الحالي
    onPressed: () => _openConnectionSettings(context),
    child: const Icon(Icons.cloud_sync),
  ),
);

// ...
void _openConnectionSettings(BuildContext context) async {
  final saved = await showDialog<bool>(
    context: context,
    builder: (_) => const ConnectionSettingsDialog(),
  );
  if (saved == true && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم حفظ إعدادات الاتصال')),
    );
  }
}
```

> الاستيراد المطلوب:
> `import 'package:edufun/core/network/connection_settings_dialog.dart';`
> (عدّل اسم الحزمة `edufun` ليطابق `name:` في pubspec — هنا المشروع اسمه `untitled1`،
> فيكون `package:untitled1/...`).

## 3. سلوك الزر باختصار

1. عند الفتح يملأ الحقول بالقيم المحفوظة (أو `localhost` و `80` افتراضياً).
2. أثناء الكتابة يُحدِّث «المسار الناتج» مباشرةً ليراه المستخدم.
3. **اختبار الاتصال** يحفظ القيم مؤقتاً ويستدعي `/ping.php`:
   - نجاح ← «الاتصال ناجح ✅».
   - فشل ← «فشل الاتصال ❌» (IP خاطئ، السيرفر متوقّف، أو جدار ناري).
4. **حفظ** يثبّت القيم في `SharedPreferences` ويُبطل كاش `ApiConfig`، فيبدأ كل
   الطلبات اللاحقة باستخدام العنوان الجديد فوراً.

## 4. ملاحظات للمستخدم النهائي (تُعرض داخل النافذة أو دليل سريع)

- **على هاتف حقيقي:** اكتب IP اللابتوب على الواي‑فاي (من الملف 07: `ipconfig`)،
  وتأكّد أن الهاتف واللابتوب على **نفس الشبكة**.
- **على محاكي أندرويد:** اكتب `10.0.2.2` بدل `localhost`.
- **البورت:** غالباً `80`. لو غيّرت بورت Apache في XAMPP إلى `8080` اكتبه هنا.
- لو فشل الاختبار رغم صحة الـ IP، فالسبب الأشيع هو **جدار Windows الناري** —
  راجع الملف 07.
