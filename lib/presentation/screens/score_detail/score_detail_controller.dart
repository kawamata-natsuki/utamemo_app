import 'package:utamemo_app/data/repositories/song/song_repository.dart';
import 'package:utamemo_app/domain/model/song.dart';
import 'package:utamemo_app/domain/model/score_record.dart';

/// S22:採点詳細画面のデータ
class ScoreDetailData {
  final Song song;
  final ScoreRecord currentRecord;
  final List<ScoreRecord> recentRecords;
  final bool hasMoreRecords;

  ScoreDetailData({
    required this.song,
    required this.currentRecord,
    required this.recentRecords,
    required this.hasMoreRecords,
  });
}

/// S22:採点詳細画面のコントローラー
class ScoreDetailController {
  ScoreDetailController(this._repository);

  final SongRepository _repository;

  /// 採点詳細に必要なデータを取得
  Stream<ScoreDetailData?> watchScoreDetail(String songId, String scoreRecordId) {
    return _repository.watchAll().map((songs) {
      // 曲を検索
      Song? song;
      try {
        song = songs.firstWhere((s) => s.id == songId);
      } catch (_) {
        return null;
      }

      // 採点記録を検索
      ScoreRecord? record;
      try {
        record = song.scoreRecords.firstWhere((r) => r.id == scoreRecordId);
      } catch (_) {
        return null;
      }

      // 直近3回の採点履歴を取得（現在の記録を除く）
      final allRecentRecords = song.scoreRecords
          .where((r) => r.id != scoreRecordId)
          .toList()
        ..sort((a, b) => b.recordedAt.compareTo(a.recordedAt));

      final recentRecords = allRecentRecords.take(3).toList();
      final hasMoreRecords = allRecentRecords.length > 3;

      return ScoreDetailData(
        song: song,
        currentRecord: record,
        recentRecords: recentRecords,
        hasMoreRecords: hasMoreRecords,
      );
    });
  }

  /// カラオケ機種名を取得
  String getKaraokeMachineName(KaraokeMachine machine) {
    switch (machine) {
      case KaraokeMachine.dam:
        return 'DAM';
      case KaraokeMachine.joysound:
        return 'JOYSOUND';
      case KaraokeMachine.unknown:
        return '不明';
    }
  }

  /// 日付をフォーマット
  String formatDate(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y/$m/$d';
  }
}