import 'package:flutter/material.dart';

class S11SongDetailPage extends StatelessWidget {
  const S11SongDetailPage({
    super.key,
    required this.songId,
  });

  final String songId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('曲情報'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          'S11 (仮): songId = $songId',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
    );
  }
}
