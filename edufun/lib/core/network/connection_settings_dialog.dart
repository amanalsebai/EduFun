import 'package:flutter/material.dart';

import 'api_client.dart';
import 'api_config.dart';
import 'connection_settings.dart';

/// نافذة إعدادات الاتصال بالسيرفر: IP اللابتوب + البورت + اختبار الاتصال.
///
/// تُفتح من زر الـ FloatingActionButton العائم في [MainLayoutScreen].
class ConnectionSettingsDialog extends StatefulWidget {
  const ConnectionSettingsDialog({super.key});

  @override
  State<ConnectionSettingsDialog> createState() =>
      _ConnectionSettingsDialogState();
}

class _ConnectionSettingsDialogState extends State<ConnectionSettingsDialog> {
  final _ipCtrl = TextEditingController();
  final _portCtrl = TextEditingController();
  String _status = '';
  bool _testing = false;
  bool _ok = false;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    _ipCtrl.text = await ConnectionSettings.getIp();
    _portCtrl.text = await ConnectionSettings.getPort();
    setState(() => _loaded = true);
  }

  String get _preview => 'http://${_ipCtrl.text}:${_portCtrl.text}/edufun/api';

  Future<void> _test() async {
    setState(() {
      _testing = true;
      _status = 'جارٍ الاختبار…';
    });
    // احفظ مؤقتاً ثم جرّب ping
    await ConnectionSettings.save(_ipCtrl.text, _portCtrl.text);
    ApiConfig.invalidate();
    final ok = await ApiClient.ping();
    if (!mounted) return;
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
                hintText: 'مثال: 192.168.1.20 (أو 10.0.2.2 للمحاكي)',
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
                hintText: '80 (بورت XAMPP/Apache الافتراضي)',
                prefixIcon: Icon(Icons.settings_ethernet),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),
            Text('المسار الناتج:', style: Theme.of(context).textTheme.bodySmall),
            SelectableText(
              _loaded ? _preview : '',
              style: const TextStyle(fontFamily: 'monospace'),
            ),
            const SizedBox(height: 12),
            if (_status.isNotEmpty)
              Text(
                _status,
                style: TextStyle(
                    color: _ok ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _testing ? null : _test,
          child: _testing
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
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
