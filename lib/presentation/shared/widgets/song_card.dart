import 'package:flutter/material.dart';

class SongCard extends StatelessWidget {
  final String title;
  final String? artistName;
  final List<String> tags;
  final int scoreCount;
  final double? bestScore;
  final double? avgScore;
  final VoidCallback onTap;
  final VoidCallback onAddScore;

  const SongCard({
    super.key,
    required this.title,
    this.artistName,
    required this.tags,
    required this.scoreCount,
    required this.bestScore,
    required this.avgScore,
    required this.onTap,
    required this.onAddScore,
  });

  bool get isUnscored => scoreCount == 0;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      clipBehavior: Clip.antiAlias,
		child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1段目：曲名＋未採点バッジ（右上）
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  if (isUnscored) ...[
                    const SizedBox(width: 8),
                    _OutlineBadge(
                      label: '未採点',
                      color: cs.primary,
                    ),
                  ]
                ],
              ),
              // 任意：アーティスト名
              if (artistName != null && artistName!.trim().isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  artistName!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                ),
              ],
              const SizedBox(height: 8),
              // 2段目：タグ＋追加ボタン
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _TagWrapper(tags: tags)),
                  IconButton(
                    tooltip: '採点を追加',
                    onPressed: onAddScore,
										icon: Icon(
										  Icons.mic,
										  color: isUnscored ? cs.primary : cs.onSurfaceVariant,
										),
                  ),
                ],
              ),
              // 3段目：スコア情報(採点履歴がある場合)
              if (!isUnscored) ...[
                const SizedBox(height: 4),
                _ScoreSummary(
                  scoreCount: scoreCount,
                  bestScore: bestScore,
                  avgScore: avgScore,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// 未採点バッジ
class _OutlineBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _OutlineBadge({
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        border: Border.all(color: color, width: 1.5),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}

/// タグラッパー
class _TagWrapper extends StatelessWidget {
  final List<String> tags;

  const _TagWrapper({required this.tags});

  @override
  Widget build(BuildContext context) {
    if (tags.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: tags
          .take(5)
          .map(
            (tag) => Chip(
              label: Text(tag),
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.zero,
              labelStyle: Theme.of(context).textTheme.labelSmall,
            ),
          )
          .toList(),
    );
  }
}

class _ScoreSummary extends StatelessWidget {
  final int scoreCount;
  final double? bestScore;
  final double? avgScore;

  const _ScoreSummary({
    required this.scoreCount,
    required this.bestScore,
    required this.avgScore,
  });

  @override
  Widget build(BuildContext context) {
    final parts = <String>[
      '最高点: ${bestScore?.toStringAsFixed(2) ?? '-'}',
      '回数: $scoreCount回',
      if (avgScore != null) '平均点: ${avgScore!.toStringAsFixed(1)}',
    ];

    return Text(
      parts.join(' / '),
      style: Theme.of(context).textTheme.bodySmall,
    );
  }
}
