import 'package:utamemo_app/data/repositories/song/song_repository.dart';
import 'package:utamemo_app/domain/model/score_record.dart';

/// S21:採点追加画面のビジネスロジックを管理するコントローラー
class ScoreAddController {
  ScoreAddController(this._repository);

  final SongRepository _repository;

  /// 点数のバリデーション
  String? validateScore(String? value) {
    final text = (value ?? '').trim();
    if (text.isEmpty) return '点数を入力してください';

    final score = double.tryParse(text);
    if (score == null) return '数値で入力してください';
    if (score < 0 || score > 100) return '0〜100の範囲で入力してください';

    // 小数点以下2桁までチェック
    final decimalParts = text.split('.');
    if (decimalParts.length == 2 && decimalParts[1].length > 2) {
      return '小数点以下は2桁までです';
    }

    return null;
  }

  /// メモのバリデーション
  String? validateMemo(String? value) {
    final text = value ?? '';
    if (text.length > 200) return 'メモは200文字以内で入力してください';
    return null;
  }

  /// 採点機種のバリデーション
  String? validateKaraokeMachine(KaraokeMachine? value) {
    if (value == null) return '採点機種を選択してください';
    return null;
  }

  /// 原曲キーのバリデーション
  String? validateOriginalKey(String? value) {
    if (value == null || value.trim().isEmpty) return null;

    final key = int.tryParse(value.trim());
    if (key == null) return '数値で入力してください';
    if (key < -24 || key > 24) return '±24以内の数値で入力してください';

    return null;
  }

  /// 変更キーのバリデーション
  String? validateShiftKey(String? value) {
    if (value == null || value.trim().isEmpty) return null;

    final key = int.tryParse(value.trim());
    if (key == null) return '数値で入力してください';
    if (key < -24 || key > 24) return '±24以内の数値で入力してください';
    return null;
  }

  /// 採点記録を保存する
  Future<void> saveScoreRecord({
    required String songId,
    required double score,
    required DateTime recordedAt,
    required KaraokeMachine karaokeMachine,
    String? memo,
    int? originalKey,
    int? shiftKey,
  }) async {
    // 採点記録のIDを生成（タイムスタンプベース）
    final recordId = 'score_${DateTime.now().millisecondsSinceEpoch}';

    await _repository.addScoreRecord(
      songId: songId,
      record: ScoreRecord(
        id: recordId,
        score: score,
        recordedAt: recordedAt,
        karaokeMachine: karaokeMachine,
        memo: memo?.trim().isEmpty == true ? null : memo?.trim(),
        originalKey: originalKey,
        shiftKey: shiftKey,
      ),
    );
  }

  /// 日付をフォーマット
  String formatDate(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y/$m/$d';
  }
}
