class Child {
  final int id;
  final String name;
  final int age;
  final int totalStars;

  Child({
    required this.id,
    required this.name,
    required this.age,
    required this.totalStars,
  });

  factory Child.fromJson(Map<String, dynamic> j) => Child(
        id: j['id'] is int ? j['id'] : int.tryParse('${j['id']}') ?? 0,
        name: (j['name'] ?? '').toString(),
        age: int.tryParse('${j['age']}') ?? 0,
        totalStars: int.tryParse('${j['total_stars']}') ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'age': age,
        'total_stars': totalStars,
      };
}
