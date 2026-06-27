/// نموذج لعبة كما يصل من المسار `GET /games/?min_age=`.
///
/// `code` (game_code) هو مفتاح الربط بين القاعدة وشاشة Flutter المقابلة له
/// (انظر `game_registry.dart`). باقي الحقول تتحكّم بالمحتوى الظاهري للبطاقة:
/// العنوان، الوصف، التصنيف، والترتيب.
class Game {
  final int id;
  final String code; // game_code — مفتاح الربط بالشاشة
  final String title; // title_ar
  final String subtitle;
  final String categoryLabel;
  final int minAge;
  final int sortOrder;

  const Game({
    required this.id,
    required this.code,
    required this.title,
    required this.subtitle,
    required this.categoryLabel,
    required this.minAge,
    required this.sortOrder,
  });

  factory Game.fromJson(Map<String, dynamic> j) => Game(
        id: int.tryParse('${j['id']}') ?? 0,
        code: (j['game_code'] ?? '').toString(),
        title: (j['title_ar'] ?? '').toString(),
        subtitle: (j['subtitle'] ?? '').toString(),
        categoryLabel: (j['category_label'] ?? '').toString(),
        minAge: int.tryParse('${j['min_age']}') ?? 6,
        sortOrder: int.tryParse('${j['sort_order']}') ?? 0,
      );
}
