import 'dart:async';

import 'package:utamemo_app/domain/model/song.dart';
import 'package:utamemo_app/domain/model/score_record.dart';
import 'package:utamemo_app/data/repositories/song/song_repository.dart';

/// メモリ上に曲を保持する Repository（開発・UI確認用）
/// 本番では永続化実装（DB / Firestore 等）に差し替える
class InMemorySongRepository implements SongRepository {
    // 曲一覧を配信する Stream を管理
    final _controller = StreamController<List<Song>>.broadcast();

    // 曲データを管理
    List<Song> _songs = [];

    // 初期データ投入
    InMemorySongRepository() {
      seed();
    }

    // ダミーの初期データ
    void seed() {
      _songs = [
        Song(
          id: 'song_1',
          title: 'STAY GOLD',
          artistName: 'Hi-STANDARD',
          tags: ['お気に入り'],
          scoreRecords: [
            ScoreRecord(
                score: 83.25,
                recordedAt: DateTime(2025, 12, 26)),
            ScoreRecord(
                score: 81.75,
                recordedAt: DateTime(2026, 1, 1)),
          ],
        ),
      ];
      _emit();
    }

    // Stream にデータを送信
    void _emit() {
      if (!_controller.isClosed) {
        _controller.add(List.unmodifiable(_songs));
      }
    }

    // 全曲を監視
    @override
    Stream<List<Song>> watchAll() async* {
      yield List.unmodifiable(_songs);
      yield* _controller.stream;
    }

    // ID から曲を 1件取得（詳細画面用）
    @override
    Future<Song?> getSongById(String songId) async {
      for (final song in _songs) {
        if (song.id == songId) {
          return song;
        }
      }
      return null;
    }

    // Stream を閉じる
    void dispose() => _controller.close();
}