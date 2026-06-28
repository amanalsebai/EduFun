/// فيديو تعليمي (درس) قادم من السيرفر — يقابل جدول `videos`.
class Video {
  final int id;
  final String subjectCode; // math / language / logic
  final String title;
  final String channel;
  final String url;
  final String thumbnail;
  final int minAge;

  Video({
    required this.id,
    required this.subjectCode,
    required this.title,
    required this.channel,
    required this.url,
    required this.thumbnail,
    required this.minAge,
  });

  factory Video.fromJson(Map<String, dynamic> j) => Video(
        id: int.tryParse('${j['id']}') ?? 0,
        subjectCode: (j['subject_code'] ?? '').toString(),
        title: (j['title'] ?? '').toString(),
        channel: (j['channel'] ?? '').toString(),
        url: (j['url'] ?? '').toString(),
        thumbnail: (j['thumbnail'] ?? '').toString(),
        minAge: int.tryParse('${j['min_age']}') ?? 6,
      );
}
