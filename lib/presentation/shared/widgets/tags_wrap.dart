import 'package:flutter/material.dart';

/// タグをChipで表示するウィジェット
class TagsWrap extends StatelessWidget {
  const TagsWrap({super.key, required this.tags});

  final List<String> tags;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: tags.map((tag) {
        return Chip(
          label: Text(tag, style: const TextStyle(fontSize: 12)),
        );
      }).toList(),
    );
  }
}
