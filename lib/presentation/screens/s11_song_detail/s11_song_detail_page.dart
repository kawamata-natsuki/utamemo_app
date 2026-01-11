import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:utamemo_app/data/repositories/song/song_repository.dart';
import 'package:utamemo_app/domain/model/song.dart';

import 'package:utamemo_app/presentation/screens/s11_song_detail/s11_song_detail_controller.dart';
import 'package:utamemo_app/presentation/screens/s21_add_score/s21_add_score_page.dart';
import 'package:utamemo_app/presentation/shared/widgets/error_scaffold.dart';
import 'package:utamemo_app/presentation/shared/widgets/not_found_scaffold.dart';
import 'package:utamemo_app/presentation/shared/widgets/score_history_section.dart';
import 'package:utamemo_app/presentation/shared/widgets/score_summary_card.dart';
import 'package:utamemo_app/presentation/shared/widgets/tags_wrap.dart';

class S11SongDetailPage extends StatefulWidget {
  const S11SongDetailPage({
    super.key,
    required this.songId,
  });

  final String songId;

  @override
  State<S11SongDetailPage> createState() => _S11SongDetailPageState();
}

class _S11SongDetailPageState extends State<S11SongDetailPage> {
  late final S11SongDetailController _controller;
  late Future<Song?> _songFuture;

  // 初期化
  @override
  void initState() {
    super.initState();
    final repo = context.read<SongRepository>();
    _controller = S11SongDetailController(repo);
    _songFuture = _controller.loadSong(widget.songId);
  }

  // 曲情報を更新
  void _refreshSong() {
    setState(() {
      _songFuture = _controller.loadSong(widget.songId);
    });
  }

  // 画面構築
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Song?>(
      future: _songFuture,
      builder: (context, snapshot) {
        // 読み込み中の表示
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // エラーが発生した場合の表示
        if (snapshot.hasError) {
          return ErrorScaffold(
            title: '曲詳細',
            message: '読み込みに失敗しました',
            details: snapshot.error.toString(),
          );
        }

        // 曲が見つからない場合の表示
        final song = snapshot.data;
        if (song == null) {
          return NotFoundScaffold(
            title: '曲詳細',
            message: '曲が見つかりません',
          );
        }

        final scoreCount = song.scoreCount;
        final bestScore = song.bestScore;
        final avgScore = song.avgScore;

        // 曲詳細画面の表示
        return Scaffold(
          appBar: AppBar(
            title: const Text('曲詳細'),
            actions: [
              IconButton(
                tooltip: '編集',
                onPressed: null, // TODO: S12へ
                icon: const Icon(Icons.edit),
              ),
              IconButton(
                tooltip: '削除',
                onPressed: null, // TODO: 削除確認ダイアログ
                icon: const Icon(Icons.delete_outline),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                song.title,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              if (song.artistName?.trim().isNotEmpty ?? false)
                Text(
                  song.artistName!,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              const SizedBox(height: 12),
              if (song.tags.isNotEmpty) TagsWrap(tags: song.tags),
              const SizedBox(height: 16),
              if (scoreCount > 0)
                ScoreSummaryCard(
                  bestScore: bestScore,
                  avgScore: (scoreCount >= 2) ? avgScore : null,
                  scoreCount: scoreCount,
                ),
              const SizedBox(height: 20),
              ScoreHistorySection(
                hasRecords: scoreCount > 0,
                onAdd: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => S21AddScorePage(songId: widget.songId),
                    ),
                  );
                  _refreshSong();
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
