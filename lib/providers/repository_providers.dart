import 'package:provider/provider.dart';

import 'package:utamemo_app/data/repositories/song/song_repository.dart';
import 'package:utamemo_app/data/repositories/song/in_memory_song_repository.dart';

// InMemorySongRepository を使用する
final repositoryProviders = <Provider>[
    Provider<SongRepository>(
        create: (context) => InMemorySongRepository(),
    ),
];