import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:utamemo_app/data/repositories/song/song_repository.dart';
import 'package:utamemo_app/presentation/screens/s21_add_score/s21_add_score_controller.dart';

enum KaraokeMachine { dam, joysound }

class S21AddScorePage extends StatefulWidget {
  const S21AddScorePage({
    super.key,
    required this.songId,
  });

  final String songId;

  @override
  State<S21AddScorePage> createState() => _S21AddScorePageState();
}

class _S21AddScorePageState extends State<S21AddScorePage> {
  final _formKey = GlobalKey<FormState>();
  final _scoreController = TextEditingController();
  late final S21AddScoreController _controller;

  KaraokeMachine? _machine;
  DateTime _date = DateTime.now();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final repo = context.read<SongRepository>();
    _controller = S21AddScoreController(repo);
  }

  @override
  void dispose() {
    _scoreController.dispose();
    super.dispose();
  }

  /// 日付選択ダイアログを表示
  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _date = picked);
    }
  }

  /// 採点記録を保存
  Future<void> _save() async {
    final ok = _formKey.currentState?.validate() ?? false;
    if (!ok) return;

    if (_machine == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('採点機種を選択してください')),
      );
      return;
    }

    final score = double.parse(_scoreController.text);

    setState(() => _saving = true);
    try {
      await _controller.saveScoreRecord(
        songId: widget.songId,
        score: score,
        recordedAt: _date,
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
                value: _machine,
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
