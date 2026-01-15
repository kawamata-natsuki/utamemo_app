import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:utamemo_app/presentation/shared/widgets/app_bar.dart';

/// S99-4: お問い合わせ画面
class ContactPage extends StatelessWidget {
  const ContactPage({super.key});

  static const supportEmail = 'utamemo.support@gmail.com';

  Future<void> _copyEmail(BuildContext context) async {
    await Clipboard.setData(const ClipboardData(text: supportEmail));
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('メールアドレスをコピーしました')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(
        context,
        title: 'お問い合わせ',
        type: AppBarType.settingsChild,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.mail_outline),
                const SizedBox(width: 8),
                Text(
                  supportEmail,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _copyEmail(context),
                icon: const Icon(Icons.copy),
                label: const Text('コピー'),
              ),
            ),

            const SizedBox(height: 16),
            Text(
              '端末 / OS / アプリバージョンを記載いただけると助かります',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
