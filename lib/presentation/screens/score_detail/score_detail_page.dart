import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:utamemo_app/constants/colors.dart';

import 'package:utamemo_app/data/repositories/song/song_repository.dart';
import 'package:utamemo_app/domain/model/score_record.dart';

import 'package:utamemo_app/presentation/screens/score_detail/score_detail_controller.dart';
import 'package:utamemo_app/presentation/screens/score_edit/score_edit_page.dart';
import 'package:utamemo_app/presentation/shared/widgets/tags_wrap.dart';
import 'package:utamemo_app/presentation/screens/score_history/score_history_page.dart';
import 'package:utamemo_app/presentation/shared/widgets/app_bar.dart';

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
            appBar: buildAppBar(
              context,
              title: '採点詳細',
              type: AppBarType.normal,
            ),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        // データが見つからない
        final data = snapshot.data;
        if (data == null) {
          return Scaffold(
            appBar: buildAppBar(
              context,
              title: '採点詳細',
              type: AppBarType.normal,
            ),
            body: const Center(child: Text('データが見つかりません')),
          );
        }

        // データ表示
        return Scaffold(
          appBar: buildAppBar(
            context,
            title: '採点詳細',
            type: AppBarType.normal,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 曲情報
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        data.song.title,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                    PopupMenuButton<String>(
                      icon: const FaIcon(
                        FontAwesomeIcons.ellipsisVertical,
                        size: 18,
                      ),
                      tooltip: 'メニュー',
                      onSelected: (value) async {
                        if (value == 'edit') {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ScoreEditPage(
                                songId: widget.songId,
                                scoreRecordId: widget.scoreRecordId,
                              ),
                            ),
                          );
                        } else if (value == 'delete') {
                          await _showDeleteConfirmDialog(context, data.currentRecord);
                        }
                      },
                      itemBuilder: (context) => const [
                        PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit, size: 20),
                              SizedBox(width: 8),
                              Text('編集'),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete_outline, size: 20),
                              SizedBox(width: 8),
                              Text('削除'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
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
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ScoreHistoryPage(songId: widget.songId),
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

  Future<void> _showDeleteConfirmDialog(
      BuildContext context, ScoreRecord record) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('採点記録を削除'),
        content: Text('${record.score.toStringAsFixed(2)}点の記録を削除してもよろしいですか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('削除'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    if (!context.mounted) return;

    try {
      final repo = context.read<SongRepository>();
      await repo.deleteScoreRecord(
        songId: widget.songId,
        scoreRecordId: record.id,
      );

      if (!context.mounted) return;
      // 削除成功したら前の画面に戻る
      Navigator.of(context).pop();
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('削除に失敗しました: $e')),
      );
    }
  }
}