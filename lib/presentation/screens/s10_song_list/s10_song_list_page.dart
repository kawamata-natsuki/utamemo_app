import 'package:flutter/material.dart';
import 'package:utamemo_app/constants/colors.dart';

// repositories
import 'package:utamemo_app/data/repositories/song/song_repository.dart';

// models
import 'package:utamemo_app/domain/model/song.dart';

// widgets
import 'package:utamemo_app/presentation/shared/widgets/song_card.dart';

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

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: SongCard(
                  title: song.title,
                  artistName: song.artistName,
                  tags: song.tags,
                  scoreCount: song.scoreCount,
                  bestScore: song.bestScore,
                  avgScore: song.avgScore,
                  onTap: () {
                    // TODO: S11へ
                    // Navigator.pushNamed(context, '/songs/${song.id}');
                  },
                  onAddScore: () {
                    // TODO: S21へ
                    // Navigator.pushNamed(context, '/songs/${song.id}/score/add');
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
