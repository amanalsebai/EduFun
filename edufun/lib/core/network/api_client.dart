import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'api_config.dart';
import 'api_result.dart';

/// غلاف موحّد فوق `package:http` يتعامل مع غلاف JSON القادم من PHP،
/// ويلتقط أعطال الشبكة ويعيدها كـ [ApiResult] بدل رمي استثناء.
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
      final uri = query == null
          ? Uri.parse('$base$path')
          : Uri.parse('$base$path').replace(queryParameters: query);
      final headers = {'Content-Type': 'application/json; charset=UTF-8'};
      http.Response res;

      switch (method) {
        case 'GET':
          res = await http.get(uri, headers: headers).timeout(_timeout);
          break;
        case 'POST':
          res = await http
              .post(uri, headers: headers, body: jsonEncode(body ?? {}))
              .timeout(_timeout);
          break;
        case 'PUT':
          res = await http
              .put(uri, headers: headers, body: jsonEncode(body ?? {}))
              .timeout(_timeout);
          break;
        case 'DELETE':
          res = await http.delete(uri, headers: headers).timeout(_timeout);
          break;
        default:
          return const ApiResult(success: false, message: 'طريقة غير مدعومة');
      }

      final decoded = jsonDecode(res.body);
      if (decoded is Map<String, dynamic>) {
        return ApiResult(
          success: decoded['success'] == true,
          message: (decoded['message'] ?? '').toString(),
          data: decoded['data'],
        );
      }
      // استجابة غير متوقّعة الشكل
      return ApiResult(success: false, message: 'استجابة غير صالحة', data: decoded);
    } on SocketException {
      return const ApiResult(success: false, message: 'تعذّر الوصول للسيرفر');
    } on FormatException {
      return const ApiResult(
          success: false, message: 'تعذّر فهم استجابة السيرفر');
    } on HttpException {
      return const ApiResult(success: false, message: 'خطأ في بروتوكول HTTP');
    } catch (e) {
      return ApiResult(success: false, message: 'خطأ: $e');
    }
  }

  static Future<ApiResult<dynamic>> get(String p,
          {Map<String, String>? query}) =>
      _send('GET', p, query: query);

  static Future<ApiResult<dynamic>> post(String p,
          [Map<String, dynamic>? b]) =>
      _send('POST', p, body: b ?? const {});

  static Future<ApiResult<dynamic>> put(String p,
          {Map<String, dynamic>? body, Map<String, String>? query}) =>
      _send('PUT', p, body: body ?? const {}, query: query);

  static Future<ApiResult<dynamic>> delete(String p,
          {Map<String, String>? query}) =>
      _send('DELETE', p, query: query);

  /// يستخدمه زر الـ FAB لفحص الاتصال.
  static Future<bool> ping() async {
    final r = await get('/ping.php');
    return r.success;
  }
}
