import 'package:flutter/material.dart';

/// 採点サマリーを表示するカードウィジェット
class ScoreSummaryCard extends StatelessWidget {
  const ScoreSummaryCard({
    super.key,
    required this.bestScore,
    required this.avgScore,
    required this.scoreCount,
  });

  final double? bestScore;
  final double? avgScore;
  final int scoreCount;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('採点サマリー', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            Row(
              children: [
                _Metric(
                  label: '最高点',
                  value: bestScore?.toStringAsFixed(2) ?? '-',
                ),
                const SizedBox(width: 12),
                _Metric(label: '採点回数', value: '$scoreCount回'),
                if (avgScore != null) ...[
                  const SizedBox(width: 12),
                  _Metric(
                    label: '平均点',
                    value: avgScore!.toStringAsFixed(1),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// メトリック（ラベルと値）を表示するウィジェット
class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(height: 4),
          Text(value, style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }
}
