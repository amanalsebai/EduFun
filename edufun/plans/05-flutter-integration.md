# 05 — ربط فلاتر بالـ API

الهدف: استبدال القراءة/الكتابة المحلية (`SharedPreferences`) باتصال بالـ API،
**دون إعادة كتابة الواجهات**، عبر طبقة شبكة منظّمة.

## 1. الحزم المطلوبة (pubspec.yaml)

أضف إلى `untitled1/pubspec.yaml` تحت `dependencies`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  http: ^1.2.0                 # طلبات HTTP
  shared_preferences: ^2.2.0   # موجود مسبقاً — لتخزين إعدادات الاتصال والكاش
```

ثم: `flutter pub get`

## 2. بنية المجلدات الجديدة في فلاتر

```
untitled1/lib/
└─ core/
   └─ network/
      ├─ api_config.dart          # يبني baseUrl من IP/البورت المحفوظين
      ├─ connection_settings.dart # حفظ/قراءة إعدادات الاتصال
      ├─ api_client.dart          # غلاف موحّد فوق package:http
      └─ api_result.dart          # نتيجة موحّدة (نجاح/خطأ)
   └─ data/
      ├─ models/
      │   ├─ child.dart
      │   ├─ game_progress.dart
      │   └─ scores.dart
      └─ repositories/
          ├─ child_repository.dart
          ├─ progress_repository.dart
          └─ scores_repository.dart
```

---

## 3. إعدادات الاتصال — `connection_settings.dart`

تخزّن IP والبورت في `SharedPreferences` (يملأها زر الـ FAB، الملف 06).

```dart
import 'package:shared_preferences/shared_preferences.dart';

class ConnectionSettings {
  static const _kIp   = 'conn_ip';
  static const _kPort = 'conn_port';

  // القيم الافتراضية: localhost والبورت 80 (XAMPP)
  static const defaultIp   = 'localhost';
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
```

## 4. بناء العنوان — `api_config.dart`

```dart
import 'connection_settings.dart';

class ApiConfig {
  static String? _cachedBaseUrl;

  /// baseUrl = http://<ip>:<port>/edufun/api
  static Future<String> baseUrl() async {
    if (_cachedBaseUrl != null) return _cachedBaseUrl!;
    final ip   = await ConnectionSettings.getIp();
    final port = await ConnectionSettings.getPort();
    _cachedBaseUrl = 'http://$ip:$port/edufun/api';
    return _cachedBaseUrl!;
  }

  static void invalidate() => _cachedBaseUrl = null;
}
```

> **مهم — المحاكي مقابل الهاتف الحقيقي:**
> - على **محاكي أندرويد** لا تكتب `localhost` (يشير للمحاكي نفسه)، بل `10.0.2.2`.
> - على **هاتف حقيقي** اكتب IP اللابتوب على الواي‑فاي (مثل `192.168.1.20`).
> - على **فلاتر-ويب/سطح المكتب** `localhost` يعمل مباشرة.
> هذا بالضبط سبب وجود زر الـ FAB: ليغيّر المستخدم العنوان دون إعادة بناء التطبيق.

## 5. النتيجة الموحّدة — `api_result.dart`

```dart
class ApiResult<T> {
  final bool success;
  final String message;
  final T? data;
  const ApiResult({required this.success, this.message = '', this.data});
}
```

## 6. غلاف الشبكة — `api_client.dart`

```dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'api_config.dart';
import 'api_result.dart';

class ApiClient {
  static const _timeout = Duration(seconds: 8);

  static Future<ApiResult<dynamic>> _send(
    String method,
    String path, {
    Map<String, dynamic>? body,
    Map<String, String>? query,
  }) async {
    try {
      final base = await ApiConfig.baseUrl();
      final uri = Uri.parse('$base$path').replace(queryParameters: query);
      final headers = {'Content-Type': 'application/json; charset=UTF-8'};
      late http.Response res;

      switch (method) {
        case 'GET':
          res = await http.get(uri, headers: headers).timeout(_timeout);
          break;
        case 'POST':
          res = await http.post(uri, headers: headers,
              body: jsonEncode(body)).timeout(_timeout);
          break;
        case 'PUT':
          res = await http.put(uri, headers: headers,
              body: jsonEncode(body)).timeout(_timeout);
          break;
        case 'DELETE':
          res = await http.delete(uri, headers: headers).timeout(_timeout);
          break;
      }

      final decoded = jsonDecode(res.body) as Map<String, dynamic>;
      return ApiResult(
        success: decoded['success'] == true,
        message: decoded['message'] ?? '',
        data: decoded['data'],
      );
    } on SocketException {
      return const ApiResult(success: false, message: 'تعذّر الوصول للسيرفر');
    } catch (e) {
      return ApiResult(success: false, message: 'خطأ: $e');
    }
  }

  static Future<ApiResult> get(String p, {Map<String, String>? query}) =>
      _send('GET', p, query: query);
  static Future<ApiResult> post(String p, Map<String, dynamic> b) =>
      _send('POST', p, body: b);
  static Future<ApiResult> put(String p, Map<String, dynamic> b,
          {Map<String, String>? query}) =>
      _send('PUT', p, body: b, query: query);
  static Future<ApiResult> delete(String p, {Map<String, String>? query}) =>
      _send('DELETE', p, query: query);

