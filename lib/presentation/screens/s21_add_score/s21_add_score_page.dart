import 'package:flutter/material.dart';

class S21AddScorePage extends StatelessWidget {
  const S21AddScorePage({
    super.key,
    required this.songId,
  });

  final String songId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('採点追加')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          'S21 (仮): songId = $songId',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
    );
  }
}
