import 'dart:async';

/// S23 用：採点履歴一覧のデータ（画面が参照する形に統一）
class ScoreHistoryData {
  const ScoreHistoryData({
    required this.song,
    required this.scoreRecords,
  });

  final ScoreHistorySong song;
  final List<ScoreHistoryScoreRecord> scoreRecords;
}

/// 画面表示に必要な最小の曲情報
class ScoreHistorySong {
  const ScoreHistorySong({
    required this.title,
    this.artistName,
  });

  final String title;
  final String? artistName;
}

/// 画面表示に必要な最小の採点行（点数＋日付）
class ScoreHistoryScoreRecord {
  const ScoreHistoryScoreRecord({
    required this.score,
    required this.recordedAt,
  });

  final double score;
  final DateTime recordedAt;
}

/// S23: 採点履歴一覧のコントローラー
class ScoreHistoryController {
  // ScoreHistoryController(this._repo);
  // final SongRepository _repo;

  /// 採点履歴一覧に必要なデータを取得
  Stream<ScoreHistoryData?> watchScoreHistory(String songId) async* {
    final dummy = ScoreHistoryData(
      song: const ScoreHistorySong(
        title: 'テスト曲（仮）',
        artistName: 'テストアーティスト',
      ),
      scoreRecords: [
        ScoreHistoryScoreRecord(
          score: 95.50,
          recordedAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
        ScoreHistoryScoreRecord(
          score: 92.10,
          recordedAt: DateTime.now().subtract(const Duration(days: 7)),
        ),
      ],
    );

    yield dummy;
  }
}
