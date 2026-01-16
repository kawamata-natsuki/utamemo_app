import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:utamemo_app/data/repositories/song/song_repository.dart';
import 'package:utamemo_app/presentation/shared/widgets/app_bar.dart';

class StatsPage extends StatelessWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final songRepo = context.read<SongRepository>();

    return Scaffold(
      appBar: buildAppBar(
        context,
        title: '統計',
        type: AppBarType.settingsChild,
      ),
      body: StreamBuilder(
        stream: songRepo.watchAll(),
        builder: (context, snapshot) {
          final songs = snapshot.data ?? const [];

          final songCount = songs.length;

          final scoreCount = songs.fold<int>(
            0,
           (sum, song) => sum + song.scoreRecords.length,
          );

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _StatRow(label: '登録曲数', value: songCount),
                const SizedBox(height: 12),
                _StatRow(label: '採点記録数', value: scoreCount),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(child: Text(label, style: textTheme.titleMedium)),
          Text(
            value.toString(),
            style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
