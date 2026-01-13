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
    _controller = ScoreAddController(repo);
  }

  @override
  void dispose() {
    _scoreController.dispose();
    _memoController.dispose();
    super.dispose();
  }

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

  Future<void> _save() async {
    final ok = _formKey.currentState?.validate() ?? false;
    if (!ok) return;

    final score = double.parse(_scoreController.text);

    // ✅ A案：未設定はnullとして保存
    final int? originalKey = _originalEnabled ? _originalKey : null;
    final int? shiftKey = _shiftEnabled ? _shiftKey : null;

    setState(() => _saving = true);
    try {
      final trimmedMemo = _memoController.text.trim();

      await _controller.saveScoreRecord(
        songId: widget.songId,
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
              const SizedBox(height: 12),

              // 原曲キー（未設定状態あり）
              _unsetRow(
                label: '原曲キー（任意）',
                enabled: _originalEnabled,
                onSet: () => setState(() {
                  _originalEnabled = true;
                  _originalKey = 0; // 初期値
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
                  if (!v) _shiftKey = 0; // OFFでリセット
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
  }
}
