import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:utamemo_app/data/repositories/song/song_repository.dart';
import 'package:utamemo_app/domain/model/song.dart';

import 'package:utamemo_app/presentation/screens/song_detail/song_detail_controller.dart';
import 'package:utamemo_app/presentation/screens/score_add/score_add_page.dart';
import 'package:utamemo_app/presentation/screens/score_detail/score_detail_page.dart';
import 'package:utamemo_app/presentation/screens/score_history/score_history_page.dart';

import 'package:utamemo_app/presentation/shared/widgets/error_scaffold.dart';
import 'package:utamemo_app/presentation/shared/widgets/not_found_scaffold.dart';
import 'package:utamemo_app/presentation/shared/widgets/score_history_section.dart';
import 'package:utamemo_app/presentation/shared/widgets/score_summary_card.dart';
import 'package:utamemo_app/presentation/shared/widgets/tags_wrap.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:utamemo_app/constants/colors.dart';

class SongDetailPage extends StatefulWidget {
  const SongDetailPage({
    super.key,
    required this.songId,
  });

  final String songId;

  @override
  State<SongDetailPage> createState() => _SongDetailPageState();
}

class _SongDetailPageState extends State<SongDetailPage> {
  late final SongDetailController _controller;
  late final Stream<Song?> _songStream;

  // 初期化
  @override
  void initState() {
    super.initState();
    final repo = context.read<SongRepository>();
    _controller = SongDetailController(repo);
    _songStream = _controller.watchSong(widget.songId);
  }

  // 画面構築
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Song?>(
      stream: _songStream,
      builder: (context, snapshot) {
        // 読み込み中の表示（初期データがない場合）
        if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // エラーが発生した場合の表示
        if (snapshot.hasError) {
          return ErrorScaffold(
            title: '曲詳細',
            message: '読み込みに失敗しました',
            details: snapshot.error.toString(),
          );
        }

        // 曲が見つからない場合の表示
        final song = snapshot.data;
        if (song == null) {
          return NotFoundScaffold(
            title: '曲詳細',
            message: '曲が見つかりません',
          );
        }

        final scoreCount = song.scoreCount;

        return Scaffold(
          appBar: AppBar(
            title: const Text('曲詳細'),
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

          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // 曲名＋メニュー
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      song.title,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                  // メニュー
                  PopupMenuButton<String>(
                    icon: const FaIcon(
                      FontAwesomeIcons.ellipsisVertical,
                      size: 18,
                    ),
                    tooltip: 'メニュー',
                    onSelected: (value) {
                      if (value == 'edit') {
                        // TODO: 曲編集モーダル（今後実装）
                      } else if (value == 'delete') {
                        // TODO: 削除確認ダイアログ表示
                        _showDeleteConfirmDialog(context, song);
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

              // アーティスト名
              const SizedBox(height: 8),
              if (song.artistName?.trim().isNotEmpty ?? false)
                Text(
                  song.artistName!,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              const SizedBox(height: 12),

              // タグ
              if (song.tags.isNotEmpty) TagsWrap(tags: song.tags),
              const SizedBox(height: 16),

              // 採点サマリー
              if (scoreCount > 0)
                ScoreSummaryCard(
                  bestScore: song.bestScore,
                  avgScore: scoreCount >= 2 ? song.avgScore : null,
                  scoreCount: scoreCount,
                ),
              const SizedBox(height: 20),

              // 採点履歴セクション
              ScoreHistorySection(
                scoreRecords: song.scoreRecords,
                // 採点追加画面へ遷移
                onAdd: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ScoreAddPage(songId: widget.songId),
                    ),
                  );
                },
                // 採点履歴一覧画面へ遷移
                onViewAll: song.scoreRecords.length > 20 ? _navigateToScoreHistoryList : null,
                // 採点詳細画面へ遷移
                onRecordTap: (record) {
                  Navigator.push(
                     context,
                     MaterialPageRoute(
                      builder: (context) => ScoreDetailPage(
                        songId: widget.songId,
                        scoreRecordId: record.id,
                      ),
                     ),
                   );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // S23 採点履歴一覧画面への遷移
  void _navigateToScoreHistoryList() {
    Navigator.push(
       context,
       MaterialPageRoute(
         builder: (context) => ScoreHistoryPage(songId: widget.songId),
       ),
     );
  }

  // 削除確認ダイアログを表示
  void _showDeleteConfirmDialog(BuildContext context, Song song) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('曲を削除'),
        content: Text('「${song.title}」を削除してもよろしいですか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () {
              // TODO: 実際の削除処理（Repository経由）
              Navigator.of(context).pop(); // ダイアログを閉じる
              Navigator.of(context).pop(); // 曲詳細画面を閉じて一覧に戻る
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('削除'),
          ),
        ],
      ),
    );
  }
}
