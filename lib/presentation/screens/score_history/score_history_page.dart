import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:utamemo_app/data/repositories/song/song_repository.dart';
import 'package:utamemo_app/presentation/screens/score_history/score_history_controller.dart';
import 'package:utamemo_app/presentation/shared/widgets/app_bar.dart';
import 'package:utamemo_app/presentation/shared/widgets/score_row_widget.dart';

/// S23: 採点履歴一覧画面（1曲分）
class ScoreHistoryPage extends StatefulWidget {
  const ScoreHistoryPage({
    super.key,
    required this.songId,
  });

  final String songId;

  @override
  State<ScoreHistoryPage> createState() => _ScoreHistoryPageState();
}

class _ScoreHistoryPageState extends State<ScoreHistoryPage> {
  late final ScoreHistoryController _controller;
  late final Stream<ScoreHistoryData?> _dataStream;

  @override
  void initState() {
    super.initState();
    final repo = context.read<SongRepository>();
    _controller = ScoreHistoryController(repo);

    _dataStream = _controller.watchScoreHistory(widget.songId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(
        context,
        title: '採点履歴',
        type: AppBarType.normal,
      ),

      body: StreamBuilder<ScoreHistoryData?>(
        stream: _dataStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('エラーが発生しました: ${snapshot.error}'),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data;
          if (data == null) {
            return const Center(child: Text('データが見つかりません'));
          }

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.song.title,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                if (data.song.artistName != null && data.song.artistName!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      data.song.artistName!,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 8),

                // 採点履歴一覧
                Expanded(
                  child: Builder(
                    builder: (context) {
                      // 最高得点を計算（採点回数が2回以上の場合）
                      final bestScore = data.scoreRecords.length >= 2
                          ? data.scoreRecords
                              .map((r) => r.score)
                              .reduce((a, b) => a > b ? a : b)
                          : null;

                      return ListView.builder(
                        itemCount: data.scoreRecords.length,
                        itemBuilder: (context, index) {
                          final r = data.scoreRecords[index];
                          return ScoreRowWidget(
                            songId: widget.songId,
                            scoreRecordId: r.id,
                            score: r.score,
                            recordedAt: r.recordedAt,
                            hasMemo: r.memo != null && r.memo!.trim().isNotEmpty,
                            hasKeyChange: r.shiftKey != null && r.shiftKey != 0,
                            isBestScore: bestScore != null && r.score == bestScore,
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
