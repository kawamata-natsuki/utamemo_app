import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:utamemo_app/constants/colors.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:utamemo_app/data/repositories/song/song_repository.dart';
import 'package:utamemo_app/presentation/screens/score_detail/score_detail_controller.dart';
import 'package:utamemo_app/presentation/shared/widgets/tags_wrap.dart';

/// S22:採点詳細画面
class ScoreDetailPage extends StatefulWidget {
  const ScoreDetailPage({
    super.key,
    required this.songId,
    required this.scoreRecordId,
  });

  final String songId;
  final String scoreRecordId;

  @override
  State<ScoreDetailPage> createState() => _ScoreDetailPageState();
}

class _ScoreDetailPageState extends State<ScoreDetailPage> {
  late final ScoreDetailController _controller;
  late final Stream<ScoreDetailData?> _dataStream;

  @override
  void initState() {
    super.initState();
    final repo = context.read<SongRepository>();
    _controller = ScoreDetailController(repo);
    _dataStream = _controller.watchScoreDetail(
      widget.songId,
      widget.scoreRecordId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ScoreDetailData?>(
      stream: _dataStream,
      builder: (context, snapshot) {
        // データ読み込み中
        if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('採点詳細'),
              centerTitle: true,
              backgroundColor: mainNavy,
              iconTheme: const IconThemeData(color: textWhite),
              titleTextStyle: const TextStyle(
                color: textWhite,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        // データが見つからない
        final data = snapshot.data;
        if (data == null) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('採点詳細'),
              centerTitle: true,
              backgroundColor: mainNavy,
              iconTheme: const IconThemeData(color: textWhite),
              titleTextStyle: const TextStyle(
                color: textWhite,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            body: const Center(child: Text('データが見つかりません')),
          );
        }

        // データ表示
        return Scaffold(
          appBar: AppBar(
            title: const Text('採点詳細'),
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
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 曲情報
                Text(
                  data.song.title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                if (data.song.artistName != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    data.song.artistName!,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
                if (data.song.tags.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  TagsWrap(tags: data.song.tags),
                ],

                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 16),

                // 採点情報
                Text(
                  '採点結果',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInfoRow(
                          context,
                          '採点',
                          '${data.currentRecord.score.toStringAsFixed(2)}点',
                          isLarge: true,
                        ),
                        const SizedBox(height: 12),
                        _buildInfoRow(
                          context,
                          '日付',
                          _controller.formatDate(data.currentRecord.recordedAt),
                        ),
                        const SizedBox(height: 8),
                        _buildInfoRow(
                          context,
                          '機種',
                          _controller.getKaraokeMachineName(
                              data.currentRecord.karaokeMachine),
                        ),
                        if (data.currentRecord.getKeyDisplay() != null) ...[
                          const SizedBox(height: 8),
                          _buildInfoRow(
                            context,
                            'キー',
                            data.currentRecord.getKeyDisplay()!,
                          ),
                        ],
                        if (data.currentRecord.memo != null) ...[
                          const SizedBox(height: 12),
                          const Divider(),
                          const SizedBox(height: 8),
                          Text(
                            'メモ',
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  color: Colors.grey[600],
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            data.currentRecord.memo!,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                // 直近の採点履歴
                if (data.recentRecords.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),
                  Text(
                    'この曲の最近の採点記録',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),
                  ...data.recentRecords.map((record) => Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${record.score.toStringAsFixed(2)}点',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                _controller.formatDate(record.recordedAt),
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      )),
                  if (data.hasMoreRecords) ...[
                    const SizedBox(height: 8),
                    Center(
                      child: TextButton(
                        onPressed: () {
                          // TODO: 採点履歴一覧ページ（S??）を作成したらここから遷移する
                          // Navigator.push(
                          //   context,
                          //   MaterialPageRoute(
                          //     builder: (_) => ScoreHistoryPage(songId: widget.songId),
                          //   ),
                          // );
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('採点履歴一覧ページは未実装です'),
                            ),
                          );
                        },
                        child: const Text('── この曲の採点履歴を見る ──'),
                      ),
                    ),
                  ],
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value,
      {bool isLarge = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 60,
          child: Text(
            label,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: isLarge
                ? Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: mainBrightNavy,
                    )
                : Theme.of(context).textTheme.bodyLarge,
          ),
        ),
      ],
    );
  }
}