import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:utamemo_app/data/repositories/song/song_repository.dart';
import 'package:utamemo_app/domain/model/song.dart';
import 'package:utamemo_app/domain/model/score_record.dart';

import 'package:utamemo_app/presentation/screens/score_edit/score_edit_controller.dart';

import 'package:utamemo_app/presentation/shared/widgets/app_bar.dart';

/// S23:採点記録編集画面を表示するウィジェット
class ScoreEditPage extends StatefulWidget {
  const ScoreEditPage({
    super.key,
    required this.songId,
    required this.scoreRecordId,
  });

  final String songId;
  final String scoreRecordId;

  @override
  State<ScoreEditPage> createState() => _ScoreEditPageState();
}

class _ScoreEditPageState extends State<ScoreEditPage> {
  final _formKey = GlobalKey<FormState>();
  final _scoreController = TextEditingController();
  final _memoController = TextEditingController();
  late final ScoreEditController _controller;

  bool _initialized = false;
  KaraokeMachine? _machine;
  DateTime _date = DateTime.now();
  bool _saving = false;

  bool _originalEnabled = false;
  int _originalKey = 0;

  bool _shiftEnabled = false;
  int _shiftKey = 0;

  static const int _minKey = -24;
  static const int _maxKey = 24;

  @override
  void initState() {
    super.initState();
    final repo = context.read<SongRepository>();
    _controller = ScoreEditController(repo);
  }

  @override
  void dispose() {
    _scoreController.dispose();
    _memoController.dispose();
    super.dispose();
  }

  /// 採点記録の情報を初期化
  void _initFromRecord(ScoreRecord record) {
    if (_initialized) return;

    _scoreController.text = record.score.toString();
    _memoController.text = record.memo ?? '';
    _machine = record.karaokeMachine;
    _date = record.recordedAt;

    if (record.originalKey != null) {
      _originalEnabled = true;
      _originalKey = record.originalKey!;
    }

    if (record.shiftKey != null) {
      _shiftEnabled = true;
      _shiftKey = record.shiftKey!;
    }

    _initialized = true;
  }

  /// 日付を選択
  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 7)),
    );
    if (picked != null) {
      setState(() => _date = picked);
    }
  }

  /// 保存ボタンが押された時の処理
  Future<void> _save() async {
    final ok = _formKey.currentState?.validate() ?? false;
    if (!ok) return;

    final score = double.parse(_scoreController.text);
    final int? originalKey = _originalEnabled ? _originalKey : null;
    final int? shiftKey = _shiftEnabled ? _shiftKey : null;

    setState(() => _saving = true);
    try {
      final trimmedMemo = _memoController.text.trim();

      await _controller.updateScoreRecord(
        songId: widget.songId,
        scoreRecordId: widget.scoreRecordId,
        score: score,
        recordedAt: _date,
        karaokeMachine: _machine!,
        memo: trimmedMemo.isEmpty ? null : trimmedMemo,
        originalKey: originalKey,
        shiftKey: shiftKey,
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

  String _formatKey(int v) => v == 0 ? '0' : (v > 0 ? '+$v' : '$v');

  /// キーをステッパーで表示
  Widget _keyStepper({
    required String label,
    required int value,
    required ValueChanged<int> onChanged,
    String? helperText,
  }) {
    final canDec = value > _minKey;
    final canInc = value < _maxKey;

    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        helperText: helperText,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: canDec ? () => onChanged(value - 1) : null,
            icon: const Icon(Icons.remove),
          ),
          Expanded(
            child: Center(
              child: Text(
                _formatKey(value),
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ),
          IconButton(
            onPressed: canInc ? () => onChanged(value + 1) : null,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }

  /// 未設定状態ありのキーを表示
  Widget _unsetRow({
    required String label,
    required VoidCallback onSet,
    required VoidCallback onClear,
    required bool enabled,
    required Widget stepper,
  }) {
    if (!enabled) {
      return InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          helperText: '未設定',
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
        child: Row(
          children: [
            const Expanded(
              child: Text(
                '未設定',
                style: TextStyle(color: Colors.black54),
              ),
            ),
            TextButton(
              onPressed: onSet,
              child: const Text('設定する'),
            ),
          ],
        ),
      );
    }

    return Stack(
      children: [
        stepper,
        Positioned(
          right: 0,
          top: 0,
          child: IconButton(
            tooltip: 'クリア',
            onPressed: onClear,
            icon: const Icon(Icons.clear),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final songRepo = context.read<SongRepository>();

    return StreamBuilder<Song?>(
      stream: songRepo.watchById(widget.songId),
      builder: (context, snapshot) {
        final song = snapshot.data;
        if (song == null) {
          return Scaffold(
            appBar: buildAppBar(
              context,
              title: '採点を編集',
              type: AppBarType.child,
            ),
            body: const Center(child: Text('曲が見つかりません')),
          );
        }

        ScoreRecord? record;
        try {
          record = song.scoreRecords.firstWhere(
            (r) => r.id == widget.scoreRecordId,
          );
        } catch (e) {
          return Scaffold(
            appBar: buildAppBar(
              context,
              title: '採点を編集',
              type: AppBarType.child,
            ),
            body: const Center(child: Text('採点記録が見つかりません')),
          );
        }

        _initFromRecord(record);

        return Scaffold(
          appBar: buildAppBar(
            context,
            title: '採点を編集',
            type: AppBarType.child,
          ),
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
                  const SizedBox(height: 12),

                  // 原曲キー（未設定状態あり）
                  _unsetRow(
                    label: '原曲キー（任意）',
                    enabled: _originalEnabled,
                    onSet: () => setState(() {
                      _originalEnabled = true;
                      _originalKey = 0;
                    }),
                    onClear: () => setState(() {
                      _originalEnabled = false;
                      _originalKey = 0;
                    }),
                    stepper: _keyStepper(
                      label: '原曲キー（任意）',
                      value: _originalKey,
                      helperText: '±24まで',
                      onChanged: (v) => setState(() => _originalKey = v),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // 変更キー（トグルで表示）
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('キー変更（任意）'),
                    subtitle: const Text('移調する場合のみON'),
                    value: _shiftEnabled,
                    onChanged: (v) => setState(() {
                      _shiftEnabled = v;
                      if (!v) _shiftKey = 0;
                    }),
                  ),

                  if (_shiftEnabled) ...[
                    const SizedBox(height: 8),
                    _keyStepper(
                      label: 'キー変更（任意）',
                      value: _shiftKey,
                      helperText: '±24まで',
                      onChanged: (v) => setState(() => _shiftKey = v),
                    ),
                  ],

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
      },
    );
  }
}
