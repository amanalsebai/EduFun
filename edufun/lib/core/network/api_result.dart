/// نتيجة موحّدة لكل طلبات الشبكة، تطابق غلاف JSON القادم من PHP:
/// `{ "success": bool, "message": String, "data": dynamic }`.
class ApiResult<T> {
  final bool success;
  final String message;
  final T? data;

  const ApiResult({
    required this.success,
    this.message = '',
    this.data,
  });

  @override
  String toString() =>
      'ApiResult(success: $success, message: $message, data: $data)';
}
