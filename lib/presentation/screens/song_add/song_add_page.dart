import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:utamemo_app/constants/colors.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:utamemo_app/data/repositories/song/song_repository.dart';

import 'package:utamemo_app/presentation/screens/song_detail/song_detail_page.dart';

/// 曲追加画面を表示するウィジェット
class SongAddPage extends StatefulWidget {
  const SongAddPage({super.key});

  @override
  State<SongAddPage> createState() => _SongAddPageState();
}

class _SongAddPageState extends State<SongAddPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _artistController = TextEditingController();

  bool _saving = false;

  @override
  void dispose() {
    _titleController.dispose();
    _artistController.dispose();
    super.dispose();
  }

  Future<void> _onSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    try {
      final songRepo = context.read<SongRepository>();

      final title = _titleController.text.trim();
      final artist = _artistController.text.trim();
      final artistOrNull = artist.isEmpty ? null : artist;

      // SongRepository.addSong を呼び出して songId を取得
      final songId = await songRepo.addSong(
        title: title,
        artistName: artistOrNull,
        tags: [], // 現時点ではタグなし（将来的に実装）
      );

      if (!mounted) return;

      // 取得した songId で S11 へ遷移
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => SongDetailPage(songId: songId),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('曲の追加に失敗しました。もう一度お試しください。'),
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('曲追加'),
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: '曲名*',
                    hintText: '曲名を入力してください',
                  ),
                  keyboardType: TextInputType.text,
                  autofocus: false,
                  textInputAction: TextInputAction.next,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return '曲名を入力してください';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _artistController,
                  decoration: const InputDecoration(
                    labelText: 'アーティスト',
                    hintText: 'アーティストを入力してください',
                  ),
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 20),

                Text(
                  'タグ機能は実装予定',
                  style: Theme.of(context).textTheme.bodySmall,
                ),

                const SizedBox(height: 20),
                Center(
                  child: SizedBox(
                    width: 200,
                    child: FilledButton(
                      onPressed: _saving ? null : _onSave,
                      style: FilledButton.styleFrom(
                        backgroundColor: mainBrightNavy,
                        foregroundColor: textWhite,
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      child: Text(_saving ? '保存中...' : '追加する'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}