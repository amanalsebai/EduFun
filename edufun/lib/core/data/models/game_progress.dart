class GameProgress {
  final int? id;
  final int childId;
  final String gameCode;
  final bool completed;
  final int starsEarned;
  final DateTime? completedAt;

  GameProgress({
    this.id,
    required this.childId,
    required this.gameCode,
    required this.completed,
    required this.starsEarned,
    this.completedAt,
  });

  factory GameProgress.fromJson(Map<String, dynamic> j) => GameProgress(
        id: j['id'] is int ? j['id'] : int.tryParse('${j['id']}'),
        childId: int.tryParse('${j['child_id']}') ?? 0,
        gameCode: (j['game_code'] ?? '').toString(),
        completed: (j['completed'] == 1 ||
            j['completed'] == true ||
            j['completed'] == '1'),
        starsEarned: int.tryParse('${j['stars_earned']}') ?? 0,
        completedAt: (j['completed_at'] == null || j['completed_at'] == '')
            ? null
            : DateTime.tryParse('${j['completed_at']}'),
      );
}
