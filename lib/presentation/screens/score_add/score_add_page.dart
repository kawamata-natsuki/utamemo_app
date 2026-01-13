import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:utamemo_app/data/repositories/song/song_repository.dart';
import 'package:utamemo_app/domain/model/score_record.dart';
import 'package:utamemo_app/presentation/screens/score_add/score_add_controller.dart';

class ScoreAddPage extends StatefulWidget {
  const ScoreAddPage({
    super.key,
    required this.songId,
  });

  final String songId;

  @override
  State<ScoreAddPage> createState() => _ScoreAddPageState();
}

class _ScoreAddPageState extends State<ScoreAddPage> {
  final _formKey = GlobalKey<FormState>();
  final _scoreController = TextEditingController();
  final _memoController = TextEditingController();
  late final ScoreAddController _controller;

  KaraokeMachine? _machine;
  DateTime _date = DateTime.now();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final repo = context.read<SongRepository>();
    _controller = ScoreAddController(repo);
  }

  @override
  void dispose() {
    _scoreController.dispose();
    _memoController.dispose();
    super.dispose();
  }

  /// 日付選択ダイアログを表示
  ///
  /// ユーザーが日付を選択すると、[_date]が更新される。
  /// キャンセルした場合は何も変更されない。
  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime.now().subtract(Duration(days: 365)),
      lastDate: DateTime.now().add(Duration(days: 7)),
    );
    if (picked != null) {
      setState(() => _date = picked);
    }
  }

  /// フォームをバリデーションし、採点記録を保存
  ///
  /// バリデーションが成功すると、採点記録をリポジトリに保存し、
  /// 前の画面に戻る。失敗した場合はエラーメッセージを表示する。
  Future<void> _save() async {
    final ok = _formKey.currentState?.validate() ?? false;
    if (!ok) return;

    final score = double.parse(_scoreController.text);

    // 保存中フラグをセット
    setState(() => _saving = true);
    try {
      final trimmedMemo = _memoController.text.trim();

      await _controller.saveScoreRecord(
        songId: widget.songId,
        score: score,
        recordedAt: _date,
        karaokeMachine: _machine!,
        memo: trimmedMemo.isEmpty ? null : trimmedMemo,
      );

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('保存に失敗しました: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('採点追加')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _scoreController,
                decoration: const InputDecoration(
                  labelText: '点数',
                  hintText: '例: 95.50',
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: _controller.validateScore,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<KaraokeMachine>(
                initialValue: _machine,
                decoration: const InputDecoration(labelText: '採点機種'),
                items: const [
                  DropdownMenuItem(
                    value: KaraokeMachine.dam,
                    child: Text('DAM'),
                  ),
                  DropdownMenuItem(
                    value: KaraokeMachine.joysound,
                    child: Text('JOYSOUND'),
                  ),
                ],
                validator: _controller.validateKaraokeMachine,
                onChanged: (value) => setState(() => _machine = value),
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('日付'),
                subtitle: Text(_controller.formatDate(_date)),
                trailing: const Icon(Icons.calendar_today),
                onTap: _pickDate,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _memoController,
                decoration: const InputDecoration(
                  labelText: 'メモ（任意）',
                  hintText: '最大200文字',
                ),
                maxLength: 200,
                maxLines: 3,
                validator: _controller.validateMemo,
              ),

              const Spacer(),

              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _saving ? null : _save,
                  child: Text(_saving ? '保存中...' : '保存'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
