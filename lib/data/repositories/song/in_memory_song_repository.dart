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
            id: 'score_1',
            score: 83.25,
            recordedAt: DateTime(2025, 12, 26),
            karaokeMachine: KaraokeMachine.dam,
            originalKey: 0,
            shiftKey: -2,
          ),
          ScoreRecord(
            id: 'score_2',
            score: 81.75,
            recordedAt: DateTime(2026, 1, 1),
            karaokeMachine: KaraokeMachine.joysound,
            shiftKey: 3,
          ),
          ScoreRecord(
            id: 'score_3',
            score: 80.00,
            recordedAt: DateTime(2026, 1, 2),
            karaokeMachine: KaraokeMachine.joysound,
            shiftKey: 1,
          ),
          ScoreRecord(
            id: 'score_4',
            score: 79.50,
            recordedAt: DateTime(2026, 1, 3),
            karaokeMachine: KaraokeMachine.joysound,
            shiftKey: 1,
          ),
          ScoreRecord(
            id: 'score_5',
            score: 78.00,
            recordedAt: DateTime(2026, 1, 4),
            karaokeMachine: KaraokeMachine.joysound,
            shiftKey: 0,
          ),
          ScoreRecord(
            id: 'score_6',
            score: 78.00,
            recordedAt: DateTime(2026, 1, 5),
            karaokeMachine: KaraokeMachine.joysound,
            shiftKey: 1,
          ),
          ScoreRecord(
            id: 'score_7',
            score: 78.00,
            recordedAt: DateTime(2026, 1, 6),
            karaokeMachine: KaraokeMachine.joysound,
            shiftKey: 1,
          ),
          ScoreRecord(
            id: 'score_8',
            score: 78.00,
            recordedAt: DateTime(2026, 1, 8),
            karaokeMachine: KaraokeMachine.joysound,
            shiftKey: 1,
          ),
          ScoreRecord(
            id: 'score_9',
            score: 78.00,
            recordedAt: DateTime(2026, 1, 9),
            karaokeMachine: KaraokeMachine.joysound,
            shiftKey: 1,
          ),
          ScoreRecord(
            id: 'score_10',
            score: 78.00,
            recordedAt: DateTime(2026, 1, 10),
            karaokeMachine: KaraokeMachine.joysound,
            shiftKey: 1,
          ),
          ScoreRecord(
            id: 'score_11',
            score: 78.00,
            recordedAt: DateTime(2026, 1, 11),
            karaokeMachine: KaraokeMachine.joysound,
            shiftKey: 1,
          ),
          ScoreRecord(
            id: 'score_12',
            score: 78.00,
            recordedAt: DateTime(2026, 1, 12),
            karaokeMachine: KaraokeMachine.joysound,
            shiftKey: 1,
          ),
          ScoreRecord(
            id: 'score_13',
            score: 78.00,
            recordedAt: DateTime(2026, 1, 13),
            karaokeMachine: KaraokeMachine.joysound,
            shiftKey: 1,
          ),
          ScoreRecord(
            id: 'score_14',
            score: 78.00,
            recordedAt: DateTime(2026, 1, 14),
            karaokeMachine: KaraokeMachine.joysound,
            shiftKey: 1,
          ),
          ScoreRecord(
            id: 'score_15',
            score: 78.00,
            recordedAt: DateTime(2026, 1, 15),
            karaokeMachine: KaraokeMachine.joysound,
            shiftKey: 1,
          ),
          ScoreRecord(
            id: 'score_16',
            score: 78.00,
            recordedAt: DateTime(2025, 12, 16),
            karaokeMachine: KaraokeMachine.joysound,
            shiftKey: 1,
          ),
          ScoreRecord(
            id: 'score_17',
            score: 78.00,
            recordedAt: DateTime(2025, 12, 17),
            karaokeMachine: KaraokeMachine.joysound,
            shiftKey: 1,
          ),
          ScoreRecord(
            id: 'score_18',
            score: 78.00,
            recordedAt: DateTime(2025, 12, 18),
            karaokeMachine: KaraokeMachine.joysound,
            shiftKey: 1,
          ),
          ScoreRecord(
            id: 'score_19',
            score: 78.00,
            recordedAt: DateTime(2025, 12, 19),
            karaokeMachine: KaraokeMachine.joysound,
            shiftKey: 1,
          ),
          ScoreRecord(
            id: 'score_20',
            score: 78.00,
            recordedAt: DateTime(2025, 12, 20),
            karaokeMachine: KaraokeMachine.joysound,
            shiftKey: 1,
          ),
          ScoreRecord(
            id: 'score_21',
            score: 78.00,
            recordedAt: DateTime(2025, 12, 21),
            karaokeMachine: KaraokeMachine.joysound,
            shiftKey: 1,
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
  Future<int> removeCustomTagFromAllSongs(String tagName) async {
    final target = tagName.trim();
    if (target.isEmpty) return 0;

    var affected = 0;

    _songs = _songs.map((song) {
      if (!song.tags.contains(target)) return song;
      affected += 1;

      final newTags = song.tags.where((t) => t != target).toList(growable: false);

      // Song が copyWith を持ってないなら、Song(...) で組み立て直し
      return Song(
        id: song.id,
        title: song.title,
        artistName: song.artistName,
        tags: newTags,
        scoreRecords: song.scoreRecords,
      );
    }).toList(growable: false);

    _emit();
    return affected;
  }

  @override
  Future<int> renameCustomTagInAllSongs({required String from, required String to}) async {
    final fromN = from.trim();
    final toN = to.trim();
    if (fromN.isEmpty || toN.isEmpty) return 0;
    if (fromN == toN) return 0;

    var affected = 0;

    _songs = _songs.map((song) {
      if (!song.tags.contains(fromN)) return song;
      affected += 1;

      final newTags = song.tags.map((t) => t == fromN ? toN : t).toList(growable: false);

      return Song(
        id: song.id,
        title: song.title,
        artistName: song.artistName,
        tags: newTags,
        scoreRecords: song.scoreRecords,
      );
    }).toList(growable: false);

    _emit();
    return affected;
  }

  @override
  void dispose() => _controller.close();
}