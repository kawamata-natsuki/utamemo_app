import 'package:flutter/material.dart';

/// エラーが発生した場合のScaffoldウィジェット
class ErrorScaffold extends StatelessWidget {
  const ErrorScaffold({
    super.key,
    required this.title,
    required this.message,
    required this.details,
  });

  final String title;
  final String message;
  final String details;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(message, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(details, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back),
            label: const Text('戻る'),
          ),
        ],
      ),
    );
  }
}
