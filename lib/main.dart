import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:utamemo_app/providers/repository_providers.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

import 'package:utamemo_app/firebase_options.dart';

import 'package:utamemo_app/data/repositories/song/song_repository.dart';

import 'package:utamemo_app/presentation/screens/s10_song_list/s10_song_list_page.dart';

// --- Entry point ---
Future<void> main() async {
  runZonedGuarded(() async {
    await bootstrap();
    runApp(
      MultiProvider(
        providers: repositoryProviders,
        child: const MyApp(),
      ),
    );
  }, (error, stack) async {
    await reportFatalError(error, stack);
  });
}

// --- Initialize ---
Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeFirebase();
  setupErrorHandlers();
}

// Firebase 初期化
Future<void> initializeFirebase() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
}

// エラーハンドラ設定
void setupErrorHandlers() {
  // Flutter framework エラーを Crashlytics に記録
  FlutterError.onError = (details) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(details);
  };

  // Flutter外（プラットフォーム/非同期）の致命的エラー
  PlatformDispatcher.instance.onError = (error, stack) {
    // 非同期処理を待たずに実行（fire-and-forget）
    unawaited(reportFatalError(error, stack));
    return true;
  };
}

// --- Crashlytics送信を共通化 ---
Future<void> reportFatalError(Object error, StackTrace stack) async {
  if (Firebase.apps.isNotEmpty) {
    try {
      await FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    } catch (e) {
      // Crashlytics送信失敗時のフォールバック
      debugPrint('[Failed to report to Crashlytics] $error');
      debugPrintStack(stackTrace: stack);
    }
  } else {
    debugPrint('[BOOT ERROR before Firebase init] $error');
    debugPrintStack(stackTrace: stack);
  }
}

// --- App全体のルートウィジェット ---
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Builder(
        builder: (context) {
          final repository = context.watch<SongRepository>();
          return SongsListScreen(songRepository: repository);
        },
      ),
    );
  }
}
