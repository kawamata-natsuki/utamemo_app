// dart async / zones
import 'dart:async';

// flutter core
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// firebase
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

// firebase options
import 'package:utamemo_app/firebase_options.dart';

// repositories
import 'package:utamemo_app/data/repositories/song/in_memory_song_repository.dart';

// screens
import 'package:utamemo_app/presentation/screens/s10_song_list/s10_song_list_page.dart';

// --- Entry point ---
Future<void> main() async {
  runZonedGuarded(() async {
    await bootstrap();
    runApp(const MyApp());
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

// Firebase 初期化だけ
Future<void> initializeFirebase() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
}

// エラーハンドラ設定だけ
void setupErrorHandlers() {
  // Flutter framework エラーを Crashlytics に記録
  FlutterError.onError = (details) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(details);
  };

  // Flutter外（プラットフォーム/非同期）の致命的エラー
  PlatformDispatcher.instance.onError = (error, stack) {
    reportFatalError(error, stack);
    return true;
  };
}

// --- エラー記録を共通化 ---
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

final songRepository = InMemorySongRepository();

// --- App全体のルートウィジェット ---
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SongsListScreen(songRepository: songRepository),
    );
  }
}
