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
    // 両方ある → 実キー
    if (originalKey != null && shiftKey != null) {
      return originalKey! + shiftKey!;
    }
    // shiftだけある → shiftを実キー扱い（MVP運用）
    if (shiftKey != null) {
      return shiftKey;
    }
    // ✅ originalだけある → originalを実キー扱い（これが必要）
    if (originalKey != null) {
      return originalKey;
    }
    return null;
  }

  String _fmt(int v) {
    if (v == 0) return '0';
    return v > 0 ? '+$v' : '$v';
  }

  /// キーの表示用文字列を生成（表示はUI用）
  String? getKeyDisplay() {
    final actual = actualKey;
    if (actual == null) return null;

    // ✅ 0のときは補足いらない（スッキリ）
    if (actual == 0) return '0';

    final actualLabel = _fmt(actual);

    if (originalKey != null) {
      final originalLabel = _fmt(originalKey!);
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