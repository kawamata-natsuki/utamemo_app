import 'package:flutter/material.dart';
import 'package:utamemo_app/constants/colors.dart';

// repositories
import 'package:utamemo_app/data/repositories/song/song_repository.dart';

// models
import 'package:utamemo_app/domain/model/song.dart';

// widgets
import 'package:utamemo_app/presentation/shared/widgets/song_card.dart';
import 'package:utamemo_app/presentation/shared/widgets/app_bar.dart';

// screens
import 'package:utamemo_app/presentation/screens/song_detail/song_detail_page.dart';
import 'package:utamemo_app/presentation/screens/song_add/song_add_page.dart';
import 'package:utamemo_app/presentation/screens/score_add/score_add_page.dart';

class SongsListPage extends StatelessWidget {
  const SongsListPage({
    super.key,
    required this.songRepository,
  });

  final SongRepository songRepository;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(
        context,
        title: 'UtaMemo',
        type: AppBarType.home,
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SongDetailPage(songId: song.id),
                      ),
                    );
                  },
                  onAddScore: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ScoreAddPage(songId: song.id),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),

      // 曲追加ボタン
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SongAddPage(),
            ),
          );
        },
        backgroundColor: mainBrightNavy,
        child: const Icon(Icons.add, color: textWhite),
      ),
    );
  }
}
