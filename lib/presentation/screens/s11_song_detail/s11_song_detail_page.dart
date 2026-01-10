import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// providers
import 'package:utamemo_app/data/repositories/song/song_repository.dart';

class S11SongDetailPage extends StatelessWidget {
  const S11SongDetailPage({
    super.key,
    required this.songId,
  });

  final String songId;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_SongDetailVm>(
      future: _load(context, songId),
      builder: (context, snapshot) {
        // ローディング
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // 例外
        if (snapshot.hasError) {
          return _ErrorScaffold(
            title: '曲詳細',
            message: '読み込みに失敗しました',
            details: snapshot.error.toString(),
          );
        }

        final vm = snapshot.data;
        if (vm == null || vm.song == null) {
          return _NotFoundScaffold(
            title: '曲詳細',
            message: '曲が見つかりません',
          );
        }

        final song = vm.song!;
        final scoreCount = song.scoreCount; // int
        final bestScore = song.bestScore; // double?（0件なら null 想定）
        final avgScore = song.avgScore; // double?（2件以上で表示）

        return Scaffold(
          appBar: AppBar(
            title: const Text('曲詳細'),
            actions: [
              // 最小実装：UIだけ置く（次ステップでS12遷移/削除ダイアログ）
              IconButton(
                tooltip: '編集',
                onPressed: null, // TODO: S12へ
                icon: const Icon(Icons.edit),
              ),
              IconButton(
                tooltip: '削除',
                onPressed: null, // TODO: 削除確認ダイアログ
                icon: const Icon(Icons.delete_outline),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // 曲名
              Text(
                song.title,
                style: Theme.of(context).textTheme.headlineSmall,
              ),

              const SizedBox(height: 8),

              // アーティスト（任意）
              if ((song.artistName ?? '').trim().isNotEmpty)
                Text(
                  song.artistName!,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),

              const SizedBox(height: 12),

              // タグ（色付き） ※最小：まずは Chip 表示。TagChip があるなら差し替え
              if (song.tags.isNotEmpty) _TagsWrap(tags: song.tags),

              const SizedBox(height: 16),

              // 採点サマリー（02: 0件なら出さない / 03: best・avg(2件以上)・count）
              if (scoreCount > 0)
                _SummaryCard(
                  bestScore: bestScore,
                  avgScore: (scoreCount >= 2) ? avgScore : null,
                  scoreCount: scoreCount,
                ),

              const SizedBox(height: 20),

              // 採点履歴枠（まずは空でもOK）
              _HistorySection(
                hasRecords: scoreCount > 0, // NOTE: 本当は scoreRecords の件数で判定する
                onAdd: () {
                  // TODO: 既にS21の仮ページがあるので、そこへ遷移する想定
                  // 例：Navigator.pushNamed(context, '/songs/$songId/score/add');
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<_SongDetailVm> _load(BuildContext context, String songId) async {
    final repo = context.read<SongRepository>();
    final song = await repo.getSongById(songId);

    return _SongDetailVm(song: song);
  }
}

class _SongDetailVm {
  const _SongDetailVm({required this.song});
  final dynamic song; // TODO: Song型に置き換え
}

/// タグ表示（最小：Chip）
/// TagChip ウィジェットが既にあるなら、ここで差し替えしてください。
class _TagsWrap extends StatelessWidget {
  const _TagsWrap({required this.tags});

  final List<dynamic> tags; // TODO: List<Tag> or List<String> に置き換え

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: tags.map((t) {
        final label = _tagLabel(t);
        return Chip(
          label: Text(label, style: const TextStyle(fontSize: 12)),
        );
      }).toList(),
    );
  }

  String _tagLabel(dynamic t) {
    // よくあるパターンに寄せて吸収（Tag model / String どちらでも一応動く）
    if (t is String) return t;
    try {
      final name = (t.name as String?)?.trim();
      if (name != null && name.isNotEmpty) return name;
    } catch (_) {}
    return t.toString();
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
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
                _Metric(label: '最高点', value: bestScore?.toStringAsFixed(2) ?? '-'),
                const SizedBox(width: 12),
                _Metric(label: '採点回数', value: 'scoreCount回'),
                if (avgScore != null) ...[
                  const SizedBox(width: 12),
                  _Metric(label: '平均点', value: avgScore!.toStringAsFixed(1)),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

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

class _HistorySection extends StatelessWidget {
  const _HistorySection({
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

            // 最小実装：0件の空状態（03準拠）
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
                    '＋追加 から最初の採点を登録しましょう',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              )
            else
              // 次ステップで ListView 化する前提の「枠」
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

class _NotFoundScaffold extends StatelessWidget {
  const _NotFoundScaffold({
    required this.title,
    required this.message,
  });

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(message, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back),
                label: const Text('戻る'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorScaffold extends StatelessWidget {
  const _ErrorScaffold({
    required this.title,
    required this.message,
    required this.details,
  });

  final String title;
  final String message;
  final String details;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(message, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(details, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back),
            label: const Text('戻る'),
          ),
        ],
      ),
    );
  }
}