import 'package:utamemo_app/data/repositories/song/song_repository.dart';
import 'package:utamemo_app/domain/model/song.dart';

/// 曲詳細画面のデータ取得ロジックを管理するコントローラー
class SongDetailController {
  SongDetailController(this._repository);

  final SongRepository _repository;

  /// 指定されたIDの曲情報を取得する
  Future<Song?> loadSong(String songId) async {
    return await _repository.getSongById(songId);
  }

  /// 指定されたIDの曲情報をリアルタイムに監視する
  ///
  /// [songId] 監視する曲のID
  ///
  /// 曲が存在しない場合は`null`を流す。
  Stream<Song?> watchSong(String songId) {
    return _repository.watchAll().map((songs) {
      final matched = songs.where((song) => song.id == songId);
      return matched.isEmpty ? null : matched.first;
    });
  }
}
