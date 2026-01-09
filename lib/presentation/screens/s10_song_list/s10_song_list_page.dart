import 'package:flutter/material.dart';
import 'package:utamemo_app/constants/colors.dart';

class SongsListScreen extends StatelessWidget {
  const SongsListScreen({Key? key}) : super(key: key);

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
        actions: [
          IconButton(onPressed: () {
            // TODO: Implement settings
          }, icon: const Icon(Icons.settings), color: textWhite,),
        ],
      ),
      body: CustomScrollView(

      ),
    );

  }
}
