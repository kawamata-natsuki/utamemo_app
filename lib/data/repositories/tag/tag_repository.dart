/// カスタムタグ（テキストのみ）を管理するリポジトリ
abstract class TagRepository {
  /// 全タグをリアルタイムに監視する
  ///
  /// タグが変更されるたびに最新のリストを流す。
  Stream<List<String>> watchAll();

  /// 新しいタグを追加する
  ///
  /// [name] 追加するタグの名前
  Future<void> add(String name);

  /// タグの名前を変更する
  ///
  /// [from] 変更前のタグの名前
  /// [to] 変更後のタグの名前
  Future<void> rename({required String from, required String to});

  /// タグを削除する
  ///
  /// [name] 削除するタグの名前
  Future<void> delete(String name);

  void dispose();
}
