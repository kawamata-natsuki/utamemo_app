import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:utamemo_app/presentation/screens/score_detail/score_detail_page.dart';

/// 採点行を表示する軽量なリストWidget
///
/// S11（曲詳細）、S22（採点詳細内の最近の採点）、S23（採点履歴一覧）で共通利用
/// Cardを使わず、高さを抑えた2行レイアウト
class ScoreRowWidget extends StatelessWidget {
  const ScoreRowWidget({
    super.key,
    required this.songId,
    required this.scoreRecordId,
    required this.score,
    required this.recordedAt,
    this.hasMemo = false,
    this.hasKeyChange = false,
    this.isBestScore = false,
  });

  final String songId;
  final String scoreRecordId;
  final double score;
  final DateTime recordedAt;
  final bool hasMemo;
  final bool hasKeyChange;
  final bool isBestScore;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ScoreDetailPage(
              songId: songId,
              scoreRecordId: scoreRecordId,
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1行目：点数・王冠・アイコン・chevron
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 点数
                Text(
                  score.toStringAsFixed(2),
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                // 王冠（最高得点の場合）
                if (isBestScore) ...[
                  const SizedBox(width: 6),
                  const FaIcon(
                    FontAwesomeIcons.crown,
                    size: 18,
                    color: Color(0xFFFFD700),
                  ),
                ],
                const SizedBox(width: 12),
                // メモアイコン
                if (hasMemo) ...[
                  FaIcon(
                    FontAwesomeIcons.noteSticky,
                    size: 16,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                ],
                // キー変更アイコン
                if (hasKeyChange) ...[
                  FaIcon(
                    FontAwesomeIcons.music,
                    size: 16,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                ],
                const Spacer(),
                // chevron_right（タップ可能を示す）
                Icon(
                  Icons.chevron_right,
                  color: colorScheme.onSurfaceVariant,
                ),
              ],
            ),
            const SizedBox(height: 4),
            // 2行目：日付
            Text(
              _formatDate(recordedAt),
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 日付をフォーマット（yyyy/MM/dd形式）
  String _formatDate(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y/$m/$d';
  }
}
