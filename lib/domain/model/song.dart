import 'score_record.dart';

class Song {
  final String id;
  final String title;
  final String? artistName;
  // ユーザー操作で更新（直接変更不可）
  final List<String> tags;
  // 採点履歴（直接変更不可）
  final List<ScoreRecord> scoreRecords;

  Song({
    required this.id,
    required this.title,
    this.artistName,
    List<String>? tags,
    List<ScoreRecord>? scoreRecords,
  })  : tags = List.unmodifiable(tags ?? []),
        scoreRecords = List.unmodifiable(scoreRecords ?? []);

  // 最高点（採点結果が1件もなければ null）
  double? get bestScore {
    if (scoreRecords.isEmpty) return null;
    return scoreRecords
      .map((record) => record.score)
      .reduce((max, score) => max > score ? max : score);
  }

  // 採点回数
  int get scoreCount => scoreRecords.length;

  // 平均点（採点回数2回以上の場合のみ計算）
  double? get avgScore {
    if (scoreRecords.length < 2) return null;
    final total = scoreRecords.fold<double>(
      0,
      (sum, record) => sum + record.score,
    );
    return total / scoreRecords.length;
  }
}