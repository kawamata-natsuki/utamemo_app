import 'dart:async';

import 'package:utamemo_app/domain/model/song.dart';
import 'package:utamemo_app/domain/model/score_record.dart';
import 'package:utamemo_app/data/repositories/song/song_repository.dart';

/// メモリ上に曲を保持する Repository（開発・UI確認用）
///
/// 本番では永続化実装（DB / Firestore 等）に差し替える
class InMemorySongRepository implements SongRepository {
  final _controller = StreamController<List<Song>>.broadcast();
  List<Song> _songs = [];

  InMemorySongRepository() {
    seed();
  }

  /// ダミーの初期データを投入
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
            recordedAt: DateTime(2025, 12, 26),
            karaokeMachine: KaraokeMachine.dam,
          ),
          ScoreRecord(
            score: 81.75,
            recordedAt: DateTime(2026, 1, 1),
            karaokeMachine: KaraokeMachine.joysound,
          ),
        ],
      ),
    ];
    _emit();
  }

  void _emit() {
    if (!_controller.isClosed) {
      _controller.add(List.unmodifiable(_songs));
    }
  }

  @override
  Stream<List<Song>> watchAll() async* {
    yield List.unmodifiable(_songs);
    yield* _controller.stream;
  }

  @override
  Future<Song?> getSongById(String songId) async {
    final index = _songs.indexWhere((song) => song.id == songId);
    return index != -1 ? _songs[index] : null;
  }

  @override
  Future<String> addSong({
    required String title,
    String? artistName,
    List<String>? tags,
  }) async {
    // 簡易的なID生成（本番ではUUID等を使用）
    final newId = 'song_${DateTime.now().millisecondsSinceEpoch}';

    final newSong = Song(
      id: newId,
      title: title,
      artistName: artistName,
      tags: tags ?? [],
      scoreRecords: [],
    );

    _songs = [..._songs, newSong];
    _emit();

    return newId;
  }

  @override
  Future<void> addScoreRecord({
    required String songId,
    required ScoreRecord record,
  }) async {
    final index = _songs.indexWhere((song) => song.id == songId);
    if (index == -1) {
      throw Exception('Song not found: $songId');
    }

    final song = _songs[index];
    final updatedSong = Song(
      id: song.id,
      title: song.title,
      artistName: song.artistName,
      tags: song.tags,
      scoreRecords: [...song.scoreRecords, record],
    );

    _songs[index] = updatedSong;
    _emit();
  }

  @override
  void dispose() => _controller.close();
}