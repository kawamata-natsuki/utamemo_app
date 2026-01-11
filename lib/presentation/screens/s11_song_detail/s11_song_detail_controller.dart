import 'package:utamemo_app/data/repositories/song/song_repository.dart';
import 'package:utamemo_app/domain/model/song.dart';

/// 曲詳細画面のデータ取得ロジックを管理するコントローラー
class S11SongDetailController {
  S11SongDetailController(this._repository);

  final SongRepository _repository;

  /// 指定されたIDの曲情報を取得する
  Future<Song?> loadSong(String songId) async {
    return await _repository.getSongById(songId);
  }
}
