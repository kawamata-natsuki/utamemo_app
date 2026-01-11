import 'package:utamemo_app/data/repositories/song/song_repository.dart';
import 'package:utamemo_app/domain/model/score_record.dart';

/// 採点追加画面のビジネスロジックを管理するコントローラー
class S21AddScoreController {
  S21AddScoreController(this._repository);

  final SongRepository _repository;

  /// スコアのバリデーション
  String? validateScore(String? value) {
    final text = (value ?? '').trim();
    if (text.isEmpty) return '点数を入力してください';

    final score = double.tryParse(text);
    if (score == null) return '数値で入力してください';
    if (score < 0 || score > 100) return '0〜100の範囲で入力してください';

    return null;
  }

  /// 採点記録を保存する
  Future<void> saveScoreRecord({
    required String songId,
    required double score,
    required DateTime recordedAt,
  }) async {
    await _repository.addScoreRecord(
      songId: songId,
      record: ScoreRecord(
        score: score,
        recordedAt: recordedAt,
      ),
    );
  }

  /// 日付をyyyy-MM-dd形式にフォーマット
  String formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
