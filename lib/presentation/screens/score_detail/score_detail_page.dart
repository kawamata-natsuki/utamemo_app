import 'package:flutter/material.dart';
import 'package:utamemo_app/constants/colors.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// S22:採点詳細画面
class ScoreDetailPage extends StatelessWidget {
  const ScoreDetailPage({
    super.key,
    required this.songId,
    required this.scoreRecordId,
  });

  final String songId;
  final String scoreRecordId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('採点詳細'),
        centerTitle: true,
        backgroundColor: mainNavy,
        iconTheme: const IconThemeData(color: textWhite),
        titleTextStyle: const TextStyle(
          color: textWhite,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        actions: [
          IconButton(
            tooltip: '設定',
            onPressed: () { /* TODO: 設定画面へ遷移 */ },
            icon: const FaIcon(
              FontAwesomeIcons.gear,
              size: 20,
              color: textWhite,
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('仮表示（最小実装）'),
                const SizedBox(height: 12),
                Text('scoreRecordId: $scoreRecordId'),
                const SizedBox(height: 8),
                Text('songId: $songId'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
