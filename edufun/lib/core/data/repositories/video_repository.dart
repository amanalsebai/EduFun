import '../../network/api_client.dart';
import '../models/video.dart';

/// نتيجة جلب من السيرفر — تفرّق بين «فشل الاتصال» و«نجح لكن القاعدة فارغة».
/// هذا التمييز ضروري ليعرف المتصل إن كان يستعمل البديل المحلي أم يحترم القاعدة.
class FetchResult<T> {
  final bool connected; // هل نجح الوصول للسيرفر فعلاً؟
  final List<T> data;
  const FetchResult({required this.connected, required this.data});
}

/// قراءة الفيديوهات (الدروس) من السيرفر. تعيد [FetchResult] يميّز حالة الاتصال:
/// - `connected:false` + قائمة فارغة → تعذّر الاتصال (يُستعمل البديل المحلي).
/// - `connected:true` + قائمة فارغة → السيرفر وصل لكن لا فيديوهات (نحترم القاعدة).
class VideoRepository {
  Future<FetchResult<Video>> getAll() async {
    final r = await ApiClient.get('/videos/');
    if (!r.success || r.data is! List) {
      return const FetchResult(connected: false, data: []);
    }
    final list = (r.data as List)
        .map((e) => Video.fromJson(e as Map<String, dynamic>))
        .toList();
    return FetchResult(connected: true, data: list);
  }

  Future<FetchResult<Video>> getBySubject(String subjectCode) async {
    final r = await ApiClient.get('/videos/', query: {'subject': subjectCode});
    if (!r.success || r.data is! List) {
      return const FetchResult(connected: false, data: []);
    }
    final list = (r.data as List)
        .map((e) => Video.fromJson(e as Map<String, dynamic>))
        .toList();
    return FetchResult(connected: true, data: list);
  }
}
