import 'package:flutter/material.dart';

/// 採点履歴セクションを表示するウィジェット
class ScoreHistorySection extends StatelessWidget {
  const ScoreHistorySection({
    super.key,
    required this.hasRecords,
    required this.onAdd,
  });

  final bool hasRecords;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
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
            if (!hasRecords)
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
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Theme.of(context).dividerColor),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text('（次ステップで採点履歴を一覧表示）'),
              ),
          ],
        ),
      ),
    );
  }
}
