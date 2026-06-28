import 'connection_settings.dart';

/// يبني العنوان الأساسي للـ API من إعدادات الاتصال:
/// `http://<ip>:<port>/edufun/api`
class ApiConfig {
  static String? _cachedBaseUrl;

  static Future<String> baseUrl() async {
    if (_cachedBaseUrl != null) return _cachedBaseUrl!;
    final ip = await ConnectionSettings.getIp();
    final port = await ConnectionSettings.getPort();
    _cachedBaseUrl = 'http://$ip:$port/edufun/api';
    return _cachedBaseUrl!;
  }

  /// يُستدعى بعد تغيير الإعدادات لإعادة بناء العنوان.
  static void invalidate() => _cachedBaseUrl = null;
}
