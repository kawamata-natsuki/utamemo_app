import 'package:utamemo_app/domain/model/song.dart';

abstract class SongRepository {
  Stream<List<Song>> watchAll();
}
