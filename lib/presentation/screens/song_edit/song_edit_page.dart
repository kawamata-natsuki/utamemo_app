import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:utamemo_app/data/repositories/song/song_repository.dart';
import 'package:utamemo_app/data/repositories/tag/tag_repository.dart';
import 'package:utamemo_app/domain/model/song.dart';
import 'package:utamemo_app/domain/model/song_status.dart';
import 'package:utamemo_app/presentation/shared/widgets/app_bar.dart';

class SongEditPage extends StatefulWidget {
  const SongEditPage({
    super.key,
    required this.songId,
  });

  final String songId;

  @override
  State<SongEditPage> createState() => _SongEditPageState();
}

class _SongEditPageState extends State<SongEditPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _artistController = TextEditingController();

  bool _initialized = false;

  static const int _statusLimit = 2;
  static const int _tagLimit = 2;

  // 曲ステータス
  final Set<SongStatus> _selectedStatuses = {};
  // カスタムタグ
  final Set<String> _selectedTags = {};

  @override
  void dispose() {
    _titleController.dispose();
    _artistController.dispose();
    super.dispose();
  }

  void _initFromSong(Song song) {
    if (_initialized) return;

    _titleController.text = song.title;
    _artistController.text = song.artistName ?? '';

    _selectedStatuses
      ..clear()
      ..addAll(song.statuses);

    _selectedTags
      ..clear()
      ..addAll(song.tags);

    _initialized = true;
  }

  /// 保存ボタンが押された時の処理
  Future<void> _save(SongRepository repo) async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    try {
      await repo.updateSong(
        songId: widget.songId,
        title: _titleController.text.trim(),
        artistName: _artistController.text.trim().isEmpty
            ? null
            : _artistController.text.trim(),
        statuses: _selectedStatuses.toList(),
        tags: _selectedTags.toList(),
      );

      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('保存に失敗しました: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final songRepo = context.read<SongRepository>();
    final tagRepo = context.read<TagRepository>();

    return Scaffold(
      appBar: buildAppBar(
        context,
        title: '曲を編集',
        type: AppBarType.child,
      ),
      body: StreamBuilder<Song?>(
        stream: songRepo.watchById(widget.songId),
        builder: (context, songSnap) {
          final song = songSnap.data;
          if (song == null) {
            return const Center(child: Text('曲が見つかりません'));
          }

          _initFromSong(song);

          return StreamBuilder<List<String>>(
            stream: tagRepo.watchAll(),
            builder: (context, tagSnap) {
              final tags = tagSnap.data ?? const <String>[];

              return SafeArea(
                child: Form(
                  key: _formKey,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(labelText: '曲名'),
                        validator: (v) {
                          if ((v ?? '').trim().isEmpty) return '曲名は必須です';
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _artistController,
                        decoration: const InputDecoration(labelText: 'アーティスト'),
                      ),
                      const SizedBox(height: 20),

                      Text(
                        '曲ステータス（最大2）',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: SongStatus.values.map((status) {
                          final isSelected = _selectedStatuses.contains(status);
                          final isLimitReached =
                              _selectedStatuses.length >= _statusLimit && !isSelected;

                          return FilterChip(
                            label: Text(status.label),
                            selected: isSelected,
                            onSelected: isLimitReached
                                ? null // ✅ 上限到達でグレーアウト＆タップ不可
                                : (v) {
                                    setState(() {
                                      v ? _selectedStatuses.add(status) : _selectedStatuses.remove(status);
                                    });
                                  },
                            disabledColor: Colors.grey.shade300,
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 24),
                      Text(
                        'カスタムタグ（最大2）',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),

                      if (tags.isEmpty)
                        const Text('タグがありません（設定 > カスタムタグ管理で作成できます）')
                      else
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: tags.map((tag) {
                            final isSelected = _selectedTags.contains(tag);
                            final isLimitReached = _selectedTags.length >= _tagLimit && !isSelected;

                            return FilterChip(
                              label: Text(tag),
                              selected: isSelected,
                              onSelected: isLimitReached
                                  ? null // ✅ 上限到達でグレーアウト＆タップ不可
                                  : (v) {
                                      setState(() {
                                        v ? _selectedTags.add(tag) : _selectedTags.remove(tag);
                                      });
                                    },
                              disabledColor: Colors.grey.shade300,
                            );
                          }).toList(),
                        ),

                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => _save(songRepo),
                          child: const Text('保存'),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
