import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:utamemo_app/constants/colors.dart';

/// AppBar の表示タイプ
enum AppBarType {
  home,       // S10 曲一覧（ホーム）
  normal,     // 通常画面
  settingsRoot,   // 設定画面（ルート）
  settingsChild,   // 設定画面（子）
}

/// 共通 AppBar
PreferredSizeWidget buildAppBar(
  BuildContext context, {
  required String title,
  required AppBarType type,
}) {
  final bool showHome;
  final bool showSettings;

  switch (type) {
    case AppBarType.home:
      showHome = false;
      showSettings = true;
      break;
    case AppBarType.settingsRoot:
    case AppBarType.settingsChild:
      showHome = false;
      showSettings = false;
      break;
    case AppBarType.normal:
      showHome = true;
      showSettings = true;
  }

  return AppBar(
    title: Text(title),
    centerTitle: true,
    backgroundColor: mainNavy,
    iconTheme: const IconThemeData(color: textWhite),
    titleTextStyle: const TextStyle(
      color: textWhite,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
    actions: [
      if (showHome)
        IconButton(
          tooltip: 'ホーム',
          onPressed: () {
            Navigator.popUntil(context, (route) => route.isFirst);
          },
          icon: const FaIcon(
            FontAwesomeIcons.house,
            size: 20,
            color: textWhite,
          ),
        ),
      if (showSettings)
        IconButton(
          tooltip: '設定',
          onPressed: () {
            Navigator.pushNamed(context, '/settings');
          },
          icon: const FaIcon(
            FontAwesomeIcons.gear,
            size: 20,
            color: textWhite,
          ),
        ),
    ],
  );
}
