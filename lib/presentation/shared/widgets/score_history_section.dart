import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:utamemo_app/domain/model/score_record.dart';

/// 採点履歴のエリアを表示するウィジェット
class ScoreHistorySection extends StatelessWidget {
  const ScoreHistorySection({
    super.key,
    required this.onAdd,
    required this.scoreRecords,
    this.onViewAll,
    this.onRecordTap,
  });

  final VoidCallback onAdd;
  final List<ScoreRecord> scoreRecords;
  final VoidCallback? onViewAll;
  final void Function(ScoreRecord)? onRecordTap;

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
                // 表示件数を20件に制限
                const displayLimit = 20;
                final displayRecords = scoreRecords.take(displayLimit).toList();
                final hasMore = scoreRecords.length > displayLimit;

                // 王冠を表示すべきレコード(=全履歴中の最高点のレコード)を計算
                final crownedRecord = _findCrownedRecord(scoreRecords);
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ...displayRecords.map((record) {
                      // 表示されるレコードが全履歴中の最高点かつ最新のものかどうかを判定
                      final isCrowned = crownedRecord != null &&
                          record.score == crownedRecord.score &&
                          record.recordedAt == crownedRecord.recordedAt;
                      return _ScoreHistoryItem(
                        record: record,
                        isCrowned: isCrowned,
                        onTap: onRecordTap != null ? () => onRecordTap!(record) : null,
                      );
                    }),
                    // 20件を超える場合は「すべて見る」ボタンを表示
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

  /// 王冠を表示すべきレコードを取得
  ///
  /// 全履歴中の単独最高点かつ採点回数が2回以上の場合、同点が複数ある場合は最新の1件のみを返す
  ScoreRecord? _findCrownedRecord(List<ScoreRecord> records) {
    if (records.length < 2) {
      return null;
    }

    // 全履歴中の最高点を取得
    final bestScore = records.map((r) => r.score).reduce((a, b) => a > b ? a : b);
    final topRecords = records.where((r) => r.score == bestScore).toList();
    // 同点が複数ある場合は最新の1件のみ
    return topRecords.reduce((a, b) =>
        a.recordedAt.isAfter(b.recordedAt) ? a : b);
  }
}

/// 採点履歴の1件を表示するウィジェット
class _ScoreHistoryItem extends StatelessWidget {
  const _ScoreHistoryItem({
    required this.record,
    required this.isCrowned,
    this.onTap,
  });

  final ScoreRecord record;
  final bool isCrowned;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0.5,
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 点数と王冠
              SizedBox(
                width: 100,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      record.score.toStringAsFixed(2),
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (isCrowned) ...[
                      const SizedBox(width: 6),
                      Icon(
                        FontAwesomeIcons.crown,
                        size: 18,
                        color: const Color(0xFFFFD700),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // 日付
              Expanded(
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: Text(
                    _formatDate(record.recordedAt),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 日付をyyyy-MM-dd形式にフォーマット
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
