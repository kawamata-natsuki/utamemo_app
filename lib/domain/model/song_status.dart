/// 曲ステータスを表す列挙型
enum SongStatus {
  favorite,   // お気に入り
  practice,   // 練習中
  wantToSing, // 歌いたい
  // unscored は「自動表示」扱いなので、編集対象に入れない（今回は定義しない）
}

/// SongStatusのラベルを取得する拡張メソッド
extension SongStatusLabel on SongStatus {
  String get label {
    switch (this) {
      case SongStatus.favorite:
        return 'お気に入り';
      case SongStatus.practice:
        return '練習中';
      case SongStatus.wantToSing:
        return '歌いたい';
    }
  }
}
