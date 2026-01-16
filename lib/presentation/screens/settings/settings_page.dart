import 'package:flutter/material.dart';

import 'package:utamemo_app/constants/colors.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:utamemo_app/presentation/shared/widgets/app_bar.dart';

/// S99: 設定画面
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(
        context,
        title: '設定',
        type: AppBarType.settingsRoot,
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const FaIcon(FontAwesomeIcons.tags),
            title: const Text('タグ管理'),
            trailing: const FaIcon(
              FontAwesomeIcons.chevronRight,
              size: 16,
              color: textSub,
            ),
            onTap: () {
              // TODO: タグ管理画面へ遷移（今回は繋がない）
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const FaIcon(FontAwesomeIcons.database),
            title: const Text('データ管理'),
            trailing: const FaIcon(
              FontAwesomeIcons.chevronRight,
              size: 16,
              color: textSub,
            ),
            onTap: () {
              // TODO: データ管理画面へ遷移（今回は繋がない）
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const FaIcon(FontAwesomeIcons.chartSimple),
            title: const Text('統計'),
            trailing: const FaIcon(
              FontAwesomeIcons.chevronRight,
              size: 16,
              color: textSub,
            ),
            onTap: () {
              Navigator.pushNamed(context, '/settings/stats');
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const FaIcon(FontAwesomeIcons.envelope),
            title: const Text('お問い合わせ'),
            trailing: const FaIcon(
              FontAwesomeIcons.chevronRight,
              size: 16,
              color: textSub,
            ),
            onTap: () {
              Navigator.pushNamed(context, '/settings/contact');
            },
          ),

          const SizedBox(height: 24),

          // フッター（最小：固定表示）
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              children: const [
                Text('UtaMemo'),
                SizedBox(height: 4),
                Text('Version 1.0.0'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
