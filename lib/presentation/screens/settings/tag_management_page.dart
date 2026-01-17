import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:utamemo_app/presentation/shared/widgets/app_bar.dart';
import 'package:utamemo_app/data/repositories/tag/tag_repository.dart';
import 'package:utamemo_app/data/repositories/song/song_repository.dart';

class TagManagementPage extends StatelessWidget {
  const TagManagementPage({super.key});

  static const int _maxCustomTags = 3;

  // 曲ステータス名（カスタムタグで作らせない）
  static const Set<String> _reservedStatusNames = {
    'お気に入り',
    '歌いたい',
    '練習中',
  };

  @override
  Widget build(BuildContext context) {
    final tagRepo = context.read<TagRepository>();
    final songRepo = context.read<SongRepository>();

    return Scaffold(
      appBar: buildAppBar(
        context,
        title: 'カスタムタグ管理',
        type: AppBarType.settingsChild,
      ),
      body: StreamBuilder<List<String>>(
        stream: tagRepo.watchAll(),
        builder: (context, snapshot) {
          final tags = snapshot.data ?? const <String>[];
          final showEmpty = tags.isEmpty;

          // rows:
          // 0: 追加行（常に表示）
          // 1: 注意カード（常に表示）
          // 2: 空状態メッセージ（タグ0件のときだけ）
          // それ以降: タグ一覧
          final itemCount = 2 + (showEmpty ? 1 : tags.length);

          return ListView.separated(
            itemCount: itemCount,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {

              // 0: タグ追加行
              if (index == 0) {
                return ListTile(
                  leading: const Icon(Icons.add),
                  title: const Text('カスタムタグを追加'),
                  onTap: () async {
                    // タグ上限チェック
                    if (tags.length >= _maxCustomTags) {
                      await _showTagLimitDialog(context, max: _maxCustomTags);
                      if (!context.mounted) return;
                      return;
                    }

                    final name = await _showTagInputDialog(
                      context,
                      title: 'タグを追加',
                    );
                    if (!context.mounted) return;
                    if (name == null) return;

                    final v = name.trim();
                    if (v.isEmpty) return;

                    // 予約語チェック（曲ステータス名の重複を防ぐ）
                    if (_reservedStatusNames.contains(v)) {
                      await _showReservedNameDialog(context, v);
                      if (!context.mounted) return;
                      return;
                    }

                    // すでに存在する場合
                    if (tags.contains(v)) {
                      await _showAlreadyExistsDialog(context, v);
                      if (!context.mounted) return;
                      return;
                    }

                    await tagRepo.add(v);
                  },
                );
              }

              // 1: 注意カード（曲ステータスとカスタムタグの違いを説明）
              if (index == 1) {
                return _NoticeCard(
                  maxTags: _maxCustomTags,
                  reservedNames: _reservedStatusNames,
                );
              }

              // 2: 空状態
              if (showEmpty) {
                return const ListTile(
                  title: Text('カスタムタグがありません'),
                  subtitle: Text('「タグを追加」から作成できます'),
                );
              }

              // タグ一覧（index=2..）
              final tag = tags[index - 2];

              return ListTile(
                title: Text(tag),
                // 右端にポップアップメニューを表示(編集・削除)
                trailing: PopupMenuButton<_TagMenu>(
                  onSelected: (v) async {
                    switch (v) {
                      case _TagMenu.edit:
                        final newName = await _showTagInputDialog(
                          context,
                          title: 'タグ名を編集',
                          initialValue: tag,
                        );
                        if (!context.mounted) return;
                        if (newName == null) return;

                        final v2 = newName.trim();
                        if (v2.isEmpty) return;

                        // 曲ステータス名に変更しようとしている
                        if (_reservedStatusNames.contains(v2)) {
                          await _showReservedNameDialog(context, v2);
                          if (!context.mounted) return;
                          return;
                        }

                        // 同名（変更先と変更前が同じ）なら何もしない
                        if (v2 == tag) return;

                        // 既に存在するタグ名に変更しようとしている
                        if (tags.contains(v2)) {
                          await _showAlreadyExistsDialog(context, v2);
                          if (!context.mounted) return;
                          return;
                        }

                        // 1) タグ一覧をリネーム
                        await tagRepo.rename(from: tag, to: v2);
                        // 2) 全曲の紐付けタグもリネーム（曲ステータスとは別）
                        await songRepo.renameCustomTagInAllSongs(from: tag, to: v2);
                        break;

                      case _TagMenu.delete:
                        final n = await _countSongsUsingTag(context, tag);
                        if (!context.mounted) return;

                        final ok = await _confirmDelete(
                          context,
                          tag: tag,
                          songCount: n,
                        );
                        if (!context.mounted) return;
                        if (ok != true) return;

                        // 1) 全曲からタグ解除
                        await songRepo.removeCustomTagFromAllSongs(tag);
                        // 2) タグ一覧から削除
                        await tagRepo.delete(tag);
                        break;
                    }
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(
                      value: _TagMenu.edit,
                      child: Text('編集'),
                    ),
                    PopupMenuItem(
                      value: _TagMenu.delete,
                      child: Text('削除'),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  /// タグが使用されている曲の数をカウント
  static Future<int> _countSongsUsingTag(BuildContext context, String tag) async {
    final songRepo = context.read<SongRepository>();
    final songs = await songRepo.watchAll().first;
    return songs.where((s) => s.tags.contains(tag)).length;
  }
}

/// 注意カード（曲ステータスとカスタムタグの違いを説明）
class _NoticeCard extends StatelessWidget {
  const _NoticeCard({
    required this.maxTags,
    required this.reservedNames,
  });

  final int maxTags;
  final Set<String> reservedNames;

  @override
  Widget build(BuildContext context) {
    final bodyStyle = Theme.of(context).textTheme.bodySmall?.copyWith(height: 1.25);
    final titleStyle =
        Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold);

    final reservedText = reservedNames.join(' / ');

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.black12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.info_outline, size: 18),
                const SizedBox(width: 8),
                Text('曲ステータスとカスタムタグ', style: titleStyle),
              ],
            ),
            const SizedBox(height: 8),
            Text('曲ごとに設定し、曲の絞り込み検索に使います。', style: bodyStyle),
            const SizedBox(height: 6),
            Text('曲ステータス：曲一覧にアイコン表示', style: bodyStyle),
            Text('カスタムタグ：曲一覧には表示されない', style: bodyStyle),
            const SizedBox(height: 6),
            Text('※「$reservedText」は曲ステータス名のため、カスタムタグでは使えません。', style: bodyStyle),
          ],
        ),
      ),
    );
  }
}

enum _TagMenu { edit, delete }

/// タグ入力ダイアログ
Future<String?> _showTagInputDialog(
  BuildContext context, {
  required String title,
  String? initialValue,
}) async {
  return showDialog<String>(
    context: context,
    builder: (context) {
      final controller = TextEditingController(text: initialValue ?? '');

      return AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'タグ名'),
          onSubmitted: (_) => Navigator.pop(context, controller.text),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('保存'),
          ),
        ],
      );
    },
  );
}

/// タグ削除確認ダイアログ
Future<bool?> _confirmDelete(
  BuildContext context, {
  required String tag,
  required int songCount,
}) {
  return showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('タグを削除しますか？'),
        content: Text('このタグは $songCount 曲 から外れます'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('キャンセル'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('削除'),
          ),
        ],
      );
    },
  );
}

/// タグ上限ダイアログ
Future<void> _showTagLimitDialog(BuildContext context, {required int max}) {
  return showDialog<void>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('タグはこれ以上追加できません'),
        content: Text('カスタムタグは最大$max個まで追加できます。'),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      );
    },
  );
}

/// カスタムタグに使用できない名前ダイアログ
Future<void> _showReservedNameDialog(BuildContext context, String name) {
  return showDialog<void>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('この名前は使えません'),
        content: Text('「$name」は曲ステータスで使用されるため、カスタムタグには追加できません。'),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      );
    },
  );
}

/// すでに存在するタグ名ダイアログ
Future<void> _showAlreadyExistsDialog(BuildContext context, String name) {
  return showDialog<void>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('すでにあります'),
        content: Text('「$name」はすでに登録されています。'),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      );
    },
  );
}
