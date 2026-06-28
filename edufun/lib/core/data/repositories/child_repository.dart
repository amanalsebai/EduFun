import '../../network/api_client.dart';
import '../models/child.dart';

class ChildRepository {
  Future<List<Child>> getAll() async {
    final r = await ApiClient.get('/children/');
    if (!r.success || r.data is! List) return [];
    return (r.data as List)
        .map((e) => Child.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Child?> getById(int id) async {
    final r = await ApiClient.get('/children/', query: {'id': '$id'});
    if (!r.success || r.data is! Map) return null;
    return Child.fromJson(r.data as Map<String, dynamic>);
  }

  Future<Child?> create(String name, int age, {int totalStars = 0}) async {
    final r = await ApiClient.post('/children/', {
      'name': name,
      'age': age,
      'total_stars': totalStars,
    });
    if (!r.success || r.data is! Map) return null;
    return Child.fromJson(r.data as Map<String, dynamic>);
  }

  Future<bool> update(int id, {String? name, int? age, int? stars}) async {
    final r = await ApiClient.put('/children/', query: {'id': '$id'}, body: {
      if (name != null) 'name': name,
      if (age != null) 'age': age,
      if (stars != null) 'total_stars': stars,
    });
    return r.success;
  }

  Future<bool> delete(int id) async {
    final r = await ApiClient.delete('/children/', query: {'id': '$id'});
    return r.success;
  }
}
