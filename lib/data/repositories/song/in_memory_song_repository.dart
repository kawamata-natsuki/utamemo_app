import 'dart:async';

import 'package:utamemo_app/domain/model/song.dart';
import 'package:utamemo_app/domain/model/score_record.dart';
import 'package:utamemo_app/domain/model/song_status.dart';
import 'package:utamemo_app/data/repositories/song/song_repository.dart';

/// メモリ上に曲を保持する Repository（開発・UI確認用）
///
/// 本番では永続化実装（DB / Firestore 等）に差し替える
class InMemorySongRepository implements SongRepository {
  final _controller = StreamController<List<Song>>.broadcast();
  /// 曲情報のリスト
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
        tags: ['盛り上がる'],
        statuses: [SongStatus.favorite],
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

  /// 全曲情報を更新する
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
  Stream<Song?> watchById(String songId) async* {
    // 初回は現在の値を流す
    final index = _songs.indexWhere((song) => song.id == songId);
    yield index != -1 ? _songs[index] : null;

    // 以降は_controllerのstreamから該当曲を抽出して流す
    yield* _controller.stream.map((songs) {
      final idx = songs.indexWhere((song) => song.id == songId);
      return idx != -1 ? songs[idx] : null;
    });
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
  Future<void> updateSong({
    required String songId,
    String? title,
    String? artistName,
    List<SongStatus>? statuses,
    List<String>? tags,
  }) async {
    final idx = _songs.indexWhere((s) => s.id == songId);
    if (idx == -1) throw Exception('Song not found');

    final current = _songs[idx];

    _songs[idx] = current.copyWith(
      title: title ?? current.title,
      artistName: artistName ?? current.artistName,
      statuses: statuses ?? current.statuses,
      tags: tags ?? current.tags,
    );

    _emit();
  }

  @override
  Future<void> updateScoreRecord({
    required String songId,
    required ScoreRecord record,
  }) async {
    final songIndex = _songs.indexWhere((s) => s.id == songId);
    // 曲が存在しない場合は例外をスロー
    if (songIndex == -1) {
      throw Exception('Song not found: $songId');
    }

    final song = _songs[songIndex];
    final recordIndex = song.scoreRecords.indexWhere((r) => r.id == record.id);
    // 採点記録が存在しない場合は例外をスロー
    if (recordIndex == -1) {
      throw Exception('Score record not found: ${record.id}');
    }

    // scoreRecordsを更新
    final updatedRecords = List<ScoreRecord>.from(song.scoreRecords);
    updatedRecords[recordIndex] = record;

    // Songを更新
    _songs[songIndex] = song.copyWith(scoreRecords: updatedRecords);
    _emit();
  }

  @override
  Future<void> deleteScoreRecord({
    required String songId,
    required String scoreRecordId,
  }) async {
    final songIndex = _songs.indexWhere((s) => s.id == songId);
    // 曲が存在しない場合は例外をスロー
    if (songIndex == -1) {
      throw Exception('Song not found: $songId');
    }

    final song = _songs[songIndex];
    // 採点記録が存在しない場合は例外をスロー
    final updatedRecords = song.scoreRecords
        .where((r) => r.id != scoreRecordId)
        .toList();

    if (updatedRecords.length == song.scoreRecords.length) {
      throw Exception('Score record not found: $scoreRecordId');
    }

    _songs[songIndex] = song.copyWith(scoreRecords: updatedRecords);
    _emit();
  }

  @override
  void dispose() => _controller.close();
}