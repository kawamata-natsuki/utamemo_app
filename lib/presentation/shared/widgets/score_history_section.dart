import 'package:flutter/material.dart';
import 'package:utamemo_app/domain/model/score_record.dart';
import 'package:utamemo_app/presentation/shared/widgets/score_row_widget.dart';

/// 採点履歴のエリアを表示するウィジェット
class ScoreHistorySection extends StatelessWidget {
  const ScoreHistorySection({
    super.key,
    required this.songId,
    required this.onAdd,
    required this.scoreRecords,
    this.onViewAll,
  });

  final String songId;
  final VoidCallback onAdd;
  final List<ScoreRecord> scoreRecords;
  final VoidCallback? onViewAll;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('採点履歴', style: Theme.of(context).textTheme.titleMedium),
              const Spacer(),
              TextButton.icon(
                onPressed: onAdd,
                icon: const Icon(Icons.add),
                label: const Text('追加'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (scoreRecords.isEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'まだ採点記録がありません',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 4),
                Text(
                  '＋追加 から採点を登録しましょう',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            )
          else
            Builder(
              builder: (context) {
                // 降順ソート（最新順）
                final sortedRecords = scoreRecords.toList()
                  ..sort((a, b) => b.recordedAt.compareTo(a.recordedAt));
                
                // 直近3件のみ表示
                const displayLimit = 3;
                final displayRecords = sortedRecords.take(displayLimit).toList();
                final hasMore = sortedRecords.length > displayLimit;

                // 最高得点を計算（全採点記録から、採点回数が2回以上の場合）
                final bestScore = scoreRecords.length >= 2
                    ? scoreRecords.map((r) => r.score).reduce((a, b) => a > b ? a : b)
                    : null;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ...displayRecords.map((record) {
                      return ScoreRowWidget(
                        songId: songId,
                        scoreRecordId: record.id,
                        score: record.score,
                        recordedAt: record.recordedAt,
                        hasMemo: record.memo != null && record.memo!.trim().isNotEmpty,
                        hasKeyChange: record.shiftKey != null && record.shiftKey != 0,
                        isBestScore: bestScore != null && record.score == bestScore,
                      );
                    }),
                    // 3件を超える場合は「すべて見る」ボタンを表示
                    if (hasMore && onViewAll != null) ...[
                      const SizedBox(height: 8),
                      Center(
                        child: OutlinedButton.icon(
                          onPressed: onViewAll,
                          icon: const Icon(Icons.list, size: 18),
                          label: Text('すべて見る（全${scoreRecords.length}件）'),
                        ),
                      ),
                    ],
                  ],
                );
              },
            ),
        ],
      ),
    );
  }
}
