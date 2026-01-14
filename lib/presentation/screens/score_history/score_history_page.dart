import 'package:flutter/material.dart';

import 'package:utamemo_app/constants/colors.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:utamemo_app/presentation/screens/score_history/score_history_controller.dart';

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
    _controller = ScoreHistoryController();

    _dataStream = _controller.watchScoreHistory(widget.songId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('採点履歴'),
        centerTitle: true,
        backgroundColor: mainNavy,
        iconTheme: const IconThemeData(color: textWhite),
        titleTextStyle: const TextStyle(
          color: textWhite,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        actions: [
          IconButton(
            tooltip: '設定',
            onPressed: () { /* TODO: 設定画面へ遷移 */ },
            icon: const FaIcon(
              FontAwesomeIcons.gear,
              size: 20,
              color: textWhite,
            ),
          ),
        ],
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

                // TODO: ここに「点数・日付のみ」の一覧（ListView）を実装
                Expanded(
                  child: ListView.builder(
                    itemCount: data.scoreRecords.length,
                    itemBuilder: (context, index) {
                      final r = data.scoreRecords[index];
                      return ListTile(
                        title: Text(r.score.toStringAsFixed(2)),
                        subtitle: Text(_formatDate(r.recordedAt)),
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

  String _formatDate(DateTime dt) {
    final y = dt.year.toString().padLeft(4, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }
}
