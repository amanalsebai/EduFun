import 'package:flutter/foundation.dart'
    show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:shared_preferences/shared_preferences.dart';

import 'api_config.dart';

/// إعدادات الاتصال بالسيرفر (IP + البورت) محفوظة محلياً في SharedPreferences.
/// يملأها زر الاتصال العائم (FAB) من [ConnectionSettingsDialog].
class ConnectionSettings {
  static const _kIp = 'conn_ip';
  static const _kPort = 'conn_port';

  /// القيمة الافتراضية للـ IP حسب المنصّة:
  /// - محاكي أندرويد يصل للابتوب عبر 10.0.2.2 (وليس localhost).
  /// - الويب/سطح المكتب/محاكي iOS: localhost.
  /// - الجهاز الحقيقي: يبقى localhost افتراضياً ويجب أن يضبطه المستخدم على IP اللابتوب.
  static String get defaultIp {
    if (kIsWeb) return 'localhost';
    if (defaultTargetPlatform == TargetPlatform.android) return '10.0.2.2';
    return 'localhost';
  }

  /// البورت 80 (إعداد XAMPP/Apache الافتراضي).
  static const defaultPort = '80';

  static Future<String> getIp() async {
    final p = await SharedPreferences.getInstance();
    return p.getString(_kIp) ?? defaultIp;
  }

  static Future<String> getPort() async {
    final p = await SharedPreferences.getInstance();
    return p.getString(_kPort) ?? defaultPort;
  }

  static Future<void> save(String ip, String port) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_kIp, ip.trim());
    await p.setString(_kPort, port.trim());
    ApiConfig.invalidate(); // أعِد بناء baseUrl
  }
}
