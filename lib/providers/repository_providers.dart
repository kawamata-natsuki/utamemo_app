import 'package:provider/provider.dart';

import 'package:utamemo_app/data/repositories/song/song_repository.dart';
import 'package:utamemo_app/data/repositories/song/in_memory_song_repository.dart';

import 'package:utamemo_app/data/repositories/tag/tag_repository.dart';
import 'package:utamemo_app/data/repositories/tag/in_memory_tag_repository.dart';

// App全体で使用する SongRepository を Provider で提供
// 実装は開発・UI確認用の InMemorySongRepository（本番では差し替え予定）
final repositoryProviders = [
  Provider<SongRepository>(
    create: (_) => InMemorySongRepository(),
    dispose: (_, repo) => repo.dispose(),
  ),
  Provider<TagRepository>(
    create: (_) => InMemoryTagRepository(),
    dispose: (_, repo) => repo.dispose(),
  ),
];
