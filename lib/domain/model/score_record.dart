enum KaraokeMachine { dam, joysound, unknown }

class ScoreRecord {
  final String id;
  final double score;
  final DateTime recordedAt;
  final String? memo;
  final KaraokeMachine karaokeMachine;
  final int? originalKey;
  final int? shiftKey;

  ScoreRecord({
    required this.id,
    required this.score,
    required this.recordedAt,
    this.memo,
    required this.karaokeMachine,
    this.originalKey,
    this.shiftKey,
  });

  /// 実キーを計算（両方入力されている場合）
  int? get actualKey {
    if (originalKey != null && shiftKey != null) {
      return originalKey! + shiftKey!;
    }
    if (shiftKey != null) {
      return shiftKey;
    }
    return null;
  }

  /// キーの表示用文字列を生成
  String? getKeyDisplay() {
    final actual = actualKey;
    if (actual == null) return null;

    final actualLabel = actual >= 0 ? '+$actual' : '$actual';

    if (originalKey != null) {
      final originalLabel =
          originalKey! >= 0 ? '+$originalKey' : '$originalKey';
      return '$actualLabel（原曲: $originalLabel）';
    }

    return actualLabel;
  }

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
    int? originalKey,
    int? shiftKey,
  }) {
    return ScoreRecord(
      id: id ?? this.id,
      score: score ?? this.score,
      recordedAt: recordedAt ?? this.recordedAt,
      memo: memo ?? this.memo,
      karaokeMachine: karaokeMachine ?? this.karaokeMachine,
      originalKey: originalKey ?? this.originalKey,
      shiftKey: shiftKey ?? this.shiftKey,
    );
  }
}