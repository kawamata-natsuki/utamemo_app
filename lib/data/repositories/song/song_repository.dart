import 'package:utamemo_app/domain/model/song.dart';
import 'package:utamemo_app/domain/model/score_record.dart';

/// 曲情報と採点記録を管理するリポジトリインターフェース
abstract class SongRepository {
  /// 全曲情報をリアルタイムに監視する
  ///
  /// 曲情報が変更されるたびに最新のリストを流す。
  Stream<List<Song>> watchAll();

  /// 指定されたIDの曲情報を取得する
  ///
  /// [songId] 取得する曲のID
  ///
  /// 曲が存在しない場合は`null`を返す。
  Future<Song?> getSongById(String songId);

  /// 新しい曲を追加する
  ///
  /// [title] 曲名（必須）
  /// [artistName] アーティスト名（任意）
  /// [tags] タグのリスト（任意）
  ///
  /// 追加された曲のIDを返す。
  Future<String> addSong({
    required String title,
    String? artistName,
    List<String>? tags,
  });

  /// 指定された曲に採点記録を追加する
  ///
  /// [songId] 採点記録を追加する曲のID
  /// [record] 追加する採点記録
  ///
  /// 曲が存在しない場合は例外をスローする可能性がある。
  Future<void> addScoreRecord({
    required String songId,
    required ScoreRecord record,
  });

  /// 全曲から指定カスタムタグを外し、外れた曲数を返す
  ///
  /// [tagName] 外すカスタムタグ
  Future<int> removeCustomTagFromAllSongs(String tagName);

  /// 全曲で指定カスタムタグ名を置換し、影響した曲数を返す
  ///
  /// [from] 置換前のカスタムタグ名
  /// [to] 置換後のカスタムタグ名
  Future<int> renameCustomTagInAllSongs({
    required String from,
    required String to,
  });

  /// リポジトリのリソースを解放する
  ///
  /// ストリームの購読やその他のリソースをクリーンアップする。
  void dispose();
}