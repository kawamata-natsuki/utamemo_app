import 'dart:async';

import 'package:utamemo_app/data/repositories/tag/tag_repository.dart';

/// InMemory: カスタムタグ管理
class InMemoryTagRepository implements TagRepository {
  InMemoryTagRepository({
    List<String>? initialTags,
  }) {
    // MVP: 初期タグを2つ用意
    final seed = (initialTags == null || initialTags.isEmpty)
        ? <String>['盛り上がる', 'しっとり']
        : initialTags;

    // 重複削除と正規化
    _tags = _normalizeAndDedupe(seed);

    _controller.add(List.unmodifiable(_tags));
  }

  // Repositoryのインターフェースを実装
  final _controller = StreamController<List<String>>.broadcast();
  late List<String> _tags;

  // 最大タグ数(3個まで)
  static const int maxTagCount = 3;

  // 全タグを監視するストリームを返す
  @override
  Stream<List<String>> watchAll() async* {
    // ✅ 購読開始時に必ず現在のタグ一覧を流す
    yield List.unmodifiable(_tags);
    // ✅ 以降は更新を流す
    yield* _controller.stream;
  }

  // 新しいタグを追加する(すでに存在するタグは追加しない)
  @override
  Future<void> add(String name) async {
    if (_tags.length >= maxTagCount) return;

    final v = _normalize(name);
    if (v.isEmpty) return;
    if (_tags.contains(v)) return;

    _tags = [..._tags, v];
    _emit();
  }

  // タグの名前を変更する(同名に変更は何もしない)
  @override
  Future<void> rename({required String from, required String to}) async {
    final fromN = _normalize(from);
    final toN = _normalize(to);

    if (fromN.isEmpty || toN.isEmpty) return;
    if (!_tags.contains(fromN)) return;

    // 同名に変更は何もしない
    if (fromN == toN) return;

    // 変更先が既に存在するなら何もしない（衝突回避）
    if (_tags.contains(toN)) return;

    _tags = _tags.map((t) => t == fromN ? toN : t).toList(growable: false);
    _emit();
  }

  // タグを削除する(存在しないタグは削除しない)
  @override
  Future<void> delete(String name) async {
    final v = _normalize(name);
    if (v.isEmpty) return;
    if (!_tags.contains(v)) return;

    _tags = _tags.where((t) => t != v).toList(growable: false);
    _emit();
  }

  // タグを更新する
  void _emit() {
    _controller.add(List.unmodifiable(_tags));
  }

  String _normalize(String s) => s.trim();

  // タグを正規化して重複を削除する
  List<String> _normalizeAndDedupe(List<String> input) {
    final seen = <String>{};
    final out = <String>[];
    for (final raw in input) {
      final v = _normalize(raw);
      if (v.isEmpty) continue;
      if (seen.add(v)) out.add(v);
    }
    return out;
  }

  @override
  void dispose() {
    _controller.close();
  }
}
