enum KaraokeMachine { dam, joysound }

class ScoreRecord {
  final String id;
  final double score;
  final DateTime recordedAt;
  final String? memo;
  final KaraokeMachine karaokeMachine;

  ScoreRecord({
    required this.id,
    required this.score,
    required this.recordedAt,
    this.memo,
    required this.karaokeMachine,
  });

  /// ScoreRecordのコピーを作成する
  ///
  /// 注意: nullableフィールド（memo）にnullを明示的に設定することはできません。
  /// 将来的に編集機能を追加する際は、Optional型パターンの導入を検討してください。
  ScoreRecord copyWith({
    String? id,
    double? score,
    DateTime? recordedAt,
    String? memo,
    KaraokeMachine? karaokeMachine,
  }) {
    return ScoreRecord(
      id: id ?? this.id,
      score: score ?? this.score,
      recordedAt: recordedAt ?? this.recordedAt,
      memo: memo ?? this.memo,
      karaokeMachine: karaokeMachine ?? this.karaokeMachine,
    );
  }
}