  /// يستخدمه زر الـ FAB لفحص الاتصال
  static Future<bool> ping() async {
    final r = await get('/ping.php');
    return r.success;
  }
}
```

---

## 7. نموذج وريبو — مثال `child`

### `core/data/models/child.dart`
```dart
class Child {
  final int id;
  final String name;
  final int age;
  final int totalStars;

  Child({required this.id, required this.name,
         required this.age, required this.totalStars});

  factory Child.fromJson(Map<String, dynamic> j) => Child(
        id: j['id'],
        name: j['name'] ?? '',
        age: int.tryParse('${j['age']}') ?? 0,
        totalStars: int.tryParse('${j['total_stars']}') ?? 0,
      );

  Map<String, dynamic> toJson() =>
      {'name': name, 'age': age, 'total_stars': totalStars};
}
```

### `core/data/repositories/child_repository.dart`
```dart
import '../../network/api_client.dart';
import '../models/child.dart';

class ChildRepository {
  Future<List<Child>> getAll() async {
    final r = await ApiClient.get('/children/');
    if (!r.success || r.data is! List) return [];
    return (r.data as List).map((e) => Child.fromJson(e)).toList();
  }

  Future<Child?> create(String name, int age) async {
    final r = await ApiClient.post('/children/', {'name': name, 'age': age});
    return r.success ? Child.fromJson(r.data) : null;
  }

  Future<bool> update(int id, {String? name, int? age, int? stars}) async {
    final r = await ApiClient.put('/children/', {
      if (name != null) 'name': name,
      if (age != null) 'age': age,
      if (stars != null) 'total_stars': stars,
    }, query: {'id': '$id'});
    return r.success;
  }

  Future<bool> delete(int id) async {
    final r = await ApiClient.delete('/children/', query: {'id': '$id'});
    return r.success;
  }
}
```

---

## 8. الاستراتيجية: تغيير الجسم فقط دون لمس الواجهات

أنظف طريقة للتحويل: نُبقي على واجهة `ScoreManager` و `ProgressManager` كما هي
(نفس أسماء الدوال) فلا تتغيّر أي شاشة، ونغيّر جسمها لتتصل بالـ API مع **بديل محلي**.

### مثال: `ScoreManager` بعد التحويل

```dart
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../network/api_client.dart';

class ScoreManager {
  static const String _keyStars = 'global_stars'; // يبقى ككاش محلي
  static int currentChildId = 1; // يُضبط بعد اختيار الطفل
  static final ValueNotifier<int> starsNotifier = ValueNotifier<int>(0);

  static Future<int> getStars() async {
    // 1) جرّب السيرفر
    final r = await ApiClient.get('/children/', query: {'id': '$currentChildId'});
    if (r.success && r.data != null) {
      final stars = int.tryParse('${r.data['total_stars']}') ?? 0;
      starsNotifier.value = stars;
      _cache(stars);                 // خزّن نسخة محلية
      return stars;
    }
    // 2) بديل: اقرأ من الكاش المحلي عند فشل الاتصال
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getInt(_keyStars) ?? 0;
    starsNotifier.value = cached;
    return cached;
  }

  static Future<int> addStars(int count) async {
    // التقدّم والنجوم يُحدَّثان معاً على السيرفر عبر /progress/
    // (هنا نكتفي بتحديث الكاش والمُخطِر؛ الزيادة الفعلية تتم عند تسجيل اللعبة)
    final updated = starsNotifier.value + count;
    starsNotifier.value = updated;
    await _cache(updated);
    return updated;
  }

  static Future<void> _cache(int v) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyStars, v);
  }
}
```

### مثال: `ProgressManager.markGameCompleted`
```dart
static Future<void> markGameCompleted(String gameId, {int stars = 1}) async {
  // 1) سجّل على السيرفر (يزيد النجوم تلقائياً عبر /progress/)
  final r = await ApiClient.post('/progress/', {
    'child_id': ScoreManager.currentChildId,
    'game_code': gameId,
    'stars': stars,
  });
  // 2) حدّث الكاش المحلي ليعمل التطبيق دون اتصال
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('game_done_$gameId', true);
  // 3) أخطِر الشاشات
  progressTick.value++;
}
```

بهذا: كل شاشات الألعاب التي تنادي `ProgressManager.markGameCompleted('word_game')`
تعمل كما هي تماماً، لكنها الآن تكتب في قاعدة البيانات.

---

## 9. أذونات وإعدادات أندرويد (مهم جداً)

بدونها سيفشل الاتصال على الهاتف الحقيقي:

في `untitled1/android/app/src/main/AndroidManifest.xml`:

```xml
<manifest ...>
    <!-- 1) إذن الإنترنت -->
    <uses-permission android:name="android.permission.INTERNET"/>

    <application
        ...
        <!-- 2) السماح بـ HTTP غير المشفّر (نستخدم http لا https محلياً) -->
        android:usesCleartextTraffic="true">
        ...
    </application>
</manifest>
```

> أندرويد 9+ يمنع `http://` العادي افتراضياً؛ لذلك `usesCleartextTraffic="true"`
> ضروري للتطوير المحلي. (بديل أدق: ملف `network_security_config.xml` يسمح فقط
> لشبكتك المحلية.)
