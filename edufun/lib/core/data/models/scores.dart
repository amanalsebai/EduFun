/// درجات المجالات الثلاثة لطفل ما.
class Scores {
  final int math;
  final int language;
  final int logic;

  const Scores({this.math = 0, this.language = 0, this.logic = 0});

  factory Scores.fromJson(Map<String, dynamic> j) => Scores(
        math: int.tryParse('${j['math']}') ?? 0,
        language: int.tryParse('${j['language']}') ?? 0,
        logic: int.tryParse('${j['logic']}') ?? 0,
      );

  Map<String, dynamic> toJson() =>
      {'math': math, 'language': language, 'logic': logic};

  int operator [](String key) {
    switch (key) {
      case 'math':
        return math;
      case 'language':
        return language;
      case 'logic':
        return logic;
      default:
        return 0;
    }
  }
}
