import 'package:utamemo_app/domain/model/score_record.dart';
import 'package:utamemo_app/domain/model/song_status.dart';

/// 曲情報を表すクラス
class Song {
  final String id;
  final String title;
  final String? artistName;

  // ユーザー操作で更新（直接変更不可）
  final List<String> tags;

  // 採点履歴（直接変更不可）
  final List<ScoreRecord> scoreRecords;

  // 曲ステータス（直接変更不可）
  final List<SongStatus> statuses;

  Song({
    required this.id,
    required this.title,
    this.artistName,
    List<String>? tags,
    List<ScoreRecord>? scoreRecords,
    List<SongStatus>? statuses,
  })  : tags = List.unmodifiable(tags ?? const []),
        scoreRecords = List.unmodifiable(scoreRecords ?? const []),
        statuses = List.unmodifiable(statuses ?? const []);

  Song copyWith({
    String? title,
    String? artistName,
    List<String>? tags,
    List<ScoreRecord>? scoreRecords,
    List<SongStatus>? statuses,
  }) {
    return Song(
      id: id,
      title: title ?? this.title,
      artistName: artistName ?? this.artistName,
      tags: tags ?? this.tags,
      scoreRecords: scoreRecords ?? this.scoreRecords,
      statuses: statuses ?? this.statuses,
    );
  }

  // 最高点（採点結果が1件もなければ null）
  double? get bestScore {
    if (scoreRecords.isEmpty) return null;
    return scoreRecords.map((r) => r.score).reduce((max, s) => max > s ? max : s);
  }

  // 採点回数
  int get scoreCount => scoreRecords.length;

  // 平均点（採点回数2回以上の場合のみ計算）
  double? get avgScore {
    if (scoreRecords.length < 2) return null;
    final total = scoreRecords.fold<double>(0, (sum, r) => sum + r.score);
    return total / scoreRecords.length;
  }
}
