/// عنصر محتوى للعبة نصية، كما يصل من `GET /game_items/`.
///
/// معنى الحقول text1..text4 يختلف حسب اللعبة (انظر جدول game_items):
///   word_game:        text1=الكلمة، text2=الإيموجي
///   english_spelling: text1=الكلمة(EN)، text2=الإيموجي، text3=التلميح
///   sentence_game:    text1=الجملة الصحيحة (كلمات بمسافات)
///   ar_en_matching:   text1=عربي، text2=إنجليزي، text3=إيموجي
///   grammar_matching: text1=الجملة، text2=الكلمة، text3=إعرابها
///   question_builder: text1=الإجابة، text2=السؤال الصحيح، text3=التلميح
///   error_hunter:     text1=الجملة، text2=الكلمة الخطأ، text3=الصحيحة، text4=التلميح
class GameContentItem {
  final int levelNumber;
  final String text1;
  final String text2;
  final String text3;
  final String text4;

  const GameContentItem({
    required this.levelNumber,
    required this.text1,
    required this.text2,
    required this.text3,
    required this.text4,
  });

  factory GameContentItem.fromJson(Map<String, dynamic> j) => GameContentItem(
        levelNumber: int.tryParse('${j['level_number']}') ?? 1,
        text1: (j['text1'] ?? '').toString(),
        text2: (j['text2'] ?? '').toString(),
        text3: (j['text3'] ?? '').toString(),
        text4: (j['text4'] ?? '').toString(),
      );
}
