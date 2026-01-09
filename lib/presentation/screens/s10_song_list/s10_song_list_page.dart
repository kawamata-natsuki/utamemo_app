import 'package:flutter/material.dart';
import 'package:utamemo_app/constants/colors.dart';

// repositories
import 'package:utamemo_app/data/repositories/song/song_repository.dart';

// models
import 'package:utamemo_app/domain/model/song.dart';

class SongsListScreen extends StatelessWidget {
  const SongsListScreen({
    super.key,
    required this.songRepository,
  });

  final SongRepository songRepository;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Uta Memo'),
        centerTitle: true,
        backgroundColor: mainNavy,
        titleTextStyle: const TextStyle(
          color: textWhite,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: StreamBuilder<List<Song>>(
        stream: songRepository.watchAll(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('エラーが発生しました: ${snapshot.error}'),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final songs = snapshot.data ?? [];

          if (songs.isEmpty) {
            return const Center(
              child: Text('曲が登録されていません'),
            );
          }

          return ListView.builder(
            itemCount: songs.length,
            itemBuilder: (context, index) {
              final song = songs[index];
              final bestScore = song.bestScore;
              final avgScore = song.avgScore;

              return ListTile(
                title: Text(song.title),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (song.tags.isNotEmpty)
                      Wrap(
                        spacing: 4,
                        children: song.tags.map((tag) => Chip(
                          label: Text(tag, style: const TextStyle(fontSize: 10)),
                          padding: const EdgeInsets.all(2),
                        )).toList(),
                      ),
                    Text([
                      if (song.artistName != null) song.artistName!,
                      '最高点: ${bestScore?.toStringAsFixed(2) ?? '-'}',
                      '回数: ${song.scoreCount}回',
                      if (avgScore != null) '平均点: ${avgScore.toStringAsFixed(2)}',
                    ].join(' ')),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
