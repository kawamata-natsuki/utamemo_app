import 'dart:async';

import 'package:utamemo_app/data/repositories/song/song_repository.dart';
import 'package:utamemo_app/domain/model/song.dart';

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
  ScoreHistoryController(this._repo);
  final SongRepository _repo;

  /// 実データ版：全曲監視 → songIdの曲を抽出 → S23表示用データへ変換
  Stream<ScoreHistoryData?> watchScoreHistory(String songId) {
    return _repo.watchAll().map((songs) {
      final Song? song = _firstOrNull(songs.where((s) => s.id == songId));
      if (song == null) return null;

      final records = song.scoreRecords.toList()
        ..sort((a, b) => b.recordedAt.compareTo(a.recordedAt));

      return ScoreHistoryData(
        song: ScoreHistorySong(
          title: song.title,
          artistName: song.artistName,
        ),
        scoreRecords: records
            .map((r) => ScoreHistoryScoreRecord(score: r.score, recordedAt: r.recordedAt))
            .toList(),
      );
    });
  }

  T? _firstOrNull<T>(Iterable<T> it) => it.isEmpty ? null : it.first;
}